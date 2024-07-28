import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isOtpSent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).checkToken(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: 'Mobile Number'),
            ),
            if (_isOtpSent)
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'OTP'),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (!_isOtpSent) {
                  await authProvider.sendOtp(_mobileController.text);
                  setState(() {
                    _isOtpSent = true;
                  });
                } else {
                  bool success = await authProvider.validateOtp(
                    _mobileController.text,
                    _otpController.text,
                  );
                  if (success) {
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  }
                }
              },
              child: Text(_isOtpSent ? 'Validate OTP' : 'Send OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
