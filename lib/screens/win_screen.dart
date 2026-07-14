import 'package:flutter/material.dart';

import '../game/game_stats.dart';

class WinScreen extends StatelessWidget {
  const WinScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  'You beat Troll Dash!',
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
                const SizedBox(height: 10),
                Text(
                  'Total deaths: ${GameStats.totalDeaths}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF65A30D),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Ein Spiel von Mias Ehrensperger',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF14532D),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/game');
                      },
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Play Again'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil('/', (_) => false);
                      },
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
}
