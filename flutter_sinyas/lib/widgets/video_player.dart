import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../services/supabase_service.dart';

class VideoContainer extends StatefulWidget {
  final String bucketName;
  final String filePath;
  final bool isPrivate;
  final double borderRadius;
  final double maxWidth;
  final double? customAspectRatio; // Optional: force 16/9, 9/16, etc.
  final bool autoPlay;
  final bool looping;

  const VideoContainer({
    super.key,
    required this.bucketName,
    required this.filePath,
    this.isPrivate = false,
    this.borderRadius = 16,
    this.maxWidth = 700, // Prevents oversized video on tablets/web
    this.customAspectRatio,
    this.autoPlay = true,
    this.looping = true,
  });

  @override
  State<VideoContainer> createState() => _VideoContainerState();
}

class _VideoContainerState extends State<VideoContainer> {
  VideoPlayerController? _controller;
  bool _hasError = false;
  bool _isMuted = false;
  bool _isLoading = true;
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _initSupabaseVideo();
  }

  @override
  void didUpdateWidget(covariant VideoContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bucketName != widget.bucketName ||
        oldWidget.filePath != widget.filePath ||
        oldWidget.isPrivate != widget.isPrivate) {
      _disposeController();
      _initSupabaseVideo();
    } else if (oldWidget.autoPlay != widget.autoPlay &&
        _controller?.value.isInitialized == true) {
      if (widget.autoPlay) {
        _controller!.play();
      } else {
        _controller!.pause();
      }
    }
  }

  Future<void> _initSupabaseVideo() async {
    setState(() {
      _hasError = false;
      _isLoading = true;
    });

    final generation = ++_loadGeneration;
    try {
      final videoUrl = await SupabaseService().createMediaUrl(
        widget.filePath,
        bucket: widget.bucketName,
        isPrivate: widget.isPrivate,
      );

      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await controller.initialize();

      if (!mounted || generation != _loadGeneration) {
        controller.dispose();
        return;
      }

      controller.setLooping(widget.looping);
      if (widget.autoPlay) {
        await controller.play();
      }

      setState(() {
        _controller = controller;
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('Supabase video load failed: $error\n$stackTrace');
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _disposeController() {
    final controller = _controller;
    _controller = null;
    controller?.dispose();
  }

  void _togglePlayPause() {
    if (_controller == null || !_controller!.value.isInitialized) return;
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
  }

  void _toggleMute() {
    if (_controller == null || !_controller!.value.isInitialized) return;
    setState(() {
      _isMuted = !_isMuted;
      _controller!.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  @override
  void dispose() {
    _loadGeneration++;
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double activeAspectRatio =
        widget.customAspectRatio ??
        (_controller != null && _controller!.value.isInitialized
            ? _controller!.value.aspectRatio
            : 16 / 9);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.maxWidth),
        child: AspectRatio(
          aspectRatio: activeAspectRatio,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: _buildVideoContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (_hasError) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.redAccent, size: 32),
              SizedBox(height: 8),
              Text(
                'Video could not be loaded. Check the Storage path and access policy.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return Center(
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Video is unavailable.',
                style: TextStyle(color: Colors.white),
              ),
      );
    }

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),

          if (!_controller!.value.isPlaying)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),

          Positioned(
            bottom: 8,
            right: 8,
            child: GestureDetector(
              onTap: _toggleMute,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
