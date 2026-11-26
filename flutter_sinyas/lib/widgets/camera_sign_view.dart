import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '/services/fsl_inference_service.dart';

class CameraSignView extends StatefulWidget {
  final String targetSign;
  final Function(String) onSignDetected;
  final bool enabled;

  const CameraSignView({
    super.key,
    required this.targetSign,
    required this.onSignDetected,
    this.enabled = true,
  });

  @override
  State<CameraSignView> createState() => _CameraSignViewState();
}

class _CameraSignViewState extends State<CameraSignView> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isProcessing = false;
  final FslInferenceService _inference = FslInferenceService();
  String? _lastDetected;
  int _sameCount = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      final front = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );
      _controller = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.bgra8888,
      );
      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _isInitialized = true);
      _startInferenceLoop();
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _startInferenceLoop() async {
    await _inference.initialize();
    while (mounted && widget.enabled) {
      if (_controller == null || !_controller!.value.isInitialized || _isProcessing) {
        await Future.delayed(const Duration(milliseconds: 33));
        continue;
      }
      _isProcessing = true;
      try {
        final image = await _controller!.takePicture();
        final bytes = await image.readAsBytes();
        // Convert BGRA to RGB (simplified - in production use proper conversion)
        final result = await _inference.predictFromImage(bytes, _controller!.value.previewSize!.width.toInt(), _controller!.value.previewSize!.height.toInt());
        if (result != null && result.label.toLowerCase() == widget.targetSign.toLowerCase()) {
          _sameCount++;
          if (_sameCount >= 3 && _lastDetected != result.label) {
            _lastDetected = result.label;
            if (mounted) widget.onSignDetected(result.label);
          }
        } else {
          _sameCount = 0;
        }
      } catch (e) {
        debugPrint('Inference error: $e');
      } finally {
        _isProcessing = false;
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _inference.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return Container(
        width: 320,
        height: 240,
        color: Colors.black12,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Stack(
      children: [
        SizedBox(
          width: 320,
          height: 240,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CameraPreview(_controller!),
          ),
        ),
        Positioned(
          bottom: 12,
          left: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Sign: ${widget.targetSign}',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        if (_lastDetected != null)
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC71),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Detected: $_lastDetected ✓',
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}