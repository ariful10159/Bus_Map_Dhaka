import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> locations = [
    'Mirpur 1, Dhaka',
    'Farmgate, Dhaka',
    'Motijheel, Dhaka',
  ];
  String? start;
  String? destination;

  LatLng? getLatLng(String? location) {
    switch (location) {
      case 'Mirpur 1, Dhaka':
        return LatLng(23.8041, 90.3667);
      case 'Farmgate, Dhaka':
        return LatLng(23.8103, 90.4125);
      case 'Motijheel, Dhaka':
        return LatLng(23.7276, 90.4106);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BusMap Home'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Start',
                      border: OutlineInputBorder(),
                    ),
                    value: start,
                    items: locations
                        .map(
                          (loc) =>
                              DropdownMenuItem(value: loc, child: Text(loc)),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        start = val;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Destination',
                      border: OutlineInputBorder(),
                    ),
                    value: destination,
                    items: locations
                        .map(
                          (loc) =>
                              DropdownMenuItem(value: loc, child: Text(loc)),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        destination = val;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          if (start != null && destination != null && start != destination)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Present Address: $start',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Destination: $destination',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Bus Name: Mirpur Express',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ],
              ),
            ),
          if (start != null && destination != null && start != destination)
            Container(
              height: 200,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: getLatLng(start!) ?? LatLng(23.8041, 90.3667),
                  initialZoom: 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.bus_map_dhaka',
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [
                          getLatLng(start!) ?? LatLng(23.8041, 90.3667),
                          getLatLng(destination!) ?? LatLng(23.8103, 90.4125),
                        ],
                        color: Colors.blue,
                        strokeWidth: 4.0,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: getLatLng(start!) ?? LatLng(23.8041, 90.3667),
                        child: Column(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.green,
                              size: 40,
                            ),
                            Text('Start'),
                          ],
                        ),
                      ),
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point:
                            getLatLng(destination!) ?? LatLng(23.8103, 90.4125),
                        child: Column(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                            Text('End'),
                          ],
                        ),
                      ),
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: getLatLng(start!) ?? LatLng(23.8041, 90.3667),
                        child: Column(
                          children: [
                            Icon(
                              Icons.directions_bus,
                              color: Colors.blue,
                              size: 40,
                            ),
                            Text('Mirpur Express'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
