import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'widgets/navigation_drawer.dart';
import 'models/bus_data.dart';
import 'pages/route_detail_page.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LocationData? _currentLocation;
  bool _loading = true;
  late final MapController _mapController;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getLocation();
  }

  Future<void> _getLocation() async {
    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        setState(() {
          _loading = false;
        });
        return;
      }
    }
    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() {
          _loading = false;
        });
        return;
      }
    }
    final loc = await location.getLocation();
    setState(() {
      _currentLocation = loc;
      _loading = false;
    });
    // Center map to current location
    if (loc.latitude != null && loc.longitude != null) {
      _mapController.move(LatLng(loc.latitude!, loc.longitude!), 13.0);
    }
  }

  void _performSearch(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      _searchResults = BusData.searchAll(query);
    });
  }

  void _onSearchResultTap(dynamic result) {
    if (result is BusRoute) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RouteDetailPage(route: result),
        ),
      );
    } else if (result is BusStop) {
      // Navigate to the stop location on the map
      _mapController.move(LatLng(result.latitude, result.longitude), 15.0);
      setState(() {
        _searchController.clear();
        _isSearching = false;
        _searchResults = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Showing ${result.name} on map')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    LatLng center = _currentLocation != null
        ? LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!)
        : LatLng(23.8103, 90.4125); // Default Dhaka

    return Scaffold(
      appBar: AppBar(
        title: Text('Bus Map Dhaka'),
        backgroundColor: Colors.teal,
      ),
      drawer: AppNavigationDrawer(),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _performSearch,
                    decoration: InputDecoration(
                      hintText: 'Search bus routes or stops...',
                      prefixIcon: Icon(Icons.search, color: Colors.teal),
                      suffixIcon: _isSearching
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _isSearching = false;
                                  _searchResults = [];
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),

                // Search Results or Map + Routes List
                Expanded(
                  child: _isSearching
                      ? _searchResults.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off,
                                      size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'No results found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final result = _searchResults[index];
                                if (result is BusRoute) {
                                  return Card(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.teal,
                                        child: Icon(Icons.directions_bus,
                                            color: Colors.white),
                                      ),
                                      title: Text(result.name),
                                      subtitle: Text(
                                        '${result.startPoint} → ${result.endPoint}',
                                      ),
                                      trailing: Icon(Icons.arrow_forward_ios,
                                          size: 16),
                                      onTap: () => _onSearchResultTap(result),
                                    ),
                                  );
                                } else if (result is BusStop) {
                                  return Card(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.orange,
                                        child: Icon(Icons.location_on,
                                            color: Colors.white),
                                      ),
                                      title: Text(result.name),
                                      subtitle: Text(
                                        '${result.routes.length} route(s) available',
                                      ),
                                      trailing:
                                          Icon(Icons.map, size: 16),
                                      onTap: () => _onSearchResultTap(result),
                                    ),
                                  );
                                }
                                return SizedBox();
                              },
                            )
                      : Column(
                          children: [
                            // Map Section
                            Expanded(
                              child: Stack(
                                children: [
                                  FlutterMap(
                                    mapController: _mapController,
                                    options: MapOptions(center: center, zoom: 13.0),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                        subdomains: ['a', 'b', 'c'],
                                      ),
                                      if (_currentLocation != null)
                                        MarkerLayer(
                                          markers: [
                                            Marker(
                                              point: LatLng(
                                                _currentLocation!.latitude!,
                                                _currentLocation!.longitude!,
                                              ),
                                              width: 40,
                                              height: 40,
                                              builder: (ctx) => Icon(
                                                Icons.my_location,
                                                color: Colors.red,
                                                size: 40,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  Positioned(
                                    bottom: 16,
                                    right: 16,
                                    child: Material(
                                      color: Colors.white.withOpacity(0.8),
                                      shape: CircleBorder(),
                                      elevation: 4,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.my_location,
                                          color: Colors.teal,
                                          size: 28,
                                        ),
                                        onPressed: () {
                                          _getLocation();
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Bus Routes List
                            Expanded(
                              child: ListView.builder(
                                itemCount: 10,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: Icon(Icons.directions_bus, color: Colors.teal),
                                    title: Text('Bus Route ${index + 1}'),
                                    subtitle: Text('Details about route ${index + 1}'),
                                    trailing: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.teal,
                                    ),
                                    onTap: () {
                                      // Navigate to route details
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add action for floating button
        },
        backgroundColor: Colors.teal,
        child: Icon(Icons.add),
      ),
    );
  }
}
