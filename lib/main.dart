import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'auth_page.dart';
import 'registration_page.dart';
import 'home_screen.dart';
import 'pages/favorites_page.dart';
import 'pages/bus_routes_page.dart';
import 'pages/bus_stops_page.dart';
import 'pages/notifications_page.dart';
import 'pages/feedback_page.dart';
import 'pages/settings_page.dart';
import 'pages/profile_page.dart';
import 'pages/help_page.dart';
import 'pages/about_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Registration',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => AuthPage(),
        '/register': (context) => RegistrationPage(),
        '/home': (context) => HomeScreen(),
        '/favorites': (context) => FavoritesPage(),
        '/bus-routes': (context) => BusRoutesPage(),
        '/bus-stops': (context) => BusStopsPage(),
        '/notifications': (context) => NotificationsPage(),
        '/feedback': (context) => FeedbackPage(),
        '/settings': (context) => SettingsPage(),
        '/profile': (context) => ProfilePage(),
        '/help': (context) => HelpPage(),
        '/about': (context) => AboutPage(),
      },
    );
  }
}
