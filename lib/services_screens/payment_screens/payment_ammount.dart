import 'package:busapp/services_screens/payment_screens/payment_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentAmount extends StatefulWidget {
  const PaymentAmount({super.key});

  @override
  State<PaymentAmount> createState() => _PaymentAmountState();
}

class _PaymentAmountState extends State<PaymentAmount> {
  final TextEditingController _amountController = TextEditingController();
  int _points = 0;
  final Color primaryColor = const Color(0xFF0F5A5F);
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_updatePoints);
  }

  @override
  void dispose() {
    _amountController.removeListener(_updatePoints);
    _amountController.dispose();
    super.dispose();
  }

  void _updatePoints() {
    final amount = int.tryParse(_amountController.text) ?? 0;
    setState(() {
      _points = amount; // 1 EGP = 1 point in this implementation
    });
  }

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStep(1, 'Enter Amount', true),
                  _buildStepConnector(true),
                  _buildStep(2, 'Payment Details', false),
                  _buildStepConnector(false),
                  _buildStep(3, 'Success', false),
                ],
              ),
              const SizedBox(height: 48),
              Column(
                children: [
                  Image.asset('assets/images/bitcoin.png', height: 200),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: 'Enter amount in EGP',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.asset('assets/images/vector.png'),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Amount: EGP ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        ' ${_amountController.text.isEmpty ? '0' : _amountController.text} ',
                        style: TextStyle(
                          fontSize: 16,
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '(${_points} points)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ), 
                ],
              ),
              const SizedBox(height: 24),
              
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ),
              
              const SizedBox(height: 24),
              
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
                  onPressed: _isLoading || _amountController.text.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentDetails(
                                amount: int.parse(_amountController.text),
                                points: _points,
                              ),
                            ),
                          );
                        },
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Continue to Payment",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
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