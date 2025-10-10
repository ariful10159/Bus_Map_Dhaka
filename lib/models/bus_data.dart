class BusRoute {
  final String id;
  final String name;
  final String startPoint;
  final String endPoint;
  final String fare;
  final List<String> stops;

  BusRoute({
    required this.id,
    required this.name,
    required this.startPoint,
    required this.endPoint,
    required this.fare,
    required this.stops,
  });
}

class BusStop {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final List<String> routes; // Route IDs that pass through this stop

  BusStop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.routes,
  });
}

// Placeholder data - can be replaced with Firebase data later
class BusData {
  static List<BusRoute> routes = [
    BusRoute(
      id: 'R1',
      name: 'Route 1: Gulshan - Motijheel',
      startPoint: 'Gulshan',
      endPoint: 'Motijheel',
      fare: '30 TK',
      stops: [
        'Gulshan 1',
        'Gulshan 2',
        'Mohakhali',
        'Farmgate',
        'Shahbag',
        'Paltan',
        'Motijheel',
      ],
    ),
    BusRoute(
      id: 'R2',
      name: 'Route 2: Mirpur - Sadarghat',
      startPoint: 'Mirpur',
      endPoint: 'Sadarghat',
      fare: '35 TK',
      stops: [
        'Mirpur 10',
        'Mirpur 2',
        'Shyamoli',
        'Asad Gate',
        'New Market',
        'Gulistan',
        'Sadarghat',
      ],
    ),
    BusRoute(
      id: 'R3',
      name: 'Route 3: Uttara - Jatrabari',
      startPoint: 'Uttara',
      endPoint: 'Jatrabari',
      fare: '40 TK',
      stops: [
        'Uttara Sector 7',
        'Airport',
        'Mohakhali',
        'Tejgaon',
        'Kamalapur',
        'Jatrabari',
      ],
    ),
    BusRoute(
      id: 'R4',
      name: 'Route 4: Dhanmondi - Gabtoli',
      startPoint: 'Dhanmondi',
      endPoint: 'Gabtoli',
      fare: '25 TK',
      stops: [
        'Dhanmondi 27',
        'Science Lab',
        'Kalabagan',
        'Shyamoli',
        'Technical',
        'Gabtoli',
      ],
    ),
    BusRoute(
      id: 'R5',
      name: 'Route 5: Banani - Old Dhaka',
      startPoint: 'Banani',
      endPoint: 'Old Dhaka',
      fare: '38 TK',
      stops: [
        'Banani',
        'Mohakhali',
        'Tejgaon',
        'Farmgate',
        'Shahbag',
        'Paltan',
        'Sadarghat',
      ],
    ),
  ];

  static List<BusStop> stops = [
    BusStop(
      id: 'S1',
      name: 'Gulshan 1',
      latitude: 23.7808,
      longitude: 90.4172,
      routes: ['R1'],
    ),
    BusStop(
      id: 'S2',
      name: 'Gulshan 2',
      latitude: 23.7925,
      longitude: 90.4078,
      routes: ['R1'],
    ),
    BusStop(
      id: 'S3',
      name: 'Mohakhali',
      latitude: 23.7808,
      longitude: 90.4031,
      routes: ['R1', 'R3', 'R5'],
    ),
    BusStop(
      id: 'S4',
      name: 'Farmgate',
      latitude: 23.7557,
      longitude: 90.3891,
      routes: ['R1', 'R5'],
    ),
    BusStop(
      id: 'S5',
      name: 'Shahbag',
      latitude: 23.7389,
      longitude: 90.3952,
      routes: ['R1', 'R5'],
    ),
    BusStop(
      id: 'S6',
      name: 'Motijheel',
      latitude: 23.7330,
      longitude: 90.4172,
      routes: ['R1'],
    ),
    BusStop(
      id: 'S7',
      name: 'Mirpur 10',
      latitude: 23.8069,
      longitude: 90.3681,
      routes: ['R2'],
    ),
    BusStop(
      id: 'S8',
      name: 'Shyamoli',
      latitude: 23.7644,
      longitude: 90.3686,
      routes: ['R2', 'R4'],
    ),
    BusStop(
      id: 'S9',
      name: 'Sadarghat',
      latitude: 23.7104,
      longitude: 90.4072,
      routes: ['R2', 'R5'],
    ),
    BusStop(
      id: 'S10',
      name: 'Uttara Sector 7',
      latitude: 23.8759,
      longitude: 90.3795,
      routes: ['R3'],
    ),
    BusStop(
      id: 'S11',
      name: 'Dhanmondi 27',
      latitude: 23.7461,
      longitude: 90.3742,
      routes: ['R4'],
    ),
    BusStop(
      id: 'S12',
      name: 'Gabtoli',
      latitude: 23.7794,
      longitude: 90.3497,
      routes: ['R4'],
    ),
    BusStop(
      id: 'S13',
      name: 'Banani',
      latitude: 23.7937,
      longitude: 90.4066,
      routes: ['R5'],
    ),
  ];

  static List<dynamic> searchAll(String query) {
    if (query.isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    List<dynamic> results = [];

    // Search in routes
    for (var route in routes) {
      if (route.name.toLowerCase().contains(lowerQuery) ||
          route.startPoint.toLowerCase().contains(lowerQuery) ||
          route.endPoint.toLowerCase().contains(lowerQuery)) {
        results.add(route);
      }
    }

    // Search in stops
    for (var stop in stops) {
      if (stop.name.toLowerCase().contains(lowerQuery)) {
        results.add(stop);
      }
    }

    return results;
  }
}
