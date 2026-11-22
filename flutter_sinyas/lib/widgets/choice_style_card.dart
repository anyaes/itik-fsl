import 'package:flutter/material.dart';

class ChoiceStyleCard extends StatelessWidget {
  const ChoiceStyleCard({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.child,
    this.scale = 1,
    this.padding,
    this.selectedColor = const Color(0xFF1EA8C3),
    this.selectedBackgroundColor = const Color(0xFF4EBFD0),
  });

  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;
  final double scale;
  final EdgeInsetsGeometry? padding;
  final Color selectedColor;
  final Color selectedBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final selectedColor = isSelected
        ? this.selectedColor
        : Colors.grey.shade300;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding:
              padding ?? EdgeInsets.symmetric(horizontal: 16, vertical: 8 * scale),
          decoration: BoxDecoration(
            color: isSelected ? selectedBackgroundColor : Colors.white,
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