import 'package:flutter/material.dart';
import '/screens/home_screen.dart';
import '/screens/onboarding_screen.dart';
import '/screens/login.dart';
import '/screens/signup.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(const ItikApp());
}

class ItikApp extends StatelessWidget {
  const ItikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Itik',
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (BuildContext context) => const HomeScreen(),
        '/login': (BuildContext context) => LoginScreen(),
        '/signup': (BuildContext context) => SignupScreen(),
        '/onboarding': (BuildContext context) => OnboardingScreen(),
      },
      theme: ThemeData(
        fontFamily: 'Dongle',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF40B9CC)),
      ),
      home: const OnboardingScreen(), // which screen loads first
    );
  }
}
