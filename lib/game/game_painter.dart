import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'models.dart';

class GamePainter extends CustomPainter {
  GamePainter({
    required this.level,
    required this.player,
    required this.cameraX,
  });

  final Level level;
  final Player player;
  final double cameraX;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.height / worldHeight;
    final visibleWorldWidth = size.width / scale;

    _drawBackground(canvas, size, visibleWorldWidth);
    _drawJumpPads(canvas, scale);
    _drawPlatforms(canvas, scale);
    _drawHazards(canvas, scale);
    _drawSpikes(canvas, scale);
    _drawGoal(canvas, scale);
    _drawPlayer(canvas, scale);
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

  void _drawGoal(Canvas canvas, double scale) {
    final rect = _toScreen(level.goal.rect, scale);
    final pole = Paint()..color = const Color(0xFF14532D);
    final flag = Paint()
      ..color = _flash(
        const Color(0xFF22C55E),
        level.goal.flash,
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
    final body = Paint()..color = const Color(0xFF2563EB);
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
