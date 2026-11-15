import 'package:flutter/material.dart';

class GreyButton extends StatefulWidget {
  final String title;
  final VoidCallback onTap;
  final Widget? icon;

  const GreyButton({
    super.key,
    required this.title,
    required this.onTap,
    this.icon,
  });

  @override
  State<GreyButton> createState() => _GreyButtonState();
}

class _GreyButtonState extends State<GreyButton> {
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFCFA),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isHovered
                  ? const Color(0xFFC9CCCC)
                  : const Color(0xFFD8D8D8),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD8D8D8),
                blurRadius: 0,
                spreadRadius: 0,
                offset: Offset(0, isPressed ? 1 : 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 12),
              ],
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E3348),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
