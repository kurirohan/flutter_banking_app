import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const NexaBankApp());
}

class NexaBankApp extends StatelessWidget {
  const NexaBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NexaBank',
      theme: AppTheme.theme,
      home: const LoginScreen(),
    );
  }
}

