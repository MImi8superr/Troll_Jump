# Troll Dash

A shape-based troll platformer built with Flutter: 29 hand-crafted levels of
reactive traps that learn your habits and use them against you.

Everything in the game is original work developed in this repository:

- **All gameplay art is drawn in code** (`CustomPainter`) — there are no
  image assets for the game itself; the app icons are rendered
  programmatically from the same design language.
- **All sound effects are synthesized** by script (see the commit history)
  — no third-party audio assets.
- **The engine and every trap class are hand-written** here, in the open,
  across the project's pull-request history: coyote time, variable jump
  height, quantum world-swapping, a movement echo, darkness zones, ice,
  reversed controls, and more.

## Running

```bash
flutter pub get
flutter run
```

Keyboard (desktop/web): arrows / WASD to move, Space/W/Up to jump
(hold for a higher jump), R to restart. On touch devices use the
on-screen controls. The game plays in landscape.

## Testing

```bash
flutter analyze
flutter test
```

The suite covers trap behavior, level-data invariants (every checkpoint
respawn stands on solid ground, goals stay in bounds, ids are unique),
the coin economy, and rendering regressions.
