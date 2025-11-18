import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/admin_bus_routes_page.dart';
import '../pages/admin_feedback_page.dart';

class AdminNavigationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.transparent),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.admin_panel_settings,
                  size: 50,
                  color: Colors.deepPurple,
                ),
              ),
              accountName: Text(
                'Admin Panel',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              accountEmail: Text(
                user?.email ?? 'No email',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ),

            // Dashboard Menu Item
            _buildDrawerItem(
              context: context,
              icon: Icons.dashboard,
              title: 'Dashboard',
              subtitle: 'Admin home',
              onTap: () {
                Navigator.pop(context); // Close drawer
                // Already on home page, just close drawer
              },
            ),

            Divider(color: Colors.white30, thickness: 1),

            // Manage Routes Menu Item
            _buildDrawerItem(
              context: context,
              icon: Icons.list_alt,
              title: 'Manage Routes',
              subtitle: 'View, edit, delete routes',
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminBusRoutesPage()),
                );
              },
            ),

            _buildDrawerItem(
              context: context,
              icon: Icons.feedback_outlined,
              title: 'User Feedback',
              subtitle: 'Review user submissions',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminFeedbackPage(),
                  ),
                );
              },
            ),

            // Add Route Menu Item
            _buildDrawerItem(
              context: context,
              icon: Icons.add_circle_outline,
              title: 'Add New Route',
              subtitle: 'Create bus route',
              onTap: () {
                Navigator.pop(context); // Close drawer and stay on home
              },
            ),

            Divider(color: Colors.white30, thickness: 1),

            // Settings Menu Item (placeholder)
            _buildDrawerItem(
              context: context,
              icon: Icons.settings,
              title: 'Settings',
              subtitle: 'App preferences',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Settings coming soon...')),
                );
              },
            ),

            // Analytics Menu Item (placeholder)
            _buildDrawerItem(
              context: context,
              icon: Icons.analytics,
              title: 'Analytics',
              subtitle: 'View statistics',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Analytics coming soon...')),
                );
              },
            ),

            Divider(color: Colors.white30, thickness: 1),

            // Logout Menu Item
            _buildDrawerItem(
              context: context,
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out',
              iconColor: Colors.red.shade300,
              onTap: () async {
                Navigator.pop(context); // Close drawer
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),

            SizedBox(height: 20),

            // Footer
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Divider(color: Colors.white30),
                  SizedBox(height: 8),
                  Text(
                    'Bus Map Dhaka',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Admin Portal v1.0',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? Colors.white, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white70, fontSize: 12),
      ),
      onTap: onTap,
      hoverColor: Colors.white.withOpacity(0.1),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }
}
