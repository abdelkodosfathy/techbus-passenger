import 'package:busapp/navbarscreens/home_screen.dart';
import 'package:busapp/navbarscreens/main_scr.dart';
import 'package:busapp/shared/constants/constants.dart';
import 'package:busapp/shared/network/local_network.dart';
import 'package:busapp/signin_signup_screens/login_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CashNetwork.cashInitialization();
  token = CashNetwork.getCacheData(key: 'token');
  cons_points = int.tryParse(CashNetwork.getCacheData(key: 'points'));
  print("token is:  $token");
  print("points is:  $cons_points");
  runApp(const TechBusApp());
}

class TechBusApp extends StatelessWidget {
  const TechBusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: token != null && token != "" ? MainScreen() : LoginScreen());
  }
}


