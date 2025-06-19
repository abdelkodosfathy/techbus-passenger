import 'package:busapp/models/user_model.dart';
import 'package:busapp/services_screens/tickets_screen.dart';
import 'package:busapp/shared/network/local_network.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:busapp/shared/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QrscanScreen extends StatefulWidget {
  const QrscanScreen({super.key});

  @override
  State<QrscanScreen> createState() => _QrscanScreenState();
}

class _QrscanScreenState extends State<QrscanScreen> {
  UserModel? userModel;
  bool _userScanning = false;
  bool _isScanned = false;
  String? _message;
  Color? _messageColor;
  MobileScannerController? _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
    _loadUserData();
  }

  void _loadUserData() {
    print("loaded...");

    final userData = CashNetwork.getCacheData(key: 'user_data');
    print(userData);
    if (userData.isNotEmpty) {
      try {
        setState(() {
          userModel = UserModel.fromJson(json.decode(userData));
        });
      } catch (e) {
        print('Error parsing user data: $e');
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> getScanData(String ticketCode) async {
    print("here is");
  final url = Uri.parse('https://tech-bus-egy.vercel.app/mobile/scan/ticket/$ticketCode');
  final authToken = 'Bearer $token';

  try {
    setState(() {
      _userScanning = false;
    });

    final response = await http.get(
      url,
      headers: {'Authorization': authToken},
    );
    // print(response.toString());
    print("scanning response: " + response.toString());

    if (response.statusCode == 200) {
      var decodedResponse = jsonDecode(response.body);
      int points = decodedResponse['data']['points'];
      cons_points = points;

      userModel = userModel?.updateBalance(points);

      final updatedData = json.encode(userModel?.toJson());
      await CashNetwork.saveCacheData(key: 'user_data', value: updatedData);

      // ✅ Also update SharedPreferences so ProfileScreen sees correct value
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('balance', userModel?.balance.points.toDouble() ?? 0.0);

      setState(() {
        _isScanned = true;
      });

      _showSuccessDialog();
    } else {
      setState(() {
        _message = response.statusCode == 404
            ? 'Not enough points!'
            : 'Scan failed (${response.statusCode})';
        _messageColor = Colors.red;
        _isScanned = false;
      });
    }
  } catch (e) {
    setState(() {
      _message = 'Connection error';
      _messageColor = Colors.red;
      _isScanned = false;
    });
  }
}

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Success',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ticket scanned successfully!'),
            SizedBox(height: 10),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                      Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => TicketsScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0A6A6A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('view your tickets',style: TextStyle(color: Colors.white)),
                ),
              ), 
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => {
              Navigator.pop(context),
              setState(() {
                _isScanned = false;
                _userScanning = false;
              })
            },
            child: const Text('OK', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(),
            SizedBox(
              width: 8,
            ),
            Image.asset(
              'assets/images/Logo.png',
              width: 192,
              height: 50,
              fit: BoxFit.contain,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Points: ${userModel?.balance.points ?? 0}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          ],
        ),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.8),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        toolbarHeight: 80,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_userScanning) ...[
              MobileScanner(
                controller: _controller,
                onDetect: (BarcodeCapture barcodeCapture) {
                  if (!_isScanned && barcodeCapture.barcodes.isNotEmpty) {
                    final barcode = barcodeCapture.barcodes.first;
                    if (barcode.rawValue != null) {
                      setState(() => _isScanned = true);
                      getScanData(barcode.rawValue!);
                    }
                  }
                },
              ),
              _buildScannerOverlay(),
              if (_message != null)
                Positioned(
                  bottom: 100,
                  child: Text(
                    _message!,
                    style: TextStyle(color: _messageColor, fontSize: 18),
                  ),
                ),
              Positioned(
                bottom: 20, // Adjust this value for vertical positioning
                left: 0,
                right: 0,
                child: Center(
                  // Center the button horizontally
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _userScanning = false; // Stop scanning
                        _isScanned = false; // Stop scanning
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 15, 90, 95),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8), // Small padding around text
                    ).copyWith(
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    child: Text("Cancel Scanning"),
                  ),
                ),
              ),
            ] else ...[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _userScanning = true; // Start scanning
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 15, 90, 95),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          shape: CircleBorder(), 
                        ).copyWith(
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                        child: Icon(
                          Icons.camera_alt, // Camera icon
                          color: Colors.white, // Icon color
                          size: 40, // Adjust the size of the icon
                        ),
                      ),
                    ),
                    
                  ),
                  SizedBox(height: 12,),
                  Text('Scan Now', style: TextStyle(fontSize: 16),)
                ],
              ),
            ]
          ],
        ),
      ),
     // bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildScannerOverlay() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.teal,
          width: 4,
        ),
      ),
      width: 250,
      height: 250,
    );
  }

  // Widget _buildBottomNavBar() {
  //   return SafeArea(
  //     child: BottomNavigationBar(
  //       currentIndex: 1,
  //       backgroundColor: Colors.white,
  //       selectedItemColor: const Color.fromARGB(255, 15, 90, 95),
  //       unselectedItemColor: Colors.grey,
  //       items: const [
  //         BottomNavigationBarItem(
  //           icon: Icon(Icons.home),
  //           label: 'Home',
  //         ),
  //         BottomNavigationBarItem(
  //           icon: Icon(Icons.qr_code_scanner),
  //           label: 'QR Scan',
  //         ),
  //         BottomNavigationBarItem(
  //           icon: Icon(Icons.person),
  //           label: 'Profile',
  //         ),
  //       ],
  //       onTap: (index) {
  //         if (index == 0)
  //           Navigator.pushReplacement(context,
  //               MaterialPageRoute(builder: (context) => HomeScreenMap()));
  //         if (index == 2)
  //           Navigator.pushReplacement(context,
  //               MaterialPageRoute(builder: (context) => TicketsScreen()));
  //       },
  //     ),
  //   );
  // }
}
