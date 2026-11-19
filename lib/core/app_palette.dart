import 'package:flutter/material.dart';

/// Brand palette for GurasEMS.
///
/// Every colour is sampled directly from the supplied artwork so the UI can
/// never drift away from the brand assets it sits next to.
abstract final class AppPalette {
  /// Warm off-white canvas of the reference design.
  static const Color background = Color(0xFFFFF9F4);

  /// Primary brand maroon — primary actions and selected states.
  static const Color primary = Color(0xFF8B0D2D);

  /// Darker maroon used for the pressed state of primary actions.
  static const Color primaryDark = Color(0xFF690820);

  /// Tinted maroon wash for secondary-pressed and emphasised surfaces.
  static const Color primaryLight = Color(0xFFF8E8ED);

  /// Wordmark colour used for "Guras".
  static const Color navy = Color(0xFF02224E);

  /// Wordmark colour used for "EMS".
  static const Color blue = Color(0xFF0258D7);

  /// Colour of the "Student" label.
  static const Color maroon = Color(0xFFB40924);

  /// Soft pink used for the decorative accents.
  static const Color blush = Color(0xFFE89FA3);

  /// Muted colour for taglines and supporting copy.
  static const Color muted = Color(0xFF6E7180);

  /// Elevated surface, used by form fields.
  static const Color surface = Color(0xFFFFFFFF);

  /// Hairline border colour.
  static const Color hairline = Color(0xFFE6E3E3);

  /// Placeholder text colour.
  static const Color hint = Color(0xFF9A9AA4);

  /// Maroon ramp used across the student app.
  ///
  /// Values come from the brand source and every screen reads them through
  /// these tokens, so the dashboard, profile and any later screen stay on one
  /// ramp instead of drifting a few shades apart.
  static const Color maroon700 = Color(0xFF8B0D2D);
  static const Color maroon800 = Color(0xFF690820);
  static const Color maroon900 = Color(0xFF50061A);

  /// Tinted maroon wash for selected or emphasised surfaces.
  static const Color maroonSurface = Color(0xFFF8E8ED);

  /// Page background behind the dashboard cards.
  static const Color dashboardBg = Color(0xFFF5F6FA);

  /// Hairline border that separates white cards from the page (slate-100).
  static const Color cardBorder = AppSlate.shade100;

  /// Secondary/supporting copy on cards (grey-500).
  static const Color supportingText = AppGray.shade500;

  /// Headings on cards (grey-900).
  static const Color headingText = AppGray.shade900;

  /// "Ongoing" status accent.
  static const Color statusGreen = Color(0xFF059669);
  static const Color statusGreenBg = Color(0xFFECFDF5);
  static const Color statusGreenBorder = Color(0xFFD1FAE5);

  /// Success green — "present", "paid", "complete" and other positive states.
  static const Color success = Color(0xFF10B981);

  /// Warning amber — "leave", "due soon" and other cautionary states.
  static const Color warning = Color(0xFFF59E0B);

  /// Error red — destructive actions and failed states. Existing screens that
  /// read [accentRed] keep that shade; new code prefers this token.
  static const Color error = Color(0xFFEF4444);

  /// "Upcoming" status badge fill / copy / border on the Classes screen.
  static const Color upcomingBg = Color(0xFFEBF4FF);
  static const Color upcomingText = Color(0xFF1D4ED8);
  static const Color upcomingBorder = Color(0xFFDBEAFE);

  /// Accent red used for an outstanding amount on the Fees screen.
  static const Color accentRed = Color(0xFFE53E3E);

  /// "Pending" badge fill / copy / border (the reference's rose ramp).
  static const Color pendingBg = Color(0xFFFFF1F2);
  static const Color pendingText = Color(0xFFE11D48);
  static const Color pendingBorder = Color(0xFFFECDD3);

  /// Soft rose for due dates and the "Remaining" label of the fee bar.
  static const Color rose = Color(0xFFF43F5E);

  /// Settled half of the paid/remaining progress bar.
  ///
  /// An alias of [success]: there is exactly one success green in the palette,
  /// and the existing call site keeps its descriptive name.
  static const Color progressGreen = success;

  /// Outstanding half of the paid/remaining progress bar.
  static const Color progressRose = Color(0xFFFDA4AF);

  /// Product accent blue for informational highlights — the "view all" chip on
  /// the dashboard, reserves, the transport route line and the timetable
  /// accents. Visually distinct from the wordmark [blue]; never substituted.
  static const Color accentBlue = Color(0xFF2563EB);

  // ── Dashboard reference accents ─────────────────────────────────────────

  /// Yellow used to highlight a word in the dashboard hero headline.
  static const Color highlightYellow = Color(0xFFFFC41E);

  /// The dashboard feature grid intentionally gives each service its own hue
  /// (rather than one brand colour) so the nine tiles read as nine distinct
  /// services, matching the reference artwork. Each foreground below is paired
  /// with the matching soft [tile…Bg] surface.
  static const Color tileEmerald = Color(0xFF17BC82);
  static const Color tileBlue = Color(0xFF2865F1);
  static const Color tileOrange = Color(0xFFEF9B05);
  static const Color tileIndigo = Color(0xFF6166F8);
  static const Color tileRed = Color(0xFFE2412F);
  static const Color tileViolet = Color(0xFFA75BF9);
  static const Color tileAmber = Color(0xFFFCA20E);
  static const Color tileRose = Color(0xFFFA466D);
  static const Color tileTeal = Color(0xFF00B499);

  /// Soft pastel surfaces, one per feature tile.
  static const Color tileEmeraldBg = Color(0xFFE8F7F0);
  static const Color tileBlueBg = Color(0xFFEBF4FD);
  static const Color tileOrangeBg = Color(0xFFFDF4E5);
  static const Color tileIndigoBg = Color(0xFFF1F1FD);
  static const Color tileRedBg = Color(0xFFFDEFEE);
  static const Color tileVioletBg = Color(0xFFF5EFFD);
  static const Color tileAmberBg = Color(0xFFFEF9E5);
  static const Color tileRoseBg = Color(0xFFFCEEEE);
  static const Color tileTealBg = Color(0xFFE8F8F7);

  /// Soft blue surface behind the "Today's Classes" card icon.
  static const Color classIconBg = Color(0xFFEFF6FF);
}

/// Neutral grey ramp (Tailwind `gray` scale), sampled from the reference.
///
/// The neutral levels recur across nearly every screen — icons, hairlines,
/// disabled controls and secondary copy — so a screen reaches for the ramp
/// instead of a one-off hex. The three most common stops also carry semantic
/// names in [AppPalette] (grey-500 → [AppPalette.supportingText], grey-900 →
/// [AppPalette.headingText]) and those aliases are the preferred reads.
///
/// Grey and [AppSlate] are two visually distinct families; they are never
/// interchanged.
abstract final class AppGray {
  static const Color shade50 = Color(0xFFF9FAFB);
  static const Color shade100 = Color(0xFFF3F4F6);
  static const Color shade200 = Color(0xFFE5E7EB);
  static const Color shade300 = Color(0xFFD1D5DB);
  static const Color shade400 = Color(0xFF9CA3AF);
  static const Color shade500 = Color(0xFF6B7280);
  static const Color shade600 = Color(0xFF4B5563);
  static const Color shade700 = Color(0xFF374151);
  static const Color shade800 = Color(0xFF1F2937);
  static const Color shade900 = Color(0xFF111827);
}

/// Cool blue-grey ramp (Tailwind `slate` scale), sampled from the reference.
///
/// Used for sheet text and hairline borders on the detail screens. Distinct
/// from [AppGray]; the two families never share a stop.
abstract final class AppSlate {
  static const Color shade50 = Color(0xFFF8FAFC);
  static const Color shade100 = Color(0xFFF1F5F9);
  static const Color shade200 = Color(0xFFE2E8F0);
  static const Color shade300 = Color(0xFFCBD5E1);
  static const Color shade400 = Color(0xFF94A3B8);
  static const Color shade500 = Color(0xFF64748B);
  static const Color shade600 = Color(0xFF475569);
  static const Color shade700 = Color(0xFF334155);
  static const Color shade800 = Color(0xFF1E293B);
  static const Color shade900 = Color(0xFF0F172A);
}

/// Absolute paths of every bundled asset.
///
/// Keeping them in one place means a typo fails loudly at a single call site
/// instead of silently breaking image loading somewhere in the UI.
abstract final class AppAssets {
  /// The GurasEMS brand mark.
  ///
  /// This is the alpha-keyed build of [logoSource]. The source artwork is a
  /// JPEG-derived red emblem flattened onto a solid (254,254,254) white square,
  /// so drawing it directly left a visible cool-white rectangle floating on the
  /// warm [AppPalette.background] of the splash and login screens. The white is
  /// pure negative space (every light pixel sits outside the emblem, none is a
  /// detail), so it is keyed out with an un-blended alpha ramp: the emblem's
  /// shape, red and anti-aliased edges are unchanged, only the surrounding
  /// square becomes transparent.
  static const String logo = 'assets/images/logo_transparent.png';

  /// The original opaque brand mark, retained on disk as the source of [logo].
  static const String logoSource = 'assets/images/logo.png';

  /// School photograph of the campus building, shown at the bottom of the
  /// splash screen and behind the dashboard hero card's motto.
  static const String school = 'assets/images/hhv.png';
}
