import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/economy.dart';
import '../game/sfx.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F4FF),
      appBar: AppBar(
        title: const Text('Skin-Shop'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ValueListenableBuilder<EconomyState>(
          valueListenable: GameEconomy.state,
          builder: (context, economy, _) {
            return ListView(
              padding: const EdgeInsets.all(18),
              children: [
                _CoinBalance(coins: economy.coins),
                const SizedBox(height: 14),
                _SpinCard(economy: economy),
                const SizedBox(height: 18),
                const Text(
                  'Skins',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),
                for (final skin in GameEconomy.skins)
                  _SkinCard(skin: skin, economy: economy),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CoinBalance extends StatelessWidget {
  const _CoinBalance({required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.monetization_on_rounded, color: Color(0xFFF59E0B)),
          const SizedBox(width: 8),
          Text(
            '$coins Münzen',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

/// The wheel's segment layout. Roughly mirrors the real odds (42% skin,
/// 28% nothing, 17% +2, 13% +7) and never puts two equal prizes side by
/// side, so the wheel reads colorful like a proper prize wheel.
const List<SpinPrize> _wheelSlices = [
  SpinPrize.skin,
  SpinPrize.coins2,
  SpinPrize.nothing,
  SpinPrize.skin,
  SpinPrize.coins7,
  SpinPrize.nothing,
  SpinPrize.skin,
  SpinPrize.coins2,
];

class _SpinCard extends StatefulWidget {
  const _SpinCard({required this.economy});

  final EconomyState economy;

  @override
  State<_SpinCard> createState() => _SpinCardState();
}

class _SpinCardState extends State<_SpinCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  );
  final math.Random _random = math.Random();

  /// Absolute wheel angle after the last completed spin.
  double _rotation = 0;
  Animation<double>? _animation;
  bool _spinning = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spin() {
    if (_spinning) {
      return;
    }
    // The outcome is decided and applied up front (safe if the screen is
    // closed mid-spin); the wheel then animates onto the matching segment
    // and only reveals the result text once it stops.
    final prize = GameEconomy.spinWheel();
    if (prize == null) {
      return;
    }

    final sliceAngle = 2 * math.pi / _wheelSlices.length;
    final options = <int>[
      for (var i = 0; i < _wheelSlices.length; i++)
        if (_wheelSlices[i] == prize) i,
    ];
    final target = options[_random.nextInt(options.length)];

    // Rotate at least four full turns, then stop with segment `target`
    // centered under the pointer at the top.
    final desired = (-target * sliceAngle) % (2 * math.pi);
    var end = _rotation + 4 * 2 * math.pi;
    end += (desired - end % (2 * math.pi) + 2 * math.pi) % (2 * math.pi);

    _animation = Tween<double>(begin: _rotation, end: end).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
    );
    _rotation = end;
    setState(() => _spinning = true);
    _controller.forward(from: 0).whenComplete(() {
      if (!mounted) {
        return;
      }
      setState(() => _spinning = false);
      if (prize == SpinPrize.nothing) {
        Sfx.trap();
      } else {
        Sfx.checkpoint();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final canSpin = widget.economy.coins >= GameEconomy.spinCost;
    final result = widget.economy.lastSpinResult;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Glücksrad',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'Ein Spin kostet 5 Münzen. Gewinne Skins, mehr Münzen oder auch nichts.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 232,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        return Transform.rotate(
                          angle: _animation?.value ?? _rotation,
                          child: CustomPaint(
                            size: const Size(210, 210),
                            painter: _WheelPainter(),
                          ),
                        );
                      },
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 54,
                    color: Color(0xFFDC2626),
                  ),
                ],
              ),
            ),
            if (!_spinning && result != null) ...[
              const SizedBox(height: 8),
              Text(
                result,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF2563EB),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: canSpin && !_spinning ? _spin : null,
              icon: const Icon(Icons.casino_rounded),
              label: const Text('Spin kaufen (5 Münzen)'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Draws the prize wheel: colored segments with a hand-drawn glyph per
/// prize (coin +2 / coin +7 / skin swatches / a miss), white separators,
/// dark rim, and a hub. Glyphs point outward so they stay readable at any
/// wheel rotation.
class _WheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final sliceAngle = 2 * math.pi / _wheelSlices.length;

    for (var i = 0; i < _wheelSlices.length; i++) {
      final start = -math.pi / 2 + i * sliceAngle - sliceAngle / 2;
      final fill = Paint()..color = _sliceColor(_wheelSlices[i], i);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 4),
        start,
        sliceAngle,
        true,
        fill,
      );
    }

    final separator = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < _wheelSlices.length; i++) {
      final angle = -math.pi / 2 + i * sliceAngle - sliceAngle / 2;
      canvas.drawLine(
        center,
        center + Offset(math.cos(angle), math.sin(angle)) * (radius - 4),
        separator,
      );
    }

    final rim = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(center, radius - 4, rim);

    for (var i = 0; i < _wheelSlices.length; i++) {
      final angle = -math.pi / 2 + i * sliceAngle;
      final position =
          center + Offset(math.cos(angle), math.sin(angle)) * (radius * 0.62);
      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(angle + math.pi / 2);
      _drawGlyph(canvas, _wheelSlices[i]);
      canvas.restore();
    }

    canvas.drawCircle(center, radius * 0.17, Paint()..color = Colors.white);
    final hubRing = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius * 0.17, hubRing);
  }

  Color _sliceColor(SpinPrize prize, int index) {
    switch (prize) {
      case SpinPrize.skin:
        return index.isEven ? const Color(0xFF9333EA) : const Color(0xFFA855F7);
      case SpinPrize.coins2:
        return const Color(0xFFFBBF24);
      case SpinPrize.coins7:
        return const Color(0xFFF59E0B);
      case SpinPrize.nothing:
        return const Color(0xFF94A3B8);
    }
  }

  void _drawGlyph(Canvas canvas, SpinPrize prize) {
    switch (prize) {
      case SpinPrize.nothing:
        final cross = Paint()
          ..color = Colors.white
          ..strokeWidth = 4.5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(const Offset(-8, -8), const Offset(8, 8), cross);
        canvas.drawLine(const Offset(8, -8), const Offset(-8, 8), cross);
      case SpinPrize.coins2:
        _drawCoin(canvas, const Offset(0, -8), 10);
        _drawText(canvas, '+2', const Offset(0, 10), 14);
      case SpinPrize.coins7:
        _drawCoin(canvas, const Offset(0, -8), 12);
        _drawText(canvas, '+7', const Offset(0, 11), 15);
      case SpinPrize.skin:
        _drawSwatch(canvas, const Offset(-11, -2), const Color(0xFF65A30D));
        _drawSwatch(canvas, const Offset(0, -10), const Color(0xFFDB2777));
        _drawSwatch(canvas, const Offset(11, -2), const Color(0xFFF59E0B));
    }
  }

  void _drawCoin(Canvas canvas, Offset at, double radius) {
    canvas.drawCircle(at, radius, Paint()..color = const Color(0xFFFACC15));
    final edge = Paint()
      ..color = const Color(0xFFB45309)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(at, radius, edge);
  }

  void _drawSwatch(Canvas canvas, Offset at, Color color) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: at, width: 13, height: 13),
      const Radius.circular(3.5),
    );
    canvas.drawRRect(rect, Paint()..color = color);
    final border = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawRRect(rect, border);
  }

  void _drawText(Canvas canvas, String text, Offset at, double fontSize) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) => false;
}

class _SkinCard extends StatelessWidget {
  const _SkinCard({required this.skin, required this.economy});

  final PlayerSkin skin;
  final EconomyState economy;

  @override
  Widget build(BuildContext context) {
    final owned = economy.ownedSkinIds.contains(skin.id);
    final selected = economy.selectedSkinId == skin.id;
    final canBuy = economy.coins >= skin.price;
    final buttonText = selected
        ? 'Ausgerüstet'
        : owned
            ? 'Ausrüsten'
            : '${skin.price} Münzen';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: skin.color,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        title: Text(
          skin.name,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(owned ? 'Freigeschaltet' : 'Noch nicht gekauft'),
        trailing: FilledButton(
          onPressed: selected
              ? null
              : owned
                  ? () => GameEconomy.selectSkin(skin)
                  : canBuy
                      ? () => GameEconomy.buySkin(skin)
                      : null,
          child: Text(buttonText),
        ),
      ),
    );
  }
}
