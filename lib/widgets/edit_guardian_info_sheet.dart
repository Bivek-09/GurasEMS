import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';
import '../models/guardian_info.dart';

/// Modal bottom sheet for editing the guardian record.
///
/// Mirrors the reference's edit drawer: an amber note about OTP verification,
/// a father group (name, phone/occupation, email, address) and a mother group
/// (name, phone/occupation, email), with a fixed Cancel / Save footer. Returns
/// a brand-new [GuardianInfo]; persistence is the screen's job.
class EditGuardianInfoSheet extends StatefulWidget {
  const EditGuardianInfoSheet({super.key, required this.initial});

  final GuardianInfo initial;

  @override
  State<EditGuardianInfoSheet> createState() => _EditGuardianInfoSheetState();
}

class _EditGuardianInfoSheetState extends State<EditGuardianInfoSheet> {
  late final TextEditingController _fatherName;
  late final TextEditingController _fatherPhone;
  late final TextEditingController _fatherOccupation;
  late final TextEditingController _fatherEmail;
  late final TextEditingController _address;
  late final TextEditingController _motherName;
  late final TextEditingController _motherPhone;
  late final TextEditingController _motherOccupation;
  late final TextEditingController _motherEmail;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fatherName = TextEditingController(text: widget.initial.father.fullName);
    _fatherPhone = TextEditingController(text: widget.initial.father.phone);
    _fatherOccupation = TextEditingController(
      text: widget.initial.father.occupation,
    );
    _fatherEmail = TextEditingController(text: widget.initial.father.email);
    _address = TextEditingController(text: widget.initial.father.address ?? '');
    _motherName = TextEditingController(text: widget.initial.mother.fullName);
    _motherPhone = TextEditingController(text: widget.initial.mother.phone);
    _motherOccupation = TextEditingController(
      text: widget.initial.mother.occupation,
    );
    _motherEmail = TextEditingController(text: widget.initial.mother.email);
  }

  @override
  void dispose() {
    _fatherName.dispose();
    _fatherPhone.dispose();
    _fatherOccupation.dispose();
    _fatherEmail.dispose();
    _address.dispose();
    _motherName.dispose();
    _motherPhone.dispose();
    _motherOccupation.dispose();
    _motherEmail.dispose();
    super.dispose();
  }

  void _cancel() => Navigator.of(context).pop();

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      widget.initial.copyWith(
        father: widget.initial.father.copyWith(
          fullName: _fatherName.text.trim(),
          phone: _fatherPhone.text.trim(),
          occupation: _fatherOccupation.text.trim(),
          email: _fatherEmail.text.trim(),
          address: _address.text.trim(),
        ),
        mother: widget.initial.mother.copyWith(
          fullName: _motherName.text.trim(),
          phone: _motherPhone.text.trim(),
          occupation: _motherOccupation.text.trim(),
          email: _motherEmail.text.trim(),
        ),
      ),
    );
  }

  InputDecoration _decor(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: const Color(0xFFF9FAFB),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppPalette.maroon800, width: 1.4),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );

  TextFormField _field(
    TextEditingController controller, {
    required String label,
    TextInputType? keyboardType,
    bool required = true,
  }) {
    final double s = AppLayout.scaleOf(context);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 13 * s,
        fontWeight: FontWeight.w500,
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

  /// Two fields sharing one row — phone digits beside an occupation text box.
  Widget _fieldPair({
    required TextEditingController phone,
    required String phoneLabel,
    required TextEditingController occupation,
    required String occupationLabel,
  }) {
    final double s = AppLayout.scaleOf(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: _field(
            phone,
            label: phoneLabel,
            keyboardType: TextInputType.phone,
          ),
        ),
        SizedBox(width: 8 * s),
        Expanded(child: _field(occupation, label: occupationLabel)),
      ],
    );
  }

  Widget _groupHeader(IconData icon, String label) {
    final double s = AppLayout.scaleOf(context);

    return Row(
      children: <Widget>[
        Icon(icon, size: 15 * s, color: AppPalette.maroon800),
        SizedBox(width: 6 * s),
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11 * s,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6 * s,
              color: AppPalette.maroon800,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);
    final double maxH = MediaQuery.sizeOf(context).height * 0.92;

    return Padding(
      // Keep the form above the keyboard instead of having it covered.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxH),
        decoration: const BoxDecoration(color: Colors.white),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Modal top bar.
              Padding(
                padding: EdgeInsets.fromLTRB(20 * s, 16 * s, 8 * s, 12 * s),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Edit Information',
                            style: TextStyle(
                              fontSize: 16 * s,
                              fontWeight: FontWeight.w700,
                              color: AppPalette.headingText,
                            ),
                          ),
                          Text(
                            'Update contacts or request profile update',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12 * s,
                              color: AppPalette.supportingText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _cancel,
                      tooltip: 'Close',
                      icon: Icon(Icons.close_rounded, size: 20 * s),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
              // Scrollable form.
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20 * s),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        // OTP / verification note.
                        Container(
                          padding: EdgeInsets.all(12 * s),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(12 * s),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 18 * s,
                                color: const Color(0xFFD97706),
                              ),
                              SizedBox(width: 10 * s),
                              Expanded(
                                child: Text(
                                  'Updates to parent mobile number require OTP '
                                  'confirmation and School Administrative '
                                  'verification.',
                                  style: TextStyle(
                                    fontSize: 11 * s,
                                    height: 1.45,
                                    color: const Color(0xFF92400E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 18 * s),
                        // Father group.
                        _groupHeader(
                          Icons.person_outline_rounded,
                          'FATHER / PRIMARY GUARDIAN',
                        ),
                        SizedBox(height: 12 * s),
                        _field(_fatherName, label: 'Full Name'),
                        SizedBox(height: 10 * s),
                        _fieldPair(
                          phone: _fatherPhone,
                          phoneLabel: 'Phone Number',
                          occupation: _fatherOccupation,
                          occupationLabel: 'Occupation',
                        ),
                        SizedBox(height: 10 * s),
                        _field(
                          _fatherEmail,
                          label: 'Email Address',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 10 * s),
                        _field(_address, label: 'Address'),
                        // Mother group.
                        SizedBox(height: 18 * s),
                        Container(height: 1, color: const Color(0xFFF3F4F6)),
                        SizedBox(height: 18 * s),
                        _groupHeader(
                          Icons.female,
                          'MOTHER / SECONDARY GUARDIAN',
                        ),
                        SizedBox(height: 12 * s),
                        _field(_motherName, label: 'Full Name'),
                        SizedBox(height: 10 * s),
                        _fieldPair(
                          phone: _motherPhone,
                          phoneLabel: 'Phone Number',
                          occupation: _motherOccupation,
                          occupationLabel: 'Occupation',
                        ),
                        SizedBox(height: 10 * s),
                        _field(
                          _motherEmail,
                          label: 'Email Address',
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Fixed footer.
              Container(
                padding: EdgeInsets.fromLTRB(20 * s, 12 * s, 20 * s, 16 * s),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _cancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppPalette.headingText,
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          padding: EdgeInsets.symmetric(vertical: 13 * s),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12 * s),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 13 * s,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12 * s),
                    Expanded(
                      child: FilledButton(
                        onPressed: _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppPalette.maroon800,
                          padding: EdgeInsets.symmetric(vertical: 13 * s),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12 * s),
                          ),
                        ),
                        child: Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 13 * s,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
