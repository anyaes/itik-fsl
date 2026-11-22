import 'package:flutter/material.dart';

import 'package:flutter_sinyas/screens/downloads_screen.dart';
import 'package:flutter_sinyas/screens/lessons_page.dart';
import 'package:flutter_sinyas/screens/profile_screen.dart';
import 'package:flutter_sinyas/screens/settings_screen.dart';
import 'package:flutter_sinyas/screens/tracks_screen.dart';
import 'package:flutter_sinyas/widgets/app_bar.dart';
import 'package:flutter_sinyas/widgets/nav_item.dart';
import 'package:flutter_sinyas/widgets/side_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final List<NavItem> _navItems = const [
  NavItem(svgAsset: 'lesson.svg', label: 'Lessons'),
  NavItem(svgAsset: 'track.svg', label: 'Tracks'),
  NavItem(svgAsset: 'downloads.svg', label: 'Downloads'),
  NavItem(svgAsset: 'profile.svg', label: 'Profile'),
  NavItem(svgAsset: 'settings.svg', label: 'Settings'),
];

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildSelectedPage() {
    return IndexedStack(
      index: _selectedIndex,
      sizing: StackFit.expand,
      children: [
        LessonsPage(onTracksSelected: () => _onItemSelected(1)),
        const TracksScreen(),
        const DownloadsScreen(),
        const ProfileScreen(),
        const SettingsScreen(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 2. Check maxWidth (< 600 = Mobile, >= 600 = Tablet)
        final bool isMobile = constraints.maxWidth < 600;

        if (!isMobile) {
          // TABLET VIEW / WIDE SCREEN VIEW
          return Scaffold(
            body: SafeArea(
              child: Row(
                children: [
                  SidePanel(
                    items: _navItems,
                    selectedIndex: _selectedIndex,
                    onItemSelected: _onItemSelected, // 3. Pass the callback
                  ),
                  Expanded(child: _buildSelectedPage()),
                ],
              ),
            ),
          );
        }

        // MOBILE VIEW
        return Scaffold(
          body: SafeArea(child: _buildSelectedPage()),
          bottomNavigationBar: AppBottomBar(
            items: _navItems,
            selectedIndex: _selectedIndex,
            onItemSelected: _onItemSelected,
          ),
        );
      },
    );
  }
}
