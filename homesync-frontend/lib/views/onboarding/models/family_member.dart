import 'user_profile.dart';

/// A family member managed from settings.
///
/// (Kept for the upcoming settings-menu family management; onboarding now
/// only creates the signed-in user's own [UserProfile].)
class FamilyMember {
  FamilyMember({
    required this.name,
    required this.age,
    required this.role,
  });

  final String name;
  final int age;
  final FamilyRole role;
}
