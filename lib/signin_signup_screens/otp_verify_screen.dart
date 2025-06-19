import 'dart:async';

import 'package:busapp/signin_signup_screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class OtpVerificationScreen extends StatefulWidget {
  final String email;

  OtpVerificationScreen({required this.email, Key? key}) : super(key: key);

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );

  Timer? _timer;
  int _timeLeft = 300; // 5:00 in seconds
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_timeLeft == 0) {
          timer.cancel();
        } else {
          setState(() {
            _timeLeft--;
          });
        }
      },
    );
  }

  String get timerText {
    int minutes = _timeLeft ~/ 60;
    int seconds = _timeLeft % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  final _otpControllers = List.generate(4, (index) => TextEditingController());
  String? _message;
  Color? _messageColor;

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((controller) => controller.text).join('');

    if (otp.length == 4) {
      try {
        // Call API to verify OTP
        final url = Uri.parse(
            'https://tech-bus-egy.vercel.app/mobile/user/verify-email');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': widget.email,
            'otp': otp,
          }),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          setState(() {
            _message =
                responseData['message'] ?? 'OTP verification successful!';
            _messageColor = Colors.green;
          });
          // Navigate to the next screen or show success message
          // For example:
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
        } else {
          final responseData = jsonDecode(response.body);
          setState(() {
            _message = responseData['message'] ?? 'OTP verification failed';
            _messageColor = Colors.red;
          });
        }
      } catch (e) {
        setState(() {
          _message = 'An error occurred: $e';
          _messageColor = Colors.red;
        });
      }
    } else {
      setState(() {
        _message = 'Please enter a valid OTP';
        _messageColor = Colors.red;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 24),
            Center(
              child: Image.asset(
                'assets/images/Logo.png',
                width: 248,
                height: 66,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 48),
            const Text(
              'OTP Verification',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You receive a code to ${widget.email}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
        Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return SizedBox(
                  width: 64,
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1, // Only allow one character
                    onChanged: (value) {
                      if (value.length == 1) {
                        // Move focus to next field
                        if (index < 3) {
                          FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                        } else {
                          // Last field - remove focus
                          _focusNodes[index].unfocus();
                        }
                      } else if (value.isEmpty) {
                        // Move focus to previous field on backspace
                        if (index > 0) {
                          FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                        }
                      }
                    },
                    decoration: InputDecoration(
                      counterText: '', // Hide the character counter
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF006B5E)),
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: _timeLeft == 0
                    ? () {
                        setState(() {
                          _timeLeft = 300;
                        });
                        startTimer();
                      }
                    : null,
                child: Text(
                  'Expired at $timerText',
                  style: TextStyle(
                    color:
                        _timeLeft == 0 ? Colors.red : const Color(0xFF006B5E),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 15, 90, 95),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
    );
  }
}
