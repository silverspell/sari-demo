import 'package:flutter/material.dart';

class SessionPlaceholderScreen extends StatelessWidget {
  const SessionPlaceholderScreen({super.key});

  static const screenKey = Key('session-placeholder-screen');

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      key: screenKey,
      body: SafeArea(child: Center(child: Text('Oturum açık'))),
    );
  }
}
