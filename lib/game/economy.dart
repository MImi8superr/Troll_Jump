import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

/// The kinds of prizes the wheel can land on. The shop's spin wheel maps
/// each outcome to one of its segments for the landing animation.
enum SpinPrize { nothing, coins2, coins7, skin }

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

  static const String _coinsKey = 'economy_coins';
  static const String _ownedKey = 'economy_owned_skins';
  static const String _selectedKey = 'economy_selected_skin';

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

  /// Restores the persisted wallet, owned skins, and selected skin. Safe to
  /// call before [runApp]; failures (e.g. missing platform plugin in tests)
  /// leave the fresh default state untouched.
  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final coins = prefs.getInt(_coinsKey);
      final owned = prefs.getStringList(_ownedKey);
      final selected = prefs.getString(_selectedKey);
      if (coins == null && owned == null && selected == null) {
        return;
      }
      final ownedSet = {...?owned, 'blue'};
      state.value = EconomyState(
        coins: math.max(0, coins ?? 0),
        ownedSkinIds: ownedSet,
        selectedSkinId:
            selected != null && ownedSet.contains(selected) ? selected : 'blue',
      );
    } catch (_) {
      // Keep the default state if storage is unavailable.
    }
  }

  static Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = state.value;
      await prefs.setInt(_coinsKey, current.coins);
      await prefs.setStringList(_ownedKey, current.ownedSkinIds.toList());
      await prefs.setString(_selectedKey, current.selectedSkinId);
    } catch (_) {
      // Non-fatal: the wallet simply won't survive this session.
    }
  }

  static void addCoins(int amount) {
    state.value = state.value.copyWith(
      coins: state.value.coins + amount,
      lastSpinResult: state.value.lastSpinResult,
    );
    _persist();
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
    _persist();
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
    _persist();
  }

  /// Charges the spin cost, applies a random prize, and returns which prize
  /// category the wheel should land on — or null if the player can't afford
  /// a spin. The result text lands in [EconomyState.lastSpinResult].
  static SpinPrize? spinWheel() {
    final current = state.value;
    if (current.coins < spinCost) {
      return null;
    }

    final afterCost = current.copyWith(
      coins: current.coins - spinCost,
      lastSpinResult: null,
    );
    state.value = afterCost;

    final roll = _random.nextInt(100);
    if (roll < 28) {
      state.value = state.value.copyWith(lastSpinResult: 'Leider nichts gewonnen');
      _persist();
      return SpinPrize.nothing;
    }
    if (roll < 58) {
      final amount = roll < 45 ? 2 : 7;
      state.value = state.value.copyWith(
        coins: state.value.coins + amount,
        lastSpinResult: '+$amount Münzen gewonnen',
      );
      _persist();
      return roll < 45 ? SpinPrize.coins2 : SpinPrize.coins7;
    }

    final lockedSkins = skins
        .where((skin) => !state.value.ownedSkinIds.contains(skin.id))
        .toList();
    if (lockedSkins.isEmpty) {
      state.value = state.value.copyWith(
        coins: state.value.coins + 3,
        lastSpinResult: 'Alle Skins da: +3 Münzen',
      );
      _persist();
      return SpinPrize.skin;
    }

    final skin = lockedSkins[_random.nextInt(lockedSkins.length)];
    state.value = state.value.copyWith(
      ownedSkinIds: {...state.value.ownedSkinIds, skin.id},
      selectedSkinId: skin.id,
      lastSpinResult: '${skin.name} freigeschaltet',
    );
    _persist();
    return SpinPrize.skin;
  }
}
