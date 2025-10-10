import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings'), backgroundColor: Colors.teal),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ListTile(
            leading: Icon(Icons.language, color: Colors.teal),
            title: Text('Language Selection'),
            subtitle: Text('English'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to language settings
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications_active, color: Colors.teal),
            title: Text('Notification Preferences'),
            subtitle: Text('Manage your notifications'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to notification settings
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.account_circle, color: Colors.teal),
            title: Text('Account Settings'),
            subtitle: Text('Manage your account'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to account settings
            },
          ),
        ],
      ),
    );
  }
}
