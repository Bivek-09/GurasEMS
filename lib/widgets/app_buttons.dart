import 'package:flutter/material.dart';

import '../core/app_palette.dart';
import '../core/app_theme.dart';

/// The maroon primary action used across the app.
///
/// Pressed (darker maroon), disabled (muted grey) and loading states are defined
/// here and inherited from the shared theme tokens, so a primary action behaves
/// identically on every screen. While [loading] is true the button keeps its
/// maroon surface and size but stops accepting taps, which prevents duplicate
/// submissions without the layout jumping.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final bool interactive = onPressed != null && !loading;

    return SizedBox(
      width: expand ? double.infinity : null,
      height: 52,
      child: FilledButton(
        onPressed: interactive ? onPressed : null,
        style: _style(loading),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (icon != null) ...<Widget>[
                    Icon(icon, size: 19),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  ButtonStyle _style(bool loading) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.disabled)) {
          return loading ? AppPalette.primary : AppGray.shade200;
        }
        return AppPalette.primary;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.disabled)) {
          return loading ? Colors.white : AppGray.shade400;
        }
        return Colors.white;
      }),
      overlayColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        return states.contains(WidgetState.pressed)
            ? AppPalette.primaryDark
            : null;
      }),
      elevation: const WidgetStatePropertyAll<double>(0),
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
}

/// White secondary action with a maroon outline.
///
/// Pressed state washes the surface in the pale maroon tint, matching the
/// reference's secondary treatment.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final bool interactive = onPressed != null && !loading;

    return SizedBox(
      width: expand ? double.infinity : null,
      height: 52,
      child: OutlinedButton(
        onPressed: interactive ? onPressed : null,
        style: _style(loading),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(AppPalette.primary),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (icon != null) ...<Widget>[
                    Icon(icon, size: 19),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  ButtonStyle _style(bool loading) {
    return ButtonStyle(
      backgroundColor: const WidgetStatePropertyAll<Color>(AppPalette.surface),
      foregroundColor: WidgetStateProperty.resolveWith((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.disabled)) {
          return loading ? AppPalette.primary : AppGray.shade400;
        }
        return AppPalette.primary;
      }),
      overlayColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        return states.contains(WidgetState.pressed)
            ? AppPalette.primaryLight
            : null;
      }),
      side: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        final Color color = states.contains(WidgetState.disabled)
            ? (loading ? AppPalette.primary : AppGray.shade300)
            : AppPalette.primary;
        return BorderSide(color: color, width: 1.4);
      }),
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
}
