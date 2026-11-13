import 'package:flutter/material.dart';

import 'theme/sari_theme.dart';

void main() {
  runApp(const SariApp());
}

class SariApp extends StatelessWidget {
  const SariApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sarı',
      debugShowCheckedModeBanner: false,
      theme: buildSariTheme(),
      home: const SplashScreen(),
    );
  }
}

/// Uygulama epic'i gelene kadar duran yer tutucu ekran.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Sarı', style: textTheme.displayMedium),
              const SizedBox(height: 8),
              Text('Taksin bir dokunuş uzağında', style: textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}
