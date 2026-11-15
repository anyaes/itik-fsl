import 'package:flutter/material.dart';

class Button extends StatefulWidget {
  final String title;
  final VoidCallback onTap;
  final double scale;

  const Button({
    super.key,
    required this.title,
    required this.onTap,
    this.scale = 1,
  });

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  bool isHovered = false;
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => isPressed = true),
        onTapUp: (_) => setState(() => isPressed = false),
        onTapCancel: () => setState(() => isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: Matrix4.translationValues(0, isPressed ? 3 : 0, 0),
          transformAlignment: Alignment.center,
          padding: EdgeInsets.all(16 * widget.scale),
          decoration: BoxDecoration(
            color: const Color(0xFF4EBFD0),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF1EA8C3), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1EA8C3),
                blurRadius: 0,
                spreadRadius: 0,
                offset: Offset(0, isPressed ? 1 : 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 36 * widget.scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 0,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
