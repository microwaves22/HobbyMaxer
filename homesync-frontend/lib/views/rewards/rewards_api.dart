import '../../core/network/api_client.dart';

/// Backend reward endpoints (parent-managed catalog + redemptions).
class RewardsApi {
  RewardsApi(this.client);

  final ApiClient client;

  /// Family reward catalog, in creation order.
  Future<List<Map<String, dynamic>>> fetchCatalog() async {
    final raw = await client.get('/rewards/') as List;
    return [for (final item in raw) item as Map<String, dynamic>];
  }

  /// Creates a catalog reward (`avatar`, `pet`, or `perk` kind).
  /// Returns the created reward JSON.
  Future<Map<String, dynamic>> createReward({
    required String name,
    required int costPoints,
    String? description,
    String kind = 'perk',
  }) async {
    final body = await client.post('/rewards/', body: {
      'name': name,
      if (description != null) 'description': description,
      'cost_points': costPoints,
      'kind': kind,
    });
    return body as Map<String, dynamic>;
  }

  /// Redeems a reward for the caller's balance.
  /// Returns the ledger transaction JSON.
  Future<Map<String, dynamic>> redeemReward(int serverId) async {
    final body = await client.post('/rewards/$serverId/redeem');
    return body as Map<String, dynamic>;
  }
}
