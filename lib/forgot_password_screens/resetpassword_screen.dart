import 'dart:convert';

import 'package:busapp/shared/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String verifyToken;

  const ResetPasswordScreen({Key? key, required this.email, required this.verifyToken}) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

 // bool _hasUpperCase = false;
 // bool _hasLowerCase = false;
 // bool _hasNumber = false;
 // bool _hasMinLength = false;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

 /* void _validatePassword(String password) {
    setState(() {
      _hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      _hasLowerCase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasMinLength = password.length >= 8;
    });
  }*/

  Future<void> _resetPassword() async {
    // TODO: Implement API call
    // API call: POST /api/reset-password
    // Parameters: email (string), password (string), confirmPassword (string)
    // Example:
    final _authToken = 'Bearer $token';

    print(_authToken);
    print(_passwordController.text);
    print(_confirmPasswordController.text);
    try {
      final response = await http.post(
        Uri.parse('https://tech-bus-egy.vercel.app/mobile/user/forget-password/reset-password'),
        headers: {'Authorization': _authToken},
        body: {
          'email': widget.email,
          'new_password': _passwordController.text,
          'new_password_confirmation': _confirmPasswordController.text,
          'token': widget.verifyToken,
        },
      );
      if (response.statusCode == 200) {
        // Show success message and navigate to login screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset successfully')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
        print("perfecto");
      } else {
        // Show error message
        final error = jsonDecode(response.body);
      print("error l;ine 64: $error");
      }
    } catch (e) {
      print("error line 67: $e");
      // Handle error
    }

    // For now, we'll just show a success message and pop to the first screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset successfully')),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
                      children: [                   
                          Center(
                            child: Image.asset(
                              'assets/images/Logo.png',
                              width: 248,
                              height: 66,
                              fit: BoxFit.contain,
                            ),
                          ),
                        const SizedBox(height: 48),
                        Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStep(1, 'Enter Email', true),
                  _buildStepConnector(true),
                  _buildStep(2, 'OTP Verify', true),
                  _buildStepConnector(true),
                  _buildStep(3, 'Resetting', true),
                ],
              ),
                const SizedBox(height: 48),
                        const Text(
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Entre new password and confirm it ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 32),
              // Email Input Field
              Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
          
                    children: [
                      
                      Text(
                                'Password',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
          
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                    //  onChanged: _validatePassword,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
          
                    //New confirm Password Field
                    Text(
            'Confirm Password',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),
                  TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      decoration: InputDecoration(
                        hintText: 'Confirm your password',
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    validator: (value) => value != _passwordController.text
                        ? 'Passwords do not match'
                        : null,
                  ),
                  SizedBox(height: 20.0),
          
                    ],
                  ),
              const SizedBox(height: 24),
              
              // Send Code Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 15, 90, 95),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int number, String title, bool isActive) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Color.fromARGB(255, 15, 90, 95) : Colors.grey[300],
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Color.fromARGB(255, 15, 90, 95) : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Container(
      width: 40,
      height: 1,
      margin: EdgeInsets.symmetric(horizontal: 4),
      color: isActive ? Color.fromARGB(255, 15, 90, 95) : Colors.grey[300],
    );
  }
}