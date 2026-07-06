import 'package:flutter/material.dart';

import '../game/game_stats.dart';

/// Looks exactly like the real win screen — until the player presses any
/// button, at which point the trolls admit there are two more levels.
class FakeWinScreen extends StatefulWidget {
  const FakeWinScreen({super.key});

  @override
  State<FakeWinScreen> createState() => _FakeWinScreenState();
}

class _FakeWinScreenState extends State<FakeWinScreen> {
  bool _revealed = false;

  void _reveal() {
    setState(() => _revealed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_revealed) {
      // Phase 1: a pixel-perfect copy of the real win screen. Every button
      // is bait.
      return Scaffold(
        backgroundColor: const Color(0xFFF7FEE7),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.flag_rounded,
                    size: 84,
                    color: Color(0xFF16A34A),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'You beat Troll Runner!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF14532D),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Every trap has been baited, dodged, or politely ignored.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3F6212),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    alignment: WrapAlignment.center,
                    children: [
                      FilledButton.icon(
                        onPressed: _reveal,
                        icon: const Icon(Icons.replay_rounded),
                        label: const Text('Play Again'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _reveal,
                        icon: const Icon(Icons.home_rounded),
                        label: const Text('Menu'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Phase 2: the trolls come clean.
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.sentiment_very_satisfied_rounded,
                  size: 84,
                  color: Color(0xFFA855F7),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Just kidding!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'The trolls built eight more levels while you were celebrating.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Deaths so far: ${GameStats.totalDeaths}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 30),
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed(
                          '/game',
                          arguments: 15,
                        );
                      },
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Level 16'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil('/', (_) => false);
                      },
                      icon: const Icon(Icons.home_rounded),
                      label: const Text('Menu (for real)'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
