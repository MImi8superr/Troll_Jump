import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/economy.dart';
import '../game/sfx.dart';

/// The shop is one swipeable page per topic — Lucky Wheel and Skins —
/// instead of a scrolling list, which fits the landscape-only viewport.
/// Chevron buttons mirror the swipe for mouse and keyboard users, and the
/// coin balance lives in the app bar so it is visible on every page.
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  static const int _pageCount = 2;

  final PageController _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    _pageController.animateToPage(
      page.clamp(0, _pageCount - 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F4FF),
      appBar: AppBar(
        title: const Text('Skin Shop'),
        centerTitle: true,
        actions: [
          ValueListenableBuilder<EconomyState>(
            valueListenable: GameEconomy.state,
            builder: (context, economy, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Row(
                  children: [
                    const Icon(
                      Icons.monetization_on_rounded,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${economy.coins} coins',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder<EconomyState>(
          valueListenable: GameEconomy.state,
          builder: (context, economy, _) {
            return Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _PageArrow(
                        icon: Icons.chevron_left_rounded,
                        enabled: _page > 0,
                        onTap: () => _goTo(_page - 1),
                      ),
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (page) =>
                              setState(() => _page = page),
                          children: [
                            _SpinCard(economy: economy),
                            _SkinsPage(economy: economy),
                          ],
                        ),
                      ),
                      _PageArrow(
                        icon: Icons.chevron_right_rounded,
                        enabled: _page < _pageCount - 1,
                        onTap: () => _goTo(_page + 1),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _pageCount; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _page == i ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _page == i
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF94A3B8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PageArrow extends StatelessWidget {
  const _PageArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: enabled ? onTap : null,
      icon: Icon(icon, size: 34),
      color: const Color(0xFF1E3A5F),
    );
  }
}

/// Page two: every skin as a card in a compact grid that fits a landscape
/// viewport without scrolling (and falls back to scrolling gracefully).
class _SkinsPage extends StatelessWidget {
  const _SkinsPage({required this.economy});

  final EconomyState economy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Skins',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 340,
                mainAxisExtent: 84,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: GameEconomy.skins.length,
              itemBuilder: (context, index) {
                final skin = GameEconomy.skins[index];
                return _SkinCard(skin: skin, economy: economy);
              },
            ),
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
  static const double _wheelDiameter = 150;
  static const double _wheelAreaHeight = 166;

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

  Future<void> _spin() async {
    if (_spinning) {
      return;
    }
    setState(() => _spinning = true);
    // The outcome is decided and applied up front (safe if the screen is
    // closed mid-spin); the wheel then animates onto the matching segment
    // and only reveals the result text once it stops.
    final prize = await GameEconomy.spinWheel();
    if (!mounted) {
      return;
    }
    if (prize == null) {
      setState(() => _spinning = false);
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

    final wheel = SizedBox(
      width: _wheelDiameter,
      height: _wheelAreaHeight,
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
                    key: const Key('spin-wheel'),
                    size: const Size.square(_wheelDiameter),
                    painter: _WheelPainter(),
                  ),
                );
              },
            ),
          ),
          const Icon(
            Icons.arrow_drop_down_rounded,
            size: 42,
            color: Color(0xFFDC2626),
          ),
        ],
      ),
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Landscape phones give the page plenty of width but little
                // height, so the wheel sits beside the text there; narrow
                // (portrait-ish) layouts stack and scroll instead.
                final wide = constraints.maxWidth >= 470;
                final details = Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: wide
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Lucky Wheel',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'One spin costs 5 coins. Win skins, extra coins — '
                      'or nothing at all.',
                      textAlign: wide ? TextAlign.start : TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (!_spinning && result != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        result,
                        textAlign: wide ? TextAlign.start : TextAlign.center,
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
                      label: const Text('Buy a spin (5 coins)'),
                    ),
                  ],
                );

                if (wide) {
                  return Row(
                    children: [
                      wheel,
                      const SizedBox(width: 22),
                      Expanded(child: details),
                    ],
                  );
                }
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [wheel, const SizedBox(height: 10), details],
                  ),
                );
              },
            ),
          ),
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
          color: const Color(0xFF0F172A),
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
        ? 'Equipped'
        : owned
            ? 'Equip'
            : '${skin.price} coins';

    return Card(
      elevation: 2,
      // The grid already provides the spacing between cards.
      margin: EdgeInsets.zero,
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
        subtitle: Text(owned ? 'Unlocked' : 'Not owned yet'),
        trailing: FilledButton(
          onPressed: selected
              ? null
              : owned
                  ? () async {
                      await GameEconomy.selectSkin(skin);
                    }
                  : canBuy
                      ? () async {
                          await GameEconomy.buySkin(skin);
                        }
                      : null,
          child: Text(buttonText),
        ),
      ),
    );
  }
}
