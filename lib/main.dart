import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'login_page.dart';
import 'dashboard_page.dart';
import 'initial_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Login App',
        routes: {
          '/': (context) => InitialScreen(),
          '/login': (context) => LoginPage(),
          '/dashboard': (context) => DashboardPage(),
        },
      ),
    );
  }
}
