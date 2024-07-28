import 'dart:convert';
import 'dart:html';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  static const String apiUrl = 'http://localhost:3000';
  String? _accessToken;
  bool _isNavigating = false; // Add a flag to prevent multiple navigations

  String? get accessToken => _accessToken;

  Future<void> sendOtp(String mobileNumber) async {
    try {
      final request = HttpRequest();
      request.open('POST', '$apiUrl/api/otp/send');
      request.setRequestHeader('Content-Type', 'application/json');
      request.withCredentials = true;
      request.send(jsonEncode({
        'countryCode': 91,
        'mobileNumber': mobileNumber,
      }));

      await request.onLoadEnd.first;
      if (request.status == 200) {
        print('OTP sent successfully');
      } else {
        print('Failed to send OTP: ${request.responseText}');
      }
    } catch (e) {
      print('Error sending OTP: $e');
    }
  }

  Future<bool> validateOtp(String mobileNumber, String otpCode) async {
    try {
      final request = HttpRequest();
      request.open('POST', '$apiUrl/api/otp/validate');
      request.withCredentials = true;
      request.setRequestHeader('Content-Type', 'application/json');
      request.send(jsonEncode({
        'countryCode': 91,
        'mobileNumber': mobileNumber,
        'otpCode': otpCode,
      }));

      await request.onLoadEnd.first;
      if (request.status == 200) {
        final data = jsonDecode(request.responseText ?? '');
        _accessToken = data['accessToken'];
        await _saveToken(_accessToken!);
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
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } else {
        throw Exception('Failed to refresh token: ${request.responseText}');
      }
    } catch (e) {
      print('Error refreshing token: $e');
    }
  }

  Future<void> checkToken(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token != null) {
      final decodedToken = _decodeToken(token);
      final expiryDate =
          DateTime.fromMillisecondsSinceEpoch(decodedToken['exp'] * 1000);

      if (expiryDate.isBefore(DateTime.now())) {
        await refreshAccessToken(context);
      } else {
        _accessToken = token;
        // Token is valid, redirect to dashboard
        if (!_isNavigating) {
          _isNavigating = true;
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      }
    } else {
      // No token found, redirect to login
      if (!_isNavigating) {
        _isNavigating = true;
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  Map<String, dynamic> _decodeToken(String token) {
    final parts = token.split('.');
    final payload =
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    return jsonDecode(payload);
  }

  Future<List<dynamic>> fetchUsers(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      throw Exception('No access token found');
    }

    final decodedToken = _decodeToken(token);
    final expiryDate =
        DateTime.fromMillisecondsSinceEpoch(decodedToken['exp'] * 1000);

    if (expiryDate.isBefore(DateTime.now())) {
      await refreshAccessToken(context);
    }

    try {
      final request = HttpRequest();
      request.open('GET', '$apiUrl/api/users');
      request.withCredentials = true;
      request.setRequestHeader('Content-Type', 'application/json');
      request.setRequestHeader('authorization', _accessToken ?? token);
      request.send();

      await request.onLoadEnd.first;
      if (request.status == 200) {
        return jsonDecode(request.responseText ?? '');
      } else if (request.status == 401) {
        // Unauthorized, redirect to login
        if (!_isNavigating) {
          _isNavigating = true;
          Navigator.of(context).pushReplacementNamed('/login');
        }
        throw Exception('Unauthorized');
      } else {
        print('Failed to load users: ${request.responseText}');
        throw Exception('Failed to load users: ${request.status}');
      }
    } catch (e) {
      print('Error fetching users: $e');
      throw Exception('Error fetching users');
    }
  }
}
