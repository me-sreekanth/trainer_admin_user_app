import 'package:flutter/material.dart';

class TrainerDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trainer Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/trainerLogin');
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome to the Trainer Dashboard!'),
      ),
    );
  }
}
