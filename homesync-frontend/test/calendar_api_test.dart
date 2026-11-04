import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:homesync/core/network/api_client.dart';
import 'package:homesync/views/calendar/calendar_api.dart';

http.Response _json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status);

MockClient _mock({List<http.BaseRequest>? seen}) {
  return MockClient((request) async {
    seen?.add(request);
    final path = request.url.path;
    if (request.method == 'GET' && path == '/calendar/events') {
      return _json([
        {
          'id': 3,
          'family_id': 2,
          'title': 'Dentist',
          'description': 'Bring card',
          'starts_at': '2026-10-31T14:00:00',
          'ends_at': '2026-10-31T15:00:00',
          'created_at': '2026-01-01T00:00:00',
        },
      ]);
    }
    if (request.method == 'POST' && path == '/calendar/events') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      return _json({
        'id': 4,
        'family_id': 2,
        'title': body['title'],
        'description': body['description'],
        'starts_at': body['starts_at'],
        'ends_at': body['ends_at'],
        'created_at': '2026-01-01T00:00:00',
      }, 201);
    }
    if (request.method == 'DELETE' && path == '/calendar/events/3') {
      return http.Response('', 204);
    }
    return http.Response('not found', 404);
  });
}

void main() {
  group('CalendarApi', () {
    test('fetchEvents returns the family events', () async {
      final api = CalendarApi(ApiClient(inner: _mock()));

      final events = await api.fetchEvents();

      expect(events.length, 1);
      expect(events.single['title'], 'Dentist');
    });

    test('createEvent posts ISO datetimes', () async {
      final seen = <http.BaseRequest>[];
      final api = CalendarApi(ApiClient(inner: _mock(seen: seen)));

      final created = await api.createEvent(
        title: 'Party',
        startsAt: DateTime(2026, 10, 31, 18),
        endsAt: DateTime(2026, 10, 31, 19),
      );

      expect(created['id'], 4);
      final sent =
          jsonDecode((seen.single as http.Request).body) as Map<String, dynamic>;
      expect(sent['starts_at'], contains('2026-10-31T18:00:00'));
      expect(sent['ends_at'], contains('2026-10-31T19:00:00'));
    });

    test('deleteEvent issues a DELETE for the id', () async {
      final seen = <http.BaseRequest>[];
      final api = CalendarApi(ApiClient(inner: _mock(seen: seen)));

      await api.deleteEvent(3);

      expect(seen.single.method, 'DELETE');
      expect(seen.single.url.path, '/calendar/events/3');
    });

    test('ApiException carries the server message', () async {
      final api = CalendarApi(ApiClient(inner: _mock()));

      expect(
        () => api.deleteEvent(999),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'status', 404),
        ),
      );
    });
  });
}
