import 'package:flutter/material.dart';

import 'game/level_progress.dart';
import 'screens/fake_win_screen.dart';
import 'screens/game_screen.dart';
import 'screens/level_select_screen.dart';
import 'screens/main_menu.dart';
import 'screens/shop_screen.dart';
import 'screens/win_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LevelProgress.load();
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
      onGenerateRoute: (settings) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) {
            switch (settings.name) {
              case '/game':
                final initialLevelIndex = settings.arguments is int
                    ? settings.arguments as int
                    : 0;
                return GameScreen(initialLevelIndex: initialLevelIndex);
              case '/levels':
                return const LevelSelectScreen();
              case '/shop':
                return const ShopScreen();
              case '/fakewin':
                return const FakeWinScreen();
              case '/win':
                return const WinScreen();
              case '/':
              default:
                return const MainMenu();
            }
          },
        );
      },
    );
  }
}
