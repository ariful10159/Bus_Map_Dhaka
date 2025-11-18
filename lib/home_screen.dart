import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/navigation_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.enableLocation = true});

  final bool enableLocation;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LocationData? _currentLocation;
  bool _loading = true;
  GoogleMapController? _mapController;

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
    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        setState(() => _loading = false);
        return;
      }
    }
    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() => _loading = false);
        return;
      }
    }
    final loc = await location.getLocation();
    setState(() {
      _currentLocation = loc;
      _loading = false;
    });
    if (loc.latitude != null &&
        loc.longitude != null &&
        _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(LatLng(loc.latitude!, loc.longitude!)),
      );
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
      final querySnapshot = await FirebaseFirestore.instance
          .collection('bus_routes')
          .where('startPoint', isEqualTo: startPoint)
          .where('endPoint', isEqualTo: endPoint)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _errorMessage = 'কোন route পাওয়া যায়নি। Sample data দেখানো হচ্ছে।';
          _loadPlaceholderData();
        });
      } else {
        List<Map<String, dynamic>> fetchedBuses = [];

        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          fetchedBuses.add({
            'busName': data['busName'] ?? 'Unknown Bus',
            'cost': data['cost']?.toString() ?? '0',
            'schedule': data['schedule'] ?? 'N/A',
            'nextArrival': _calculateNextArrival(data['schedule']),
          });

          if (data.containsKey('routePath') && data['routePath'] is List) {
            List<dynamic> pathData = data['routePath'];
            _routePoints = pathData.map((point) {
              return LatLng(point['lat'] ?? 23.8103, point['lng'] ?? 90.4125);
            }).toList();
          }
        }

        setState(() {
          _buses = fetchedBuses;
          _setMarkersAndZoom();
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e\nSample data দেখানো হচ্ছে।';
        _loadPlaceholderData();
      });
    } finally {
      setState(() => _isSearching = false);
    }
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

    _setMarkersAndZoom();
  }

  void _setMarkersAndZoom() {
    if (_routePoints.isNotEmpty && _mapController != null) {
      _startMarker = _routePoints.first;
      _endMarker = _routePoints.last;

      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(
            (_startMarker!.latitude + _endMarker!.latitude) / 2,
            (_startMarker!.longitude + _endMarker!.longitude) / 2,
          ),
        ),
      );
    }
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
    Set<Marker> markers = {};

    if (_currentLocation != null) {
      markers.add(
        Marker(
          markerId: MarkerId('currentLocation'),
          position: LatLng(
            _currentLocation!.latitude!,
            _currentLocation!.longitude!,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: 'You'),
        ),
      );
    }

    if (_startMarker != null) {
      markers.add(
        Marker(
          markerId: MarkerId('start'),
          position: _startMarker!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(title: 'START'),
        ),
      );
    }

    if (_endMarker != null) {
      markers.add(
        Marker(
          markerId: MarkerId('end'),
          position: _endMarker!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(title: 'END'),
        ),
      );
    }

    Set<Polyline> polylines = {};
    if (_routePoints.length > 1) {
      polylines.add(
        Polyline(
          polylineId: PolylineId('route'),
          points: _routePoints,
          color: Colors.blue,
          width: 5,
        ),
      );
    }

    return Expanded(
      flex: 3,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(target: center, zoom: 13.0),
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        markers: markers,
        polylines: polylines,
        onMapCreated: (controller) {
          _mapController = controller;
        },
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
