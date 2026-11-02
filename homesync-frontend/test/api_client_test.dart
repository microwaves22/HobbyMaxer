import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:homesync/core/network/api_client.dart';

void main() {
  group('ApiClient', () {
    test('injects the bearer token', () async {
      String? auth;
      final client = ApiClient(
        inner: MockClient((request) async {
          auth = request.headers['Authorization'];
          return http.Response('{}', 200);
        }),
        tokenProvider: () => 'abc123',
      );

      await client.get('/auth/me');

      expect(auth, 'Bearer abc123');
    });

    test('omits the auth header without a token', () async {
      String? auth;
      final client = ApiClient(
        inner: MockClient((request) async {
          auth = request.headers['Authorization'];
          return http.Response('{}', 200);
        }),
      );

      await client.get('/auth/me');

      expect(auth, isNull);
    });

    test('parses FastAPI error details', () async {
      final client = ApiClient(
        inner: MockClient(
          (_) async => http.Response(
            jsonEncode({'detail': 'Nope.'}),
            403,
          ),
        ),
      );

      expect(
        () => client.get('/families/me'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.message, 'message', 'Nope.')
              .having((e) => e.statusCode, 'statusCode', 403),
        ),
      );
    });

    test('form posts send urlencoded fields', () async {
      String? contentType;
      Map<String, String>? fields;
      final client = ApiClient(
        inner: MockClient((request) async {
          contentType = request.headers['content-type'];
          fields = Uri.splitQueryString(request.body);
          return http.Response(
            jsonEncode({'access_token': 'tok', 'token_type': 'bearer'}),
            200,
          );
        }),
      );

      final body = await client.postForm(
        '/auth/login',
        {'username': 'mom@x.com', 'password': 'pw'},
      ) as Map<String, dynamic>;

      expect(contentType, contains('application/x-www-form-urlencoded'));
      expect(fields, {'username': 'mom@x.com', 'password': 'pw'});
      expect(body['access_token'], 'tok');
    });

    test('socket errors become ApiException without a status', () async {
      final client = ApiClient(
        inner: MockClient((_) => throw const SocketException('down')),
      );

      expect(
        () => client.get('/tasks/'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', isNull)
              .having((e) => e.message, 'message', contains('Could not reach')),
        ),
      );
    });
  });
}
