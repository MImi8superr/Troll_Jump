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
            // The maker's mark: visible on every launch.
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'A game by Mias Ehrensperger',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Center(
              child: Transform.translate(
                offset: const Offset(0, -36),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Fake Floor',
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
                        'Tiny jumps. Mean traps. Twenty-nine levels.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const _TrapSignature(),
                      const SizedBox(height: 22),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () => Navigator.of(
                                  context,
                                ).pushNamed('/levels'),
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: const Text('Choose Level'),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(0, 56),
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => Navigator.of(
                                  context,
                                ).pushNamed('/shop'),
                                icon: const Icon(Icons.storefront_rounded),
                                label: const Text('Skin Shop'),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 56),
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF1E3A5F),
                                  side: const BorderSide(
                                    color: Color(0xFF475569),
                                    width: 1.5,
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A compact preview of the authored mechanics, rather than a generic
/// play/shop menu. Each promise maps to traps that appear in the level set.
class _TrapSignature extends StatelessWidget {
  const _TrapSignature();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _MechanicChip(
          icon: Icons.visibility_off_rounded,
          label: 'Hidden hazards',
        ),
        _MechanicChip(icon: Icons.swap_horiz_rounded, label: 'World swaps'),
        _MechanicChip(icon: Icons.replay_rounded, label: 'Second-lap traps'),
      ],
    );
  }
}

class _MechanicChip extends StatelessWidget {
  const _MechanicChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xD9FFFFFF),
        border: Border.all(color: const Color(0xFF93C5FD)),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: const Color(0xFF1D4ED8)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF1E3A5F),
                fontSize: 12,
                fontWeight: FontWeight.w800,
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
