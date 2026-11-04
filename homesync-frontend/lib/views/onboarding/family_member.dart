import 'dart:typed_data';

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
<<<<<<< HEAD
/// Collected locally during onboarding: kids and teens are added as
/// backend child profiles on the first authenticated sync, while
/// additional parents join with the family invite code (see `HomeScreen`).
=======
/// Local UI state only: no API call persists these members yet, except
/// the avatar upload once [serverId] is known (see [MembersApi]).
>>>>>>> 48e512845754349ab492b180d4e531d2082a5fd4
class FamilySetupMember {
  const FamilySetupMember({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.role,
    required this.avatarColor,
    required this.glyph,
    this.serverId,
    this.avatarUrl,
    this.photoBytes,
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

  /// Emoji glyph kept for legacy tiles; the photo placeholder now uses
  /// the member's initials (see [MemberAvatar]).
  final String glyph;

  /// Backend user id, when this member is synced. `null` for
  /// local-only onboarding members (avatar upload unavailable).
  final int? serverId;

  /// Persisted avatar reference from `POST /members/{id}/avatar`
  /// (relative path such as `/avatars/....png`). Survives refresh.
  final String? avatarUrl;

  /// Freshly picked photo bytes for the web-safe preview. Transient:
  /// upload it, then rely on [avatarUrl].
  final Uint8List? photoBytes;

  bool get isParent => role == 'Parent';
  bool get isTeen => role == 'Teen';
  bool get isKids => role == 'Kids';

  /// Whether any picture (fresh bytes or persisted URL) is set.
  bool get hasPhoto => photoBytes != null || avatarUrl != null;

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
    int? serverId,
    String? avatarUrl,
    Uint8List? photoBytes,
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
      serverId: serverId ?? this.serverId,
      avatarUrl: clearPhoto ? null : (avatarUrl ?? this.avatarUrl),
      photoBytes: clearPhoto ? null : (photoBytes ?? this.photoBytes),
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
