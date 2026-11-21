import 'package:flutter/material.dart';
import 'package:flutter_sinyas/widgets/choice_style_card.dart';

class ChoiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final double scale;

  const ChoiceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.scale = 1,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceStyleCard(
      isSelected: isSelected,
      onTap: onTap,
      scale: scale,
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 36 * scale,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    color: isSelected ? Colors.white : const Color(0xFF002247),
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 0,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    height: 1,
                    fontSize: 24 * scale,
                    color: isSelected ? Colors.white : const Color(0xFF002247),
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
          ),
        ],
      ),
    );
  }
}
