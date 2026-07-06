import 'dart:math' as math;

import 'package:flutter/material.dart';

class PlayerSkin {
  const PlayerSkin({
    required this.id,
    required this.name,
    required this.color,
    this.price = 0,
  });

  final String id;
  final String name;
  final Color color;
  final int price;
}

class EconomyState {
  const EconomyState({
    this.coins = 0,
    this.ownedSkinIds = const {'blue'},
    this.selectedSkinId = 'blue',
    this.lastSpinResult,
  });

  final int coins;
  final Set<String> ownedSkinIds;
  final String selectedSkinId;
  final String? lastSpinResult;

  EconomyState copyWith({
    int? coins,
    Set<String>? ownedSkinIds,
    String? selectedSkinId,
    String? lastSpinResult,
  }) {
    return EconomyState(
      coins: coins ?? this.coins,
      ownedSkinIds: ownedSkinIds ?? this.ownedSkinIds,
      selectedSkinId: selectedSkinId ?? this.selectedSkinId,
      lastSpinResult: lastSpinResult,
    );
  }
}

class GameEconomy {
  GameEconomy._();

  static const int spinCost = 5;

  static const List<PlayerSkin> skins = [
    PlayerSkin(id: 'blue', name: 'Classic Blue', color: Color(0xFF2563EB)),
    PlayerSkin(id: 'lime', name: 'Toxic Lime', color: Color(0xFF65A30D), price: 4),
    PlayerSkin(id: 'pink', name: 'Trap Pink', color: Color(0xFFDB2777), price: 6),
    PlayerSkin(id: 'gold', name: 'Coin Gold', color: Color(0xFFF59E0B), price: 9),
    PlayerSkin(id: 'void', name: 'Void', color: Color(0xFF111827), price: 12),
  ];

  static final ValueNotifier<EconomyState> state =
      ValueNotifier<EconomyState>(const EconomyState());

  static final math.Random _random = math.Random();

  static PlayerSkin get selectedSkin {
    return skins.firstWhere(
      (skin) => skin.id == state.value.selectedSkinId,
      orElse: () => skins.first,
    );
  }

  static void addCoins(int amount) {
    state.value = state.value.copyWith(
      coins: state.value.coins + amount,
      lastSpinResult: state.value.lastSpinResult,
    );
  }

  static bool buySkin(PlayerSkin skin) {
    final current = state.value;
    if (current.ownedSkinIds.contains(skin.id) || current.coins < skin.price) {
      return false;
    }
    final owned = {...current.ownedSkinIds, skin.id};
    state.value = current.copyWith(
      coins: current.coins - skin.price,
      ownedSkinIds: owned,
      selectedSkinId: skin.id,
      lastSpinResult: current.lastSpinResult,
    );
    return true;
  }

  static void selectSkin(PlayerSkin skin) {
    if (!state.value.ownedSkinIds.contains(skin.id)) {
      return;
    }
    state.value = state.value.copyWith(
      selectedSkinId: skin.id,
      lastSpinResult: state.value.lastSpinResult,
    );
  }

  static bool spinWheel() {
    final current = state.value;
    if (current.coins < spinCost) {
      return false;
    }

    final afterCost = current.copyWith(
      coins: current.coins - spinCost,
      lastSpinResult: null,
    );
    state.value = afterCost;

    final roll = _random.nextInt(100);
    if (roll < 28) {
      state.value = state.value.copyWith(lastSpinResult: 'Leider nichts gewonnen');
      return true;
    }
    if (roll < 58) {
      final amount = roll < 45 ? 2 : 7;
      state.value = state.value.copyWith(
        coins: state.value.coins + amount,
        lastSpinResult: '+$amount Münzen gewonnen',
      );
      return true;
    }

    final lockedSkins = skins
        .where((skin) => !state.value.ownedSkinIds.contains(skin.id))
        .toList();
    if (lockedSkins.isEmpty) {
      state.value = state.value.copyWith(
        coins: state.value.coins + 3,
        lastSpinResult: 'Alle Skins da: +3 Münzen',
      );
      return true;
    }

    final skin = lockedSkins[_random.nextInt(lockedSkins.length)];
    state.value = state.value.copyWith(
      ownedSkinIds: {...state.value.ownedSkinIds, skin.id},
      selectedSkinId: skin.id,
      lastSpinResult: '${skin.name} freigeschaltet',
    );
    return true;
  }
}
