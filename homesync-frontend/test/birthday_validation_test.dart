import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/views/onboarding/models/user_profile.dart';

void main() {
  final now = DateTime(2026, 6, 15);

  group('validateBirthday', () {
    test('accepts a valid past birthday', () {
      expect(validateBirthday('2016-04-23', now: now), isNull);
    });

    test('accepts today', () {
      expect(validateBirthday('2026-06-15', now: now), isNull);
    });

    test('rejects empty input', () {
      expect(validateBirthday('', now: now), isNotNull);
      expect(validateBirthday('   ', now: now), isNotNull);
    });

    test('rejects malformed input', () {
      expect(validateBirthday('04/23/2016', now: now), contains('YYYY-MM-DD'));
      expect(validateBirthday('2016-4-3', now: now), contains('YYYY-MM-DD'));
    });

    test('rejects impossible calendar dates', () {
      expect(
        validateBirthday('2024-02-30', now: now),
        contains('does not exist'),
      );
      expect(
        validateBirthday('2023-13-01', now: now),
        contains('does not exist'),
      );
    });

    test('rejects future dates', () {
      expect(validateBirthday('2026-06-16', now: now), contains('future'));
      expect(validateBirthday('5000-01-01', now: now), isNotNull);
    });

    test('rejects years before 1900', () {
      expect(validateBirthday('1899-05-05', now: now), contains('1900'));
    });

    test('rejects ages over 120', () {
      expect(validateBirthday('1905-01-01', now: now), contains('120'));
      expect(validateBirthday('1906-06-15', now: now), isNull);
    });
  });

  group('tryParseBirthday', () {
    test('returns the date for valid input', () {
      expect(
        tryParseBirthday('2016-04-23', now: now),
        DateTime(2016, 4, 23),
      );
    });

    test('returns null for invalid input', () {
      expect(tryParseBirthday('not-a-date', now: now), isNull);
      expect(tryParseBirthday('5000-01-01', now: now), isNull);
    });
  });

  group('ageOn', () {
    test('counts only full years', () {
      expect(ageOn(DateTime(2016, 4, 23), DateTime(2026, 6, 15)), 10);
      expect(ageOn(DateTime(2016, 4, 23), DateTime(2026, 4, 22)), 9);
      expect(ageOn(DateTime(2016, 4, 23), DateTime(2026, 4, 23)), 10);
    });
  });
}
