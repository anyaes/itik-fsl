import 'dart:math';
import 'package:flutter/material.dart';
import '../models/sign.dart';
import '../models/question.dart';
import '../services/supabase_service.dart';

class LessonController extends ChangeNotifier {
  final SupabaseService _service = SupabaseService();
  final int lessonId;

  List<Sign> _targetSigns = [];
  List<Sign> _distractors = [];
  List<LessonQuestion> queue = [];

  int _originalLength = 0;
  int currentIndex = 0;
  int correctCount = 0;
  int totalAnswered = 0;
  bool isLoading = true;
  bool cameraDisabledForSession = false;

  LessonController({required this.lessonId});

  LessonQuestion? get currentQuestion =>
      currentIndex < queue.length ? queue[currentIndex] : null;

  bool get isFinished => !isLoading && currentIndex >= _originalLength;

  double get progress {
    if (_originalLength == 0) return 0.0;
    return (correctCount / _originalLength).clamp(0.0, 1.0);
  }

  // 1. Load data from Supabase and build randomized questions
  Future<void> initLesson() async {
    isLoading = true;
    notifyListeners();

    _targetSigns = await _service.fetchLessonSigns(lessonId);
    final targetIds = _targetSigns.map((sign) => sign.id).toSet();
    _distractors = (await _service.fetchAllSigns())
        .where((sign) => !targetIds.contains(sign.id))
        .toList();

    queue = _buildSessionQueue();
    isLoading = false;
    notifyListeners();
  }

  List<LessonQuestion> _buildSessionQueue() {
    final generated = <LessonQuestion>[];
    final random = Random();

    // Prioritize signs the user previously got wrong
    final sortedTargets = List<Sign>.from(_targetSigns)
      ..sort((a, b) => b.mistakeCount.compareTo(a.mistakeCount));

    for (final sign in sortedTargets) {
      // Passive multiple-choice question
      generated.add(_createMultipleChoice(sign, random));

      // Active camera question (or fallback multiple-choice if disabled)
      if (!cameraDisabledForSession && sign.isCameraSupported) {
        generated.add(
          LessonQuestion(targetSign: sign, mode: QuestionMode.cameraSign),
        );
      } else {
        generated.add(_createMultipleChoice(sign, random));
      }
    }

    final maxQuestions = 10 + random.nextInt(6); // 10 to 15

    _originalLength = generated.length;

    return generated;
  }

  LessonQuestion _createMultipleChoice(Sign target, Random random) {
    final pool = [
      ..._targetSigns,
      ..._distractors,
    ].where((s) => s.id != target.id).toList()..shuffle(random);

    final options = [target, ...pool.take(3)]..shuffle(random);
    final mode = random.nextBool()
        ? QuestionMode.videoToText
        : QuestionMode.textToVideo;

    return LessonQuestion(targetSign: target, mode: mode, options: options);
  }

  // 2. Submit an answer (from Multiple Choice OR Python Camera API)
  Future<void> submitAnswer(bool isCorrect, {double? confidence}) async {
  final question = currentQuestion;
  if (question == null) return;

  totalAnswered++;
  if (isCorrect) {
    correctCount++;
  }
  // No re-queue — wrong answers are logged but not repeated

  await _service.logAttempt(
    signId: question.targetSign.id,
    lessonId: lessonId,
    mode: question.mode,
    status: 'completed',
    isCorrect: isCorrect,
    confidenceScore: confidence,
  );

  currentIndex++;

  if (isFinished) {
    final accuracy = totalAnswered > 0 ? correctCount / totalAnswered : 1.0;
    await _service.completeLesson(lessonId, accuracy);
  }

  notifyListeners();
}

  Future<void> recordIncorrectAnswer() async {
  final question = currentQuestion;
  if (question == null) return;

  await _service.logAttempt(
    signId: question.targetSign.id,
    lessonId: lessonId,
    mode: question.mode,
    status: 'completed',
    isCorrect: false,
  );
  totalAnswered++;
}

  // 3. Skip Camera ("Can't sign right now")
  Future<void> skipCameraForSession() async {
    final question = currentQuestion;
    if (question == null) return;

    cameraDisabledForSession = true;

    await _service.logAttempt(
      signId: question.targetSign.id,
      lessonId: lessonId,
      mode: QuestionMode.cameraSign,
      status: 'SKIPPED',
    );

    final random = Random();
    // Swap current & all remaining camera questions into multiple-choice
    for (int i = currentIndex; i < queue.length; i++) {
      if (queue[i].mode == QuestionMode.cameraSign) {
        queue[i] = _createMultipleChoice(queue[i].targetSign, random);
      }
    }

    notifyListeners();
  }
}