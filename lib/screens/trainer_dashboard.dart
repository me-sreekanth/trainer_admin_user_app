import 'package:flutter/material.dart';

class TrainerDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trainer Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/trainerProfile');
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome to Trainer Dashboard'),
      ),
    );
  }
}
