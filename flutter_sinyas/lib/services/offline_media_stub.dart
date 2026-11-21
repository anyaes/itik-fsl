import '../models/sign.dart';
import 'downloaded_media.dart';

const supportsOfflineDownloads = false;

Future<DownloadedMedia> downloadSignMedia(Sign sign, {required bool video}) {
  throw UnsupportedError(
    'Offline file downloads are supported on Android, iOS, Windows, macOS, and Linux.',
  );
}

Future<List<DownloadedMedia>> listDownloadedMedia() async => [];

Future<void> deleteDownloadedMedia(DownloadedMedia item) async {}
