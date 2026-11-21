import '../models/question.dart';
import '../models/sign.dart';

const demoVideoUrl = 'https://www.youtube.com/watch?v=7UecFm_bSTU';

final demoSigns = [
  Sign(
    id: 1,
    name: 'Thank you',
    category: 'Greetings',
    videoPath: 'demo-video',
  ),
  Sign(id: 2, name: 'Hello', category: 'Greetings', videoPath: 'demo-video'),
  Sign(id: 3, name: 'Goodbye', category: 'Greetings', videoPath: 'demo-video'),
  Sign(
    id: 4,
    name: 'Please',
    category: 'Everyday phrases',
    videoPath: 'demo-video',
  ),
];

final demoQuestions = [
  LessonQuestion(
    targetSign: demoSigns[0],
    mode: QuestionMode.videoToText,
    options: demoSigns,
  ),
  LessonQuestion(
    targetSign: demoSigns[0],
    mode: QuestionMode.photoToText,
    options: demoSigns,
  ),
  LessonQuestion(
    targetSign: demoSigns[0],
    mode: QuestionMode.textToVideo,
    options: demoSigns,
  ),
  LessonQuestion(targetSign: demoSigns[0], mode: QuestionMode.cameraSign),
];

final demoVideoLinks = {for (final sign in demoSigns) sign.id: demoVideoUrl};
