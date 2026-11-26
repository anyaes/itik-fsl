import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/widgets/choice_card.dart';
import '/widgets/button.dart';
import '/screens/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController();

  int scene = 0; // 0 name, 1 role, 2 experience, 3 camera, 4 done
  int selectedIndex = 0;
  int? selectedKnowledgeIndex;

  static const learnerTypes = [
    'Learner (I want to learn FSL from scratch or improve)',
    'Guardian / Parent (I\'m learning to support someone I love)',
    'Hard of Hearing / PWD (I want to practice, connect, or sharpen my skills)',
  ];

  static const knowledgeLevels = [
    'Complete Beginner',
    'Know Basics',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final name = _nameController.text.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    await prefs.setString('user_name', name);
    await prefs.setString('user_role', learnerTypes[selectedIndex]);
    await prefs.setString(
      'user_experience',
      selectedKnowledgeIndex == null
          ? 'Complete Beginner'
          : knowledgeLevels[selectedKnowledgeIndex!],
    );

    // Persist display name to Supabase profile.
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null && name.isNotEmpty) {
      try {
        await Supabase.instance.client
            .from('profiles')
            .upsert({'id': user.id, 'display_name': name});
      } catch (_) {}
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _next() => setState(() => scene++);

  Widget _sceneCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), blurRadius: 16, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget _buildScene() {
    switch (scene) {
      case 0:
        return _sceneCard([
          Image.asset('assets/mascot.png', height: 120, fit: BoxFit.contain),
          const SizedBox(height: 16),
          const Text('Huh… where am I…?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Ah! Who are you?', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Enter your name',
              border: OutlineInputBorder(),
            ),
          ),
          if (_nameController.text.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Oh, you\'re ${_nameController.text.trim()}.', style: const TextStyle(fontSize: 18)),
          ],
        ]);
      case 1:
        return _sceneCard([
          Image.asset('assets/mascot.png', height: 96, fit: BoxFit.contain),
          const SizedBox(height: 12),
          const Text('What brings you here?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...List.generate(learnerTypes.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ChoiceCard(
                title: learnerTypes[i],
                subtitle: '',
                isSelected: selectedIndex == i,
                scale: 1.0,
                onTap: () => setState(() => selectedIndex = i),
              ),
            );
          }),
        ]);
      case 2:
        return _sceneCard([
          Image.asset('assets/mascot.png', height: 96, fit: BoxFit.contain),
          const SizedBox(height: 12),
          const Text('How familiar are you with FSL?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...List.generate(knowledgeLevels.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ChoiceCard(
                title: knowledgeLevels[i],
                subtitle: i == 0
                    ? 'Start with the basics.'
                    : 'Answer a few questions to find your starting point.',
                isSelected: selectedKnowledgeIndex == i,
                scale: 1.0,
                onTap: () => setState(() => selectedKnowledgeIndex = i),
              ),
            );
          }),
        ]);
      case 3:
        return _sceneCard([
          Image.asset('assets/mascot.png', height: 96, fit: BoxFit.contain),
          const SizedBox(height: 12),
          const Text('Magic Mirror', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Let\'s test it out! Mirror the sign "Kumusta".',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Icon(Icons.videocam, size: 64, color: Color(0xFF16899F)),
        ]);
      default:
        return _sceneCard([
          Image.asset('assets/mascot.png', height: 120, fit: BoxFit.contain),
          const SizedBox(height: 16),
          Text(
            'Welcome, ${_nameController.text.trim()}!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text('Whenever you\'re ready, lead the way!'),
        ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = scene == 4;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3FA2C9), Color(0xFFF4FAFB)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(child: _buildScene()),
                  ),
                ),
                const SizedBox(height: 16),
                Button(
                  title: isLast ? 'START' : 'CONTINUE',
                  scale: 1.0,
                  onTap: () {
                    if (scene == 0 && _nameController.text.trim().isEmpty) return;
                    if (scene == 2 && selectedKnowledgeIndex == null) return;
                    if (isLast) {
                      _finish();
                    } else {
                      _next();
                    }
                  },
                ),
                if (scene == 3)
                  TextButton(
                    onPressed: _next,
                    child: const Text('Skip to Onboarding'),
                  ),
                if (scene > 0)
                  TextButton(
                    onPressed: () => setState(() => scene--),
                    child: const Text('Back'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
