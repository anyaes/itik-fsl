import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_sinyas/widgets/nav_item.dart';

class SidePanel extends StatelessWidget {
  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const SidePanel({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300, // Fixed width prevents Row layout errors on tablet
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.fromLTRB(24, 24, 0, 24),
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        border: BorderDirectional(
          end: BorderSide(color: Colors.grey.shade300, width: 2.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 64),
          const Text(
            'logo',
            style: TextStyle(
              fontFamily: 'Dongle',
              fontSize: 40),
          ),
          const SizedBox(height: 24),
          ...List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = index == selectedIndex;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    // Keeps the #1EADC3 border visible on the active tab
                    side: isSelected
                        ? const BorderSide(color: Color(0xFF1EADC3), width: 2)
                        : BorderSide.none,
                    backgroundColor: isSelected
                        ? const Color(0xFF1EADC3).withValues(alpha: 0.08)
                        : Colors.transparent,
                  ),
                  icon: SvgPicture.asset(
                    item.svgAsset,
                    height: 36,
                    width: 36,
                  ),
                  onPressed: () => onItemSelected(index),
                  label: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontFamily: 'Dongle',
                          fontSize: 40,
                          color: Color(0xFF002247),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
