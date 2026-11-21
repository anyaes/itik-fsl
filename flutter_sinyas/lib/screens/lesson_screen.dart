import 'package:flutter/material.dart';
import 'package:gradient_progress_bar/gradient_progress_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/sign.dart';
import '../services/supabase_service.dart';
import '../widgets/supabase_image.dart';
import '../widgets/video_player.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.lessonId});

  final int? lessonId;

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
      if (Supabase.instance.client.auth.currentUser != null) {
        await _service.completeLesson(widget.lessonId!, 1);
      }
      if (!mounted) return;
      setState(() => _isCompleted = true);
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
      backgroundColor: const Color(0xFFF4FAFB),
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

            return LayoutBuilder(
              builder: (context, constraints) {
                final scale = (constraints.maxWidth / 390)
                    .clamp(0.85, 1.25)
                    .toDouble();
                return Column(
                  children: [
                    Padding(
                    padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                    child: Row(
                      children: [
                        const SizedBox(height: 20),
                        IconButton(
                          tooltip: 'Back to tracks',
                          onPressed: () => Navigator.maybePop(context),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GradientProgressIndicator(
                            [const Color(0xFFFFAA2E), const Color(0xFFFFD75D)],
                            (_currentSignIndex + 1) / lesson.signs.length,
                          ),
                        ),
                        const SizedBox(width: 12),
                        SvgPicture.asset('assets/FeatherHeart.svg', width: 24, height: 24),
                        const SizedBox(width: 14),
                      ],
                    ),
                  ),
                  SizedBox(width: 14),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 700),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (sign.videoPath case final videoPath?)
                                  VideoContainer(
                                    bucketName: SupabaseService.mediaBucket,
                                    filePath: 'videos/h2h_1.mp4',
                                    maxWidth: 700,
                                    autoPlay: _autoPlayVideos,
                                  )
                                else if (sign.photoPath case final photoPath?)
                                  SupabaseImage(path: photoPath, height: 280)
                                else
                                  const _NoMediaCard(),
                                const SizedBox(height: 20),
                                Text(
                                  lesson.title,
                                  style: TextStyle(
                                    color: const Color(0xFF526D76),
                                    fontSize: 18 * scale,
                                  ),
                                ),
                                Text(
                                  sign.name,
                                  style: TextStyle(
                                    color: const Color(0xFF002247),
                                    fontSize: 34 * scale,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (sign.category != null)
                                  Text(
                                    sign.category!,
                                    style: const TextStyle(
                                      color: Color(0xFF16899F),
                                      fontSize: 18,
                                    ),
                                  ),
                                const SizedBox(height: 10),
                                Text(
                                  '${_currentSignIndex + 1} of ${lesson.signs.length}',
                                  style: const TextStyle(
                                    color: Color(0xFF526D76),
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: _currentSignIndex == 0
                                            ? null
                                            : () => setState(
                                                () => _currentSignIndex--,
                                              ),
                                        child: const Text('BACK'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: FilledButton(
                                        onPressed: _isCompleting
                                            ? null
                                            : isLast
                                            ? () => _completeLesson(
                                                lesson.signs.length,
                                              )
                                            : () => setState(
                                                () => _currentSignIndex++,
                                              ),
                                        child: _isCompleting
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Text(
                                                _isCompleted
                                                    ? 'COMPLETED'
                                                    : isLast
                                                    ? 'FINISH LESSON'
                                                    : 'NEXT SIGN',
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
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
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFFE5F7F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text('Add a photo or video path for this sign in Supabase.'),
      ),
    );
  }
}
