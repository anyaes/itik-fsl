class Sign {
  final int id;
  final String name;
  final String? videoPath;
  final String? photoPath;
  final String? category;
  final List<int> similarSignIds;
  final bool isCameraSupported;
  final int mistakeCount;

  Sign({
    required this.id,
    required this.name,
    this.videoPath,
    this.photoPath,
    this.category,
    this.similarSignIds = const [],
    this.isCameraSupported = true,
    this.mistakeCount = 0,
  });

  // Converts a raw JSON map from Supabase into a Dart Sign object
  factory Sign.fromJson(Map<String, dynamic> json) {
    return Sign(
      id: (json['sign_id'] as num).toInt(),
      name: json['sign_name'] as String,
      videoPath: json['video_path'] as String?,
      photoPath: json['photo_path'] as String?,
      category: json['category'] as String?,
      similarSignIds: (json['similar_sign_ids'] as List<dynamic>? ?? [])
          .map((id) => (id as num).toInt())
          .toList(),
      isCameraSupported: json['is_camera_supported'] as bool? ?? true,
      mistakeCount: (json['mistake_count'] as num?)?.toInt() ?? 0,
    );
  }
}
