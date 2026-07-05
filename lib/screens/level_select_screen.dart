import 'package:flutter/material.dart';

import '../game/level_progress.dart';
import '../game/levels.dart';
import '../game/models.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  // Built once per screen instead of on every rebuild of the reactive body.
  late final List<Level> _levels = buildLevels();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F4FF),
      appBar: AppBar(
        title: const Text('Level-Auswahl'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ValueListenableBuilder<int>(
          valueListenable: LevelProgress.highestUnlockedLevel,
          builder: (context, highestUnlocked, _) {
            return Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Freigeschaltet: Level $highestUnlocked von ${_levels.length}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      // A fixed tile height (mainAxisExtent) keeps the icon +
                      // two-line title from overflowing on small phones, while
                      // maxCrossAxisExtent adapts the column count to the width.
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 170,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        mainAxisExtent: 134,
                      ),
                      itemCount: _levels.length,
                      itemBuilder: (context, index) {
                        final level = _levels[index];
                        final unlocked = LevelProgress.isUnlocked(level.number);
                        return _LevelTile(
                          number: level.number,
                          title: level.title,
                          unlocked: unlocked,
                          onTap: unlocked
                              ? () => Navigator.of(context).pushNamed(
                                    '/game',
                                    arguments: index,
                                  )
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.number,
    required this.title,
    required this.unlocked,
    required this.onTap,
  });

  final int number;
  final String title;
  final bool unlocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final background = unlocked ? Colors.white : const Color(0xFFCBD5E1);
    final foreground =
        unlocked ? const Color(0xFF0F172A) : const Color(0xFF64748B);

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(18),
      elevation: unlocked ? 4 : 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                unlocked ? Icons.play_circle_fill_rounded : Icons.lock_rounded,
                color: unlocked ? const Color(0xFF2563EB) : foreground,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Level $number',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: foreground,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
