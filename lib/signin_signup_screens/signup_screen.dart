import 'package:busapp/signin_signup_screens/login_screen.dart';
import 'package:busapp/signin_signup_screens/otp_verify_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import 'package:techbusapp/HomeScreens/findbus_screen.dart';
import 'dart:convert';
//import 'package:techbusapp/otp_verify_screen.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // String get firstName => _firstNameController.text;

  String? _message;
  Color? _messageColor;
//new
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasNumber = false;
  bool _hasMinLength = false;
  bool _isLoading = false;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _validatePassword(String password) {
    setState(() {
      _hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      _hasLowerCase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasMinLength = password.length >= 8;
    });
  }
  //-----------------------------------------------------

  Future<void> _registerUser() async {
    setState(() {
      _isLoading = true;
    });
    final url =
        Uri.parse('https://tech-bus-egy.vercel.app/mobile/user/register');

    if (_formKey.currentState!.validate()) {
      final data = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'password_confirmation': _confirmPasswordController.text,
      };

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        );

        if (response.statusCode == 200) {
          setState(() {
            _message = 'Registration successful!';
            _messageColor = Colors.green;
          });
          _formKey.currentState!.reset();

          // Navigate to OTP Verification screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                email: _emailController
                    .text, // Pass the email for OTP verification
              ),
            ),
          );
          /*   Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => RealTimeZoneSearchPage(firstName: _firstNameController.text),
  ),
);*/
        } else {
          final responseData = jsonDecode(response.body);
          setState(() {
            _message = responseData['message'] ?? 'Registration failed';
            _messageColor = Colors.red;
          });
        }
      } catch (e) {
        setState(() {
          _message = 'An error occurred: $e';
          _messageColor = Colors.red;
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),

                Image.asset(
                  'assets/images/Logo.png',
                  width: 248,
                  height: 66,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Welcome To TechBus!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 16),
                _buildTextField(
                  hintText: 'Enter your name',
                  label: 'First Name',
                  controller: _firstNameController,
                  icon: Icons.person,
                ),
                SizedBox(height: 10.0),

                _buildTextField(
                  hintText: 'Enter your last name',
                  label: 'Last Name',
                  controller: _lastNameController,
                  icon: Icons.person,
                ),
                SizedBox(height: 10.0),

                _buildTextField(
                  hintText: 'Enter your phone number',
                  label: 'Phone',
                  controller: _phoneController,
                  icon: Icons.person,
                ),
                SizedBox(height: 10.0),

                _buildTextField(
                  label: 'Email',
                  hintText: 'Enter your email adress',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  icon: Icons.person,
                ),
                SizedBox(height: 10.0),

                //New Password Field
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
                      onChanged: _validatePassword,
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
                        prefixIcon:
                            const Icon(Icons.lock_outline, color: Colors.grey),
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

                // New Password Requirements
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildValidationItem(
                      "Both upper and lower case letters",
                      _hasUpperCase && _hasLowerCase,
                    ),
                    _buildValidationItem(
                      "At least 8 characters",
                      _hasMinLength,
                    ),
                    _buildValidationItem(
                      "Must contain 1 number",
                      _hasNumber,
                    ),
                  ],
                ),
                SizedBox(height: 20.0),

                SizedBox(
                  width: 400,
                  child: ElevatedButton(
                    onPressed: _registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 15, 90, 95),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ).copyWith(
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    // child: Text('Sign Up'),
                    child: _isLoading
                        ? SizedBox(
                            width: 16.0, // Reduced size
                            height: 16.0, // Reduced size
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth:
                                  2.0, // You can keep adjusting this to affect the circle thickness
                            ),
                          ) // Show a loading spinner when in loading state
                        : Text('Sign Up'),
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
                //New
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                        );
                      },
                      child: const Text('Sign In'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 15, 90, 95),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //New
  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
            fontWeight: FontWeight.w500,
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(icon, color: Colors.grey),
            suffixIcon: Icon(Icons.check, color: Colors.green),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ],
    );
  }

//New
  Widget _buildValidationItem(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel,
          color: isValid ? Colors.green : Colors.red,
          size: 24.0,
        ),
        SizedBox(width: 8.0),
        Text(
          text,
          style: TextStyle(
            fontSize: 14.0,
            color: isValid ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}
