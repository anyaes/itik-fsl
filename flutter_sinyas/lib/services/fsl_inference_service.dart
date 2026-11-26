import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:mediapipe_vision/mediapipe_vision.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class FslInferenceService {
  static final FslInferenceService _instance = FslInferenceService._internal();
  factory FslInferenceService() => _instance;
  FslInferenceService._internal();

  Interpreter? _interpreter;
  List<String> _labels = [];
  HandLandmarker? _landmarker;
  bool _initialized = false;

  static const int _numFeatures = 126; // 2 hands x 21 landmarks x 3 coords
  static const double _threshold = 0.7;
  static const int _smoothingWindow = 5;
  final List<int> _recentPredictions = [];

  Future<void> initialize() async {
    if (_initialized) return;

    // Load labels
    final labelsJson = await rootBundle.loadString('assets/mediapipe/labels.json');
    _labels = _parseLabels(labelsJson);

    // Load TFLite model
    _interpreter = await Interpreter.fromAsset('assets/mediapipe/sign_model.tflite');

    // Initialize MediaPipe Hand Landmarker
    final options = HandLandmarkerOptions(
      model: VisionModels.handLandmarker,
      runningMode: RunningMode.image,
      numHands: 2,
      minHandDetectionConfidence: 0.6,
      minHandPresenceConfidence: 0.5,
      minTrackingConfidence: 0.5,
    );
    _landmarker = await HandLandmarker.create(options);

    _initialized = true;
  }

  List<String> _parseLabels(String json) {
    final trimmed = json.trim();
    if (trimmed.startsWith('[')) {
      return trimmed
          .substring(1, trimmed.length - 1)
          .split(',')
          .map((e) => e.trim().replaceAll('"', '').replaceAll("'", ''))
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return trimmed
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<PredictionResult?> predictFromImage(Uint8List imageBytes, int width, int height) async {
    if (!_initialized) await initialize();

    // Camera gives BGRA, convert to RGB
    final rgbBytes = _bgraToRgb(imageBytes, width, height);

    final visionImage = VisionImage.fromPixels(
      pixels: rgbBytes,
      width: width,
      height: height,
      format: VisionPixelFormat.rgb,
    );

    final result = await _landmarker!.detect(visionImage);

    if (result.handLandmarks.isEmpty) {
      _recentPredictions.clear();
      return null;
    }

    final features = _extractFeatures(result);
    if (features == null) return null;

    // Run inference
    final input = [features];
    final output = List.filled(_labels.length, 0.0).reshape([1, _labels.length]);
    _interpreter!.run(input, output);

    final probs = output[0] as List<double>;
    var maxProb = 0.0;
    var maxIdx = -1;
    for (var i = 0; i < probs.length; i++) {
      if (probs[i] > maxProb) {
        maxProb = probs[i];
        maxIdx = i;
      }
    }

    // Smoothing: only accept if above threshold
    int prediction = (maxProb >= _threshold && maxIdx != -1) ? maxIdx : -1;
    _recentPredictions.add(prediction);
    if (_recentPredictions.length > _smoothingWindow) {
      _recentPredictions.removeAt(0);
    }

    // Majority vote
    final counts = <int, int>{};
    for (final p in _recentPredictions) {
      if (p != -1) counts[p] = (counts[p] ?? 0) + 1;
    }
    int? bestIdx;
    int bestCount = 0;
    counts.forEach((k, v) {
      if (v > bestCount) {
        bestCount = v;
        bestIdx = k;
      }
    });

    if (bestIdx != null && bestCount >= (_smoothingWindow ~/ 2) + 1) {
      return PredictionResult(
        label: _labels[bestIdx!],
        confidence: maxProb,
      );
    }
    return null;
  }

  Uint8List _bgraToRgb(Uint8List bgra, int width, int height) {
    final rgb = Uint8List(width * height * 3);
    for (var i = 0, j = 0; i < bgra.length; i += 4, j += 3) {
      rgb[j] = bgra[i + 2];     // R
      rgb[j + 1] = bgra[i + 1]; // G
      rgb[j + 2] = bgra[i];     // B
    }
    return rgb;
  }

  Float32List? _extractFeatures(HandLandmarkerResult result) {
    if (result.handLandmarks.isEmpty) return null;

    final feats = Float32List(_numFeatures);
    for (var h = 0; h < result.handLandmarks.length; h++) {
      final hand = result.handLandmarks[h];
      final handed = result.handedness[h].first.categoryName ?? 'Right';
      final slot = handed == 'Left' ? 0 : 1;

      // Extract normalized coordinates (already 0-1 from MediaPipe)
      final pts = <double>[];
      for (final lm in hand) {
        pts.add(lm.x);
        pts.add(lm.y);
        pts.add(lm.z);
      }

      // Normalize: wrist-origin, scale-invariant (same as Python)
      // wrist is landmark 0
      final wx = pts[0];
      final wy = pts[1];
      final wz = pts[2];
      for (var i = 0; i < pts.length; i += 3) {
        pts[i] -= wx;
        pts[i + 1] -= wy;
        pts[i + 2] -= wz;
      }
      var scale = pts.map((e) => e.abs()).reduce(math.max);
      if (scale == 0) scale = 1.0;
      for (var i = 0; i < pts.length; i++) {
        pts[i] /= scale;
      }

      final start = slot * 63;
      for (var i = 0; i < 63; i++) {
        feats[start + i] = pts[i];
      }
    }
    return feats;
  }

  void dispose() {
    _interpreter?.close();
    _landmarker?.dispose();
    _initialized = false;
    _recentPredictions.clear();
  }
}

class PredictionResult {
  final String label;
  final double confidence;

  PredictionResult({required this.label, required this.confidence});
}