import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              // Navigate to settings or user profile
              print('Menu icon pressed');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for bus stops or routes',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                // Handle search logic
                print('Search query: $value');
              },
            ),
          ),
          // Interactive Map
          Expanded(
            child: FlutterMap(
              options: MapOptions(center: LatLng(23.8103, 90.4125), zoom: 13.0),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(23.8103, 90.4125),
                      builder: (ctx) => Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // List of Bus Routes
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Replace with actual bus route count
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.directions_bus, color: Colors.blue),
                  title: Text('Bus Route ${index + 1}'),
                  subtitle: Text('Scheduled Time: 8:00 AM'),
                  onTap: () {
                    // Handle bus route selection
                    print('Bus Route ${index + 1} selected');
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add quick action logic here
          print('Floating action button pressed');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
