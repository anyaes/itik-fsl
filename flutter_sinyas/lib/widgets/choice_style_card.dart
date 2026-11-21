import 'package:flutter/material.dart';

class ChoiceStyleCard extends StatelessWidget {
  const ChoiceStyleCard({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.child,
    this.scale = 1,
    this.padding,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;
  final double scale;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final selectedColor = isSelected
        ? const Color(0xFF1EA8C3)
        : Colors.grey.shade300;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding:
              padding ??
              EdgeInsets.symmetric(horizontal: 16, vertical: 8 * scale),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4EBFD0) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selectedColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: selectedColor,
                blurRadius: 0,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
