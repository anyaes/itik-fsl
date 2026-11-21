import 'dart:io';

import 'package:flutter/material.dart';

import '../models/sign.dart';
import '../services/offline_media_service.dart';
import '../services/supabase_service.dart';
import '../widgets/decorative_panel.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  final SupabaseService _supabase = SupabaseService();
  final OfflineMediaService _offline = OfflineMediaService();
  late Future<List<Sign>> _signs;
  late Future<List<DownloadedMedia>> _downloads;
  final Set<String> _activeDownloads = {};

  @override
  void initState() {
    super.initState();
    _signs = _supabase.fetchAllSigns();
    _downloads = _offline.listDownloadedMedia();
  }

  Future<void> _refresh() async {
    setState(() {
      _signs = _supabase.fetchAllSigns();
      _downloads = _offline.listDownloadedMedia();
    });
    await Future.wait([_signs, _downloads]);
  }

  Future<void> _download(Sign sign, {required bool video}) async {
    final key = '${sign.id}_${video ? 'video' : 'photo'}';
    setState(() => _activeDownloads.add(key));
    try {
      await _offline.downloadSignMedia(sign, video: video);
      if (!mounted) return;
      setState(() => _downloads = _offline.listDownloadedMedia());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${sign.name} saved for offline use.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Download failed: $error')));
    } finally {
      if (mounted) setState(() => _activeDownloads.remove(key));
    }
  }

  Future<void> _delete(DownloadedMedia item) async {
    try {
      await _offline.delete(item);
      if (mounted) setState(() => _downloads = _offline.listDownloadedMedia());
    } on FileSystemException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not delete download: ${error.message}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final offlineSupported = _offline.isSupported;
    return ColoredBox(
      color: const Color(0xFFF4FAFB),
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Downloads',
                      style: TextStyle(
                        color: Color(0xFF002247),
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Save lesson media to this device for offline practice.',
                      style: TextStyle(color: Color(0xFF526D76), fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    DecorativePanel(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.phone_android,
                            color: Color(0xFF1EADC3),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              offlineSupported
                                  ? 'Downloads are stored in the app’s private files and are available here. They are not exported to the public Downloads folder.'
                                  : 'Offline downloads are supported on Android, iOS, Windows, macOS, and Linux. Browser downloads are not enabled.',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Supabase media',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF002247),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<List<Sign>>(
                      future: _signs,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return _ErrorCard(
                            message: snapshot.error.toString(),
                            onRetry: _refresh,
                          );
                        }
                        if (!snapshot.hasData) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (snapshot.data!.isEmpty) {
                          return const DecorativePanel(
                            padding: EdgeInsets.all(18),
                            child: Text(
                              'No signs found. Add demo rows and media paths using supabase/demo_seed.sql.',
                            ),
                          );
                        }
                        return Column(
                          children: [
                            for (final sign in snapshot.data!)
                              _SignDownloadCard(
                                sign: sign,
                                activeDownloads: _activeDownloads,
                                isSupported: offlineSupported,
                                onDownload: _download,
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Saved on this device',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF002247),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<List<DownloadedMedia>>(
                      future: _downloads,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return _ErrorCard(
                            message: snapshot.error.toString(),
                            onRetry: _refresh,
                          );
                        }
                        if (!snapshot.hasData) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (snapshot.data!.isEmpty) {
                          return const DecorativePanel(
                            padding: EdgeInsets.zero,
                            child: ListTile(
                              leading: Icon(Icons.folder_open_rounded),
                              title: Text('Nothing downloaded yet'),
                            ),
                          );
                        }
                        return DecorativePanel(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              for (final item in snapshot.data!)
                                ListTile(
                                  leading: Icon(
                                    item.name.endsWith('.mp4')
                                        ? Icons.movie_outlined
                                        : Icons.image_outlined,
                                    color: const Color(0xFF1EADC3),
                                  ),
                                  title: Text(item.name),
                                  subtitle: Text(_formatBytes(item.sizeBytes)),
                                  trailing: IconButton(
                                    tooltip: 'Delete download',
                                    onPressed: () => _delete(item),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _SignDownloadCard extends StatelessWidget {
  const _SignDownloadCard({
    required this.sign,
    required this.activeDownloads,
    required this.isSupported,
    required this.onDownload,
  });

  final Sign sign;
  final Set<String> activeDownloads;
  final bool isSupported;
  final Future<void> Function(Sign, {required bool video}) onDownload;

  @override
  Widget build(BuildContext context) {
    final videoKey = '${sign.id}_video';
    final photoKey = '${sign.id}_photo';
    return DecorativePanel(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sign.name,
            style: const TextStyle(
              color: Color(0xFF002247),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (sign.category != null) Text(sign.category!),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (sign.videoPath != null)
                OutlinedButton.icon(
                  onPressed: activeDownloads.contains(videoKey) || !isSupported
                      ? null
                      : () => onDownload(sign, video: true),
                  icon: activeDownloads.contains(videoKey)
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download_rounded),
                  label: const Text('Video'),
                ),
              if (sign.photoPath != null)
                OutlinedButton.icon(
                  onPressed: activeDownloads.contains(photoKey) || !isSupported
                      ? null
                      : () => onDownload(sign, video: false),
                  icon: activeDownloads.contains(photoKey)
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download_rounded),
                  label: const Text('Photo'),
                ),
              if (sign.videoPath == null && sign.photoPath == null)
                const Text('No media paths are set for this sign.'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return DecorativePanel(
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, color: Colors.red),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
