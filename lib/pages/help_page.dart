import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildIntroCard(),
          const SizedBox(height: 20),
          _buildFaqSection(),
          const SizedBox(height: 20),
          _buildGuideSection(),
          const SizedBox(height: 20),
          _buildContactSection(),
        ],
      ),
    );
  }

  Widget _buildIntroCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Need assistance?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 10),
            Text(
              'Browse the FAQs, read the quick guide, or contact our support team. We are here to make your Dhaka commute easier.',
              style: TextStyle(fontSize: 15, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqSection() {
    final faqs = [
      {
        'question': 'How do I search for a bus route?',
        'answer':
            'Enter your start and destination points on the Home screen and tap Search. You will see available buses, fares, and schedules.',
      },
      {
        'question': 'Can I trust the timings shown?',
        'answer':
            'We combine official schedules with admin updates. Arrival estimates may vary during traffic spikes, so plan a few minutes early.',
      },
      {
        'question': 'How do I report incorrect data?',
        'answer':
            'Open Settings → Feedback or contact support so we can correct the route information quickly.',
      },
    ];

    return _buildSectionContainer(
      title: 'FAQs',
      child: Column(
        children: faqs
            .map(
              (faq) => ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                leading: const Icon(Icons.question_answer, color: Colors.teal),
                title: Text(
                  faq['question']!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12, right: 12),
                      child: Text(
                        faq['answer']!,
                        style: const TextStyle(
                          height: 1.4,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildGuideSection() {
    final steps = [
      'Allow location access so the map can center on your current position.',
      'Use the search fields on the Home screen to find buses between two points.',
      'Tap a bus result to view costs, schedules, and arrival estimates.',
      'Save preferred routes or stops for quick access from the Favorites tab.',
      'Use the profile section to update personal info or change language settings.',
    ];

    return _buildSectionContainer(
      title: 'Quick User Guide',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: steps
            .map(
              (step) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color: Colors.teal,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(step, style: const TextStyle(height: 1.4)),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildContactSection() {
    const contactDetails = [
      {'icon': Icons.person, 'label': 'Name', 'value': 'Ariful Islam Masum'},
      {'icon': Icons.phone, 'label': 'Phone', 'value': '01823139965'},
      {
        'icon': Icons.email_outlined,
        'label': 'Email',
        'value': 'ug2102032@gmail.com',
      },
      {
        'icon': Icons.chat_bubble_outline,
        'label': 'WhatsApp / Telegram',
        'value': '01823139965',
      },
      {
        'icon': Icons.location_on,
        'label': 'Address',
        'value': 'Bijoy 24 Hall, Patuakhali Science and Technology University',
      },
    ];

    return _buildSectionContainer(
      title: 'Contact & Support',
      child: Column(
        children: contactDetails
            .map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(item['icon'] as IconData?, color: Colors.teal),
                title: Text(
                  item['label'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(item['value'] as String),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
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
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
