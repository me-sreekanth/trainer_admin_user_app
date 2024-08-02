import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'screens/admin_login.dart';
import 'screens/admin_signup.dart';
import 'screens/admin_dashboard.dart';
import 'screens/trainer_login.dart';
import 'screens/trainer_dashboard.dart';
import 'screens/customer_login.dart'; // Ensure you have this screen
import 'screens/customer_dashboard.dart'; // Ensure you have this screen
import 'screens/landing_page.dart'; // Import the LandingPage

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        title: 'Flutter App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) =>
              LandingPage(), // Use LandingPage as the initial route
          '/adminLogin': (context) => AdminLoginPage(),
          '/adminSignup': (context) => AdminSignupPage(),
          '/adminDashboard': (context) => AdminDashboardPage(),
          '/trainerLogin': (context) => TrainerLoginPage(),
          '/trainerDashboard': (context) => TrainerDashboardPage(),
          '/customerLogin': (context) => CustomerLoginPage(),
          '/customerDashboard': (context) => CustomerDashboardPage(),
        },
      ),
    );
  }
}
