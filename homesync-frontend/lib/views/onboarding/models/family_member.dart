/// A family member added during onboarding.
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

enum FamilyRole { parent, child }

extension FamilyRoleLabel on FamilyRole {
  String get label => switch (this) {
        FamilyRole.parent => 'Parent',
        FamilyRole.child => 'Child',
      };
}
