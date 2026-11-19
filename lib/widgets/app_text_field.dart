import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';

/// Standard labelled form field used across the app.
///
/// Border, fill, focus and error colours come from the shared
/// `inputDecorationTheme`; this widget only adds the label row and, for password
/// fields, a visibility toggle. It is a [FormField], so it participates in
/// `Form.validate()` and shows inline validation messages.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.icon,
    this.hint,
    this.controller,
    this.keyboardType,
    this.obscure = false,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.enabled = true,
    this.autofillHints,
    this.focusNode,
    this.helperText,
  });

  final String label;
  final IconData icon;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  /// When true the field masks its value and shows a visibility toggle.
  final bool obscure;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final bool enabled;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final String? helperText;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 13.5 * s,
            fontWeight: FontWeight.w600,
            color: AppPalette.navy,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: 8 * s),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscure ? _obscure : false,
          obscuringCharacter: '•',
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          style: TextStyle(fontSize: 15 * s, color: AppPalette.navy),
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: Icon(widget.icon, size: 20, color: AppPalette.muted),
            suffixIcon: widget.obscure
                ? IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    tooltip: _obscure ? 'Show password' : 'Hide password',
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppPalette.muted,
                    ),
                  )
                : null,
            helperText: widget.helperText,
          ),
        ),
      ],
    );
  }
}
