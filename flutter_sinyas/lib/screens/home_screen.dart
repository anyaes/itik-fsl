import 'package:flutter/material.dart';
import 'package:gradient_progress_bar/gradient_progress_bar.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                IconButton(
                icon: Icon(Icons.arrow_back),
                iconSize: 26,
                color: const Color.fromARGB(255, 116, 79, 79),
                onPressed: () {
                  debugPrint('hey');
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GradientProgressIndicator([
                Color(0xFFFFAA2E),
                Color(0xFFFFD75D)
              ], 1)
              ),
              const SizedBox(width: 12),
              ]
            )
          )
        ],
      )
    );
  }
}

