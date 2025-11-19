import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:http/http.dart' as http;

import 'widgets/navigation_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.enableLocation = true});

  final bool enableLocation;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  loc.LocationData? _currentLocation;
  bool _loading = true;
  final MapController _mapController = MapController();

  final TextEditingController _startPointController = TextEditingController();
  final TextEditingController _endPointController = TextEditingController();

  List<Map<String, dynamic>> _buses = [];
  List<LatLng> _routePoints = [];
  LatLng? _startMarker;
  LatLng? _endMarker;
  bool _isSearching = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    if (widget.enableLocation) {
      _getLocation();
    } else {
      _loading = false;
    }
  }

  Future<void> _getLocation() async {
    loc.Location location = loc.Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        setState(() => _loading = false);
        return;
      }
    }
    loc.PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        setState(() => _loading = false);
        return;
      }
    }
    final locationData = await location.getLocation();
    setState(() {
      _currentLocation = locationData;
      _loading = false;
    });
    if (locationData.latitude != null && locationData.longitude != null) {
      final currentPoint = LatLng(
        locationData.latitude!,
        locationData.longitude!,
      );
      Future.microtask(() {
        if (mounted) {
          _mapController.move(currentPoint, 13);
        }
      });
    }
  }

  Future<void> _searchRoute() async {
    final startPoint = _startPointController.text.trim();
    final endPoint = _endPointController.text.trim();

    if (startPoint.isEmpty || endPoint.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ অনুগ্রহ করে Start এবং End উভয় point লিখুন'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = '';
      _buses = [];
      _routePoints = [];
    });

    try {
      final startLocation = await _geocodeAddress(startPoint);
      final endLocation = await _geocodeAddress(endPoint);

      if (startLocation == null || endLocation == null) {
        setState(() {
          _errorMessage =
              'স্থান খুঁজে পাওয়া যায়নি। অনুগ্রহ করে সঠিক নাম লিখুন।';
          _isSearching = false;
        });
        return;
      }

      final defaultRoute = [
        startLocation,
        LatLng(
          (startLocation.latitude + endLocation.latitude) / 2,
          (startLocation.longitude + endLocation.longitude) / 2,
        ),
        endLocation,
      ];

      final querySnapshot = await FirebaseFirestore.instance
          .collection('bus_routes')
          .get();

      debugPrint('Firestore fetched ${querySnapshot.docs.length} documents');

      final searchStart = startPoint.toLowerCase().trim();
      final searchEnd = endPoint.toLowerCase().trim();

      final matchingDocs = querySnapshot.docs.where((doc) {
        final data = doc.data();
        final docStartPoint = (data['startPoint'] ?? '')
            .toString()
            .toLowerCase()
            .trim();
        final docEndPoint = (data['endPoint'] ?? '')
            .toString()
            .toLowerCase()
            .trim();
        debugPrint(
          'Comparing: "$docStartPoint" vs "$docEndPoint" with "$searchStart" vs "$searchEnd"',
        );
        return docStartPoint == searchStart && docEndPoint == searchEnd;
      }).toList();
      
      debugPrint('Found ${matchingDocs.length} matching bus routes');

      if (matchingDocs.isEmpty) {
        setState(() {
          _errorMessage =
              'এই রুটে কোনো বাস খুঁজে পাওয়া যায়নি। (No bus found for this route)';
          _buses = [];
          _startMarker = startLocation;
          _endMarker = endLocation;
          _routePoints = defaultRoute;
        });
        _setMarkersAndZoom(defaultRoute);
      } else {
        final fetchedBuses = <Map<String, dynamic>>[];
        final computedRoute = <LatLng>[];

        for (final doc in matchingDocs) {
          final data = doc.data();
          fetchedBuses.add({
            'busName': data['busName'] ?? 'Unknown Bus',
            'cost': data['cost']?.toString() ?? '0',
            'schedule': data['schedule'] ?? 'N/A',
            'nextArrival': _calculateNextArrival(data['schedule']),
          });

          if (data['routePath'] is List) {
            final pathData = data['routePath'] as List;
            final parsedPoints = pathData
                .map((point) {
                  if (point is Map) {
                    final latValue = point['lat'] ?? point['latitude'];
                    final lngValue =
                        point['lng'] ?? point['lon'] ?? point['longitude'];
                    final lat = latValue is num
                        ? latValue.toDouble()
                        : double.tryParse(latValue?.toString() ?? '');
                    final lng = lngValue is num
                        ? lngValue.toDouble()
                        : double.tryParse(lngValue?.toString() ?? '');
                    if (lat != null && lng != null) {
                      return LatLng(lat, lng);
                    }
                  }
                  return null;
                })
                .whereType<LatLng>()
                .toList();

            if (parsedPoints.isNotEmpty) {
              computedRoute
                ..clear()
                ..addAll(parsedPoints);
            }
          }
        }

        setState(() {
          _buses = fetchedBuses;
          _startMarker = startLocation;
          _endMarker = endLocation;
          _routePoints = computedRoute.isNotEmpty
              ? computedRoute
              : defaultRoute;
          _errorMessage = '';
        });
        _setMarkersAndZoom(_routePoints);
      }
    } catch (e) {
      debugPrint('Route search error: $e');
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _buses = [];
        _routePoints = [];
        _startMarker = null;
        _endMarker = null;
        _isSearching = false;
      });
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<LatLng?> _geocodeAddress(String place) async {
    final query = '$place, Dhaka, Bangladesh';

    try {
      if (kIsWeb) {
        final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1',
        );
        final response = await http.get(
          uri,
          headers: {
            'User-Agent': 'bus_map_dhaka',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          if (decoded is List && decoded.isNotEmpty) {
            final lat = double.tryParse(decoded.first['lat']?.toString() ?? '');
            final lon = double.tryParse(
              decoded.first['lon']?.toString() ??
                  decoded.first['lng']?.toString() ??
                  '',
            );
            if (lat != null && lon != null) {
              return LatLng(lat, lon);
            }
          }
        }
        return null;
      } else {
        final locations = await geo.locationFromAddress(query);
        if (locations.isNotEmpty) {
          return LatLng(locations.first.latitude, locations.first.longitude);
        }
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }

    return null;
  }

  void _loadPlaceholderData() {
    _buses = [
      {
        'busName': 'Dhaka Express',
        'cost': '30',
        'schedule': '08:00, 10:00, 12:00, 14:00',
        'nextArrival': '15 mins',
      },
      {
        'busName': 'City Rider',
        'cost': '25',
        'schedule': '07:30, 09:30, 11:30, 13:30',
        'nextArrival': '28 mins',
      },
      {
        'busName': 'Metro Line',
        'cost': '35',
        'schedule': '08:15, 10:15, 12:15, 14:15',
        'nextArrival': '42 mins',
      },
    ];

    _routePoints = [
      LatLng(23.8103, 90.4125),
      LatLng(23.8000, 90.4100),
      LatLng(23.7900, 90.4050),
      LatLng(23.7800, 90.4000),
      LatLng(23.7700, 90.3950),
      LatLng(23.7600, 90.3900),
    ];

    _startMarker = _routePoints.first;
    _endMarker = _routePoints.last;
    _setMarkersAndZoom(_routePoints);
  }

  void _setMarkersAndZoom([List<LatLng>? points]) {
    final effectivePoints = points ?? _routePoints;
    if (effectivePoints.isEmpty) return;

    final avgLat =
        effectivePoints
            .map((p) => p.latitude)
            .reduce((value, element) => value + element) /
        effectivePoints.length;
    final avgLng =
        effectivePoints
            .map((p) => p.longitude)
            .reduce((value, element) => value + element) /
        effectivePoints.length;

    final zoomLevel = effectivePoints.length > 1 ? 12.5 : 14.0;
    _mapController.move(LatLng(avgLat, avgLng), zoomLevel);
  }

  String _calculateNextArrival(String? schedule) {
    if (schedule == null || schedule.isEmpty) return 'N/A';

    final now = TimeOfDay.now();
    final times = schedule.split(',').map((t) => t.trim()).toList();

    for (var time in times) {
      try {
        final parts = time.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        final scheduleTime = TimeOfDay(hour: hour, minute: minute);
        final nowMinutes = now.hour * 60 + now.minute;
        final scheduleMinutes = scheduleTime.hour * 60 + scheduleTime.minute;

        if (scheduleMinutes > nowMinutes) {
          final diff = scheduleMinutes - nowMinutes;
          return '$diff mins';
        }
      } catch (e) {
        continue;
      }
    }

    return 'Next day';
  }

  @override
  Widget build(BuildContext context) {
    LatLng center = _currentLocation != null
        ? LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!)
        : LatLng(23.8103, 90.4125);

    return Scaffold(
      appBar: AppBar(
        title: Text('Bus Map Dhaka'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      drawer: AppNavigationDrawer(),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchSection(),
                _buildMapSection(center),
                if (_buses.isNotEmpty) _buildBusListSection(),
              ],
            ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.teal, Colors.teal.shade700],
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _startPointController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Start Point (e.g., Gulshan)',
              hintStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.location_on, color: Colors.white),
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: _endPointController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'End Point (e.g., Motijheel)',
              hintStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.flag, color: Colors.white),
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSearching ? null : _searchRoute,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: _isSearching
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.teal,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Search Routes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                _errorMessage,
                style: TextStyle(color: Colors.amber, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapSection(LatLng center) {
    final markers = <Marker>[];

    if (_currentLocation?.latitude != null &&
        _currentLocation?.longitude != null) {
      markers.add(
        Marker(
          point: LatLng(
            _currentLocation!.latitude!,
            _currentLocation!.longitude!,
          ),
          width: 40,
          height: 40,
          builder: (context) =>
              Icon(Icons.my_location, color: Colors.redAccent, size: 26),
        ),
      );
    }

    if (_startMarker != null) {
      markers.add(
        Marker(
          point: _startMarker!,
          width: 42,
          height: 42,
          builder: (context) => Icon(Icons.flag, color: Colors.green, size: 30),
        ),
      );
    }

    if (_endMarker != null) {
      markers.add(
        Marker(
          point: _endMarker!,
          width: 42,
          height: 42,
          builder: (context) =>
              Icon(Icons.flag, color: Colors.orange, size: 30),
        ),
      );
    }

    final polylines = <Polyline>[];
    if (_routePoints.length > 1) {
      polylines.add(
        Polyline(
          points: _routePoints,
          strokeWidth: 4,
          color: Colors.blueAccent,
        ),
      );
    }

    return Expanded(
      flex: 3,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: center,
          zoom: 12.5,
          maxZoom: 18,
          minZoom: 3,
          onMapReady: () {
            if (_routePoints.isNotEmpty) {
              Future.microtask(() => _setMarkersAndZoom(_routePoints));
            }
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.busmapdhaka.app',
          ),
          if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
          if (markers.isNotEmpty) MarkerLayer(markers: markers),
        ],
      ),
    );
  }

  Widget _buildBusListSection() {
    return Expanded(
      flex: 2,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.directions_bus, color: Colors.teal),
                  SizedBox(width: 8),
                  Text(
                    'Available Buses (${_buses.length})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade900,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 8),
                itemCount: _buses.length,
                itemBuilder: (context, index) {
                  final bus = _buses[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.teal.shade100,
                        child: Icon(
                          Icons.directions_bus,
                          color: Colors.teal.shade700,
                          size: 28,
                        ),
                      ),
                      title: Text(
                        bus['busName'] ?? 'Unknown',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Next: ${bus['nextArrival']}',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Schedule: ${bus['schedule'] ?? 'N/A'}',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '৳${bus['cost']}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _startPointController.dispose();
    _endPointController.dispose();
    super.dispose();
  }
}
