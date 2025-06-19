import 'dart:async';
import 'package:busapp/forgot_password_screens/resetpassword_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OTPForgotScreen extends StatefulWidget {
  final String email;

  OTPForgotScreen({Key? key, required this.email}) : super(key: key);

  @override
  _OTPForgotScreenState createState() => _OTPForgotScreenState();
}

class _OTPForgotScreenState extends State<OTPForgotScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  Timer? _timer;
  int _timeLeft = 300; // 5 minutes in seconds
  String? _message;
  Color? _messageColor;

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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft == 0) {
        timer.cancel();
      } else {
        setState(() {
          _timeLeft--;
        });
      }
    });
  }

  String get timerText {
    int minutes = _timeLeft ~/ 60;
    int seconds = _timeLeft % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _otpForget() async {
    print("email we printed: ${widget.email}");

  final otp = _controllers.map((controller) => controller.text).join('');

  // Validation
  if (otp.length != 4 || !RegExp(r'^\d{4}$').hasMatch(otp)) {
    setState(() {
      _message = 'Please enter a valid 4-digit OTP.';
      _messageColor = Colors.red;
    });
    return;
  }
// abdelkodosfathy@gmail.com
  // Proceed with the API call
  try {
    final url = Uri.parse('https://tech-bus-egy.vercel.app/mobile/user/forget-password/verify');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': widget.email, 'otp': otp}),
    );
    final responseErr = jsonDecode(response.body);
    String? token = responseErr['data']['token'];
    print("printing: $token");

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        _message = responseData['message'] ?? 'OTP verification successful!';
        _messageColor = Colors.green;
      });
      // Navigate to the next screen or perform further actions
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(email: widget.email, verifyToken: token ?? '')
        )
      );
    } else {
      final responseData = jsonDecode(response.body);
      setState(() {
        _message = responseData['message'] ?? 'OTP verification failed.';
        _messageColor = Colors.red;
      });
    }
  } catch (e) {
      print(e);

    setState(() {
      _message = 'An error occurred: $e';
      _messageColor = Colors.red;
    });
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
        padding: const EdgeInsets.all(20.0),
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
                _buildStepConnector(false),
                _buildStep(3, 'Resetting', false),
              ],
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
              'You received a code on ${widget.email}',
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
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: InputDecoration(
                      counterText: "",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF0F5A5F)),
                      ),
                    ),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < _controllers.length - 1) {
                        _focusNodes[index + 1].requestFocus();
                      }
                    },
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
                          _message = null;
                        });
                        startTimer();
                      }
                    : null,
                child: Text(
                  _timeLeft == 0 ? 'Resend OTP' : 'Expires in $timerText',
                  style: TextStyle(color: _timeLeft == 0 ? Colors.red : Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _otpForget,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F5A5F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  Widget _buildStep(int number, String title, bool isActive) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFF0F5A5F) : Colors.grey[300],
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
            color: isActive ? const Color(0xFF0F5A5F) : Colors.grey,
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
      color: isActive ? const Color(0xFF0F5A5F) : Colors.grey[300],
    );
  }
}