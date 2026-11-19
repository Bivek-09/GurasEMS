import 'package:flutter/material.dart';

import 'app_page_transitions.dart';
import 'app_palette.dart';
import 'app_system_ui.dart';

/// Shared corner radii so cards, fields and buttons line up across screens.
abstract final class AppRadii {
  static const double button = 14;
  static const double field = 14;
  static const double card = 18;
  static const double sheet = 28;

  /// In-card tiles, list rows and panels — the radius the reference reuses
  /// between a card and its contents so the two read as one family.
  static const double block = 16;

  /// Boxes, chips and inset panels living inside a card or sheet.
  static const double inner = 12;

  /// Small controls: compact inputs, tab pills and secondary buttons.
  static const double small = 10;

  /// Badges and micro-controls inside cards and sheets.
  static const double tiny = 8;

  /// Tags and tiny pills inside cards and sheets.
  static const double micro = 6;

  /// Fully rounded — pills, status badges, avatars and drag handles.
  static const double pill = 999;
}

/// Shared spacing scale (logical pixels, before the responsive scale factor).
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double block = 24;
  static const double xxl = 28;
}

/// Builds the single [ThemeData] every screen inherits.
///
/// All button, field, card and feedback styling lives here, so a screen can add
/// a control without re-deriving the brand's pressed, focused or disabled
/// states. Screens should only override a style when the semantic colour must
/// differ — for example a destructive red action or an in-card status badge.
ThemeData buildAppTheme() {
  final ColorScheme scheme =
      ColorScheme.fromSeed(
        seedColor: AppPalette.primary,
        brightness: Brightness.light,
        surface: AppPalette.background,
      ).copyWith(
        primary: AppPalette.primary,
        onPrimary: Colors.white,
        surface: AppPalette.surface,
        error: AppPalette.accentRed,
        onError: Colors.white,
      );

  return ThemeData(
    useMaterial3: true,
    // Brand typeface, bundled so typography renders identically offline.
    fontFamily: 'PlusJakartaSans',
    colorScheme: scheme,
    scaffoldBackgroundColor: AppPalette.background,
    // One shared motion language for every push, so navigation feels
    // consistent across Android, iOS and desktop.
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: AppPageTransitionsBuilder(),
        TargetPlatform.iOS: AppPageTransitionsBuilder(),
        TargetPlatform.macOS: AppPageTransitionsBuilder(),
        TargetPlatform.windows: AppPageTransitionsBuilder(),
        TargetPlatform.linux: AppPageTransitionsBuilder(),
      },
    ),
    // Every header in the app is maroon, so a future [AppBar] inherits light
    // system icons without each screen restating it. Screens that draw their
    // own header get their style from the route region in `main.dart`.
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: AppSystemUi.onDarkHeader,
    ),
    dividerTheme: const DividerThemeData(
      color: AppPalette.cardBorder,
      thickness: 1,
      space: 1,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppPalette.primary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppPalette.surface,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(
        color: AppPalette.hint,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: const TextStyle(color: AppPalette.muted),
      errorStyle: const TextStyle(
        color: AppPalette.accentRed,
        fontWeight: FontWeight.w500,
      ),
      border: _fieldBorder(AppPalette.hairline),
      enabledBorder: _fieldBorder(AppPalette.hairline),
      focusedBorder: _fieldBorder(AppPalette.primary, width: 1.6),
      errorBorder: _fieldBorder(AppPalette.accentRed),
      focusedErrorBorder: _fieldBorder(AppPalette.accentRed, width: 1.6),
    ),
    cardTheme: CardThemeData(
      color: AppPalette.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: const BorderSide(color: AppPalette.cardBorder),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppPalette.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppGray.shade900,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.inner),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(style: _filledStyle()),
    elevatedButtonTheme: ElevatedButtonThemeData(style: _filledStyle()),
    outlinedButtonTheme: OutlinedButtonThemeData(style: _outlinedStyle()),
    textButtonTheme: TextButtonThemeData(style: _textStyle()),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: const WidgetStatePropertyAll<Color>(
          AppPalette.maroon800,
        ),
        overlayColor: _overlay(pressed: AppPalette.primaryLight),
        shape: const WidgetStatePropertyAll<OutlinedBorder>(CircleBorder()),
      ),
    ),
  );
}

/// Border used by every text field state, so focus/error only change the colour
/// and width rather than the shape.
OutlineInputBorder _fieldBorder(Color color, {double width = 1}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadii.field),
    borderSide: BorderSide(color: color, width: width),
  );
}

/// Resolves the pressed / hovered overlay for a control.
///
/// A pressed colour is applied opaque so filled buttons read as an immediately
/// darker maroon, while hover/focus use a light wash so they stay subtle.
WidgetStateProperty<Color?> _overlay({required Color pressed, Color? hovered}) {
  return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
    if (states.contains(WidgetState.pressed)) return pressed;
    if (states.contains(WidgetState.hovered) ||
        states.contains(WidgetState.focused)) {
      return (hovered ?? pressed).withValues(alpha: 0.12);
    }
    return null;
  });
}

ButtonStyle _filledStyle() {
  return ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) return AppGray.shade200;
      return AppPalette.primary;
    }),
    foregroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) return AppGray.shade400;
      return Colors.white;
    }),
    overlayColor: _overlay(pressed: AppPalette.primaryDark),
    minimumSize: const WidgetStatePropertyAll<Size>(Size(64, 52)),
    padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
      EdgeInsets.symmetric(horizontal: 20),
    ),
    shape: WidgetStatePropertyAll<OutlinedBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.button),
      ),
    ),
    textStyle: const WidgetStatePropertyAll<TextStyle>(
      TextStyle(
        fontSize: 15.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    ),
  );
}

ButtonStyle _outlinedStyle() {
  return ButtonStyle(
    backgroundColor: const WidgetStatePropertyAll<Color>(AppPalette.surface),
    foregroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) return AppGray.shade400;
      return AppPalette.primary;
    }),
    overlayColor: _overlay(pressed: AppPalette.primaryLight),
    side: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      final Color color = states.contains(WidgetState.disabled)
          ? AppGray.shade300
          : AppPalette.primary;
      return BorderSide(color: color, width: 1.4);
    }),
    minimumSize: const WidgetStatePropertyAll<Size>(Size(64, 52)),
    padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
      EdgeInsets.symmetric(horizontal: 20),
    ),
    shape: WidgetStatePropertyAll<OutlinedBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.button),
      ),
    ),
    textStyle: const WidgetStatePropertyAll<TextStyle>(
      TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
    ),
  );
}

ButtonStyle _textStyle() {
  return ButtonStyle(
    foregroundColor: const WidgetStatePropertyAll<Color>(AppPalette.primary),
    overlayColor: _overlay(pressed: AppPalette.primaryLight),
    minimumSize: const WidgetStatePropertyAll<Size>(Size(48, 40)),
    textStyle: const WidgetStatePropertyAll<TextStyle>(
      TextStyle(fontWeight: FontWeight.w600),
    ),
  );
}

/// Shared card shadows.
///
/// Two levels only: the resting lift for white cards on the page background,
/// and the stronger lift for feature cards. The values are identical to the
/// ones the dashboard cards already shipped with, so adopting the tokens
/// changes nothing visually — it just pins the two levels in one place so new
/// screens cannot invent a third.
abstract final class AppShadows {
  /// Resting elevation for white cards on the page background.
  static List<BoxShadow> card(double s) => <BoxShadow>[
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 18 * s,
      offset: Offset(0, 4 * s),
    ),
  ];

  /// Feature elevation for the dashboard hero.
  static List<BoxShadow> feature(double s) => <BoxShadow>[
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.18),
      blurRadius: 18 * s,
      offset: Offset(0, 6 * s),
    ),
  ];
}
