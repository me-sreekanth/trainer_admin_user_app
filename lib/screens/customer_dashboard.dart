import 'package:flutter/material.dart';

class CustomerDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/customerLogin');
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome to the Customer Dashboard!'),
      ),
    );
  }
}
