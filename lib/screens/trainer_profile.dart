import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TrainerProfilePage extends StatefulWidget {
  @override
  _TrainerProfilePageState createState() => _TrainerProfilePageState();
}

class _TrainerProfilePageState extends State<TrainerProfilePage> {
  Map<String, dynamic>? trainerData;
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    fetchTrainerProfile();
  }

  Future<void> fetchTrainerProfile() async {
    final String apiUrl =
        'http://localhost:3000/api/trainer/66acdfea99eff105a5318a83/profile';

    try {
      // Retrieve the access token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      // Debugging to check if the token is fetched
      print('Access Token: $accessToken');

      if (accessToken == null) {
        setState(() {
          isLoading = false;
          isError = true;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization':
              '$accessToken', // Ensure Bearer prefix is used if needed
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          trainerData = json.decode(response.body);
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        // Unauthorized, redirect to login
        Navigator.pushReplacementNamed(context, '/trainerLogin');
      } else {
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile & Settings'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : isError
              ? Center(child: Text('Error loading profile'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Trainer Info Card
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.lightBlue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                trainerData?['signedProfilePic'] ?? '',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.person, size: 80),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trainerData?['name'] ?? 'N/A',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    trainerData?['phoneNumber'] ?? 'N/A',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Credits per hour: ${trainerData?['creditsPerHour'] ?? 'N/A'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                // Navigate to edit profile screen or implement edit functionality
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32),
                      // More Options
                      ListTile(
                        leading: Icon(Icons.attach_money),
                        title: Text('Earnings'),
                        onTap: () {
                          // Implement navigation or functionality
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.payment),
                        title: Text('Payment method information'),
                        onTap: () {
                          // Implement navigation or functionality
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.access_time),
                        title: Text('Availability'),
                        onTap: () {
                          // Implement navigation or functionality
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Log out'),
                        onTap: () {
                          // Implement logout functionality
                          // Example:
                          // Provider.of<AuthProvider>(context, listen: false).logout();
                          // Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}
