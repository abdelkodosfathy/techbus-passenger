import 'dart:convert';

import 'package:busapp/shared/network/local_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:busapp/services_screens/payment_screens/payment_success.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PaymentDetails extends StatefulWidget {
  final int amount;
  final int points;

  const PaymentDetails({super.key, required this.amount, required this.points});

  @override
  State<PaymentDetails> createState() => PaymentDetailsState();
}

class PaymentDetailsState extends State<PaymentDetails> {
    bool _isProcessing = true;
  String? _errorMessage;
  
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool isLoading = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final Color primaryColor = const Color(0xFF0F5A5F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Charge My Points",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStep(1, 'Enter Amount', true),
                _buildStepConnector(true),
                _buildStep(2, 'Payment Details', true),
                _buildStepConnector(false),
                _buildStep(3, 'Success', false),
              ],
            ),
            const SizedBox(height: 32),
            CreditCardWidget(
              cardBgColor: primaryColor,
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              isHolderNameVisible: true,
              cardHolderName: cardHolderName, 
              cvvCode: cvvCode,
              showBackView: isCvvFocused,
              onCreditCardWidgetChange: (brand) {},
            ),    
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CreditCardForm(
                      formKey: formKey,
                      cardNumber: cardNumber,
                      cvvCode: cvvCode,
                      isHolderNameVisible: true,
                      cardHolderName: cardHolderName, 
                      expiryDate: expiryDate,
                      onCreditCardModelChange: onCreditCardModelChange,
                      inputConfiguration: InputConfiguration(
                        cardNumberDecoration: InputDecoration(
                          hintText: 'Card Number',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        expiryDateDecoration: InputDecoration(
                          hintText: 'XX/XX',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        cvvCodeDecoration: InputDecoration(
                          hintText: 'XXXX',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        cardHolderDecoration: InputDecoration(
                          hintText: 'Enter CardHolder name',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Amount: EGP ${widget.amount} (${widget.points} points)',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                                onPressed: _processPayment,
                                child: const Text(
                                  'Pay Now',
                                  style: TextStyle(fontSize: 18,color: Colors.white),
                                ),
                              ),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
  Future<void> _completePayment() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception('Token not found');

      // Charge the user
      final chargeUrl = Uri.parse('https://tech-bus-egy.vercel.app/mobile/user/balance');
      final chargeResponse = await http.post(
        chargeUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'points': widget.amount}),
      );

      if (chargeResponse.statusCode != 200) {
        throw Exception('Charging failed: ${chargeResponse.body}');
      }

      final chargeData = json.decode(chargeResponse.body);
      final newResPoints = chargeData['data']['Points'];
        await prefs.setDouble('balance', newResPoints.toDouble());
      print("charge points: $newResPoints");

      // Load cached user_data
      final cachedUserDataStr = await CashNetwork.getCacheData(key: 'user_data');
      if (cachedUserDataStr == null) throw Exception('Cached user data not found');

      final cachedUserData = json.decode(cachedUserDataStr);
      final oldImage = cachedUserData['data']['image'] ?? '';
      final user = cachedUserData['data']['user'];

      // Update only the points
      user['balance']['points'] = newResPoints;

      print("70: user: $user");

      // Save updated user data back to cache
      await CashNetwork.saveCacheData(
        key: 'user_data',
        value: jsonEncode({
          "data": {
            "user": user,
            "token": token,
            "image": oldImage,
          }
        }),
      );

    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to complete payment: ${e.toString()}';
        _isProcessing = false;
      });
    } finally { 
        _isProcessing = false;
    }
  }


  Future<void> _processPayment() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => isLoading = true);

    try {
      // Simulate payment processing
      // await Future.delayed(const Duration(seconds: 1));
      await _completePayment();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentSuccess(
            amount: widget.amount,
            points: widget.points,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
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