import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/sign.dart';
import 'downloaded_media.dart';
import 'supabase_service.dart';

const supportsOfflineDownloads = true;

Future<Directory> _downloadDirectory() async {
  final documents = await getApplicationDocumentsDirectory();
  final directory = Directory(
    '${documents.path}${Platform.pathSeparator}downloads',
  );
  await directory.create(recursive: true);
  return directory;
}

Future<DownloadedMedia> downloadSignMedia(
  Sign sign, {
  required bool video,
}) async {
  final path = video ? sign.videoPath : sign.photoPath;
  if (path == null || path.trim().isEmpty) {
    throw StateError(
      'No ${video ? 'video' : 'photo'} is configured for ${sign.name}.',
    );
  }

  final bytes = await SupabaseService().downloadMedia(path);
  final extension = path.split('.').last.toLowerCase().split('?').first;
  final safeExtension = RegExp(r'^[a-z0-9]{2,5}$').hasMatch(extension)
      ? extension
      : (video ? 'mp4' : 'jpg');
  final directory = await _downloadDirectory();
  final file = File(
    '${directory.path}${Platform.pathSeparator}${sign.id}_${video ? 'video' : 'photo'}.$safeExtension',
  );
  await file.writeAsBytes(bytes, flush: true);
  return DownloadedMedia(
    handle: file,
    name: file.uri.pathSegments.last,
    sizeBytes: bytes.length,
  );
}

Future<List<DownloadedMedia>> listDownloadedMedia() async {
  final directory = await _downloadDirectory();
  final items = <DownloadedMedia>[];
  await for (final entity in directory.list(followLinks: false)) {
    if (entity is File) {
      items.add(
        DownloadedMedia(
          handle: entity,
          name: entity.uri.pathSegments.last,
          sizeBytes: await entity.length(),
        ),
      );
    }
  }
  items.sort((a, b) {
    final first = (a.handle as File).lastModifiedSync();
    final second = (b.handle as File).lastModifiedSync();
    return second.compareTo(first);
  });
  return items;
}

Future<void> deleteDownloadedMedia(DownloadedMedia item) {
  final file = item.handle;
  if (file is! File) {
    throw ArgumentError.value(item, 'item', 'Not an app-local file');
  }
  return file.delete();
}
