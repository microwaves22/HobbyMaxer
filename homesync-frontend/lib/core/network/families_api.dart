import '../../core/network/api_client.dart';

/// Backend family endpoints: setup, roster, children, and invite codes.
class FamiliesApi {
  FamiliesApi(this.client);

  final ApiClient client;

  /// Formats a compact 6-character code as `XXX XXX` for display.
  static String formatInviteCode(String compact) {
    final code = compact.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    if (code.length != 6) return compact;
    return '${code.substring(0, 3)} ${code.substring(3)}';
  }

  /// Creates the caller's family. Returns the family JSON (with its
  /// generated invite code).
  Future<Map<String, dynamic>> createFamily({
    required String name,
    required String parentPin,
  }) async {
    final body = await client.post('/families/', body: {
      'name': name,
      'parent_pin': parentPin,
    });
    return body as Map<String, dynamic>;
  }

  /// Joins the family matching [code] (dashes/spaces tolerated).
  /// Returns the joined family JSON.
  Future<Map<String, dynamic>> joinFamily(String code) async {
    final body = await client.post('/families/join', body: {'code': code});
    return body as Map<String, dynamic>;
  }

  /// Sets (or clears with null) a child's login PIN. Parents only.
  Future<Map<String, dynamic>> setChildPin({
    required int familyId,
    required int childId,
    required String? pin,
  }) async {
    final body = await client.patch(
      '/families/$familyId/children/$childId/pin',
      body: {'child_pin': pin},
    );
    return body as Map<String, dynamic>;
  }

  /// The caller's family with members. Throws [ApiException] with
  /// status 404 when no family exists yet.
  Future<Map<String, dynamic>> myFamily() async {
    final body = await client.get('/families/me');
    return body as Map<String, dynamic>;
  }

  /// Per-parent workload shares over the trailing 7 days.
  Future<Map<String, dynamic>> loadBalance() async {
    final body = await client.get('/families/load-balance');
    return body as Map<String, dynamic>;
  }

  /// Adds a child profile (`kids` or `teen` mode). Returns the user JSON.
  Future<Map<String, dynamic>> addChild({
    required int familyId,
    required String displayName,
    required String mode,
  }) async {
    final body = await client.post('/families/$familyId/children', body: {
      'display_name': displayName,
      'mode': mode,
    });
    return body as Map<String, dynamic>;
  }
}
