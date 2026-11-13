import 'package:flutter/material.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  static const screenKey = Key('otp-screen');

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      key: screenKey,
      body: SafeArea(child: Center(child: Text('Doğrulama kodu'))),
    );
  }
}
