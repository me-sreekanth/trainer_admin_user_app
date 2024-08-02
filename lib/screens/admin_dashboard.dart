import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';

class AdminDashboardPage extends StatefulWidget {
  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late Future<List<dynamic>> _adminUsersFuture;

  @override
  void initState() {
    super.initState();
    _adminUsersFuture = Provider.of<AuthProvider>(context, listen: false)
        .fetchAdminUsers(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushReplacementNamed('/adminLogin');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _adminUsersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No admin users found'));
          } else {
            final adminUsers = snapshot.data!;
            return ListView.builder(
              itemCount: adminUsers.length,
              itemBuilder: (context, index) {
                final admin = adminUsers[index];
                return ListTile(
                  title: Text('Admin ID: ${admin['_id']}'),
                  subtitle: Text('Version: ${admin['__v']}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
