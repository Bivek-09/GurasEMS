/// Sample learner record shared by every screen that shows the signed-in
/// student — today the dashboard header and the profile screens.
///
/// One source of truth so the name, class and portrait can never drift apart
/// between screens. Replaced by the authentication response once a real
/// backend is wired in; do not invent additional personal data here.
abstract final class StudentProfile {
  static const String name = 'Sujan Karki';

  static const String registrationId = 'STU-2083-0156';

  static const String grade = '10';

  static const String section = 'A';

  static const String academicYear = '2083/84';

  /// Sample portrait. [UserAvatar]'s initials fallback covers the offline and
  /// failure cases, so the UI never depends on the network.
  static const String avatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAJgjZQlgRhz9OST16a_'
      'MbVAjBSsZngDFS4NyN4lNuQrTOSn_GiGCeqOeR_TDwHTV-gll_LejysWTX1tqbP2Mep'
      'dkywfl0mppCHESewPlkUNcmUVso4PCJx1rBu0DJCJ6yavoY7jdOJtQDRQT-XX5j_'
      'NpGpKIotd668vELVFKLfa9FcVMRjt2LLqVM9YsOiESUjzbinK-gZrVCeSkaA75YiW'
      'NyOS1fRW_Pbf7gbzwwNRh7Nx9Eq0Jc';
}
