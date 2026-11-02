import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/views/rewards/models/reward_item.dart';
import 'package:homesync/views/rewards/rewards_controller.dart';
import 'package:homesync/views/tasks/tasks_controller.dart';

RewardsController _store({int balance = 100}) {
  return RewardsController(
    tasks: TasksController.test(balances: {'Maya': balance}),
  );
}

void main() {
  group('RewardsController', () {
    test('digital redeem deducts points and logs the redemption', () {
      final store = _store();

      final result = store.redeem('Maya', 'dig-avatar');

      expect(result, RedeemResult.success);
      expect(store.balanceFor('Maya'), 50);
      expect(store.redemptions.length, 1);
      expect(store.redemptions.first.rewardTitle, 'Pixel Avatar Pack');
      expect(store.redemptions.first.kind, RewardKind.digital);
      expect(store.perkRequests, isEmpty);
    });

    test('perk redeem raises a parent fulfillment request', () {
      final store = _store();

      final result = store.redeem('Maya', 'perk-screen');

      expect(result, RedeemResult.success);
      expect(store.balanceFor('Maya'), 75);
      expect(store.perkRequests.length, 1);
      expect(
        store.perkRequests.first.perkTitle,
        'Extra 30 min screen time',
      );
      expect(store.perkRequests.first.childName, 'Maya');
    });

    test('insufficient balance blocks redemption without side effects', () {
      final store = _store(balance: 10);

      final result = store.redeem('Maya', 'dig-avatar');

      expect(result, RedeemResult.insufficient);
      expect(store.balanceFor('Maya'), 10);
      expect(store.redemptions, isEmpty);
      expect(store.perkRequests, isEmpty);
    });

    test('unknown reward id returns notFound', () {
      final store = _store();

      expect(store.redeem('Maya', 'nope'), RedeemResult.notFound);
      expect(store.balanceFor('Maya'), 100);
    });

    test('fulfillRequest clears the perk request', () {
      final store = _store();
      store.redeem('Maya', 'perk-screen');
      final id = store.perkRequests.first.id;

      store.fulfillRequest(id);

      expect(store.perkRequests, isEmpty);
    });

    test('addPerk puts a new parent-managed perk first', () {
      final store = _store();
      final before = store.rewardsOf(RewardKind.parentPerk).length;

      store.addPerk(
        title: 'Bonus story',
        description: 'One extra bedtime story.',
        cost: 15,
      );

      final perks = store.rewardsOf(RewardKind.parentPerk);
      expect(perks.length, before + 1);
      expect(perks.first.title, 'Bonus story');
      expect(perks.first.cost, 15);
    });

    test('balance stays shared with task approvals', () {
      final tasks = TasksController.test(balances: {'Maya': 0});
      final store = RewardsController(tasks: tasks);

      // Simulate earning elsewhere: deduct must see the same wallet.
      expect(store.balanceFor('Maya'), 0);
      expect(store.redeem('Maya', 'dig-hat'), RedeemResult.insufficient);
    });
  });
}
