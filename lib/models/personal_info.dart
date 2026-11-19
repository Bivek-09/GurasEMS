import 'package:flutter/foundation.dart';

/// The student's personal record shown on the Personal Information screen.
///
/// Immutable: the edit bottom sheet returns a new instance and the screen
/// swaps it in, rather than mutating fields in place.
@immutable
class PersonalInfo {
  const PersonalInfo({
    required this.fullName,
    required this.dob,
    required this.gender,
    required this.bloodGroup,
    required this.nationality,
    required this.phone,
    required this.email,
    required this.address,
  });

  final String fullName;
  final String dob;
  final String gender;
  final String bloodGroup;
  final String nationality;
  final String phone;
  final String email;
  final String address;

  PersonalInfo copyWith({
    String? fullName,
    String? dob,
    String? gender,
    String? bloodGroup,
    String? nationality,
    String? phone,
    String? email,
    String? address,
  }) {
    return PersonalInfo(
      fullName: fullName ?? this.fullName,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      nationality: nationality ?? this.nationality,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
    );
  }
}

/// Placeholder record for the signed-in student.
const PersonalInfo kPlaceholderStudent = PersonalInfo(
  fullName: 'Sujan Karki',
  dob: '2059-05-12 (BS)',
  gender: 'Male',
  bloodGroup: 'B+',
  nationality: 'Nepali',
  phone: '9841234567',
  email: 'sujan.karki@student.edu.np',
  address: 'Main Chowk, Biratnagar\nMorang, Nepal',
);
