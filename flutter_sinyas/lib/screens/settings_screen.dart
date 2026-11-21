import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/decorative_panel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<SharedPreferences> _preferences;

  @override
  void initState() {
    super.initState();
    _preferences = SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF4FAFB),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Settings',
                    style: TextStyle(
                      color: Color(0xFF002247),
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Adjust your learning experience on this device.',
                    style: TextStyle(color: Color(0xFF526D76), fontSize: 18),
                  ),
                  const SizedBox(height: 22),
                  FutureBuilder<SharedPreferences>(
                    future: _preferences,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text(
                          'Could not load settings: ${snapshot.error}',
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final preferences = snapshot.data!;
                      return DecorativePanel(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            _PreferenceSwitch(
                              preferences: preferences,
                              preferenceKey: 'sound_effects_enabled',
                              title: 'Sound effects',
                              subtitle: 'Play sounds during lessons.',
                              icon: Icons.volume_up_rounded,
                            ),
                            const Divider(height: 1),
                            _PreferenceSwitch(
                              preferences: preferences,
                              preferenceKey: 'daily_reminders_enabled',
                              title: 'Daily reminders',
                              subtitle:
                                  'Allow learning reminder notifications.',
                              icon: Icons.notifications_active_outlined,
                            ),
                            const Divider(height: 1),
                            _PreferenceSwitch(
                              preferences: preferences,
                              preferenceKey: 'autoplay_videos_enabled',
                              title: 'Autoplay lesson videos',
                              subtitle: 'Start lesson videos automatically.',
                              icon: Icons.play_circle_outline_rounded,
                              initialValue: true,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  const DecorativePanel(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      leading: Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF1EADC3),
                      ),
                      title: Text('About ITIK'),
                      subtitle: Text(
                        'Sign-language learning, one lesson at a time.',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreferenceSwitch extends StatefulWidget {
  const _PreferenceSwitch({
    required this.preferences,
    required this.preferenceKey,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.initialValue = false,
  });

  final SharedPreferences preferences;
  final String preferenceKey;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool initialValue;

  @override
  State<_PreferenceSwitch> createState() => _PreferenceSwitchState();
}

class _PreferenceSwitchState extends State<_PreferenceSwitch> {
  late bool _value =
      widget.preferences.getBool(widget.preferenceKey) ?? widget.initialValue;

  Future<void> _update(bool value) async {
    setState(() => _value = value);
    final saved = await widget.preferences.setBool(widget.preferenceKey, value);
    if (!saved && mounted) {
      setState(() => _value = !value);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save this setting.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(widget.icon, color: const Color(0xFF1EADC3)),
      title: Text(widget.title),
      subtitle: Text(widget.subtitle),
      value: _value,
      onChanged: _update,
      activeTrackColor: const Color(0xFF1EADC3),
    );
  }
}
