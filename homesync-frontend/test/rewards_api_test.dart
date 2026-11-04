import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:homesync/core/network/api_client.dart';
import 'package:homesync/views/rewards/models/reward_item.dart';
import 'package:homesync/views/rewards/rewards_api.dart';
import 'package:homesync/views/rewards/rewards_controller.dart';
import 'package:homesync/views/tasks/tasks_controller.dart';

Map<String, dynamic> _reward({
  required int id,
  required String name,
  required int cost,
  String kind = 'perk',
}) {
  return {
    'id': id,
    'family_id': 2,
    'name': name,
    'description': '$name!',
    'cost_points': cost,
    'kind': kind,
    'created_at': '2026-01-01T00:00:00',
  };
}

http.Response _json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status);

MockClient _mock({bool insufficient = false}) {
  return MockClient((request) async {
    final path = request.url.path;
    if (request.method == 'GET' && path == '/rewards/') {
      return _json([
        _reward(id: 5, name: 'Dragon Avatar', cost: 50, kind: 'avatar'),
        _reward(id: 6, name: 'Movie Night', cost: 100),
      ]);
    }
    if (request.method == 'POST' && path == '/rewards/') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      return _json(
        _reward(
          id: 7,
          name: body['name'] as String,
          cost: body['cost_points'] as int,
          kind: body['kind'] as String? ?? 'perk',
        ),
        201,
      );
    }
    if (request.method == 'POST' && path == '/rewards/5/redeem') {
      if (insufficient) {
        return _json({'detail': 'Insufficient points.'}, 400);
      }
      return _json({
        'id': 1,
        'family_id': 2,
        'user_id': 10,
        'amount': -50,
        'balance_after': 70,
        'reason': 'redeem',
        'ref_type': 'reward',
        'ref_id': 5,
        'created_at': '2026-01-01T00:00:00',
      });
    }
    return http.Response('not found', 404);
  });
}

RewardsController _controller({TasksController? tasks}) => RewardsController(
      tasks: tasks ?? TasksController.test(balances: {'Maya': 120}),
    );

void main() {
  group('RewardsApi', () {
    test('fetchCatalog returns the family catalog', () async {
      final api = RewardsApi(ApiClient(inner: _mock()));

      final catalog = await api.fetchCatalog();

      expect(catalog.length, 2);
      expect(catalog.first['name'], 'Dragon Avatar');
    });

    test('createReward posts the perk fields', () async {
      final api = RewardsApi(ApiClient(inner: _mock()));

      final created = await api.createReward(
        name: 'Park Trip',
        description: 'Saturday!',
        costPoints: 80,
      );

      expect(created['id'], 7);
      expect(created['cost_points'], 80);
    });

    test('redeemReward returns the ledger transaction', () async {
      final api = RewardsApi(ApiClient(inner: _mock()));

      final txn = await api.redeemReward(5);

      expect(txn['balance_after'], 70);
    });
  });

  group('RewardsController backend sync', () {
    test('refresh maps kinds, icons, and server ids', () async {
      final controller = _controller();
      controller.attachBackend(RewardsApi(ApiClient(inner: _mock())));

      await controller.refresh();

      expect(controller.isSynced, isTrue);
      expect(controller.rewards.length, 2);
      final avatar = controller.rewards.firstWhere((r) => r.serverId == 5);
      expect(avatar.kind, RewardKind.digital);
      expect(avatar.icon, Icons.face);
      final perk = controller.rewards.firstWhere((r) => r.serverId == 6);
      expect(perk.kind, RewardKind.parentPerk);
    });

    test('redeemAsync follows the server balance and logs', () async {
      final controller = _controller();
      controller.attachBackend(RewardsApi(ApiClient(inner: _mock())));
      await controller.refresh();

      final result = await controller.redeemAsync('Maya', 'srv-5');

      expect(result, RedeemResult.success);
      expect(controller.balanceFor('Maya'), 70);
      expect(controller.redemptions.single.rewardTitle, 'Dragon Avatar');
      expect(controller.perkRequests, isEmpty);
    });

    test('redeemAsync maps a 400 to insufficient', () async {
      final controller = _controller();
      controller.attachBackend(
        RewardsApi(ApiClient(inner: _mock(insufficient: true))),
      );
      await controller.refresh();

      final result = await controller.redeemAsync('Maya', 'srv-5');

      expect(result, RedeemResult.insufficient);
      expect(controller.balanceFor('Maya'), 120);
      expect(controller.redemptions, isEmpty);
    });

    test('redeemAsync falls back to the local ledger offline', () async {
      final controller = _controller();

      final result = await controller.redeemAsync('Maya', 'dig-avatar');

      expect(result, RedeemResult.success);
      expect(controller.balanceFor('Maya'), 70);
    });

    test('addPerkAsync inserts the server perk at the top', () async {
      final controller = _controller();
      controller.attachBackend(RewardsApi(ApiClient(inner: _mock())));
      await controller.refresh();

      await controller.addPerkAsync(
        title: 'Park Trip',
        description: 'Saturday!',
        cost: 80,
      );

      expect(controller.rewards.first.title, 'Park Trip');
      expect(controller.rewards.first.serverId, 7);
    });

    test('redeemExternal deducts and raises perk requests', () {
      final controller = _controller();

      final result = controller.redeemExternal(
        childName: 'Maya',
        title: 'Trampoline Park',
        cost: 100,
        kind: RewardKind.parentPerk,
      );

      expect(result, RedeemResult.success);
      expect(controller.balanceFor('Maya'), 20);
      expect(controller.redemptions.single.rewardTitle, 'Trampoline Park');
      expect(controller.perkRequests.single.perkTitle, 'Trampoline Park');

      expect(
        controller.redeemExternal(
          childName: 'Maya',
          title: 'Too Rich',
          cost: 999,
          kind: RewardKind.digital,
        ),
        RedeemResult.insufficient,
      );
    });

    test('requestPerk records without deducting', () {
      final controller = _controller();

      controller.requestPerk(
        childName: 'Maya',
        perkTitle: 'Zoo Day',
        cost: 150,
      );

      expect(controller.balanceFor('Maya'), 120);
      expect(controller.perkRequests.single.perkTitle, 'Zoo Day');
    });
  });
}
