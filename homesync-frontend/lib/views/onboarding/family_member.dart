import 'package:flutter/material.dart';

/// Account-role options for family members (parent side).
///
/// The shared [FamilyRole] enum elsewhere in onboarding has only
/// Parent/Child (tied to auth semantics, no Teen), so these screens keep
/// the spec's Kids/Teen/Parent set locally instead of widening it.
class FamilySetupOptions {
  static const List<String> roles = ['Kids', 'Teen', 'Parent'];

  static const List<String> genders = ['Female', 'Male', 'Other'];
}

/// One member of the family list shared by [FamilySetupScreen] and the
/// member edit screen.
///
/// Collected locally during onboarding: kids and teens are added as
/// backend child profiles on the first authenticated sync, while
/// additional parents join with the family invite code (see `HomeScreen`).
class FamilySetupMember {
  const FamilySetupMember({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.role,
    required this.avatarColor,
    required this.glyph,
    this.photoPath,
  });

  final String id;
  final String name;

  /// Age as entered (digits only); may be empty when unknown.
  final String age;

  /// One of [FamilySetupOptions.genders].
  final String gender;

  /// One of [FamilySetupOptions.roles].
  final String role;

  final Color avatarColor;

  /// Emoji glyph shown when [photoPath] is null.
  final String glyph;

  /// Local path of the picked profile picture, if any.
  final String? photoPath;

  bool get isParent => role == 'Parent';
  bool get isTeen => role == 'Teen';
  bool get isKids => role == 'Kids';

  /// Secondary line under the name on the member card.
  String get detail =>
      isParent ? 'Parent' : '$role · Age ${age.isEmpty ? '–' : age}';

  FamilySetupMember copyWith({
    String? name,
    String? age,
    String? gender,
    String? role,
    Color? avatarColor,
    String? glyph,
    String? photoPath,
    bool clearPhoto = false,
  }) {
    return FamilySetupMember(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      avatarColor: avatarColor ?? this.avatarColor,
      glyph: glyph ?? this.glyph,
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
    );
  }
}

/// Result popped by the member edit screen.
///
/// `null` (system back / back button) means "no change".
sealed class MemberEditResult {
  const MemberEditResult();
}

/// The member was edited; replace the matching list entry.
class MemberUpdated extends MemberEditResult {
  const MemberUpdated(this.member);

  final FamilySetupMember member;
}

/// The member was deleted; remove the matching list entry.
class MemberDeleted extends MemberEditResult {
  const MemberDeleted(this.memberId);

  final String memberId;
}
