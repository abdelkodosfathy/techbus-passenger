import 'dart:convert';
import 'package:busapp/forgot_password_screens/otp_forgotpassword_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import 'package:techbusapp/forgot%20password/otp_forgot_screen.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  String? _message;
  Color? _messageColor;

  final Color primaryColor = const Color.fromARGB(255, 15, 90, 95);

Future<void> _forgetPasswordUser() async {
  final url =
      Uri.parse('https://tech-bus-egy.vercel.app/mobile/user/forget-password');

  if (_formKey.currentState!.validate()) {
    final data = {'email': _emailController.text};

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        setState(() {
          _message = 'Request successful! Check your email for further steps.';
          _messageColor = Colors.green;
        });
          String emailText = _emailController.text;
        _formKey.currentState!.reset();
        _emailController.clear();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OTPForgotScreen(
              email: emailText,  // Pass the email for OTP Forget Password
            ),
          ),
        );
      } else {
        try {
          final responseData = jsonDecode(response.body);
          setState(() {
            _message = responseData['message'] ?? 'Request failed';
            _messageColor = Colors.red;
          });
        } catch (e) {
          // Handle invalid JSON
          setState(() {
            _message = 'Unexpected server response: ${response.body}';
            _messageColor = Colors.red;
          });
        }
      }
    } catch (e) {
      setState(() {
        _message = 'An error occurred: ${e.toString()}';
        _messageColor = Colors.red;
      });
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
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
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStep(1, 'Enter Email', true),
                  _buildStepConnector(true),
                  _buildStep(2, 'OTP Verify', false),
                  _buildStepConnector(false),
                  _buildStep(3, 'Resetting', false),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                'Forget Password',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Write your email here to receive an OTP verification',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (!RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _forgetPasswordUser,
                  child: const Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              if (_message != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    _message!,
                    style: TextStyle(color: _messageColor),
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
            color: isActive ? primaryColor : Colors.grey[300],
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
            color: isActive ? primaryColor : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Container(
      width: 40,
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: isActive ? primaryColor : Colors.grey[300],
    );
  }
}