import 'package:flutter/material.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F4FF),
      body: SafeArea(
        child: Stack(
          children: [
            const _MenuBackdrop(),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Troll Runner',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 44,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF101827),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Tiny jumps. Mean traps. Fifteen levels.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 30),
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).pushNamed('/game'),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Play'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(180, 56),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuBackdrop extends StatelessWidget {
  const _MenuBackdrop();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MenuBackdropPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _MenuBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFBEE3FF), Color(0xFFF8FAFC)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sky);

    final ground = Paint()..color = const Color(0xFF263238);
    canvas.drawRect(Rect.fromLTWH(0, size.height - 74, size.width, 74), ground);

    final spikePaint = Paint()..color = const Color(0xFFEF4444);
    for (var i = 0; i < 6; i++) {
      final x = 22.0 + i * 62;
      final path = Path()
        ..moveTo(x, size.height - 74)
        ..lineTo(x + 22, size.height - 112)
        ..lineTo(x + 44, size.height - 74)
        ..close();
      canvas.drawPath(path, spikePaint);
    }

    final player = Paint()..color = const Color(0xFF2563EB);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 94, size.height - 122, 38, 48),
        const Radius.circular(8),
      ),
      player,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
