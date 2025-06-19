import 'package:busapp/forgot_password_screens/forgotpassword_screen.dart';
import 'package:busapp/models/user_model.dart';
import 'package:busapp/navbarscreens/home_screen.dart';
import 'package:busapp/navbarscreens/main_scr.dart';
import 'package:busapp/shared/constants/constants.dart';
import 'package:busapp/shared/network/local_network.dart';
import 'package:busapp/signin_signup_screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  Color? _messageColor;

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final response = await http
          .post(
            Uri.parse('https://tech-bus-egy.vercel.app/mobile/user/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': _emailController.text,
              'password': _passwordController.text,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final responseBody = response.body;
      dynamic responseData;
      try {
        responseData = jsonDecode(responseBody);
        print(responseData);
      } catch (e) {
        throw FormatException('Invalid server response format');
      }

      if (response.statusCode == 200) {
        print("Full response body: ${response.body}");
        // Parse the response body to get the token
        Map<String, dynamic> parsedResponse = json.decode(response.body);
        String parsedToken = parsedResponse['data']['token'];
        String parsedImage = parsedResponse['data']['user']['image']; // for example : https://res.cloudinary.com/dnrhne5fh/image/upload/v1733608099/mspvvthjcuokw7eiyxo6.png
        print("login token: ${parsedToken} ");
        print("login image: ${parsedImage} "); 

        try {
          final userModel = UserModel.fromJson(responseData);
          await _saveUserData(userModel);
          token = parsedToken;
          image = parsedImage;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainScreen(initialIndex: 0),
            ),
          );
        } catch (e) {
          throw FormatException('Failed to parse user data');
        }
      } else {
        final errorMessage =
            responseData?['message'] ?? 'Login failed. Please try again.';
        throw HttpException(errorMessage, code: response.statusCode);
      }
    } on FormatException catch (e) {
      setState(() {
        _message = e.message;
        _messageColor = Colors.red;
      });
    } on HttpException catch (e) {
      setState(() {
        _message = e.message;
        _messageColor = Colors.red;
      });
    } on Exception catch (e) {
      setState(() {
        _message =
            'Connection error: ${e.toString().replaceAll(RegExp(r'^Exception: '), '')}';
        _messageColor = Colors.red;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveUserData(UserModel userModel) async {
    try {
      await CashNetwork.saveCacheData(
        key: 'user_data',
        value: json.encode(userModel.toJson()),
      );
      await CashNetwork.saveCacheData(
        key: 'token',
        value: userModel.token,
      );
      await CashNetwork.saveCacheData(
        key: 'image',
        value: userModel.image,
      );
      print("asdasdasd");
    } catch (e) {
      throw Exception('Failed to save user data locally');
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
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Email',
                  hintText: 'Please enter your email adress',
                  controller: _emailController,
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10.0),
                _buildTextField(
                  label: 'Password',
                  hintText: 'Please enter your password',
                  controller: _passwordController,
                  icon: Icons.lock,
                  obscureText: true,
                ),
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  // crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgetPasswordScreen()),
                        );
                      },
                      child: const Text('Forgot Password?'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 15, 90, 95),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                SizedBox(
                  width: 400,
                  child: ElevatedButton(
                    onPressed: _loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 15, 90, 95),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ).copyWith(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 19.0, // Reduced size
                            height: 19.0, // Reduced size
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth:
                                  2.0, // You can keep adjusting this to affect the circle thickness
                            ),
                          ) // Show a loading spinner when in loading state
                        : Text('Login'),
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
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don\'t have an account?',
                      style: TextStyle(
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
                              builder: (context) => RegistrationScreen()),
                        );
                      },
                      child: const Text('Sign Up'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 15, 90, 95),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

 Widget _buildTextField({
  required String label,
  required String hintText,
  required TextEditingController controller,
  required IconData icon,
  TextInputType keyboardType = TextInputType.text,
  bool obscureText = false,
}) {
  // Add state for password visibility
  bool isPasswordVisible = false;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      StatefulBuilder(
        builder: (context, setState) {
          return TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText && !isPasswordVisible,
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: Color(0xFF066B9A), 
                  width: 2,
                ),
              ),
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey),
              prefixIcon: Icon(icon, color: Colors.grey),
              suffixIcon: obscureText ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              ) : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '$label is required';
              }
              return null;
            },
          );
        },
      ),
    ],
  );
}
}

class HttpException implements Exception {
  final String message;
  final int code;

  HttpException(this.message, {this.code = 0});

  @override
  String toString() => message;
}
