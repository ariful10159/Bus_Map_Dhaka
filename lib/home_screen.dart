import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LocationData? _currentLocation;
  bool _loading = true;
  late final MapController _mapController;

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
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
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
                              _getLocation(); // Re-center map to current location
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
