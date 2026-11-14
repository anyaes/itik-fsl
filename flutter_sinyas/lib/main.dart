import 'package:flutter/material.dart';
import 'package:flutter_sinyas/screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

void main() => runApp(const ItikApp());

class ItikApp extends StatelessWidget {
  const ItikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Itik',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Dongle',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF40B9CC),
        ),
      ),
      home: const OnboardingScreen(), // which screen loads first
    );
  }
}
