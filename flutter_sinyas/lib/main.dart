import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/screens/home_screen.dart';
import '/screens/lesson_screen.dart';
import '/screens/login.dart';
import '/screens/onboarding_screen.dart';
import '/screens/quiz_demo_screen.dart';
import '/screens/signup.dart';
import '/screens/video_test.dart';
import '/screens/lesson_quiz_screen.dart';
import 'dart:async';

const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    throw StateError(
      'Supabase is not configured. Run with '
      '--dart-define-from-file=env.json containing SUPABASE_URL and '
      'SUPABASE_ANON_KEY (or set these defines in your launch configuration).',
    );
  }

  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);
  runApp(const ItikApp());
}

class ItikApp extends StatefulWidget {
  const ItikApp({super.key});

  @override
  State<ItikApp> createState() => _ItikAppState();
}

class _ItikAppState extends State<ItikApp> {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      if (!mounted) return;
      setState(() {
        _isAuthenticated = data.session != null;
        _isLoading = false;
      });
    });
  }

  Future<void> _checkAuth() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (!mounted) return;
    setState(() {
      _isAuthenticated = session != null;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'Itik',
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (BuildContext context) => const HomeScreen(),
        '/login': (BuildContext context) => const LoginScreen(),
        '/signup': (BuildContext context) => const SignupScreen(),
        '/onboarding': (BuildContext context) => const OnboardingScreen(),
        '/quiz-demo': (BuildContext context) => const QuizDemoScreen(),
        '/lesson': (BuildContext context) {
          if (Supabase.instance.client.auth.currentUser == null) {
            return const LoginScreen();
          }
          final args = ModalRoute.of(context)?.settings.arguments;
          return LessonScreen(lessonId: args is int ? args : null);
        },
        '/quiz': (BuildContext context) {
          if (Supabase.instance.client.auth.currentUser == null) {
            return const LoginScreen();
          }
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map<String, dynamic>) {
            return LessonQuizScreen(
              lessonId: args['lessonId'] as int? ?? 0,
              lessonName: args['lessonName'] as String? ?? 'Lesson',
            );
          }
          return LessonQuizScreen(
            lessonId: args is int ? args : 0,
            lessonName: 'Lesson',
          );
        },
      },
      theme: ThemeData(
        fontFamily: 'Dongle',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF40B9CC)),
        scaffoldBackgroundColor: const Color(0xFFF4FAFB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF002247),
          elevation: 0,
          centerTitle: false,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF4EBFD0),
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF1EA8C3), width: 2),
            ),
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF002247),
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            side: const BorderSide(color: Color(0xFFD8D8D8), width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF002247),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: _isAuthenticated ? const HomeScreen() : const LoginScreen(),
    );
  }
}
