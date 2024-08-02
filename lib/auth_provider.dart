import 'dart:convert';
import 'dart:html';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  static const String apiUrl = 'http://localhost:3000';
  String? _accessToken;
  bool _isNavigating = false; // Flag to prevent multiple navigations

  String? get accessToken => _accessToken;

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token);
  }

  Future<void> refreshAccessToken(BuildContext context) async {
    try {
      final request = HttpRequest();
      request.open('POST', '$apiUrl/api/auth/token');
      request.withCredentials = true;
      request.setRequestHeader('Content-Type', 'application/json');
      request.send();

      await request.onLoadEnd.first;
      if (request.status == 200) {
        final data = jsonDecode(request.responseText ?? '');
        _accessToken = data['accessToken'];
        await _saveToken(_accessToken!);
        notifyListeners();
      } else if (request.status == 401) {
        // Unauthorized, redirect to login
        if (!_isNavigating) {
          _isNavigating = true;
          Navigator.of(context).pushReplacementNamed('/trainerLogin');
        }
      } else {
        throw Exception('Failed to refresh token: ${request.responseText}');
      }
    } catch (e) {
      print('Error refreshing token: $e');
    }
  }

  void logout() {
    _accessToken = null;
    _isNavigating = false;
    notifyListeners();
  }

  Future<bool> signupAdmin(String username, String password) async {
    try {
      final request = HttpRequest();
      request.open('POST', '$apiUrl/api/admin/signup');
      request.setRequestHeader('Content-Type', 'application/json');
      request.send(jsonEncode({
        'username': username,
        'password': password,
      }));

      await request.onLoadEnd.first;

      // Debugging print statements to ensure correct response is received
      print('Response Status: ${request.status}');
      print('Response Text: ${request.responseText}');

      // Check for 201 status code for successful signup
      if (request.status == 201 &&
          (request.responseText?.trim() ?? "") ==
              "Admin registered successfully") {
        return true;
      } else {
        print('Failed to register admin: ${request.responseText}');
        return false;
      }
    } catch (e) {
      print('Error registering admin: $e');
      return false;
    }
  }

  Future<bool> loginAdmin(String username, String password) async {
    try {
      final request = HttpRequest();
      request.open('POST', '$apiUrl/api/admin/login');
      request.setRequestHeader('Content-Type', 'application/json');
      request.withCredentials = true; // Include credentials if cookies are used
      request.send(jsonEncode({
        'username': username,
        'password': password,
      }));

      await request.onLoadEnd.first;

      if (request.status == 200) {
        final data = jsonDecode(request.responseText ?? '');
        _accessToken = data['accessToken'];
        await _saveToken(_accessToken!);
        notifyListeners(); // Notify listeners of the change
        return true;
      } else {
        print('Failed to login admin: ${request.responseText}');
        return false;
      }
    } catch (e) {
      print('Error logging in admin: $e');
      return false;
    }
  }

  Future<bool> loginTrainer(String username, String password) async {
    try {
      final request = HttpRequest();
      request.open('POST', '$apiUrl/api/trainer/login');
      request.setRequestHeader('Content-Type', 'application/json');
      request.withCredentials = true; // Include credentials if cookies are used
      request.send(jsonEncode({
        'username': username,
        'password': password,
      }));

      await request.onLoadEnd.first;

      if (request.status == 200) {
        final data = jsonDecode(request.responseText ?? '');
        _accessToken = data['accessToken'];
        await _saveToken(_accessToken!);
        notifyListeners(); // Notify listeners of the change
        return true;
      } else {
        print('Failed to login trainer: ${request.responseText}');
        return false;
      }
    } catch (e) {
      print('Error logging in trainer: $e');
      return false;
    }
  }

  Future<List<dynamic>> fetchAdminUsers(BuildContext context) async {
    if (_accessToken == null) {
      throw Exception('No access token found');
    }

    // Decode token to check expiry (for debugging purposes)
    final decodedToken = _decodeToken(_accessToken!);
    final expiryDate =
        DateTime.fromMillisecondsSinceEpoch(decodedToken['exp'] * 1000);
    print('Token expiry date: $expiryDate');

    if (expiryDate.isBefore(DateTime.now())) {
      print('Token has expired');
      // Implement token refresh logic here if applicable
      Navigator.of(context).pushReplacementNamed('/adminLogin');
      return [];
    }

    try {
      final request = HttpRequest();
      request.open('GET', '$apiUrl/api/admin/getAllAdmins');
      request.withCredentials = true; // Handle cookies if necessary
      request.setRequestHeader('Content-Type', 'application/json');
      request.setRequestHeader('Authorization', '$_accessToken');
      request.send();

      await request.onLoadEnd.first;
      if (request.status == 200) {
        return jsonDecode(request.responseText ?? '');
      } else if (request.status == 403) {
        print('Forbidden: Check authorization or token');
        Navigator.of(context).pushReplacementNamed('/adminLogin');
        throw Exception('Forbidden access');
      } else {
        print('Failed to load admin users: ${request.responseText}');
        throw Exception('Failed to load admin users: ${request.status}');
      }
    } catch (e) {
      print('Error fetching admin users: $e');
      throw Exception('Error fetching admin users');
    }
  }

  Map<String, dynamic> _decodeToken(String token) {
    final parts = token.split('.');
    final payload =
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    return jsonDecode(payload);
  }

  Future<bool> sendOtp(String mobileNumber) async {
    try {
      final request = HttpRequest();
      request.open('POST', '$apiUrl/api/otp/send');
      request.setRequestHeader('Content-Type', 'application/json');
      request.send(jsonEncode({
        'countryCode': '91', // Ensure the country code is a string
        'mobileNumber': mobileNumber,
      }));

      await request.onLoadEnd.first;

      if (request.status == 200) {
        print('OTP sent successfully');
        return true;
      } else {
        print('Failed to send OTP: ${request.responseText}');
        return false;
      }
    } catch (e) {
      print('Error sending OTP: $e');
      return false;
    }
  }

  Future<bool> validateOtp(String mobileNumber, String otpCode) async {
    try {
      final request = HttpRequest();
      request.open('POST', '$apiUrl/api/otp/validate');
      request.withCredentials = true; // Include credentials if cookies are used
      request.setRequestHeader('Content-Type', 'application/json');
      request.send(jsonEncode({
        'countryCode': '91', // Ensure the country code is a string
        'mobileNumber': mobileNumber,
        'otpCode': otpCode,
      }));

      await request.onLoadEnd.first;

      if (request.status == 200) {
        final data = jsonDecode(request.responseText ?? '');
        _accessToken = data['accessToken'];
        await _saveToken(_accessToken!);
        notifyListeners();
        return true;
      } else {
        print('Failed to validate OTP: ${request.responseText}');
        return false;
      }
    } catch (e) {
      print('Error validating OTP: $e');
      return false;
    }
  }
}
