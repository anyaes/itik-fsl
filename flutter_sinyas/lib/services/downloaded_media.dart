class DownloadedMedia {
  const DownloadedMedia({
    required this.handle,
    required this.name,
    required this.sizeBytes,
  });

  final Object handle;
  final String name;
  final int sizeBytes;
}
