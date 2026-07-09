import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:troll_dash/game/economy.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GameEconomy.state.value = const EconomyState();
  });

  test('coins accumulate and gate purchases', () async {
    expect(GameEconomy.state.value.coins, 0);
    await GameEconomy.addCoins(3);
    expect(GameEconomy.state.value.coins, 3);

    final lime = GameEconomy.skins.firstWhere((skin) => skin.id == 'lime');
    expect(await GameEconomy.buySkin(lime), isFalse, reason: '3 < price 4');
    await GameEconomy.addCoins(3);
    expect(await GameEconomy.buySkin(lime), isTrue);
    expect(GameEconomy.state.value.coins, 2);
    expect(GameEconomy.state.value.ownedSkinIds, contains('lime'));
    expect(GameEconomy.state.value.selectedSkinId, 'lime');
    expect(
      await GameEconomy.buySkin(lime),
      isFalse,
      reason: 'already owned',
    );
  });

  test('selecting requires ownership', () async {
    final voidSkin = GameEconomy.skins.firstWhere((skin) => skin.id == 'void');
    await GameEconomy.selectSkin(voidSkin);
    expect(GameEconomy.state.value.selectedSkinId, 'blue');
  });

  test('spin wheel charges its cost and never goes negative', () async {
    expect(await GameEconomy.spinWheel(), isNull, reason: '0 < 5');
    await GameEconomy.addCoins(GameEconomy.spinCost);
    final prize = await GameEconomy.spinWheel();
    expect(prize, isNotNull, reason: 'affordable spin returns its prize');
    expect(GameEconomy.state.value.coins, greaterThanOrEqualTo(0));
    expect(GameEconomy.state.value.lastSpinResult, isNotNull);
  });

  test('load restores the persisted wallet', () async {
    SharedPreferences.setMockInitialValues({
      'economy_coins': 12,
      'economy_owned_skins': ['blue', 'pink'],
      'economy_selected_skin': 'pink',
    });
    await GameEconomy.load();
    expect(GameEconomy.state.value.coins, 12);
    expect(GameEconomy.state.value.ownedSkinIds, containsAll(['blue', 'pink']));
    expect(GameEconomy.state.value.selectedSkinId, 'pink');

    final prefs = await SharedPreferences.getInstance();
    final migrated = jsonDecode(prefs.getString('economy_state')!);
    expect(migrated['version'], 1);
    expect(migrated['coins'], 12);
    expect(migrated['ownedSkinIds'], containsAll(['blue', 'pink']));
    expect(migrated['selectedSkinId'], 'pink');
    expect(prefs.containsKey('economy_coins'), isFalse);
    expect(prefs.containsKey('economy_owned_skins'), isFalse);
    expect(prefs.containsKey('economy_selected_skin'), isFalse);
  });

  test('load restores the versioned economy record', () async {
    SharedPreferences.setMockInitialValues({
      'economy_state': jsonEncode({
        'version': 1,
        'coins': 9,
        'ownedSkinIds': ['blue', 'gold'],
        'selectedSkinId': 'gold',
      }),
    });

    await GameEconomy.load();

    expect(GameEconomy.state.value.coins, 9);
    expect(GameEconomy.state.value.ownedSkinIds, containsAll(['blue', 'gold']));
    expect(GameEconomy.state.value.selectedSkinId, 'gold');
  });

  test('load falls back to blue when the selected skin is not owned', () async {
    SharedPreferences.setMockInitialValues({
      'economy_coins': 5,
      'economy_owned_skins': ['blue'],
      'economy_selected_skin': 'gold',
    });
    await GameEconomy.load();
    expect(GameEconomy.state.value.selectedSkinId, 'blue');
  });

  test('mutations replace one complete economy record', () async {
    await GameEconomy.addCoins(4);
    final prefs = await SharedPreferences.getInstance();
    var persisted = jsonDecode(prefs.getString('economy_state')!);
    expect(persisted['coins'], 4);
    expect(persisted['ownedSkinIds'], ['blue']);
    expect(persisted['selectedSkinId'], 'blue');
    expect(prefs.containsKey('economy_coins'), isFalse);
    expect(prefs.containsKey('economy_owned_skins'), isFalse);
    expect(prefs.containsKey('economy_selected_skin'), isFalse);

    final lime = GameEconomy.skins.firstWhere((skin) => skin.id == 'lime');
    expect(await GameEconomy.buySkin(lime), isTrue);
    persisted = jsonDecode(prefs.getString('economy_state')!);
    expect(persisted['coins'], 0);
    expect(persisted['ownedSkinIds'], containsAll(['blue', 'lime']));
    expect(persisted['selectedSkinId'], 'lime');
  });
}
