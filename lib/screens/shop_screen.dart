import 'package:flutter/material.dart';

import '../game/economy.dart';

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

class _SpinCard extends StatelessWidget {
  const _SpinCard({required this.economy});

  final EconomyState economy;

  @override
  Widget build(BuildContext context) {
    final canSpin = economy.coins >= GameEconomy.spinCost;
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
            if (economy.lastSpinResult != null) ...[
              const SizedBox(height: 10),
              Text(
                economy.lastSpinResult!,
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
              onPressed: canSpin ? GameEconomy.spinWheel : null,
              icon: const Icon(Icons.casino_rounded),
              label: const Text('Spin kaufen (5 Münzen)'),
            ),
          ],
        ),
      ),
    );
  }
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
