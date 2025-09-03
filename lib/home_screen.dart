import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BusMap Home'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              // Open settings/profile
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search bus stops or routes',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.directions_bus),
                  title: Text('Route 1: Mirpur to Motijheel'),
                  subtitle: Text('Scheduled: 7:00, 8:00, 9:00'),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.directions_bus),
                  title: Text('Route 2: Uttara to Gulistan'),
                  subtitle: Text('Scheduled: 7:30, 8:30, 9:30'),
                  onTap: () {},
                ),
                // Add more routes here
              ],
            ),
          ),
          // Placeholder for interactive map
          Container(
            height: 200,
            color: Colors.grey[200],
            child: Center(
              child: Text('Interactive Map Placeholder'),
            ),
          ),
        ],
      ),
    );
  }
}
