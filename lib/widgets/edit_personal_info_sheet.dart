import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';
import '../core/app_theme.dart' show AppRadii, AppSpacing;
import '../models/personal_info.dart';

/// Modal bottom sheet for editing the personal record.
///
/// Presented when the on-screen "Edit Information" button is tapped. Saves a
/// new [PersonalInfo] back to the screen, which then refreshes the card and
/// confirms with a toast. The sheet itself does not persist anything — that is
/// the screen's job.
class EditPersonalInfoSheet extends StatefulWidget {
  const EditPersonalInfoSheet({super.key, required this.initial});

  final PersonalInfo initial;

  static const List<String> genderOptions = <String>['Male', 'Female', 'Other'];

  @override
  State<EditPersonalInfoSheet> createState() => _EditPersonalInfoSheetState();
}

class _EditPersonalInfoSheetState extends State<EditPersonalInfoSheet> {
  late final TextEditingController _name;
  late final TextEditingController _dob;
  late final TextEditingController _bloodGroup;
  late final TextEditingController _nationality;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _address;
  late String _gender;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial.fullName);
    _dob = TextEditingController(text: widget.initial.dob);
    _bloodGroup = TextEditingController(text: widget.initial.bloodGroup);
    _nationality = TextEditingController(text: widget.initial.nationality);
    _phone = TextEditingController(text: widget.initial.phone);
    _email = TextEditingController(text: widget.initial.email);
    _address = TextEditingController(text: widget.initial.address);
    _gender = widget.initial.gender;
  }

  @override
  void dispose() {
    _name.dispose();
    _dob.dispose();
    _bloodGroup.dispose();
    _nationality.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    super.dispose();
  }

  void _cancel() => Navigator.of(context).pop();

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      widget.initial.copyWith(
        fullName: _name.text.trim(),
        dob: _dob.text.trim(),
        gender: _gender,
        bloodGroup: _bloodGroup.text.trim(),
        nationality: _nationality.text.trim(),
        phone: _phone.text.trim(),
        email: _email.text.trim(),
        address: _address.text.trim(),
      ),
    );
  }

  InputDecoration _decor(String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.small),
      borderSide: const BorderSide(color: AppGray.shade200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.small),
      borderSide: const BorderSide(color: AppGray.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.small),
      borderSide: const BorderSide(color: AppPalette.maroon800, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: AppSpacing.md,
    ),
  );

  TextFormField _field(
    TextEditingController controller, {
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: 14 * AppLayout.scaleOf(context),
        color: AppPalette.headingText,
      ),
      decoration: _decor(label),
      validator: (String? value) {
        if (required && (value == null || value.trim().isEmpty)) {
          return 'Required';
        }
        if (keyboardType == TextInputType.emailAddress &&
            value != null &&
            value.isNotEmpty &&
            !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
          return 'Enter a valid email';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);

    return Padding(
      // Keep the form above the keyboard instead of having it covered.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl * s,
          AppSpacing.xl * s,
          AppSpacing.xl * s,
          AppSpacing.block * s,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Grab handle
            Center(
              child: Container(
                width: 36 * s,
                height: 4 * s,
                decoration: BoxDecoration(
                  color: AppGray.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.lg * s),

            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Edit Personal Information',
                    style: TextStyle(
                      fontSize: 16 * s,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.headingText,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _cancel,
                  tooltip: 'Close',
                  icon: Icon(Icons.close_rounded, size: 20 * s),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg * s),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _field(_name, label: 'Full Name'),
                  SizedBox(height: AppSpacing.md * s),
                  _field(_dob, label: 'Date of Birth (BS)'),
                  SizedBox(height: AppSpacing.md * s),
                  DropdownButtonFormField<String>(
                    initialValue: _gender,
                    decoration: _decor('Gender'),
                    items: <DropdownMenuItem<String>>[
                      for (final String option
                          in EditPersonalInfoSheet.genderOptions)
                        DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        ),
                    ],
                    onChanged: (String? value) =>
                        setState(() => _gender = value ?? _gender),
                  ),
                  SizedBox(height: AppSpacing.md * s),
                  _field(_bloodGroup, label: 'Blood Group'),
                  SizedBox(height: AppSpacing.md * s),
                  _field(_nationality, label: 'Nationality'),
                  SizedBox(height: AppSpacing.md * s),
                  _field(
                    _phone,
                    label: 'Phone Number',
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: AppSpacing.md * s),
                  _field(
                    _email,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: AppSpacing.md * s),
                  _field(_address, label: 'Permanent Address', maxLines: 2),
                  SizedBox(height: AppSpacing.xl * s),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _cancel,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14 * s),
                            side: const BorderSide(color: AppGray.shade200),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadii.inner,
                              ),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 14 * s,
                              fontWeight: FontWeight.w600,
                              color: AppPalette.supportingText,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.md * s),
                      Expanded(
                        child: FilledButton(
                          onPressed: _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppPalette.maroon800,
                            padding: EdgeInsets.symmetric(vertical: 14 * s),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadii.inner,
                              ),
                            ),
                          ),
                          child: Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 14 * s,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
