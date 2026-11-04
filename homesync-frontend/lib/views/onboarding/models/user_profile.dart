/// Profile created during single-user onboarding.
class UserProfile {
  UserProfile({
    required this.name,
    this.birthday,
    required this.role,
    required this.mode,
  });

  final String name;

  /// Null for backend-synced profiles: the API tracks no birthday.
  final DateTime? birthday;
  final FamilyRole role;
  final FamilyMode mode;

  bool get isParent => role == FamilyRole.parent;

  /// Whole years old, or null when the birthday is unknown.
  int? age({DateTime? on}) =>
      birthday == null ? null : ageOn(birthday!, on ?? DateTime.now());
}

enum FamilyRole { parent, child }

extension FamilyRoleLabel on FamilyRole {
  String get label => switch (this) {
        FamilyRole.parent => 'Parent',
        FamilyRole.child => 'Kid',
      };
}

enum FamilyMode { kids, teen, parent }

extension FamilyModeLabel on FamilyMode {
  String get label => switch (this) {
        FamilyMode.kids => 'Kids',
        FamilyMode.teen => 'Teens',
        FamilyMode.parent => 'Parent',
      };
}

/// Whole years between [birthday] and [on].
int ageOn(DateTime birthday, DateTime on) {
  var years = on.year - birthday.year;
  if (on.month < birthday.month ||
      (on.month == birthday.month && on.day < birthday.day)) {
    years--;
  }
  return years;
}

/// Strict `YYYY-MM-DD` birthday validation.
///
/// Returns an error message for empty input, malformed dates, impossible
/// calendar dates (e.g. 2024-02-30), future dates, years before 1900, or
/// ages over 120. Returns `null` when the input is a valid birthday.
String? validateBirthday(String input, {DateTime? now}) {
  final text = input.trim();
  if (text.isEmpty) return 'Enter a birthday.';
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(text);
  if (match == null) {
    return 'Use the format YYYY-MM-DD (e.g. 2016-04-23).';
  }
  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  final date = DateTime.tryParse(text);
  if (date == null ||
      date.year != year ||
      date.month != month ||
      date.day != day) {
    return 'That date does not exist.';
  }
  final today = now ?? DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  if (date.isAfter(todayDate)) {
    return 'Birthday cannot be in the future.';
  }
  if (year < 1900) return 'Year must be 1900 or later.';
  if (ageOn(date, todayDate) > 120) {
    return 'Year must be within the last 120 years.';
  }
  return null;
}

/// Parses [input] into a birthday, or returns `null` when
/// [validateBirthday] rejects it.
DateTime? tryParseBirthday(String input, {DateTime? now}) {
  if (validateBirthday(input, now: now) != null) return null;
  return DateTime.parse(input.trim());
}
