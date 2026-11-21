import '../models/sign.dart';
import 'downloaded_media.dart';
import 'offline_media_stub.dart'
    if (dart.library.io) 'offline_media_io.dart'
    as platform;

export 'downloaded_media.dart';

class OfflineMediaService {
  bool get isSupported => platform.supportsOfflineDownloads;

  Future<DownloadedMedia> downloadSignMedia(Sign sign, {required bool video}) {
    return platform.downloadSignMedia(sign, video: video);
  }

  Future<List<DownloadedMedia>> listDownloadedMedia() {
    return platform.listDownloadedMedia();
  }

  Future<void> delete(DownloadedMedia item) {
    return platform.deleteDownloadedMedia(item);
  }
}
