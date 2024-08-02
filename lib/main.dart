import 'package:flutter/material.dart';
import 'screens/landing_page.dart';
import 'screens/admin_login.dart';
import 'screens/admin_signup.dart';
import 'screens/admin_dashboard.dart';
import 'screens/trainer_login.dart';
import 'screens/trainer_dashboard.dart';
import 'screens/customer_login.dart';
import 'screens/customer_dashboard.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      initialRoute: '/',
      routes: {
        '/': (context) => LandingPage(),
        '/adminLogin': (context) => AdminLoginPage(),
        '/adminSignup': (context) => AdminSignupPage(),
        '/adminDashboard': (context) => AdminDashboardPage(),
        '/trainerLogin': (context) => TrainerLoginPage(),
        '/trainerDashboard': (context) => TrainerDashboardPage(),
        '/customerLogin': (context) => CustomerLoginPage(),
        '/customerDashboard': (context) => CustomerDashboardPage(),
      },
    );
  }
}
