import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:homesync/core/network/api_client.dart';
import 'package:homesync/core/network/families_api.dart';

Map<String, dynamic> _member({
  required int id,
  required String name,
  required String role,
  String? mode,
  int balance = 0,
}) {
  return {
    'id': id,
    'family_id': 2,
    'email': role == 'parent' ? 'm@example.com' : null,
    'display_name': name,
    'role': role,
    'mode': mode,
    'points_balance': balance,
    'created_at': '2026-01-01T00:00:00',
  };
}

http.Response _json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status);

MockClient _mock({List<Map<String, dynamic>>? posted}) {
  return MockClient((request) async {
    final path = request.url.path;
    if (request.method == 'POST' && path == '/families/') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      posted?.add({'path': path, ...body});
      return _json({
        'id': 2,
        'name': body['name'],
        'invite_code': 'AB12CD',
        'created_at': '2026-01-01T00:00:00',
      }, 201);
    }
    if (request.method == 'POST' && path == '/families/join') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      if (body['code'] != 'AB12CD') {
        return _json({'detail': 'Invite code not found.'}, 404);
      }
      return _json({
        'id': 2,
        'name': 'Fam',
        'invite_code': 'AB12CD',
        'created_at': '2026-01-01T00:00:00',
      });
    }
    if (request.method == 'GET' && path == '/families/me') {
      return _json({
        'id': 2,
        'name': 'Fam',
        'invite_code': 'H7K2M9',
        'created_at': '2026-01-01T00:00:00',
        'members': [
          _member(id: 9, name: 'Mom', role: 'parent'),
          _member(id: 10, name: 'Maya', role: 'child', mode: 'kids'),
          _member(id: 11, name: 'Leo', role: 'child', mode: 'teen'),
        ],
      });
    }
    if (request.method == 'POST' && path == '/families/2/children') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      posted?.add({'path': path, ...body});
      return _json(
        _member(
          id: 12,
          name: body['display_name'] as String,
          role: 'child',
          mode: body['mode'] as String?,
        ),
        201,
      );
    }
    return http.Response('not found', 404);
  });
}

void main() {
  group('FamiliesApi', () {
    test('createFamily returns the family with its invite code', () async {
      final posted = <Map<String, dynamic>>[];
      final api = FamiliesApi(ApiClient(inner: _mock(posted: posted)));

      final family =
          await api.createFamily(name: 'The Mom Family', parentPin: '1234');

      expect(family['id'], 2);
      expect(family['invite_code'], 'AB12CD');
      expect(posted.single['parent_pin'], '1234');
    });

    test('joinFamily joins on a valid code and 404s otherwise', () async {
      final api = FamiliesApi(ApiClient(inner: _mock()));

      final family = await api.joinFamily('AB12CD');
      expect(family['id'], 2);

      expect(
        () => api.joinFamily('WRONG1'),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'status', 404),
        ),
      );
    });

    test('myFamily returns the invite code and roster', () async {
      final api = FamiliesApi(ApiClient(inner: _mock()));

      final family = await api.myFamily();

      expect(family['invite_code'], 'H7K2M9');
      final members = family['members'] as List;
      expect(members.length, 3);
      expect(members.where((m) => m['role'] != 'parent').length, 2);
    });

    test('addChild posts the display name and mode', () async {
      final posted = <Map<String, dynamic>>[];
      final api = FamiliesApi(ApiClient(inner: _mock(posted: posted)));

      final child = await api.addChild(
        familyId: 2,
        displayName: 'Maya',
        mode: 'kids',
      );

      expect(child['display_name'], 'Maya');
      expect(
        posted.single,
        {'path': '/families/2/children', 'display_name': 'Maya', 'mode': 'kids'},
      );
    });

    test('formatInviteCode groups compact codes for display', () {
      expect(FamiliesApi.formatInviteCode('ab12cd'), 'AB1 2CD');
      expect(FamiliesApi.formatInviteCode('H7K 2M9'), 'H7K 2M9');
      expect(FamiliesApi.formatInviteCode('short'), 'short');
    });
  });
}
