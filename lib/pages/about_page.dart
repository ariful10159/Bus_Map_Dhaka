import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About App'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.directions_bus, size: 110, color: Colors.teal),
            const SizedBox(height: 16),
            const Text(
              'Bus Map Dhaka',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Version ${_appVersion}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              '''Bus Map Dhaka is your trusted companion for navigating the city’s
public transport network. We aggregate live and curated route data so
you can plan commutes, discover alternative buses, and stay informed
about timing or fare changes.''',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Key Highlights',
              bullets: const [
                'Interactive map with your live location and nearby stops.',
                'Search routes by start and destination to view fares, schedules, and arrival estimates.',
                'Admins keep the data fresh through an integrated dashboard.',
                'Profile and settings let you personalize language, notifications, and account details.',
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Our Mission',
              body:
                  'Empower everyday commuters with reliable, real-time transit information so traveling across Dhaka becomes safer, faster, and more predictable.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Contact & Support',
              body:
                  'Need help or want to suggest a feature? Reach us at support@busmapdhaka.com or follow our updates on facebook.com/busmapdhaka.',
            ),
            const SizedBox(height: 32),
            const Text(
              '© 2025 Bus Map Dhaka. All rights reserved.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static const String _appVersion = '1.0.0';

  Widget _buildSection({
    required String title,
    String? body,
    List<String>? bullets,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 8),
          if (body != null)
            Text(body, style: const TextStyle(fontSize: 15, height: 1.4)),
          if (bullets != null)
            ...bullets.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 15, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
