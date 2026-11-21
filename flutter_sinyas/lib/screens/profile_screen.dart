import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';
import '../widgets/decorative_panel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseService _service = SupabaseService();
  late Future<Map<String, dynamic>?> _profile;

  @override
  void initState() {
    super.initState();
    _profile = _service.fetchCurrentProfile();
  }

  Future<void> _refresh() async {
    setState(() => _profile = _service.fetchCurrentProfile());
    await _profile;
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF4FAFB),
      child: FutureBuilder<Map<String, dynamic>?>(
        future: _profile,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _ProfileMessage(
              icon: Icons.cloud_off_rounded,
              title: 'Could not load profile',
              message: snapshot.error.toString(),
              action: TextButton(
                onPressed: _refresh,
                child: const Text('Retry'),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = Supabase.instance.client.auth.currentUser;
          final profile = snapshot.data;
          if (user == null || profile == null) {
            return _ProfileMessage(
              icon: Icons.person_outline_rounded,
              title: 'Your learning profile',
              message: user == null
                  ? 'Sign in to save your progress and personalize your profile.'
                  : 'Your profile has not been created yet. Run the Supabase setup SQL to enable profile creation.',
              action: user == null
                  ? FilledButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: const Text('Sign in'),
                    )
                  : TextButton(onPressed: _refresh, child: const Text('Retry')),
            );
          }

          final displayName =
              (profile['display_name'] as String?)?.trim().isNotEmpty == true
              ? profile['display_name'] as String
              : (user.email?.isNotEmpty == true ? user.email! : 'Learner');

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Profile',
                        style: TextStyle(
                          color: Color(0xFF002247),
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      DecorativePanel(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 42,
                              backgroundColor: const Color(0xFFE5F7F9),
                              child: Text(
                                displayName.characters.first.toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF16899F),
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              displayName,
                              style: const TextStyle(
                                color: Color(0xFF002247),
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              user.email ?? '',
                              style: const TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 18),
                            OutlinedButton.icon(
                              onPressed: () => _editDisplayName(displayName),
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Edit name'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      DecorativePanel(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            _ProfileStat(
                              icon: Icons.local_fire_department_rounded,
                              label: 'Current streak',
                              value: '${profile['current_streak'] ?? 0} days',
                            ),
                            const Divider(height: 1),
                            _ProfileStat(
                              icon: Icons.emoji_events_outlined,
                              label: 'Longest streak',
                              value: '${profile['longest_streak'] ?? 0} days',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: _signOut,
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Sign out'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _editDisplayName(String currentName) async {
    final controller = TextEditingController(text: currentName);
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit display name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (name == null || name.trim().isEmpty || !mounted) return;
    try {
      await _service.updateDisplayName(name);
      await _refresh();
    } catch (error) {
      if (mounted) _showMessage('Could not update profile: $error');
    }
  }

  Future<void> _signOut() async {
    try {
      await _service.signOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    } catch (error) {
      if (mounted) _showMessage('Could not sign out: $error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1EADC3)),
      title: Text(label),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ProfileMessage extends StatelessWidget {
  const _ProfileMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: DecorativePanel(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 52, color: const Color(0xFF1EADC3)),
                const SizedBox(height: 12),
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                action,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
