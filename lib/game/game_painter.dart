import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'models.dart';

class GamePainter extends CustomPainter {
  GamePainter({
    required this.level,
    required this.player,
    required this.playerColor,
    required this.cameraX,
    this.particles = const [],
    this.deathProgress = 0,
    this.hidePlayer = false,
  });

  final Level level;
  final Player player;
  final Color playerColor;
  final double cameraX;

  /// Debris from the death effect, in world coordinates.
  final List<DeathParticle> particles;

  /// 1 at the moment of death, decaying to 0; drives the red screen tint.
  final double deathProgress;

  final bool hidePlayer;

  @override
  void paint(Canvas canvas, Size size) {
    // A zero (or negative) dimension makes scale 0 and visibleWorldWidth
    // infinite, which turns the background loop below into an infinite loop
    // and freezes the app. Reachable when the play area collapses on
    // resizable desktop/web windows.
    if (size.isEmpty) {
      return;
    }

    final scale = size.height / worldHeight;
    final visibleWorldWidth = size.width / scale;

    _drawBackground(canvas, size, visibleWorldWidth);
    _drawReverseZones(canvas, scale);
    _drawJumpPads(canvas, scale);
    _drawCoins(canvas, scale);
    _drawPlatforms(canvas, scale);
    _drawIceZones(canvas, scale);
    _drawCheckpoints(canvas, scale);
    _drawHazards(canvas, scale);
    _drawSpikes(canvas, scale);
    final decoy = level.decoyGoal;
    if (decoy != null) {
      _drawGoalFlag(canvas, scale, decoy);
    }
    _drawGoalFlag(canvas, scale, level.goal);
    if (!hidePlayer) {
      _drawPlayer(canvas, scale);
    }
    _drawParticles(canvas, scale);
    _drawDeathOverlay(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size, double visibleWorldWidth) {
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFBFE7FF), Color(0xFFEFF8FF)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sky);

    final hillPaint = Paint()..color = const Color(0xFFB7E4C7);
    final farOffset = -(cameraX * 0.18) % 360;
    for (var x = farOffset - 360; x < visibleWorldWidth + 720; x += 360) {
      final path = Path()
        ..moveTo(x, size.height)
        ..quadraticBezierTo(x + 180, size.height - 118, x + 360, size.height)
        ..close();
      canvas.drawPath(path, hillPaint);
    }

    final sun = Paint()..color = const Color(0xFFFBBF24);
    canvas.drawCircle(Offset(size.width - 58, 58), 24, sun);
  }

  void _drawReverseZones(Canvas canvas, double scale) {
    for (final zone in level.reverseZones) {
      if (!zone.revealed) {
        continue;
      }
      final rect = _toScreen(zone.rect, scale);
      final alpha = 0.14 + math.min(0.2, zone.flash * 0.3);
      final fill = Paint()
        ..color = const Color(0xFF9333EA).withValues(alpha: alpha);
      canvas.drawRect(rect, fill);
      final border = Paint()
        ..color = const Color(0xFF7E22CE).withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, 2 * scale);
      canvas.drawRect(rect, border);
    }
  }

  void _drawPlatforms(Canvas canvas, double scale) {
    for (final platform in level.platforms) {
      if (!platform.visible) {
        continue;
      }
      final rect = _toScreen(platform.rect, scale);
      final paint = Paint()
        ..color = _flash(
          platform.color,
          platform.flash,
          const Color(0xFFFFF176),
        );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(5 * scale)),
        paint,
      );

      if (platform.cracked) {
        final crack = Paint()
          ..color = const Color(0xFFCBD5E1)
          ..strokeWidth = math.max(1, 2 * scale)
          ..style = PaintingStyle.stroke;
        final y = rect.top + rect.height * 0.38;
        canvas.drawLine(
          Offset(rect.left + rect.width * 0.18, y),
          Offset(rect.left + rect.width * 0.38, rect.bottom - 5 * scale),
          crack,
        );
        canvas.drawLine(
          Offset(rect.left + rect.width * 0.56, rect.top + 4 * scale),
          Offset(rect.left + rect.width * 0.75, rect.bottom - 6 * scale),
          crack,
        );
      }
    }
  }

  void _drawIceZones(Canvas canvas, double scale) {
    for (final zone in level.iceZones) {
      final rect = _toScreen(zone.rect, scale);
      final sheet = Paint()
        ..color = const Color(0xFF7DD3FC).withValues(alpha: 0.6);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(4 * scale)),
        sheet,
      );
      // A couple of white sheen streaks so it reads as ice at a glance.
      final sheen = Paint()
        ..color = Colors.white.withValues(alpha: 0.7)
        ..strokeWidth = math.max(1, 1.5 * scale)
        ..strokeCap = StrokeCap.round;
      final y = rect.top + rect.height * 0.35;
      canvas.drawLine(
        Offset(rect.left + rect.width * 0.1, y),
        Offset(rect.left + rect.width * 0.22, y),
        sheen,
      );
      canvas.drawLine(
        Offset(rect.left + rect.width * 0.6, y),
        Offset(rect.left + rect.width * 0.78, y),
        sheen,
      );
    }
  }

  void _drawCheckpoints(Canvas canvas, double scale) {
    for (final checkpoint in level.checkpoints) {
      if (!checkpoint.visible) {
        continue;
      }
      final rect = _toScreen(checkpoint.rect, scale);
      final baseColor = checkpoint.reached
          ? const Color(0xFF16A34A)
          : const Color(0xFF94A3B8);
      final color = _flash(baseColor, checkpoint.flash, const Color(0xFFFFF176));

      final pole = Paint()..color = const Color(0xFF475569);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(rect.left, rect.top, 4 * scale, rect.height),
          Radius.circular(2 * scale),
        ),
        pole,
      );

      final pennant = Paint()..color = color;
      final path = Path()
        ..moveTo(rect.left + 4 * scale, rect.top + 3 * scale)
        ..lineTo(rect.left + 26 * scale, rect.top + 11 * scale)
        ..lineTo(rect.left + 4 * scale, rect.top + 19 * scale)
        ..close();
      canvas.drawPath(path, pennant);
    }
  }

  void _drawJumpPads(Canvas canvas, double scale) {
    for (final pad in level.jumpPads) {
      final rect = _toScreen(pad.rect, scale);
      final paint = Paint()
        ..color = _flash(
          const Color(0xFF9333EA),
          pad.flash,
          const Color(0xFFFFF176),
        );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(7 * scale)),
        paint,
      );
      final stripe = Paint()
        ..color = const Color(0xFFE9D5FF)
        ..strokeWidth = math.max(1, 2 * scale);
      canvas.drawLine(
        Offset(rect.left + 8 * scale, rect.center.dy),
        Offset(rect.right - 8 * scale, rect.center.dy),
        stripe,
      );
    }
  }

  void _drawCoins(Canvas canvas, double scale) {
    for (final coin in level.coins) {
      if (coin.collected) {
        continue;
      }
      final rect = _toScreen(coin.rect, scale);
      final center = rect.center;
      final squash = 0.68 + math.cos(coin.spin).abs() * 0.32;
      final coinRect = Rect.fromCenter(
        center: center,
        width: rect.width * squash,
        height: rect.height,
      );
      final paint = Paint()..color = const Color(0xFFFACC15);
      canvas.drawOval(coinRect, paint);
      final edge = Paint()
        ..color = const Color(0xFFB45309)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, 2 * scale);
      canvas.drawOval(coinRect, edge);
      final sparkle = Paint()..color = const Color(0xBFFFFFFF);
      canvas.drawCircle(
        Offset(center.dx - rect.width * 0.18, center.dy - rect.height * 0.18),
        math.max(1.2, 2.6 * scale),
        sparkle,
      );
    }
  }

  void _drawHazards(Canvas canvas, double scale) {
    for (final hazard in level.hazards) {
      if (!hazard.visible) {
        continue;
      }
      final rect = _toScreen(hazard.rect, scale);
      final paint = Paint()
        ..color = _flash(
          const Color(0xFF263238),
          hazard.flash,
          const Color(0xFFEF4444),
        );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(4 * scale)),
        paint,
      );
    }
  }

  void _drawSpikes(Canvas canvas, double scale) {
    for (final spike in level.spikes) {
      if (!spike.visible) {
        continue;
      }
      final rect = _toScreen(spike.rect, scale);
      final paint = Paint()
        ..color = _flash(
          const Color(0xFFEF4444),
          spike.flash,
          const Color(0xFFFFF176),
        );
      final path = Path();
      if (spike.direction == SpikeDirection.up) {
        path
          ..moveTo(rect.left, rect.bottom)
          ..lineTo(rect.center.dx, rect.top)
          ..lineTo(rect.right, rect.bottom);
      } else {
        path
          ..moveTo(rect.left, rect.top)
          ..lineTo(rect.center.dx, rect.bottom)
          ..lineTo(rect.right, rect.top);
      }
      path.close();
      canvas.drawPath(path, paint);

      final edge = Paint()
        ..color = const Color(0xFF7F1D1D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, 1.5 * scale);
      canvas.drawPath(path, edge);
    }
  }

  void _drawGoalFlag(Canvas canvas, double scale, Goal goal) {
    if (!goal.visible) {
      return;
    }
    final rect = _toScreen(goal.rect, scale);
    final pole = Paint()..color = const Color(0xFF14532D);
    final flag = Paint()
      ..color = _flash(
        const Color(0xFF22C55E),
        goal.flash,
        const Color(0xFFFFF176),
      );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rect.left + 8 * scale, rect.top, 6 * scale, rect.height),
        Radius.circular(3 * scale),
      ),
      pole,
    );
    final path = Path()
      ..moveTo(rect.left + 14 * scale, rect.top + 6 * scale)
      ..lineTo(rect.right, rect.top + 20 * scale)
      ..lineTo(rect.left + 14 * scale, rect.top + 36 * scale)
      ..close();
    canvas.drawPath(path, flag);
  }

  void _drawPlayer(Canvas canvas, double scale) {
    final rect = _toScreen(player.rect, scale);
    final body = Paint()..color = playerColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(8 * scale)),
      body,
    );

    final eye = Paint()..color = Colors.white;
    final pupil = Paint()..color = const Color(0xFF0F172A);
    final eyeRadius = 3.2 * scale;
    final leftEye = Offset(
      rect.left + rect.width * 0.34,
      rect.top + 15 * scale,
    );
    final rightEye = Offset(
      rect.left + rect.width * 0.66,
      rect.top + 15 * scale,
    );
    canvas.drawCircle(leftEye, eyeRadius, eye);
    canvas.drawCircle(rightEye, eyeRadius, eye);
    canvas.drawCircle(leftEye, eyeRadius * 0.45, pupil);
    canvas.drawCircle(rightEye, eyeRadius * 0.45, pupil);
  }

  void _drawParticles(Canvas canvas, double scale) {
    for (final particle in particles) {
      final alpha = math.max(0.0, math.min(1.0, particle.life / 0.55));
      final paint = Paint()
        ..color = Color.lerp(
          const Color(0xFFF97316),
          const Color(0xFFDC2626),
          alpha,
        )!.withValues(alpha: alpha);
      final center = Offset(
        (particle.position.dx - cameraX) * scale,
        particle.position.dy * scale,
      );
      canvas.drawCircle(center, 3.2 * scale * (0.5 + alpha * 0.5), paint);
    }
  }

  void _drawDeathOverlay(Canvas canvas, Size size) {
    if (deathProgress <= 0) {
      return;
    }
    final paint = Paint()
      ..color = const Color(0xFFDC2626).withValues(alpha: 0.30 * deathProgress);
    canvas.drawRect(Offset.zero & size, paint);
  }

  Rect _toScreen(Rect rect, double scale) {
    return Rect.fromLTWH(
      (rect.left - cameraX) * scale,
      rect.top * scale,
      rect.width * scale,
      rect.height * scale,
    );
  }

  Color _flash(Color base, double amount, Color flashColor) {
    if (amount <= 0) {
      return base;
    }
    return Color.lerp(base, flashColor, math.min(1, amount * 2.4))!;
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}
