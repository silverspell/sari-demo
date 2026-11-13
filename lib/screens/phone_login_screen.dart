import 'package:flutter/material.dart';

class PhoneLoginScreen extends StatelessWidget {
  const PhoneLoginScreen({super.key});

  static const screenKey = Key('phone-login-screen');

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      key: screenKey,
      body: SafeArea(child: Center(child: Text('Telefon numarası ile giriş'))),
    );
  }
}
