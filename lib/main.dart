import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'sign_up_screen.dart';
import 'home_screen.dart';

void main() {
  runApp(const BusMapApp());
}

class BusMapApp extends StatelessWidget {
  const BusMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BusMap',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}