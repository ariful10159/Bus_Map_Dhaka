import 'package:flutter/material.dart';

class RouteInfoScreen extends StatelessWidget {
  final String routeName;
  final String routeNumber;
  final String startPoint;
  final String endPoint;
  final List<Map<String, String>> busStops; // {name, time}

  const RouteInfoScreen({
    super.key,
    required this.routeName,
    required this.routeNumber,
    required this.startPoint,
    required this.endPoint,
    required this.busStops,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$routeName ($routeNumber)'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.map),
            onPressed: () {
              // Show route on map
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Route Map'),
                  content: Container(
                    height: 200,
                    child: Center(child: Text('Map Placeholder')), // Replace with real map widget
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Start: $startPoint', style: TextStyle(fontSize: 18)),
            Text('End: $endPoint', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Text('Bus Stops:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: busStops.length,
                itemBuilder: (context, index) {
                  final stop = busStops[index];
                  return ListTile(
                    leading: Icon(Icons.location_on),
                    title: Text(stop['name'] ?? ''),
                    subtitle: Text('Scheduled: ${stop['time'] ?? ''}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
