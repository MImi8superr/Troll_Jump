import 'package:flutter/material.dart';

import 'screens/game_screen.dart';
import 'screens/main_menu.dart';
import 'screens/win_screen.dart';

void main() {
  runApp(const TrollRunnerApp());
}

class TrollRunnerApp extends StatelessWidget {
  const TrollRunnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Troll Runner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      routes: {
        '/': (_) => const MainMenu(),
        '/game': (_) => const GameScreen(),
        '/win': (_) => const WinScreen(),
      },
    );
  }
}
