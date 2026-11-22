import 'package:flutter/material.dart';

class BrandingPanel extends StatelessWidget {
  const BrandingPanel({super.key});

  static const _navy = Color(0xFF002247);
  static const _teal = Color(0xFF1EADC3);
  static const _pageBackground = Color(0xFFF4FAFB);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _teal,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/mascot.png',
              width: 160,
              height: 160,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            const Text(
              'Itik',
              style: TextStyle(
                fontFamily: 'Dongle',
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Learn everyday signs at your own pace.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Dongle',
                color: Colors.white70,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}