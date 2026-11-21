import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DemoVideoPreview extends StatelessWidget {
  const DemoVideoPreview({
    super.key,
    required this.videoUrl,
    this.aspectRatio = 16 / 9,
  });

  final String videoUrl;
  final double aspectRatio;

  Future<void> _openVideo(BuildContext context) async {
    final opened = await openDemoVideo(videoUrl);
    if (!opened) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the demo video link.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Tooltip(
        message: 'Open the official NMIXX video on YouTube',
        child: Material(
          color: const Color(0xFFFAFCFA),
          child: InkWell(
            onTap: () => _openVideo(context),
            child: Semantics(
              button: true,
              label: 'Open the official NMIXX DASH music video on YouTube',
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: Color(0xFFFAFCFA)),
                  const Center(
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Color(0xFF002247),
                      size: 54,
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 10,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: const LinearProgressIndicator(
                        value: 0.28,
                        minHeight: 5,
                        color: Color(0xFF24B5C5),
                        backgroundColor: Color(0xFFD8D8D8),
                      ),
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

Future<bool> openDemoVideo(String videoUrl) {
  return launchUrl(Uri.parse(videoUrl), mode: LaunchMode.externalApplication);
}
