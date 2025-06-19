import 'dart:convert';
import 'package:busapp/models/user_model.dart';
import 'package:busapp/navbarscreens/main_scr.dart';
import 'package:busapp/navbarscreens/profile_screen.dart';
import 'package:busapp/shared/network/local_network.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentSuccess extends StatefulWidget {
  final int amount;
  final int points;

  const PaymentSuccess({
    super.key,
    required this.amount,
    required this.points,
  });

  @override
  State<PaymentSuccess> createState() => _PaymentSuccessState();
}

class _PaymentSuccessState extends State<PaymentSuccess> {
  bool _isProcessing = true;
  String? _errorMessage;
  final Color primaryColor = const Color(0xFF0F5A5F);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: const Text(
              "Payment Success",
              style: TextStyle(color: Colors.black),
            ),
            centerTitle: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStep(1, 'Enter amount', true),
                      _buildStepConnector(true),
                      _buildStep(2, 'Payment Details', true),
                      _buildStepConnector(true),
                      _buildStep(3, 'Success', true),
                    ],
                  ),
                  const SizedBox(height: 48),
                  Image.asset('assets/images/pay3.png', height: 200),
                  const SizedBox(height: 32),
                  Text(
                    "Payment Successful!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    child: Text(
                      'Added ${widget.points} points to your balance',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Amount:', 'EGP ${widget.amount}'),
                        const SizedBox(height: 8),
                        _buildDetailRow('Points Added:', '${widget.points} pts'),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          'Transaction Date:',
                          '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                       Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainScreen(initialIndex: 2),
                        ),
                      );
                      },
                      child: const Text(
                        "Back to Home",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
        const SizedBox(height: 8),
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
