import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/views/auth/login_screen.dart';
import 'package:homesync/views/onboarding/choose_mode_screen.dart';
import 'package:homesync/views/onboarding/splash_screen.dart';

Future<void> _pumpSplash(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
  await tester.pumpAndSettle();
}

TextStyle _styleOf(WidgetTester tester, String text) {
  final widget = tester.widget<Text>(find.text(text));
  final style = widget.style;
  expect(style, isNotNull, reason: '$text has an explicit style');
  return style!;
}

void main() {
  testWidgets('Splash matches the Figma 01 spec', (tester) async {
    await _pumpSplash(tester);

    // Solid cream background, edge to edge (Scaffold paints it all).
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, const Color(0xFFF9F8F6));

    // Brand: exact copy, Nunito, sizes, weights, colors.
    final title = _styleOf(tester, 'HomeSync');
    expect(title.fontFamily, 'Nunito');
    expect(title.fontSize, 42);
    expect(title.fontWeight, FontWeight.w800);
    expect(title.color, const Color(0xFF2B3A2B));
    final tagline = _styleOf(tester, 'Plan. Share. Grow Together.');
    expect(tagline.fontFamily, 'Nunito');
    expect(tagline.fontSize, 16);
    expect(tagline.fontWeight, FontWeight.w500);
    expect(tagline.color, const Color(0xFF7C877A));

    // Illustration slot: local asset, exactly 260 x 205, aspect kept.
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.width, 260);
    expect(image.height, 205);
    expect(image.fit, BoxFit.contain);
    expect(
      (image.image as AssetImage).assetName,
      'assets/homePageImg.png',
    );

    // Buttons: exact labels, order, and 12px gap.
    expect(find.widgetWithText(ElevatedButton, 'Get Started'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Log In'), findsOneWidget);
    final primary = _styleOf(tester, 'Get Started');
    expect(primary.fontFamily, 'Nunito');
    expect(primary.fontSize, 16);
    expect(primary.fontWeight, FontWeight.w800);
    expect(
      tester.getTopLeft(find.text('Log In')).dy -
          tester.getBottomLeft(find.text('Get Started')).dy,
      greaterThanOrEqualTo(12),
    );
  });

  testWidgets('Get Started opens the choose mode screen', (tester) async {
    await _pumpSplash(tester);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.byType(ChooseModeScreen), findsOneWidget);
  });

  testWidgets('Log In opens the login screen', (tester) async {
    await _pumpSplash(tester);

    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
