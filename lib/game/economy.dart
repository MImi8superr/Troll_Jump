import 'dart:convert';
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
    this.claimedRareCoinLevels = const {},
    this.lastSpinResult,
  });

  final int coins;
  final Set<String> ownedSkinIds;
  final String selectedSkinId;
  final Set<int> claimedRareCoinLevels;
  final String? lastSpinResult;

  EconomyState copyWith({
    int? coins,
    Set<String>? ownedSkinIds,
    String? selectedSkinId,
    Set<int>? claimedRareCoinLevels,
    String? lastSpinResult,
  }) {
    return EconomyState(
      coins: coins ?? this.coins,
      ownedSkinIds: ownedSkinIds ?? this.ownedSkinIds,
      selectedSkinId: selectedSkinId ?? this.selectedSkinId,
      claimedRareCoinLevels:
          claimedRareCoinLevels ?? this.claimedRareCoinLevels,
      lastSpinResult: lastSpinResult,
    );
  }
}

class GameEconomy {
  GameEconomy._();

  static const int spinCost = 5;

  static const int _storageVersion = 1;
  static const String _stateKey = 'economy_state';
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
  static Future<void> _writeQueue = Future<void>.value();

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
      await _writeQueue;
      final prefs = await SharedPreferences.getInstance();
      final encodedState = prefs.getString(_stateKey);
      if (encodedState != null) {
        final restored = _decodeState(encodedState);
        if (restored != null) {
          state.value = restored;
          return;
        }
      }

      final coins = prefs.getInt(_coinsKey);
      final owned = prefs.getStringList(_ownedKey);
      final selected = prefs.getString(_selectedKey);
      if (coins == null && owned == null && selected == null) {
        return;
      }
      final ownedSet = {...?owned, 'blue'};
      final migrated = EconomyState(
        coins: math.max(0, coins ?? 0),
        ownedSkinIds: ownedSet,
        selectedSkinId:
            selected != null && ownedSet.contains(selected) ? selected : 'blue',
      );
      state.value = migrated;

      // Commit the complete replacement before removing any legacy value. If
      // the app stops during migration, the next launch can safely retry it.
      if (await _persist(migrated)) {
        await prefs.remove(_coinsKey);
        await prefs.remove(_ownedKey);
        await prefs.remove(_selectedKey);
      }
    } catch (_) {
      // Keep the default state if storage is unavailable.
    }
  }

  static EconomyState? _decodeState(String encoded) {
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map<String, dynamic> ||
          decoded['version'] != _storageVersion ||
          decoded['coins'] is! int ||
          decoded['ownedSkinIds'] is! List ||
          decoded['selectedSkinId'] is! String) {
        return null;
      }

      final owned = <String>{'blue'};
      for (final id in decoded['ownedSkinIds'] as List<dynamic>) {
        if (id is String) {
          owned.add(id);
        }
      }
      final claimedRareCoinLevels = <int>{};
      final claimed = decoded['claimedRareCoinLevels'];
      if (claimed is List<dynamic>) {
        for (final levelNumber in claimed) {
          if (levelNumber is int && levelNumber > 0) {
            claimedRareCoinLevels.add(levelNumber);
          }
        }
      }
      final selected = decoded['selectedSkinId'] as String;
      return EconomyState(
        coins: math.max(0, decoded['coins'] as int),
        ownedSkinIds: owned,
        selectedSkinId: owned.contains(selected) ? selected : 'blue',
        claimedRareCoinLevels: claimedRareCoinLevels,
      );
    } catch (_) {
      return null;
    }
  }

  static String _encodeState(EconomyState value) {
    final owned = value.ownedSkinIds.toList()..sort();
    final claimedRareCoinLevels = value.claimedRareCoinLevels.toList()..sort();
    return jsonEncode({
      'version': _storageVersion,
      'coins': value.coins,
      'ownedSkinIds': owned,
      'selectedSkinId': value.selectedSkinId,
      'claimedRareCoinLevels': claimedRareCoinLevels,
    });
  }

  /// Serializes writes so an older snapshot can never finish after a newer
  /// one. Each mutation replaces one complete, versioned record.
  static Future<bool> _persist(EconomyState snapshot) {
    final encoded = _encodeState(snapshot);
    final write = _writeQueue.then((_) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        return await prefs.setString(_stateKey, encoded);
      } catch (_) {
        // Non-fatal: the current in-memory session can continue.
        return false;
      }
    });
    _writeQueue = write.then<void>((_) {});
    return write;
  }

  static Future<void> addCoins(int amount) async {
    final updated = state.value.copyWith(
      coins: state.value.coins + amount,
      lastSpinResult: state.value.lastSpinResult,
    );
    state.value = updated;
    await _persist(updated);
  }

  static bool hasClaimedRareCoin(int levelNumber) {
    return state.value.claimedRareCoinLevels.contains(levelNumber);
  }

  /// Banks a level's rare coin at most once. The claim and its coin value are
  /// committed in the same record, so neither half can survive on its own.
  static Future<bool> collectRareCoin(int levelNumber, int amount) async {
    final current = state.value;
    if (levelNumber <= 0 ||
        current.claimedRareCoinLevels.contains(levelNumber)) {
      return false;
    }
    final updated = current.copyWith(
      coins: current.coins + amount,
      claimedRareCoinLevels: {...current.claimedRareCoinLevels, levelNumber},
      lastSpinResult: current.lastSpinResult,
    );
    state.value = updated;
    await _persist(updated);
    return true;
  }

  static Future<bool> buySkin(PlayerSkin skin) async {
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
    await _persist(state.value);
    return true;
  }

  static Future<void> selectSkin(PlayerSkin skin) async {
    if (!state.value.ownedSkinIds.contains(skin.id)) {
      return;
    }
    state.value = state.value.copyWith(
      selectedSkinId: skin.id,
      lastSpinResult: state.value.lastSpinResult,
    );
    await _persist(state.value);
  }

  /// Charges the spin cost, applies a random prize, and returns which prize
  /// category the wheel should land on — or null if the player can't afford
  /// a spin. The result text lands in [EconomyState.lastSpinResult].
  static Future<SpinPrize?> spinWheel() async {
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
      await _persist(state.value);
      return SpinPrize.nothing;
    }
    if (roll < 58) {
      final amount = roll < 45 ? 2 : 7;
      state.value = state.value.copyWith(
        coins: state.value.coins + amount,
        lastSpinResult: '+$amount Münzen gewonnen',
      );
      await _persist(state.value);
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
      await _persist(state.value);
      return SpinPrize.skin;
    }

    final skin = lockedSkins[_random.nextInt(lockedSkins.length)];
    state.value = state.value.copyWith(
      ownedSkinIds: {...state.value.ownedSkinIds, skin.id},
      selectedSkinId: skin.id,
      lastSpinResult: '${skin.name} freigeschaltet',
    );
    await _persist(state.value);
    return SpinPrize.skin;
  }
}
