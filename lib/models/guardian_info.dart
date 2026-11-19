import 'package:flutter/foundation.dart';

/// One guardian's record on the Guardian Information screen.
///
/// Immutable: the edit sheet returns a new [GuardianInfo] and the screen swaps
/// it in, rather than mutating fields in place.
@immutable
class Guardian {
  const Guardian({
    required this.fullName,
    required this.relation,
    required this.occupation,
    required this.phone,
    required this.email,
    this.address,
  });

  final String fullName;
  final String relation;
  final String occupation;
  final String phone;
  final String email;

  /// Only the primary guardian carries an address row in the reference layout,
  /// so the secondary guardian leaves it null.
  final String? address;

  Guardian copyWith({
    String? fullName,
    String? relation,
    String? occupation,
    String? phone,
    String? email,
    String? address,
  }) {
    return Guardian(
      fullName: fullName ?? this.fullName,
      relation: relation ?? this.relation,
      occupation: occupation ?? this.occupation,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
    );
  }
}

/// The guardian record shown on the Guardian Information screen.
///
/// The emergency contact is derived from the two guardians rather than stored
/// alongside them: it names the primary guardian and repeats both guardians'
/// numbers, so keeping a separate copy would let the card go stale the moment
/// an edit changes a name or a phone number.
@immutable
class GuardianInfo {
  const GuardianInfo({
    required this.father,
    required this.mother,
    this.relationship = 'Father / Legal Guardian',
  });

  final Guardian father;
  final Guardian mother;

  /// How the primary emergency contact relates to the student.
  final String relationship;

  /// Emergency contact person — always the primary guardian, e.g.
  /// "Hari Karki (Father)".
  String get emergencyContactPerson =>
      '${father.fullName} (${father.relation})';

  /// The emergency card mirrors the guardians' numbers for the same reason.
  String get emergencyPrimaryPhone => father.phone;
  String get emergencySecondaryPhone => mother.phone;

  GuardianInfo copyWith({
    Guardian? father,
    Guardian? mother,
    String? relationship,
  }) {
    return GuardianInfo(
      father: father ?? this.father,
      mother: mother ?? this.mother,
      relationship: relationship ?? this.relationship,
    );
  }
}

/// Placeholder guardians for the signed-in student — the sample record the
/// reference artwork presents, replaced by the student API in production.
const GuardianInfo kPlaceholderGuardians = GuardianInfo(
  father: Guardian(
    fullName: 'Hari Karki',
    relation: 'Father',
    occupation: 'Civil Engineer',
    phone: '9851023456',
    email: 'hari.karki@gmail.com',
    address: 'Main Chowk, Biratnagar, Morang',
  ),
  mother: Guardian(
    fullName: 'Sita Karki',
    relation: 'Mother',
    occupation: 'Educator / Teacher',
    phone: '9842011223',
    email: 'sita.karki@gmail.com',
  ),
);
