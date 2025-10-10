import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade700, Colors.teal.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              accountName: Text(
                user?.displayName ?? 'User',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              accountEmail: Text(
                user?.email ?? 'user@example.com',
                style: TextStyle(color: Colors.white70),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.teal,
                ),
              ),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.home,
              title: 'Home / Dashboard',
              route: '/home',
            ),
            _buildDrawerItem(
              context,
              icon: Icons.favorite,
              title: 'My Favorite Routes',
              route: '/favorites',
            ),
            _buildDrawerItem(
              context,
              icon: Icons.directions_bus,
              title: 'Bus Routes List',
              route: '/bus-routes',
            ),
            _buildDrawerItem(
              context,
              icon: Icons.location_on,
              title: 'Bus Stops',
              route: '/bus-stops',
            ),
            _buildDrawerItem(
              context,
              icon: Icons.notifications,
              title: 'Notifications',
              route: '/notifications',
            ),
            _buildDrawerItem(
              context,
              icon: Icons.feedback,
              title: 'Feedback / Report Issue',
              route: '/feedback',
            ),
            Divider(color: Colors.white30, thickness: 1),
            _buildDrawerItem(
              context,
              icon: Icons.settings,
              title: 'Settings',
              route: '/settings',
            ),
            _buildDrawerItem(
              context,
              icon: Icons.person,
              title: 'Profile',
              route: '/profile',
            ),
            _buildDrawerItem(
              context,
              icon: Icons.help,
              title: 'Help / Support',
              route: '/help',
            ),
            _buildDrawerItem(
              context,
              icon: Icons.info,
              title: 'About App',
              route: '/about',
            ),
            Divider(color: Colors.white30, thickness: 1),
            _buildDrawerItem(
              context,
              icon: Icons.logout,
              title: 'Logout',
              route: null,
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? route,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap ??
          () {
            Navigator.pop(context); // Close drawer
            if (route != null) {
              Navigator.pushNamed(context, route);
            }
          },
      hoverColor: Colors.white.withOpacity(0.1),
      splashColor: Colors.white.withOpacity(0.2),
    );
  }
}
