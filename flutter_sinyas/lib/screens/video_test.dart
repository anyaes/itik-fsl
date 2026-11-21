import 'package:flutter/material.dart';
import 'package:flutter_sinyas/services/supabase_service.dart';
import 'package:flutter_sinyas/widgets/video_player.dart';

class VideoTestScreen extends StatelessWidget {
  const VideoTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video test')),
      body: Center(
        child: VideoContainer(
          bucketName: SupabaseService.mediaBucket,
          filePath: 'videos/h2h_1.mp4', // path inside the bucket
          maxWidth: 400,
          autoPlay: true,
        ),
      ),
    );
  }
}