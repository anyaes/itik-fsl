import 'package:flutter/material.dart';

import '../models/course.dart';
import '../services/supabase_service.dart';
import '../widgets/choice_style_card.dart';
import '../widgets/decorative_panel.dart';

class TracksScreen extends StatefulWidget {
  const TracksScreen({super.key});

  @override
  State<TracksScreen> createState() => _TracksScreenState();
}

class _TracksScreenState extends State<TracksScreen> {
  final SupabaseService _service = SupabaseService();
  late Future<List<LearningTrack>> _tracks;

  @override
  void initState() {
    super.initState();
    _tracks = _service.fetchTracks();
  }

  void _reload() {
    setState(() => _tracks = _service.fetchTracks());
  }

  @override
  Widget build(BuildContext context) {
    return _PageFrame(
      title: 'Tracks',
      subtitle: 'Choose a learning path and continue at your pace.',
      headerAction: TextButton.icon(
        onPressed: () => Navigator.of(context).pushNamed('/quiz-demo'),
        icon: const Icon(Icons.preview_outlined),
        label: const Text('Preview'),
      ),
      onRefresh: _reload,
      child: FutureBuilder<List<LearningTrack>>(
        future: _tracks,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _LoadError(
              message: snapshot.error.toString(),
              onRetry: _reload,
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.isEmpty) {
            return const _EmptyState(
              icon: Icons.route_rounded,
              title: 'No tracks yet',
              message:
                  'Add tracks to the Track table in Supabase to see them here.',
            );
          }

          return Column(
            children: [
              for (final track in snapshot.data!)
                _TrackDrawer(track: track, service: _service),
            ],
          );
        },
      ),
    );
  }
}

class _TrackDrawer extends StatefulWidget {
  const _TrackDrawer({required this.track, required this.service});

  final LearningTrack track;
  final SupabaseService service;

  @override
  State<_TrackDrawer> createState() => _TrackDrawerState();
}

class _TrackDrawerState extends State<_TrackDrawer> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          ChoiceStyleCard(
            isSelected: _isExpanded,
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Icon(
                  Icons.sign_language_rounded,
                  size: 32,
                  color: _isExpanded ? Colors.white : const Color(0xFF1EADC3),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.track.name,
                        style: TextStyle(
                          color: _isExpanded
                              ? Colors.white
                              : const Color(0xFF002247),
                          fontSize: 28,
                          height: 1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.track.description.isNotEmpty)
                        Text(
                          widget.track.description,
                          style: TextStyle(
                            color: _isExpanded
                                ? Colors.white
                                : const Color(0xFF526D76),
                            fontSize: 18,
                            height: 1.1,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: _isExpanded ? Colors.white : const Color(0xFF002247),
                  size: 30,
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            alignment: Alignment.topCenter,
            child: _isExpanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 12, left: 12, right: 4),
                    child: _UnitsList(
                      track: widget.track,
                      service: widget.service,
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _UnitsList extends StatefulWidget {
  const _UnitsList({required this.track, required this.service});

  final LearningTrack track;
  final SupabaseService service;

  @override
  State<_UnitsList> createState() => _UnitsListState();
}

class _UnitsListState extends State<_UnitsList> {
  late Future<List<LearningUnit>> _units;

  @override
  void initState() {
    super.initState();
    _units = widget.service.fetchUnits(widget.track.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LearningUnit>>(
      future: _units,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return DecorativePanel(
            child: Text('Could not load units: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData) {
          return const DecorativePanel(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data!.isEmpty) {
          return const DecorativePanel(
            child: Text('No units in this track yet.'),
          );
        }
        return Column(
          children: [
            for (final unit in snapshot.data!)
              _UnitDrawer(unit: unit, service: widget.service),
          ],
        );
      },
    );
  }
}

class _UnitDrawer extends StatefulWidget {
  const _UnitDrawer({required this.unit, required this.service});

  final LearningUnit unit;
  final SupabaseService service;

  @override
  State<_UnitDrawer> createState() => _UnitDrawerState();
}

class _UnitDrawerState extends State<_UnitDrawer> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          ChoiceStyleCard(
            isSelected: _isExpanded,
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  color: _isExpanded ? Colors.white : const Color(0xFF1EADC3),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.unit.name,
                    style: TextStyle(
                      color: _isExpanded
                          ? Colors.white
                          : const Color(0xFF002247),
                      fontSize: 24,
                      height: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: _isExpanded ? Colors.white : const Color(0xFF002247),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            alignment: Alignment.topCenter,
            child: _isExpanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 10, left: 10),
                    child: _LessonsList(
                      unit: widget.unit,
                      service: widget.service,
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _LessonsList extends StatefulWidget {
  const _LessonsList({required this.unit, required this.service});

  final LearningUnit unit;
  final SupabaseService service;

  @override
  State<_LessonsList> createState() => _LessonsListState();
}

class _LessonsListState extends State<_LessonsList> {
  late Future<List<LearningLesson>> _lessons;

  @override
  void initState() {
    super.initState();
    _lessons = widget.service.fetchLessons(widget.unit.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LearningLesson>>(
      future: _lessons,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return DecorativePanel(
            child: Text('Could not load lessons: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData) {
          return const DecorativePanel(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data!.isEmpty) {
          return const DecorativePanel(
            child: Text('No lessons in this unit yet.'),
          );
        }
        return DecorativePanel(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              for (final lesson in snapshot.data!)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ChoiceStyleCard(
                    isSelected: false,
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        '/quiz',
                        arguments: {
                          'lessonId': lesson.id,
                          'lessonName': lesson.name,
                        },
                      );
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.play_circle_outline_rounded,
                          color: Color(0xFF1EADC3),
                          size: 26,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lesson.name,
                                style: const TextStyle(
                                  color: Color(0xFF002247),
                                  fontSize: 22,
                                  height: 1,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                lesson.type,
                                style: const TextStyle(
                                  color: Color(0xFF526D76),
                                  fontSize: 17,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFF002247),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PageFrame extends StatelessWidget {
  const _PageFrame({
    required this.title,
    required this.subtitle,
    required this.child,
    this.headerAction,
    this.onRefresh,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? headerAction;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF4FAFB),
      child: RefreshIndicator(
        onRefresh: () async => onRefresh?.call(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Color(0xFF002247),
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ?headerAction,
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF526D76),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 24),
                  child,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return DecorativePanel(
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 36, color: Colors.red),
          const SizedBox(height: 8),
          const Text('Could not load Supabase data'),
          const SizedBox(height: 4),
          Text(message, textAlign: TextAlign.center),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return DecorativePanel(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Icon(icon, size: 48, color: const Color(0xFF1EADC3)),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
