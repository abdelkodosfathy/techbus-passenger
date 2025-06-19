import 'package:busapp/models/user_model.dart';
import 'package:busapp/shared/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ComplaintSrc extends StatefulWidget {
  @override
  State<ComplaintSrc> createState() => _ComplaintSrcState();
}

class _ComplaintSrcState extends State<ComplaintSrc> {
  final String authToken = "Bearer $token";
  final Color primaryColor = const Color(0xFF0F5A5F);
  final _formKey = GlobalKey<FormState>();
  String? selectedComplaint;
  String additionalNotes = '';
  bool _isLoading = false;
  String? _errorMessage;

  // List of transportation complaints (English only)
  final List<String> complaints = [
    'Bad service',
    'Late arrival',
    'Rude driver',
    'Overcrowding',
    'Unclean vehicle',
    'Missed stop',
    'Overcharging',
    'Reckless driving',
    'Vehicle condition',
    'Other issue'
  ];

  Future<void> submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://tech-bus-egy.vercel.app/mobile/report'),
        headers: {
          'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'note': selectedComplaint,
          'description': additionalNotes,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint submitted successfully')),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          _errorMessage = 'Failed to submit complaint. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please check your connection.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
          "Make a Complaint",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                Column(
                  children: [
                    Image.asset('assets/images/complaint.png', height: 200),
                    const SizedBox(height: 32),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Choose complaint',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: selectedComplaint,
                          icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                          hint: const Text('Choose your complaint', style: TextStyle(color: Colors.grey)),
                          dropdownColor: Colors.white,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: const Color(0xFF0F5A5F), width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: complaints.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedComplaint = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a complaint type';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Additional Notes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          maxLines: 4,
                          onChanged: (value) => additionalNotes = value,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some details';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter any notes..',
                            contentPadding: const EdgeInsets.all(16.0),
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: const Color(0xFF0F5A5F), width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
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
                    onPressed: _isLoading ? null : submitComplaint,
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
                            "Submit Complaint",
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
      ),
    );
  }
}
