import 'package:flutter/material.dart';
import 'package:gradient_progress_bar/gradient_progress_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../demo/demo_quiz_data.dart';
import '../models/sign.dart';
import '../services/supabase_service.dart';
import '../widgets/decorative_panel.dart';
import '../widgets/demo_video_preview.dart';
import '../widgets/supabase_image.dart';
import '../widgets/video_player.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.lessonId}) : isDemo = false;

  const LessonScreen.demo({super.key}) : lessonId = null, isDemo = true;

  final int? lessonId;
  final bool isDemo;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final SupabaseService _service = SupabaseService();
  late final Future<_LessonData> _lessonData = _loadLesson();
  int _currentSignIndex = 0;
  bool _isCompleting = false;
  bool _isCompleted = false;
  bool _autoPlayVideos = true;

  @override
  void initState() {
    super.initState();
    _loadVideoPreference();
  }

  Future<void> _loadVideoPreference() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(
      () => _autoPlayVideos =
          preferences.getBool('autoplay_videos_enabled') ?? true,
    );
  }

  Future<_LessonData> _loadLesson() async {
    if (widget.isDemo) {
      return _LessonData(
        title: 'UNIT 1  •  FOUNDATIONS',
        signs: [
          Sign(id: 1, name: 'Salamat - Thank you!', category: 'Greetings'),
        ],
      );
    }

    final lessonId = widget.lessonId;
    if (lessonId == null) {
      throw StateError('Open a lesson from the Tracks screen to begin.');
    }
    final lesson = await _service.fetchLesson(lessonId);
    final signs = await _service.fetchLessonSigns(lessonId);
    if (signs.isEmpty) {
      throw StateError('This lesson has no signs linked in Supabase yet.');
    }
    return _LessonData(title: lesson['lesson_name'] as String, signs: signs);
  }

  Future<void> _completeLesson(int signCount) async {
    if (_isCompleting || _isCompleted) return;
    setState(() => _isCompleting = true);
    try {
      if (!widget.isDemo && Supabase.instance.client.auth.currentUser != null) {
        await _service.completeLesson(widget.lessonId!, 1);
      }
      if (!mounted) return;
      setState(() => _isCompleted = true);
      if (widget.isDemo) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Supabase.instance.client.auth.currentUser == null
                ? 'Lesson completed. Sign in to save your progress.'
                : 'Lesson completed! $signCount signs reviewed.',
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save lesson progress: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCompleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<_LessonData>(
          future: _lessonData,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _LessonError(message: snapshot.error.toString());
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final lesson = snapshot.data!;
            final sign = lesson.signs[_currentSignIndex];
            final isLast = _currentSignIndex == lesson.signs.length - 1;

            return Column(
              children: [
                _buildHeader(lesson.signs.length),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (widget.isDemo)
                              const DemoVideoPreview(videoUrl: demoVideoUrl)
                            else if (sign.videoPath case final videoPath?)
                              VideoContainer(
                                bucketName: SupabaseService.mediaBucket,
                                filePath: videoPath,
                                maxWidth: 900,
                                autoPlay: _autoPlayVideos,
                              )
                            else if (sign.photoPath case final photoPath?)
                              SupabaseImage(path: photoPath, height: 280)
                            else
                              const _NoMediaCard(),
                            const SizedBox(height: 14),
                            Text(
                              lesson.title,
                              style: const TextStyle(
                                color: Color(0xFF526D76),
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              sign.name,
                              style: const TextStyle(
                                color: Color(0xFF002247),
                                fontSize: 32,
                                height: 1,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'This is the sign for ${sign.name}. Watch the handshape and movement closely.',
                              style: const TextStyle(
                                color: Color(0xFF002247),
                                fontSize: 18,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildTip(sign),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                _buildContinueBar(isLast),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(int signCount) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 950),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Back to tracks',
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                color: const Color(0xFF002247),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GradientProgressIndicator(const [
                  Color(0xFFFFAA2E),
                  Color(0xFFFFD75D),
                ], (_currentSignIndex + 1) / signCount),
              ),
              const SizedBox(width: 12),
              SvgPicture.asset(
                'assets/FeatherHeart.svg',
                width: 22,
                height: 22,
              ),
              const SizedBox(width: 5),
              const Text(
                '3',
                style: TextStyle(
                  color: Color(0xFFFFAA2E),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTip(Sign sign) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F8FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC9EEF4)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: Color(0xFF002247),
            size: 22,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'A tip! Focus on the handshape and movement for ${sign.name}.',
              style: const TextStyle(
                color: Color(0xFF002247),
                fontSize: 17,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueBar(bool isLast) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E5E5))),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 950),
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 230,
                height: 48,
                child: FilledButton(
                  onPressed: _isCompleting
                      ? null
                      : isLast
                      ? () => _completeLesson(1)
                      : () => setState(() => _currentSignIndex++),
                  child: _isCompleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isCompleted
                              ? 'COMPLETED'
                              : isLast
                              ? 'FINISH LESSON'
                              : 'CONTINUE',
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LessonData {
  const _LessonData({required this.title, required this.signs});

  final String title;
  final List<Sign> signs;
}

class _LessonError extends StatelessWidget {
  const _LessonError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 44, color: Colors.red),
            const SizedBox(height: 12),
            const Text(
              'Could not load this lesson',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.maybePop(context),
              child: const Text('Back to tracks'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoMediaCard extends StatelessWidget {
  const _NoMediaCard();

  @override
  Widget build(BuildContext context) {
    return const DecorativePanel(
      padding: EdgeInsets.all(28),
      child: SizedBox(
        height: 164,
        child: Center(
          child: Text('Add a photo or video path for this sign in Supabase.'),
        ),
      ),
    );
  }
}
