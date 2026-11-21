class LearningTrack {
  const LearningTrack({
    required this.id,
    required this.name,
    required this.description,
  });

  final int id;
  final String name;
  final String description;

  factory LearningTrack.fromJson(Map<String, dynamic> json) {
    return LearningTrack(
      id: (json['track_id'] as num).toInt(),
      name: json['track_name'] as String,
      description: json['track_desc'] as String? ?? '',
    );
  }
}

class LearningUnit {
  const LearningUnit({
    required this.id,
    required this.trackId,
    required this.name,
    required this.order,
  });

  final int id;
  final int trackId;
  final String name;
  final int order;

  factory LearningUnit.fromJson(Map<String, dynamic> json) {
    return LearningUnit(
      id: (json['unit_id'] as num).toInt(),
      trackId: (json['track_id'] as num).toInt(),
      name: json['unit_name'] as String,
      order: (json['order_index'] as num).toInt(),
    );
  }
}

class LearningLesson {
  const LearningLesson({
    required this.id,
    required this.unitId,
    required this.name,
    required this.type,
    required this.order,
  });

  final int id;
  final int unitId;
  final String name;
  final String type;
  final int order;

  factory LearningLesson.fromJson(Map<String, dynamic> json) {
    return LearningLesson(
      id: (json['lesson_id'] as num).toInt(),
      unitId: (json['unit_id'] as num).toInt(),
      name: json['lesson_name'] as String,
      type: json['lesson_type']?.toString() ?? 'lesson',
      order: (json['order_index'] as num).toInt(),
    );
  }
}
