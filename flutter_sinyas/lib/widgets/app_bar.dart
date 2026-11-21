import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_sinyas/widgets/nav_item.dart';

class AppBottomBar extends StatelessWidget {
  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const AppBottomBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onItemSelected,
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFF1EADC3).withValues(alpha: 0.15),
      destinations: items.map((item) {
        return NavigationDestination(
          icon: SvgPicture.asset(
            item.svgAsset,
            height: 24,
            width: 24,
            colorFilter: const ColorFilter.mode(
              Color(0xFF002247),
              BlendMode.srcIn,
            ),
          ),
          selectedIcon: SvgPicture.asset(
            item.svgAsset,
            height: 24,
            width: 24,
            colorFilter: const ColorFilter.mode(
              Color(0xFF1EADC3),
              BlendMode.srcIn,
            ),
          ),
          label: item.label,
        );
      }).toList(),
    );
  }
}
