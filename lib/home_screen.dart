import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bus Map Dhaka'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(center: LatLng(23.8103, 90.4125), zoom: 13.0),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
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
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.teal),
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
