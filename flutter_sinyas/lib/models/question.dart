import '/models/sign.dart';

enum QuestionMode { videoToText, textToVideo, photoToText, cameraSign }

class LessonQuestion {
  final Sign targetSign;
  final QuestionMode mode;
  final List<Sign> options; // Empty if mode == cameraSign
  bool isRetry;

  LessonQuestion({
    required this.targetSign,
    required this.mode,
    this.options = const [],
    this.isRetry = false,
  });
}