import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gradient_progress_bar/gradient_progress_bar.dart';

import '../controllers/lesson_controller.dart';
import '../models/question.dart';
import '../models/sign.dart';
import '../services/supabase_service.dart';
import '../widgets/choice_style_card.dart';
import '../widgets/decorative_panel.dart';
import '../widgets/supabase_image.dart';
import '../widgets/video_player.dart';

class LessonQuizScreen extends StatefulWidget {
  final int lessonId;
  final String lessonName;

  const LessonQuizScreen({
    super.key,
    required this.lessonId,
    this.lessonName = 'Lesson',
  });

  @override
  State<LessonQuizScreen> createState() => _LessonQuizScreenState();
}

class _LessonQuizScreenState extends State<LessonQuizScreen> {
  late final LessonController _controller;
  int _lives = 3;
  bool _isCorrectAnswer = false;
  bool _isRecordingAnswer = false;
  bool _isSubmitting = false;
  int? _selectedAnswerId;
  String? _tip;

  @override
  void initState() {
    super.initState();
    _controller = LessonController(lessonId: widget.lessonId)
      ..addListener(() {
        if (mounted) setState(() {});
      });
    _controller.initLesson();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _answer(Sign sign, LessonQuestion question) async {
    if (_isCorrectAnswer || _isRecordingAnswer || _isSubmitting) return;

    if (sign.id == question.targetSign.id) {
      setState(() {
        _isCorrectAnswer = true;
        _selectedAnswerId = sign.id;
        _tip = null;
      });
      return;
    }

    setState(() {
      if (_lives > 0) _lives--;
      _tip = 'A tip! Watch the handshape and movement closely, then try again.';
      _isRecordingAnswer = true;
    });
    try {
      await _controller.recordIncorrectAnswer();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save your answer: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isRecordingAnswer = false);
    }
  }

  Future<void> _continue() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await _controller.submitAnswer(true);
      if (mounted) {
        setState(() {
          _isCorrectAnswer = false;
          _selectedAnswerId = null;
          _tip = null;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save your progress: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _mediaFor(Sign sign, {double maxWidth = 480, double height = 240}) {
    if (sign.videoPath != null) {
      return VideoContainer(
        bucketName: SupabaseService.mediaBucket,
        filePath: sign.videoPath!,
        maxWidth: maxWidth,
        autoPlay: false,
        looping: false,
      );
    }
    if (sign.photoPath != null) {
      return SupabaseImage(path: sign.photoPath!, height: height);
    }
    return SizedBox(
      width: maxWidth,
      height: height,
      child: const Center(
        child: Icon(
          Icons.sign_language_rounded,
          color: Color(0xFF16899F),
          size: 56,
        ),
      ),
    );
  }

  double _getProgress() {
    final queueLen = _controller.queue.length;
    if (queueLen == 0) return 0.0;
    return (_controller.currentIndex / queueLen).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = _controller.currentQuestion;
    if (question == null) return _buildFinished(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressHeader(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 760;
                  final media = _buildMediaPanel(question);
                  final prompt = _buildQuestionPanel(question);
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1050),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (isWide)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 5, child: media),
                                  const SizedBox(width: 32),
                                  Expanded(flex: 6, child: prompt),
                                ],
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  media,
                                  const SizedBox(height: 22),
                                  prompt,
                                ],
                              ),
                            if (_tip != null) ...[
                              const SizedBox(height: 24),
                              _buildTipPanel(_tip!),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isCorrectAnswer) _buildContinueBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1050),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Back to tracks',
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                color: const Color(0xFF002247),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GradientProgressIndicator(const [
                  Color(0xFFFFAA2E),
                  Color(0xFFFFD75D),
                ], _getProgress()),
              ),
              const SizedBox(width: 16),
              SvgPicture.asset(
                'assets/FeatherHeart.svg',
                width: 23,
                height: 23,
                colorFilter: ColorFilter.mode(
                  _lives > 0
                      ? const Color(0xFFFFD75D)
                      : const Color(0xFFB7C7CA),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$_lives',
                style: TextStyle(
                  color: _lives > 0
                      ? const Color(0xFFFFAA2E)
                      : const Color(0xFFB7C7CA),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaPanel(LessonQuestion question) {
    final Widget content;
    if (question.mode == QuestionMode.textToVideo) {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.sign_language_rounded,
            color: Color(0xFF002247),
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            question.targetSign.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF002247),
              fontSize: 28,
              height: 1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else {
      content = _mediaFor(question.targetSign);
    }

    return DecorativePanel(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 250,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ColoredBox(
            color: const Color(0xFFFAFCFA),
            child: Center(child: content),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionPanel(LessonQuestion question) {
    final isTextChoice =
        question.mode == QuestionMode.videoToText ||
        question.mode == QuestionMode.photoToText;
    final heading = question.mode == QuestionMode.cameraSign
        ? 'Practice this sign'
        : question.mode == QuestionMode.textToVideo
        ? 'Choose the sign'
        : 'Choose the correct answer';
    final subtitle = question.mode == QuestionMode.textToVideo
        ? 'Find the sign for “${question.targetSign.name}”.'
        : question.mode == QuestionMode.cameraSign
        ? 'Sign it clearly, then continue when you are ready.'
        : 'What does this sign demonstrate?';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          heading,
          style: const TextStyle(
            color: Color(0xFF002247),
            fontSize: 32,
            height: 1,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF002247),
            fontSize: 18,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 16),
        if (question.isRetry)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Let’s try that one again.',
              style: TextStyle(
                color: Color(0xFF16899F),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (question.mode == QuestionMode.cameraSign)
          _buildCameraActions()
        else if (isTextChoice)
          _buildTextOptions(question)
        else
          _buildMediaOptions(question),
      ],
    );
  }

  Widget _buildTextOptions(LessonQuestion question) {
    return Column(
      children: [
        for (final option in question.options)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ChoiceStyleCard(
              isSelected: _selectedAnswerId == option.id,
              onTap: _isRecordingAnswer || _isSubmitting
                  ? () {}
                  : () => _answer(option, question),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text(
                    option.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _selectedAnswerId == option.id
                          ? Colors.white
                          : const Color(0xFF002247),
                      fontSize: 22,
                      height: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMediaOptions(LessonQuestion question) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final option in question.options)
          SizedBox(
            width: 150,
            child: ChoiceStyleCard(
              isSelected: _selectedAnswerId == option.id,
              onTap: _isRecordingAnswer || _isSubmitting
                  ? () {}
                  : () => _answer(option, question),
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  _mediaFor(option, maxWidth: 126, height: 92),
                  const SizedBox(height: 6),
                  Text(
                    option.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _selectedAnswerId == option.id
                          ? Colors.white
                          : const Color(0xFF002247),
                      fontSize: 18,
                      height: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCameraActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: _isSubmitting
              ? null
              : () => setState(() {
                  _isCorrectAnswer = true;
                  _selectedAnswerId = null;
                  _tip = null;
                }),
          icon: const Icon(Icons.check_circle_outline_rounded),
          label: const Text('I signed it correctly'),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: _isSubmitting
              ? null
              : () async {
                  await _controller.skipCameraForSession();
                  if (mounted) {
                    setState(() {
                      _isCorrectAnswer = false;
                      _selectedAnswerId = null;
                      _tip = null;
                    });
                  }
                },
          child: const Text("Can't sign right now"),
        ),
      ],
    );
  }

  Widget _buildTipPanel(String tip) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
              tip,
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

  Widget _buildContinueBar() {
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
            constraints: const BoxConstraints(maxWidth: 1050),
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 230,
                height: 48,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _continue,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('CONTINUE'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinished(BuildContext context) {
    final total = _controller.totalAnswered;
    final correct = _controller.correctCount;
    final accuracy = total > 0 ? correct / total : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF4FAFB),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: DecorativePanel(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.celebration_rounded,
                    size: 72,
                    color: Color(0xFF1EADC3),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Lesson complete!',
                    style: TextStyle(
                      color: Color(0xFF002247),
                      fontSize: 34,
                      height: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$correct / $total correct\n${(accuracy * 100).toStringAsFixed(0)}% accuracy',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF526D76),
                      fontSize: 20,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('BACK TO TRACKS'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
