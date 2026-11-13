import 'package:flutter/material.dart';

class NameEntryScreen extends StatelessWidget {
  const NameEntryScreen({super.key});

  static const screenKey = Key('name-entry-screen');

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      key: screenKey,
      body: SafeArea(child: Center(child: Text('Ad ve soyad'))),
    );
  }
}
