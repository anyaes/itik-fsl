import 'package:flutter/material.dart';

import '../services/supabase_service.dart';

class SupabaseImage extends StatelessWidget {
  const SupabaseImage({
    super.key,
    required this.path,
    this.bucket = SupabaseService.mediaBucket,
    this.isPrivate = false,
    this.fit = BoxFit.cover,
    this.borderRadius = 16,
    this.height,
  });

  final String path;
  final String bucket;
  final bool isPrivate;
  final BoxFit fit;
  final double borderRadius;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final service = SupabaseService();
    return FutureBuilder<String>(
      future: service.createMediaUrl(
        path,
        bucket: bucket,
        isPrivate: isPrivate,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint('Supabase image URL failed: ${snapshot.error}');
          return _placeholder(
            Icons.broken_image_outlined,
            message: 'Image unavailable',
          );
        }
        if (!snapshot.hasData) {
          return _placeholder(Icons.image_outlined, loading: true);
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.network(
            snapshot.data!,
            height: height,
            width: double.infinity,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Supabase image load failed: $error');
              return _placeholder(
                Icons.broken_image_outlined,
                message: 'Image unavailable',
              );
            },
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return _placeholder(Icons.image_outlined, loading: true);
            },
          ),
        );
      },
    );
  }

  Widget _placeholder(IconData icon, {bool loading = false, String? message}) {
    return Container(
      height: height ?? 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4F5),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 40, color: const Color(0xFF1EADC3)),
                  if (message != null) ...[
                    const SizedBox(height: 8),
                    Text(message),
                  ],
                ],
              ),
      ),
    );
  }
}
