import 'package:flutter/material.dart';

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

  static const screenKey = Key('location-permission-screen');

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      key: screenKey,
      body: SafeArea(child: Center(child: Text('Konum izni'))),
    );
  }
}
