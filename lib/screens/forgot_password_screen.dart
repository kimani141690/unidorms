import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../colors.dart';
import '../models/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showAlertDialog(String title, String message, {bool showBackToLoginButton = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundColor, // Set the background color
          title: Text(title),
          content: Text(message),
          actions: [
            if (showBackToLoginButton)
              TextButton(
                child: const Text('Back to Login'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
              ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showAlertDialog('Error', 'Please enter your email address to reset your password.');
      return;
    }
    try {
      await _authService.sendPasswordResetEmail(email);
      _showAlertDialog('Success', 'Password reset email sent. Please check your email.', showBackToLoginButton: true);
    } catch (e) {
      _showAlertDialog('Error', 'Failed to send password reset email. Please try again.');
    }
    _emailController.clear(); // Clear the email field after use
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textWhite,
      appBar: AppBar(
        title: Text('Reset Password'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Enter your email to reset your password',
                style: TextStyle(fontSize: 18, color: AppColors.textBlack),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: AppColors.textBlack),
                  filled: true,
                  fillColor: AppColors.backlight,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.textWhite,
                  backgroundColor: AppColors.backgroundColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  minimumSize: const Size(400, 40),
                ),
                onPressed: _resetPassword,
                child: const Text('Reset Password'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.textWhite,
                  backgroundColor: AppColors.backgroundColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  minimumSize: const Size(400, 40),
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
