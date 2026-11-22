import 'package:flutter/material.dart';
import 'package:flutter_sinyas/widgets/choice_style_card.dart';
import 'package:flutter_sinyas/services/supabase_service.dart';
import 'package:flutter_sinyas/models/course.dart';

/*
  Lessons page is what renders on the Lessons tab.
  This includes the nodes, side panel, etc.

  They load from db
*/

const _navy = Color(0xFF002247);
const _teal = Color(0xFF1EADC3);
const _pageBackground = Color(0xFFF4FAFB);

class LessonsPage extends StatefulWidget {
  const LessonsPage({super.key, required this.onTracksSelected});

  final VoidCallback onTracksSelected;

  @override
  State<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage> {
  final SupabaseService _service = SupabaseService();
  List<_PathLesson> _lessons = [];
  bool _isLoading = true;

  static const _navy = Color(0xFF002247);
  static const _teal = Color(0xFF1EADC3);
  static const _pageBackground = Color(0xFFF4FAFB);

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    try {
      final tracks = await _service.fetchTracks();
      if (tracks.isEmpty) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        return;
      }

      final units = await _service.fetchUnits(tracks.first.id);
      if (units.isEmpty) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        return;
      }

      final lessons = await _service.fetchLessons(units.first.id);
      if (!mounted) return;
      setState(() {
        _lessons = lessons
            .map(
              (l) => _PathLesson(
                title: l.name,
                icon: _iconFor(l.name),
                lessonId: l.id,
                isUnlocked: true,
                isComplete: false,
              ),
            )
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  IconData _iconFor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('hand') || lower.contains('shape')) {
      return Icons.back_hand_rounded;
    }
    if (lower.contains('greet') || lower.contains('wave')) {
      return Icons.waving_hand_rounded;
    }
    if (lower.contains('introduce') || lower.contains('yourself')) {
      return Icons.person_rounded;
    }
    if (lower.contains('phrase') || lower.contains('everyday')) {
      return Icons.chat_bubble_rounded;
    }
    if (lower.contains('review') || lower.contains('unit')) {
      return Icons.emoji_events_rounded;
    }
    return Icons.class_rounded;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return ColoredBox(
        color: _pageBackground,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return ColoredBox(
      color: _pageBackground,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return _buildMobilePage(context);
          }

          final wide = constraints.maxWidth >= 980;
          final compact = constraints.maxWidth < 720;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 18 : 32,
              vertical: compact ? 20 : 28,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildLearningPath(compact)),
                          const SizedBox(width: 28),
                          SizedBox(
                            width: 290,
                            child: _ToolsRail(
                              showStats: true,
                              onToolSelected: (feature) =>
                                  _showToolNotice(context, feature),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildLearningPath(compact),
                          const SizedBox(height: 28),
                          _ToolsRail(
                            onToolSelected: (feature) =>
                                _showToolNotice(context, feature),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobilePage(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _PinnedHeaderDelegate(
            height: 56,
            child: const _MobileStatsBar(),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _PinnedHeaderDelegate(
            height: 120,
            child: _CompactUnitCard(onTap: widget.onTracksSelected),
            backgroundColor: Colors.transparent,
            drawShadow: false,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            child: Column(
              children: [
                _LessonPath(lessons: _lessons, nodeSize: 78),
                const SizedBox(height: 24),
                _ToolsRail(
                  onToolSelected: (feature) =>
                      _showToolNotice(context, feature),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLearningPath(bool compact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Learning path',
          style: TextStyle(
            color: _navy,
            fontSize: compact ? 40 : 60,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Small steps make confident signing.',
          style: TextStyle(
            color: _navy.withValues(alpha: 0.65),
            fontSize: compact ? 20 : 23,
          ),
        ),
        const SizedBox(height: 24),
        _UnitCard(onTap: widget.onTracksSelected),
        const SizedBox(height: 24),
        Text(
          'Your path',
          style: TextStyle(
            color: _navy,
            fontSize: compact ? 27 : 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap an available lesson to preview it.',
          style: TextStyle(color: _navy.withValues(alpha: 0.65), fontSize: 19),
        ),
        const SizedBox(height: 16),
        _LessonPath(lessons: _lessons),
      ],
    );
  }

  void _showToolNotice(BuildContext context, String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature will be available soon.')));
  }

  void _showLessonPreview(BuildContext context, _PathLesson lesson) {
    Navigator.of(context).pushNamed(
      '/quiz',
      arguments: {
        'lessonId': lesson.lessonId,
        'lessonName': lesson.title,
      },
    );
  }
}

class _WideStatsBar extends StatelessWidget {
  const _WideStatsBar();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _WideStat(
          icon: Icons.local_fire_department_rounded,
          value: '3',
          color: Color(0xFF64777C),
        ),
        _WideStat(
          icon: Icons.diamond_rounded,
          value: '120',
          color: Color(0xFF22B8F0),
        ),
        _WideStat(
          icon: Icons.favorite_rounded,
          value: '5',
          color: Color(0xFFFF5B6E),
        ),
      ],
    );
  }
}

class _WideStat extends StatelessWidget {
  const _WideStat({
    required this.icon,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 23, color: color),
        const SizedBox(width: 7),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _PinnedHeaderDelegate({
    required this.height,
    required this.child,
    this.backgroundColor = Colors.white,
    this.drawShadow = true,
  });

  final double height;
  final Widget child;
  final Color backgroundColor;
  final bool drawShadow;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: backgroundColor,
      elevation: drawShadow && overlapsContent ? 2 : 0,
      child: SizedBox.expand(child: child),
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) {
    return oldDelegate.height != height ||
        oldDelegate.child != child ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.drawShadow != drawShadow;
  }
}

class _MobileStatsBar extends StatelessWidget {
  const _MobileStatsBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFDCEBED))),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _MobileStat(
            icon: Icons.local_fire_department_rounded,
            value: '3',
            color: Color(0xFFFF9F43),
          ),
          _MobileStat(
            icon: Icons.bolt_rounded,
            value: '120',
            color: Color(0xFF4299E1),
          ),
          _MobileStat(
            icon: Icons.favorite_rounded,
            value: '5',
            color: Color(0xFFE85D75),
          ),
        ],
      ),
    );
  }
}

class _MobileStat extends StatelessWidget {
  const _MobileStat({
    required this.icon,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: _navy,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _CompactUnitCard extends StatelessWidget {
  const _CompactUnitCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ChoiceStyleCard(
        isSelected: true,
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'UNIT 1  •  FOUNDATIONS',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 20,
                      height: 1.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4,
                    ),
                  ),
                  Text(
                    'Greetings and introductions',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      height: 1.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 42,
              height: 42,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: 0.2,
                    strokeWidth: 4,
                    backgroundColor: Colors.white30,
                    color: Colors.white,
                  ),
                  const Text(
                    '1/5',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  const _UnitCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceStyleCard(
      isSelected: true,
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UNIT 1  •  FOUNDATIONS',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 24,
                    height: 1.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.7,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Greetings and introductions',
                  style: TextStyle(
                    color: Colors.white,
                    height: 1.0,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Learn your first everyday signs',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 58,
            height: 58,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: 0.2,
                  strokeWidth: 6,
                  backgroundColor: Colors.white30,
                  color: Colors.white,
                ),
                const Text(
                  '1/5',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolsRail extends StatelessWidget {
  const _ToolsRail({required this.onToolSelected, this.showStats = false});

  final ValueChanged<String> onToolSelected;
  final bool showStats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showStats) ...[const _WideStatsBar(), const SizedBox(height: 14)],
        _InfoCard(
          icon: Icons.emoji_events_rounded,
          title: 'Learning milestones',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Complete 3 lessons to unlock the community board.',
                style: TextStyle(color: _navy, fontSize: 18),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: const LinearProgressIndicator(
                  value: 0.33,
                  minHeight: 8,
                  color: _teal,
                  backgroundColor: Color(0xFFE3EFF0),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '1 of 3 lessons',
                style: TextStyle(
                  color: _navy.withValues(alpha: 0.6),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _InfoCard(
          icon: Icons.flag_rounded,
          title: 'Daily practice goal',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.bolt_rounded, color: Color(0xFFFFA726)),
                  SizedBox(width: 8),
                  Text(
                    '40 / 100 XP',
                    style: TextStyle(
                      color: _navy,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: const LinearProgressIndicator(
                  value: 0.4,
                  minHeight: 8,
                  color: Color(0xFFFFA726),
                  backgroundColor: Color(0xFFE3EFF0),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => onToolSelected('Daily goals'),
                  child: const Text('VIEW GOALS',
                    style: TextStyle(
                      fontFamily: 'Dongle',
                      fontSize: 24,
                      height: 2
                    )
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _InfoCard(
          icon: Icons.auto_awesome_rounded,
          title: 'Practice tools',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                onPressed: () => onToolSelected('Sign guide'),
                icon: const Icon(Icons.menu_book_rounded),
                label: const Text('Sign guide',
                style: TextStyle(
                      fontFamily: 'Dongle',
                      fontSize: 24,
                      height: 2
                    )),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => onToolSelected('Camera practice'),
                icon: const Icon(Icons.camera_alt_rounded),
                label: const Text('Camera practice',
                style: TextStyle(
                      fontFamily: 'Dongle',
                      fontSize: 24,
                      height: 2
                    )),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCEBED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _teal, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 20,
                    fontFamily: 'Dongle',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _LessonPath extends StatelessWidget {
  const _LessonPath({required this.lessons, this.nodeSize = 70});

  final List<_PathLesson> lessons;
  final double nodeSize;

  static const _itemSpacing = 132.0;
  static const _leftPosition = 0.34;
  static const _rightPosition = 0.66;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = lessons.length * _itemSpacing;
        final positions = List.generate(
          lessons.length,
          (index) => width * (index.isEven ? _leftPosition : _rightPosition),
        );

        return SizedBox(
          height: height,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _LessonPathPainter(
                    nodePositions: positions,
                    itemSpacing: _itemSpacing,
                    nodeCenterOffset: nodeSize / 2 + 3,
                  ),
                ),
              ),
              for (var index = 0; index < lessons.length; index++)
                Positioned(
                  left: positions[index] - 62,
                  top: index * _itemSpacing + 3,
                  width: 124,
                  child: _LessonNode(
                    lesson: lessons[index],
                    size: nodeSize,
                    onTap: lessons[index].isUnlocked
                        ? () => _LessonPath._onTap(context, lessons[index])
                        : null,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  static void _onTap(BuildContext context, _PathLesson lesson) {
    Navigator.of(context).pushNamed(
      '/quiz',
      arguments: {
        'lessonId': lesson.lessonId,
        'lessonName': lesson.title,
      },
    );
  }
}

class _LessonNode extends StatelessWidget {
  const _LessonNode({
    required this.lesson,
    required this.onTap,
    required this.size,
  });

  final _PathLesson lesson;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final nodeColor = lesson.isComplete
        ? const Color(0xFF16899F)
        : lesson.isUnlocked
        ? _teal
        : const Color(0xFFB7C7CA);

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: nodeColor,
                border: Border.all(
                  color: lesson.isUnlocked
                      ? nodeColor.withValues(alpha: 0.3)
                      : const Color(0xFFE1E8E9),
                  width: 5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: nodeColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                lesson.isComplete
                    ? Icons.check_rounded
                    : lesson.isUnlocked
                    ? lesson.icon
                    : Icons.lock_rounded,
                color: Colors.white,
                size: size * 0.43,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          lesson.title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: lesson.isUnlocked
                ? _navy
                : _navy.withValues(alpha: 0.45),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _PathLesson {
  const _PathLesson({
    required this.title,
    required this.icon,
    required this.lessonId,
    this.isUnlocked = false,
    this.isComplete = false,
  });

  final String title;
  final IconData icon;
  final int lessonId;
  final bool isUnlocked;
  final bool isComplete;
}

class _LessonPathPainter extends CustomPainter {
  const _LessonPathPainter({
    required this.nodePositions,
    required this.itemSpacing,
    required this.nodeCenterOffset,
  });

  final List<double> nodePositions;
  final double itemSpacing;
  final double nodeCenterOffset;

  @override
  void paint(Canvas canvas, Size size) {
    if (nodePositions.length < 2) return;

    final paint = Paint()
      ..color = const Color(0xFFD5E7E9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;

    final path = Path()..moveTo(nodePositions.first, nodeCenterOffset);

    for (var index = 1; index < nodePositions.length; index++) {
      final previousY = (index - 1) * itemSpacing + nodeCenterOffset;
      final currentY = index * itemSpacing + nodeCenterOffset;
      path.quadraticBezierTo(
        size.width / 2,
        (previousY + currentY) / 2,
        nodePositions[index],
        currentY,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LessonPathPainter oldDelegate) {
    return oldDelegate.nodePositions != nodePositions ||
        oldDelegate.itemSpacing != itemSpacing ||
        oldDelegate.nodeCenterOffset != nodeCenterOffset;
  }
}