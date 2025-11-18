import 'package:flutter/material.dart';
// Import your admin pages here
import '../admin_login_page.dart';
import '../admin_registration_page.dart';
// Add other admin page imports as needed

class AdminRouteManager {
  static const String adminLogin = '/admin-login';
  static const String adminRegister = '/admin-register';
  // Add other admin route names as needed

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      adminLogin: (context) => AdminLoginPage(),
      adminRegister: (context) => const AdminRegistrationPage(),
      // Add other admin routes here
    };
  }
}
