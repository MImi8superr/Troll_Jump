/// Session-wide gameplay statistics.
///
/// Troll games live on their death count, so the total is carried across
/// levels and screens (win screen, fake win screen) for the current app run.
class GameStats {
  GameStats._();

  static int totalDeaths = 0;
}
