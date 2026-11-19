import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';
import '../core/app_routes.dart';
import '../core/app_theme.dart' show AppRadii, AppSpacing;
import '../models/result_data.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_screen_bar.dart';
import '../widgets/marksheet_sheet.dart';

/// Results / Marksheet — Academics tab.
class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  /// Route name declared in `MaterialApp.routes`.
  static const String routeName = AppRoutes.results;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  // Sample record — comes from the course API in production.
  String _termName = kTerms.first.name;
  String _percentage = kTerms.first.percentage;
  String _gpa = kTerms.first.gpa;

  bool _termOpen = false;
  static const List<ExamTerm> _terms = kTerms;

  int get _academicsIndex => kBottomNavDestinations.indexWhere(
    (BottomNavDestination d) => d.label == 'Academics',
  );

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);
    final double navH = AppBottomNav.heightOf(context);
    final double barH = MediaQuery.paddingOf(context).top + 56 * s;

    return Scaffold(
      backgroundColor: AppPalette.dashboardBg,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(top: barH),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg * s,
                  AppSpacing.lg * s,
                  AppSpacing.lg * s,
                  navH + AppSpacing.block * s,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppLayout.maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _TermSelector(
                          selectedName: _termName,
                          open: _termOpen,
                          onToggle: () =>
                              setState(() => _termOpen = !_termOpen),
                        ),
                        if (_termOpen) ...<Widget>[
                          SizedBox(height: 6 * s),
                          _TermOptions(
                            terms: _terms,
                            onSelect: (ExamTerm t) {
                              setState(() {
                                _termName = t.name;
                                _percentage = t.percentage;
                                _gpa = t.gpa;
                                _termOpen = false;
                              });
                            },
                          ),
                        ],
                        SizedBox(height: 14 * s),
                        _MetricRow(
                          percentage: _percentage,
                          gpa: _gpa,
                          scale: s,
                        ),
                        SizedBox(height: 14 * s),
                        _SubjectsTable(subjects: kSubjects, scale: s),
                        SizedBox(height: AppSpacing.lg * s),
                        _ViewMarksheetButton(scale: s),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppScreenBar(
              title: 'Results',
              onBack: () => Navigator.of(context).maybePop(),
              // This screen's bar uses the round chevron at 22 and a compact
              // 16pt w700 title — the shared bar reproduces both.
              leadingIcon: Icons.chevron_left_rounded,
              iconSize: 22,
              titleSize: 16,
              titleWeight: FontWeight.w700,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNav(
              selectedIndex: _academicsIndex,
              enabledIndices: <int>{0, 1, 2, 3},
              onSelected: (int i) =>
                  AppRoutes.switchTab(context, i, _academicsIndex),
            ),
          ),
        ],
      ),
    );
  }
}

class _TermSelector extends StatelessWidget {
  const _TermSelector({
    required this.selectedName,
    required this.open,
    required this.onToggle,
  });

  final String selectedName;
  final bool open;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadii.inner * s),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onToggle,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 14 * s),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.inner * s),
            border: Border.all(color: AppPalette.cardBorder),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  selectedName,
                  style: TextStyle(
                    fontSize: 13 * s,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.headingText,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: open ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18 * s,
                  color: AppGray.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TermOptions extends StatelessWidget {
  const _TermOptions({required this.terms, required this.onSelect});

  final List<ExamTerm> terms;
  final ValueChanged<ExamTerm> onSelect;

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.inner * s),
        border: Border.all(color: AppPalette.cardBorder),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12 * s,
            offset: Offset(0, 4 * s),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          for (int i = 0; i < terms.length; i++) ...<Widget>[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: AppGray.shade100),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelect(terms[i]),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg * s,
                    vertical: AppSpacing.md * s,
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          terms[i].name,
                          style: TextStyle(
                            fontSize: 13 * s,
                            fontWeight: FontWeight.w600,
                            color: AppPalette.headingText,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6 * s,
                          vertical: 3 * s,
                        ),
                        decoration: BoxDecoration(
                          color: terms[i].status == 'Completed'
                              ? AppPalette.statusGreenBg
                              : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(
                            AppRadii.micro * s,
                          ),
                        ),
                        child: Text(
                          terms[i].status,
                          style: TextStyle(
                            fontSize: 10.5 * s,
                            fontWeight: FontWeight.w700,
                            color: terms[i].status == 'Completed'
                                ? const Color(0xFF065F46)
                                : const Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Resting lift shared by the white metric and subjects cards on the page.
List<BoxShadow> _resultsCardShadow(double s) => <BoxShadow>[
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.04),
    blurRadius: 8 * s,
    offset: Offset(0, 2 * s),
  ),
];

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.percentage,
    required this.gpa,
    required this.scale,
  });

  final String percentage;
  final String gpa;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    Widget card(String value, String label) {
      return Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.lg * s),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadii.inner * s),
            border: Border.all(color: AppPalette.cardBorder),
            boxShadow: _resultsCardShadow(s),
          ),
          child: Column(
            children: <Widget>[
              Text(
                value,
                style: TextStyle(
                  fontSize: 20 * s,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1F73B7),
                ),
              ),
              SizedBox(height: AppSpacing.xs * s),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11 * s,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.supportingText,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: <Widget>[
        card(percentage, 'Percentage'),
        SizedBox(width: AppSpacing.md * s),
        card(gpa, 'GPA'),
      ],
    );
  }
}

class _SubjectsTable extends StatelessWidget {
  const _SubjectsTable({required this.subjects, required this.scale});

  final List<SubjectResult> subjects;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.inner * s),
        border: Border.all(color: AppPalette.cardBorder),
        boxShadow: _resultsCardShadow(s),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          Container(
            color: AppGray.shade50,
            padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 10 * s),
            child: Row(
              children: <Widget>[
                Expanded(flex: 5, child: _head('Subject')),
                Expanded(flex: 2, child: _head('Full', center: true)),
                Expanded(flex: 3, child: _head('Obtained', center: true)),
                Expanded(flex: 2, child: _head('Grade', center: true)),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F2F5)),
          for (int i = 0; i < subjects.length; i++) ...<Widget>[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: Color(0xFFF7F8FA)),
            _row(subjects[i], s),
          ],
        ],
      ),
    );
  }

  Widget _head(String text, {bool center = false}) {
    return Text(
      text,
      textAlign: center ? TextAlign.center : TextAlign.left,
      style: TextStyle(
        fontSize: 11 * scale,
        fontWeight: FontWeight.w600,
        color: AppGray.shade400,
      ),
    );
  }

  Widget _row(SubjectResult subject, double s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 11 * s),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Text(
              subject.name,
              style: TextStyle(
                fontSize: 13 * s,
                fontWeight: FontWeight.w500,
                color: AppPalette.headingText,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${subject.fullMarks}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12 * s, color: AppGray.shade400),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '${subject.obtained}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13 * s,
                fontWeight: FontWeight.w600,
                color: AppPalette.headingText,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              subject.grade,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13 * s,
                fontWeight: FontWeight.w700,
                color: AppPalette.headingText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewMarksheetButton extends StatelessWidget {
  const _ViewMarksheetButton({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => MarksheetSheet.show(context),
        icon: Icon(Icons.menu_book_rounded, size: 16 * s),
        label: Text(
          'View Full Marksheet',
          style: TextStyle(fontSize: 13.5 * s, fontWeight: FontWeight.w700),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppPalette.maroon800,
          padding: EdgeInsets.symmetric(vertical: 14 * s),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.inner * s),
          ),
        ),
      ),
    );
  }
}
