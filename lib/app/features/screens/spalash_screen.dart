import 'package:flutter/material.dart';
import 'package:qibla_compass_app/app/features/screens/home%20nav%20screen/home_nav_screen.dart';

class SpalashScreen extends StatefulWidget {
  const SpalashScreen({super.key});

  @override
  State<SpalashScreen> createState() => _SpalashScreenState();
}

class _SpalashScreenState extends State<SpalashScreen> {
  @override
  void initState() {
    super.initState();
    navigateToHome(context);
  }

  Future<void> navigateToHome(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 3));
    // Navigate to the home screen after the delay
    // You can replace this with your actual navigation logic
    // For example:
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeNav()));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/SPLASH.png'), fit: BoxFit.cover)
        ),
      ),
    );
  }
}