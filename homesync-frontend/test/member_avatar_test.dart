import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/core/widgets/member_avatar.dart';

// 1x1 transparent PNG.
Uint8List _testPng() => base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
    );

Future<void> _pumpAvatar(
  WidgetTester tester,
  MemberAvatar avatar,
) async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: avatar)));
  await tester.pump();
}

void main() {
  test('avatarInitials uses first and last name initials', () {
    expect(avatarInitials('Maya Chen'), 'MC');
    expect(avatarInitials('Maya'), 'MA');
    expect(avatarInitials('  '), '');
    expect(avatarInitials(''), '');
  });

  test('resolveAvatarUrl joins relative paths with the base URL', () {
    expect(resolveAvatarUrl(null, 'http://localhost:8000'), isNull);
    expect(resolveAvatarUrl('', 'http://localhost:8000'), isNull);
    expect(
      resolveAvatarUrl('/avatars/a.png', 'http://localhost:8000'),
      'http://localhost:8000/avatars/a.png',
    );
    expect(
      resolveAvatarUrl('http://cdn/x.png', 'http://localhost:8000'),
      'http://cdn/x.png',
    );
  });

  testWidgets('placeholder shows initials when no picture is set',
      (tester) async {
    await _pumpAvatar(
      tester,
      const MemberAvatar(name: 'Maya Chen', size: 40),
    );

    expect(find.text('MC'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('placeholder shows an icon when the name is empty',
      (tester) async {
    await _pumpAvatar(tester, const MemberAvatar(name: '  ', size: 40));

    expect(find.byIcon(Icons.person_outline), findsOneWidget);
  });

  testWidgets('bytes preview renders Image.memory without File',
      (tester) async {
    await _pumpAvatar(
      tester,
      MemberAvatar(name: 'Maya', bytes: _testPng(), size: 40),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<MemoryImage>());
    expect(find.text('MA'), findsNothing);
  });

  testWidgets('persisted URL renders Image.network', (tester) async {
    await _pumpAvatar(
      tester,
      const MemberAvatar(
        name: 'Maya',
        imageUrl: 'http://localhost:8000/avatars/a.png',
        size: 40,
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<NetworkImage>());
  });

  testWidgets('bytes take precedence over the persisted URL',
      (tester) async {
    await _pumpAvatar(
      tester,
      MemberAvatar(
        name: 'Maya',
        bytes: _testPng(),
        imageUrl: 'http://localhost:8000/avatars/a.png',
        size: 40,
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<MemoryImage>());
  });
}
