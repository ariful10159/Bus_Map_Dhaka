import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help / Support'),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ListTile(
            leading: Icon(Icons.question_answer, color: Colors.teal),
            title: Text('FAQs'),
            subtitle: Text('Frequently Asked Questions'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to FAQs
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.contact_support, color: Colors.teal),
            title: Text('Contact Support'),
            subtitle: Text('Get in touch with us'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to contact support
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.book, color: Colors.teal),
            title: Text('User Guide'),
            subtitle: Text('Learn how to use the app'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to user guide
            },
          ),
        ],
      ),
    );
  }
}
