import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:troll_run/game/economy.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GameEconomy.state.value = const EconomyState();
  });

  test('coins accumulate and gate purchases', () {
    expect(GameEconomy.state.value.coins, 0);
    GameEconomy.addCoins(3);
    expect(GameEconomy.state.value.coins, 3);

    final lime = GameEconomy.skins.firstWhere((skin) => skin.id == 'lime');
    expect(GameEconomy.buySkin(lime), isFalse, reason: '3 < price 4');
    GameEconomy.addCoins(3);
    expect(GameEconomy.buySkin(lime), isTrue);
    expect(GameEconomy.state.value.coins, 2);
    expect(GameEconomy.state.value.ownedSkinIds, contains('lime'));
    expect(GameEconomy.state.value.selectedSkinId, 'lime');
    expect(GameEconomy.buySkin(lime), isFalse, reason: 'already owned');
  });

  test('selecting requires ownership', () {
    final voidSkin = GameEconomy.skins.firstWhere((skin) => skin.id == 'void');
    GameEconomy.selectSkin(voidSkin);
    expect(GameEconomy.state.value.selectedSkinId, 'blue');
  });

  test('spin wheel charges its cost and never goes negative', () {
    expect(GameEconomy.spinWheel(), isFalse, reason: '0 < 5');
    GameEconomy.addCoins(GameEconomy.spinCost);
    expect(GameEconomy.spinWheel(), isTrue);
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

  test('mutations are written to storage', () async {
    GameEconomy.addCoins(4);
    // _persist is fire-and-forget; let its microtasks complete.
    await Future<void>.delayed(Duration.zero);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('economy_coins'), 4);

    final lime = GameEconomy.skins.firstWhere((skin) => skin.id == 'lime');
    expect(GameEconomy.buySkin(lime), isTrue);
    await Future<void>.delayed(Duration.zero);
    expect(prefs.getInt('economy_coins'), 0);
    expect(prefs.getStringList('economy_owned_skins'), contains('lime'));
    expect(prefs.getString('economy_selected_skin'), 'lime');
  });
}
