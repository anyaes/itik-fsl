/*import 'package:flutter/material.dart';

import '../demo/demo_quiz_data.dart';
import '../models/question.dart';
import '../widgets/choice_style_card.dart';
import '../widgets/decorative_panel.dart';
import '../widgets/demo_video_preview.dart';
import 'lesson_quiz_screen.dart';
import 'lesson_screen.dart';

class QuizDemoScreen extends StatelessWidget {
  const QuizDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final demos = [
      (
        title: 'Standard lesson',
        subtitle: 'Watch a sign, read its tip, and continue.',
        icon: Icons.menu_book_rounded,
        onTap: () => _open(context, const LessonScreen.demo()),
      ),
      (
        title: 'Watch a video, choose a sign name',
        subtitle: 'Video on the left; answer cards on the right.',
        icon: Icons.ondemand_video_rounded,
        onTap: () => _openQuiz(context, demoQuestions[0]),
      ),
      (
        title: 'Photo, choose a sign name',
        subtitle: 'Photo prompt with the same answer-card layout.',
        icon: Icons.image_outlined,
        onTap: () => _openQuiz(context, demoQuestions[1]),
      ),
      (
        title: 'Word, choose a video',
        subtitle: 'A centered word prompt with four video choices.',
        icon: Icons.video_library_outlined,
        onTap: () => _openQuiz(context, demoQuestions[2]),
      ),
      (
        title: 'Camera practice',
        subtitle: 'Preview the distinct signing-practice layout.',
        icon: Icons.camera_alt_outlined,
        onTap: () => _openQuiz(context, demoQuestions[3]),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4FAFB),
      appBar: AppBar(title: const Text('Screen demos')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 850),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Try each lesson layout',
                    style: TextStyle(
                      color: Color(0xFF002247),
                      fontSize: 38,
                      height: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'These screens use hardcoded sample questions and do not call Supabase.',
                    style: TextStyle(color: Color(0xFF526D76), fontSize: 19),
                  ),
                  const SizedBox(height: 18),
                  const DecorativePanel(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFF1EADC3),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Demo video is a mock player. Tap it to open NMIXX “DASH” M/V on JYP Entertainment’s official YouTube channel.',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final demo in demos)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: ChoiceStyleCard(
                        isSelected: false,
                        onTap: demo.onTap,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              demo.icon,
                              color: const Color(0xFF1EADC3),
                              size: 30,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    demo.title,
                                    style: const TextStyle(
                                      color: Color(0xFF002247),
                                      fontSize: 24,
                                      height: 1,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    demo.subtitle,
                                    style: const TextStyle(
                                      color: Color(0xFF526D76),
                                      fontSize: 18,
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFF002247),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: () => _openVideo(context),
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('Open official NMIXX video'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /*void _openQuiz(BuildContext context, LessonQuestion question) {
    _open(
      context,
      LessonQuizScreen.demo(question: question, demoVideoLinks: demoVideoLinks),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }*/

  Future<void> _openVideo(BuildContext context) async {
    final opened = await openDemoVideo(demoVideoUrl);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the demo video link.')),
      );
    }
  }
  
}*/
