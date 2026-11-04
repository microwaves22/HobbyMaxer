import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/views/auth/login_screen.dart';
import 'package:homesync/views/onboarding/profile_setup_screen.dart';

Finder _fieldWithHint(String hint) => find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == hint,
    );

/// The eye toggle button inside the password field with [hint].
Finder _eyeFor(String hint) => find.descendant(
      of: _fieldWithHint(hint),
      matching: find.byType(IconButton),
    );

bool _isObscured(String hint) {
  final field = find.byWidgetPredicate(
    (w) => w is TextField && w.decoration?.hintText == hint,
  );
  // ignore: avoid-non-null-assertion (test helper; field must exist)
  final widget = field.evaluate().single.widget as TextField;
  return widget.obscureText;
}

void main() {
  group('Password visibility toggles', () {
    testWidgets('login password is hidden by default and toggles repeatedly',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pumpAndSettle();

      final passwordField = _fieldWithHint('Password');
      expect(passwordField, findsOneWidget);
      expect(_isObscured('Password'), isTrue);
      expect(
        find.descendant(
          of: _eyeFor('Password'),
          matching: find.byIcon(Icons.visibility_off),
        ),
        findsOneWidget,
      );

      await tester.enterText(passwordField, 'secret123');
      await tester.pump();
      final controller =
          tester.widget<TextField>(passwordField).controller!;
      controller.selection = const TextSelection.collapsed(offset: 3);
      await tester.pump();

      // Show: icon flips, text and cursor stay intact.
      await tester.tap(_eyeFor('Password'));
      await tester.pump();
      expect(_isObscured('Password'), isFalse);
      expect(
        find.descendant(
          of: _eyeFor('Password'),
          matching: find.byIcon(Icons.visibility),
        ),
        findsOneWidget,
      );
      expect(controller.text, 'secret123');
      expect(controller.selection,
          const TextSelection.collapsed(offset: 3));

      // Hide again, then show once more: toggling works repeatedly.
      await tester.tap(_eyeFor('Password'));
      await tester.pump();
      expect(_isObscured('Password'), isTrue);
      expect(controller.text, 'secret123');

      await tester.tap(_eyeFor('Password'));
      await tester.pump();
      expect(_isObscured('Password'), isFalse);
      expect(controller.text, 'secret123');
    });

    testWidgets('create-account passwords toggle independently', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ProfileSetupScreen(focusAreas: ['a'])),
      );
      await tester.pumpAndSettle();

      for (final hint in ['Password', 'Confirm Password']) {
        expect(_fieldWithHint(hint), findsOneWidget);
        expect(_isObscured(hint), isTrue);
        expect(
          find.descendant(
            of: _eyeFor(hint),
            matching: find.byIcon(Icons.visibility_off),
          ),
          findsOneWidget,
        );
      }

      await tester.enterText(_fieldWithHint('Password'), 'secret123');
      await tester.enterText(_fieldWithHint('Confirm Password'), 'secret123');
      await tester.pump();
      final passwordController =
          tester.widget<TextField>(_fieldWithHint('Password')).controller!;
      passwordController.selection =
          const TextSelection.collapsed(offset: 3);
      await tester.pump();

      // Toggling Password leaves Confirm Password hidden.
      await tester.tap(_eyeFor('Password'));
      await tester.pump();
      expect(_isObscured('Password'), isFalse);
      expect(_isObscured('Confirm Password'), isTrue);
      expect(passwordController.text, 'secret123');
      expect(passwordController.selection,
          const TextSelection.collapsed(offset: 3));

      // Toggling Confirm Password leaves Password visible.
      await tester.tap(_eyeFor('Confirm Password'));
      await tester.pump();
      expect(_isObscured('Password'), isFalse);
      expect(_isObscured('Confirm Password'), isFalse);

      // Each toggles back independently, repeatedly.
      await tester.tap(_eyeFor('Password'));
      await tester.pump();
      expect(_isObscured('Password'), isTrue);
      expect(_isObscured('Confirm Password'), isFalse);

      await tester.tap(_eyeFor('Confirm Password'));
      await tester.pump();
      expect(_isObscured('Password'), isTrue);
      expect(_isObscured('Confirm Password'), isTrue);
    });

    testWidgets('create-account requires matching passwords', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ProfileSetupScreen(focusAreas: ['a'])),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
          _fieldWithHint('Email address'), 'mom@x.com');
      await tester.enterText(_fieldWithHint('Password'), 'secret123');
      await tester.enterText(_fieldWithHint('Confirm Password'), 'other456');
      await tester.enterText(_fieldWithHint('Enter name'), 'Mom');
      await tester.enterText(
          _fieldWithHint('Birthday (YYYY-MM-DD)'), '1990-01-01');
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match.'), findsOneWidget);
    });
  });
}
