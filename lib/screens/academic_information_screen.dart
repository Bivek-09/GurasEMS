import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';
import '../core/app_routes.dart';
import '../models/academic_data.dart';
import '../models/student_profile.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_feedback.dart';
import '../widgets/user_avatar.dart';

/// Academic Information — the student's enrolled curriculum, faculty and
/// result history in one scrollable screen.
///
/// Ported from the reference's "Academic Information" screen: a maroon bar, a
/// student summary card, three pill tabs (Subjects / Faculty / History), the
/// six expandable subject cards with syllabus progress, the faculty roster, the
/// published-result timeline and the two academic shortcuts. Every figure comes
/// from [AcademicSummary] and [kAcademicSubjects] so the screen cannot drift
/// from the data the rest of the app reads.
class AcademicInformationScreen extends StatefulWidget {
  const AcademicInformationScreen({super.key});

  /// Route name declared in `MaterialApp.routes`.
  static const String routeName = AppRoutes.academicInformation;

  @override
  State<AcademicInformationScreen> createState() =>
      _AcademicInformationScreenState();
}

/// The three pill tabs above the content.
enum _AcademicTab { subjects, faculty, history }

class _AcademicInformationScreenState extends State<AcademicInformationScreen> {
  // ── Geometry ──────────────────────────────────────────────────────────
  static const double _barTopPadding = 4;
  static const double _barControl = 40;
  static const double _barBottomPadding = 16;
  static const double _gutter = 16;

  /// The maroon band starts one accordion pre-expanded, as the reference does.
  static const Set<String> _initiallyExpanded = <String>{'mth'};

  _AcademicTab _tab = _AcademicTab.subjects;
  late final Set<String> _expanded = <String>{..._initiallyExpanded};

  /// Full height of the pinned maroon bar, including the status-bar inset.
  static double _barHeightOf(BuildContext context) {
    final double s = AppLayout.scaleOf(context);
    return MediaQuery.paddingOf(context).top +
        (_barTopPadding + _barControl + _barBottomPadding) * s;
  }

  int get _academicsIndex => kBottomNavDestinations.indexWhere(
    (BottomNavDestination d) => d.label == 'Academics',
  );

  // ── Actions ───────────────────────────────────────────────────────────

  void _notify(String message) => showAppSnackBar(context, message);

  void _toggleSubject(String id) {
    setState(() {
      if (!_expanded.remove(id)) _expanded.add(id);
    });
  }

  Future<void> _openExamRoutine() async {
    final String? message = await _ExamRoutineSheet.show(context);
    if (!mounted || message == null) return;
    _notify(message);
  }

  Future<void> _openSyllabus(AcademicSubject subject) async {
    final String? message = await _SyllabusSheet.show(
      context,
      subject: subject,
    );
    if (!mounted || message == null) return;
    _notify(message);
  }

  Future<void> _openFacultyQuery({
    required String name,
    required String role,
    required String email,
  }) async {
    final String? message = await _FacultyQuerySheet.show(
      context,
      name: name,
      role: role,
      email: email,
    );
    if (!mounted || message == null) return;
    _notify(message);
  }

  Future<void> _openMarkSheet({
    required String title,
    required String published,
    required String gpa,
    required String badge,
  }) async {
    final String? message = await _MarkSheetSheet.show(
      context,
      title: title,
      published: published,
      gpa: gpa,
      badge: badge,
    );
    if (!mounted || message == null) return;
    _notify(message);
  }

  // ── UI ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);
    final double barHeight = _barHeightOf(context);
    final double navHeight = AppBottomNav.heightOf(context);

    return Scaffold(
      backgroundColor: AppPalette.dashboardBg,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          // Layer 1 — scrolling body beneath the pinned maroon bar.
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(top: barHeight),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  _gutter * s,
                  14 * s,
                  _gutter * s,
                  navHeight + 24 * s,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppLayout.maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _SummaryCard(scale: s, onStatTap: _notify),
                        SizedBox(height: 14 * s),
                        _TabSelector(
                          selected: _tab,
                          subjectCount: kAcademicSubjects.length,
                          scale: s,
                          onSelected: (_AcademicTab tab) =>
                              setState(() => _tab = tab),
                        ),
                        SizedBox(height: 14 * s),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: KeyedSubtree(
                            key: ValueKey<_AcademicTab>(_tab),
                            child: _panel(s),
                          ),
                        ),
                        SizedBox(height: 16 * s),
                        _QuickActions(
                          scale: s,
                          onExamRoutine: _openExamRoutine,
                          onMarkSheet: () => _openMarkSheet(
                            title: 'Term II Terminal Mark Sheet (Interim)',
                            published: 'Poush 2083',
                            gpa: '3.65 GPA',
                            badge: 'Grade Distinction',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Layer 2 — pinned maroon bar.
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: _AcademicBar(
              scale: s,
              onBack: () => Navigator.of(context).maybePop(),
              onDownload: () =>
                  _notify('Downloading Academic Summary Report (PDF)...'),
            ),
          ),

          // Layer 3 — persistent bottom navigation.
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

  Widget _panel(double s) {
    return switch (_tab) {
      _AcademicTab.subjects => _SubjectsPanel(
        scale: s,
        expanded: _expanded,
        onToggle: _toggleSubject,
        onDownloadAll: () =>
            _notify('Compiling 6 Enrolled Syllabi into PDF...'),
        onOpenSyllabus: _openSyllabus,
        onMessageFaculty: (AcademicSubject subject) => _openFacultyQuery(
          name: subject.faculty,
          role: subject.name,
          email: subject.email,
        ),
      ),
      _AcademicTab.faculty => _FacultyPanel(
        scale: s,
        onMessage: (FacultyMember member) => _openFacultyQuery(
          name: member.name,
          role: member.role,
          email: member.email,
        ),
      ),
      _AcademicTab.history => _HistoryPanel(
        scale: s,
        onOpen: (AcademicTermRecord record) => _openMarkSheet(
          title: record.title,
          published: record.published,
          gpa: record.gpa,
          badge: record.badge,
        ),
      ),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────

class _AcademicBar extends StatelessWidget {
  const _AcademicBar({
    required this.scale,
    required this.onBack,
    required this.onDownload,
  });

  final double scale;
  final VoidCallback onBack;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final double s = scale;
    final double inset = MediaQuery.paddingOf(context).top;

    return Container(
      padding: EdgeInsets.only(
        top: inset + _AcademicInformationScreenState._barTopPadding * s,
        bottom: _AcademicInformationScreenState._barBottomPadding * s,
        left: 16 * s,
        right: 16 * s,
      ),
      decoration: const BoxDecoration(color: AppPalette.maroon800),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppLayout.maxContentWidth,
          ),
          child: Row(
            children: <Widget>[
              _BarIconButton(
                icon: Icons.chevron_left_rounded,
                scale: s,
                onTap: onBack,
                semanticLabel: 'Go Back',
              ),
              SizedBox(width: 8 * s),
              Expanded(
                child: Text(
                  'Academic Information',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18 * s,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2 * s,
                    color: Colors.white,
                  ),
                ),
              ),
              _BarIconButton(
                icon: Icons.file_download_outlined,
                scale: s,
                onTap: onDownload,
                semanticLabel: 'Download Curriculum',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarIconButton extends StatelessWidget {
  const _BarIconButton({
    required this.icon,
    required this.scale,
    required this.onTap,
    required this.semanticLabel,
  });

  final IconData icon;
  final double scale;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return SizedBox(
      width: 40 * s,
      height: 40 * s,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Semantics(
            button: true,
            label: semanticLabel,
            child: Icon(icon, size: 20 * s, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Student summary card
// ─────────────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.scale, required this.onStatTap});

  final double scale;
  final ValueChanged<String> onStatTap;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: AppPalette.cardBorder),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12 * s,
            offset: Offset(0, 4 * s),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: _Identity(s: s)),
              SizedBox(width: 8 * s),
              _GpaBadge(s: s),
            ],
          ),
          SizedBox(height: 14 * s),
          Container(height: 1, color: AppPalette.cardBorder),
          SizedBox(height: 12 * s),
          Row(
            children: <Widget>[
              Expanded(
                child: _StatTile(
                  label: 'Academic Year',
                  value: AcademicSummary.academicYear,
                  scale: s,
                  onTap: () => onStatTap('Academic Session 2083/84 (Active)'),
                ),
              ),
              SizedBox(width: 8 * s),
              Expanded(
                child: _StatTile(
                  label: 'Current Term',
                  value: AcademicSummary.currentTerm,
                  scale: s,
                  onTap: () => onStatTap('Term II Examinations in progress'),
                ),
              ),
              SizedBox(width: 8 * s),
              Expanded(
                child: _StatTile(
                  label: 'Class Rank',
                  value: AcademicSummary.classRank,
                  valueColor: AppPalette.maroon800,
                  scale: s,
                  onTap: () => onStatTap('Rank #2 of 48 Students in Section A'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity({required this.s});

  final double s;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 52 * s,
          height: 52 * s,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Container(
                width: 52 * s,
                height: 52 * s,
                decoration: BoxDecoration(
                  color: AppPalette.maroonSurface,
                  borderRadius: BorderRadius.circular(16 * s),
                  border: Border.all(
                    color: AppPalette.maroon800.withValues(alpha: 0.2),
                  ),
                ),
                child: Center(
                  child: Text(
                    UserAvatar.initialsOf(StudentProfile.name),
                    style: TextStyle(
                      fontSize: 18 * s,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.maroon800,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -2 * s,
                bottom: -2 * s,
                child: Container(
                  width: 14 * s,
                  height: 14 * s,
                  decoration: BoxDecoration(
                    color: AppPalette.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2 * s),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12 * s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Wrap rather than a Row: on the narrowest phones the name and
              // the "Active" pill cannot share one line, so the pill drops to
              // its own line instead of overflowing.
              Wrap(
                spacing: 6 * s,
                runSpacing: 2 * s,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Text(
                    StudentProfile.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17 * s,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                      color: AppPalette.headingText,
                    ),
                  ),
                  _Pill(
                    text: 'Active',
                    background: const Color(0xFFD1FAE5),
                    foreground: const Color(0xFF065F46),
                    scale: s,
                  ),
                ],
              ),
              SizedBox(height: 2 * s),
              Text(
                'Grade ${StudentProfile.grade} • Section ${StudentProfile.section} '
                '(Roll: ${AcademicSummary.rollNumber})',
                maxLines: 2,
                style: TextStyle(
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.supportingText,
                ),
              ),
              SizedBox(height: 1 * s),
              Text(
                StudentProfile.registrationId,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11 * s,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2 * s,
                  fontFamily: 'monospace',
                  color: AppPalette.hint,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GpaBadge extends StatelessWidget {
  const _GpaBadge({required this.s});

  final double s;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 6 * s),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            'CUM. GPA',
            style: TextStyle(
              fontSize: 9 * s,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6 * s,
              color: const Color(0xFFB45309),
            ),
          ),
          Text(
            AcademicSummary.cumulativeGpa,
            style: TextStyle(
              fontSize: 17 * s,
              fontWeight: FontWeight.w800,
              height: 1.1,
              color: AppPalette.maroon800,
            ),
          ),
          Text(
            AcademicSummary.gpaRemark,
            style: TextStyle(
              fontSize: 9 * s,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF92400E),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.scale,
    required this.onTap,
    this.valueColor,
  });

  final String label;
  final String value;
  final double scale;
  final VoidCallback onTap;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Material(
      color: AppGray.shade50,
      borderRadius: BorderRadius.circular(12 * s),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 8 * s),
          child: Column(
            children: <Widget>[
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10 * s,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.hint,
                ),
              ),
              SizedBox(height: 2 * s),
              Text(
                value,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? AppGray.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Tab selector
// ─────────────────────────────────────────────────────────────────────────

class _TabSelector extends StatelessWidget {
  const _TabSelector({
    required this.selected,
    required this.subjectCount,
    required this.scale,
    required this.onSelected,
  });

  final _AcademicTab selected;
  final int subjectCount;
  final double scale;
  final ValueChanged<_AcademicTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      padding: EdgeInsets.all(4 * s),
      decoration: BoxDecoration(
        color: AppGray.shade200,
        borderRadius: BorderRadius.circular(12 * s),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _TabPill(
              label: 'Subjects ($subjectCount)',
              active: selected == _AcademicTab.subjects,
              scale: s,
              onTap: () => onSelected(_AcademicTab.subjects),
            ),
          ),
          Expanded(
            child: _TabPill(
              label: 'Faculty',
              active: selected == _AcademicTab.faculty,
              scale: s,
              onTap: () => onSelected(_AcademicTab.faculty),
            ),
          ),
          Expanded(
            child: _TabPill(
              label: 'History',
              active: selected == _AcademicTab.history,
              scale: s,
              onTap: () => onSelected(_AcademicTab.history),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.label,
    required this.active,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final bool active;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Material(
      color: active ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(9 * s),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 7 * s),
          decoration: active
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(9 * s),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4 * s,
                      offset: Offset(0, 1 * s),
                    ),
                  ],
                )
              : null,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12 * s,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? AppPalette.maroon800 : AppGray.shade600,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Subjects panel
// ─────────────────────────────────────────────────────────────────────────

class _SubjectsPanel extends StatelessWidget {
  const _SubjectsPanel({
    required this.scale,
    required this.expanded,
    required this.onToggle,
    required this.onDownloadAll,
    required this.onOpenSyllabus,
    required this.onMessageFaculty,
  });

  final double scale;
  final Set<String> expanded;
  final ValueChanged<String> onToggle;
  final VoidCallback onDownloadAll;
  final ValueChanged<AcademicSubject> onOpenSyllabus;
  final ValueChanged<AcademicSubject> onMessageFaculty;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4 * s),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'ENROLLED CURRICULUM',
                  style: TextStyle(
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8 * s,
                    color: AppPalette.supportingText,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onDownloadAll,
                child: Text(
                  'Download All (PDF)',
                  style: TextStyle(
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.maroon800,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10 * s),
        for (int i = 0; i < kAcademicSubjects.length; i++) ...<Widget>[
          if (i > 0) SizedBox(height: 12 * s),
          _SubjectAccordion(
            subject: kAcademicSubjects[i],
            expanded: expanded.contains(kAcademicSubjects[i].id),
            scale: s,
            onToggle: () => onToggle(kAcademicSubjects[i].id),
            onOpenSyllabus: () => onOpenSyllabus(kAcademicSubjects[i]),
            onMessageFaculty: () => onMessageFaculty(kAcademicSubjects[i]),
          ),
        ],
      ],
    );
  }
}

class _SubjectAccordion extends StatelessWidget {
  const _SubjectAccordion({
    required this.subject,
    required this.expanded,
    required this.scale,
    required this.onToggle,
    required this.onOpenSyllabus,
    required this.onMessageFaculty,
  });

  final AcademicSubject subject;
  final bool expanded;
  final double scale;
  final VoidCallback onToggle;
  final VoidCallback onOpenSyllabus;
  final VoidCallback onMessageFaculty;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18 * s),
        border: Border.all(color: AppPalette.cardBorder),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12 * s,
            offset: Offset(0, 4 * s),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              child: Padding(
                padding: EdgeInsets.all(14 * s),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 40 * s,
                      height: 40 * s,
                      decoration: BoxDecoration(
                        color: subject.tintBackground,
                        borderRadius: BorderRadius.circular(12 * s),
                      ),
                      child: Icon(
                        subject.icon,
                        size: 20 * s,
                        color: subject.tint,
                      ),
                    ),
                    SizedBox(width: 12 * s),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  subject.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14 * s,
                                    fontWeight: FontWeight.w700,
                                    color: AppPalette.headingText,
                                  ),
                                ),
                              ),
                              SizedBox(width: 6 * s),
                              _CodeBadge(code: subject.code, scale: s),
                            ],
                          ),
                          SizedBox(height: 3 * s),
                          Text.rich(
                            TextSpan(
                              style: TextStyle(
                                fontSize: 12 * s,
                                fontWeight: FontWeight.w500,
                                color: AppPalette.supportingText,
                              ),
                              children: <InlineSpan>[
                                const TextSpan(text: 'Faculty: '),
                                TextSpan(
                                  text: subject.faculty,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppGray.shade700,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8 * s),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        _Pill(
                          text: '${subject.attendancePercent}% Attn.',
                          background: AppPalette.statusGreenBg,
                          foreground: AppPalette.statusGreen,
                          scale: s,
                        ),
                        SizedBox(height: 8 * s),
                        AnimatedRotation(
                          turns: expanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 220),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18 * s,
                            color: AppPalette.hint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: expanded
                ? Padding(
                    padding: EdgeInsets.fromLTRB(14 * s, 0, 14 * s, 14 * s),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(height: 1, color: AppPalette.cardBorder),
                        SizedBox(height: 12 * s),
                        _ProgressBlock(subject: subject, scale: s),
                        SizedBox(height: 12 * s),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _MetaTile(
                                label: subject.meta[0].label,
                                value: subject.meta[0].value,
                                scale: s,
                              ),
                            ),
                            SizedBox(width: 8 * s),
                            Expanded(
                              child: _MetaTile(
                                label: subject.meta[1].label,
                                value: subject.meta[1].value,
                                scale: s,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12 * s),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Material(
                                color: subject.tintBackground,
                                borderRadius: BorderRadius.circular(10 * s),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: onOpenSyllabus,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 10 * s,
                                    ),
                                    child: Text(
                                      subject.actionLabel,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12 * s,
                                        fontWeight: FontWeight.w600,
                                        color: subject.tint,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8 * s),
                            Material(
                              color: AppGray.shade100,
                              borderRadius: BorderRadius.circular(10 * s),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: onMessageFaculty,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12 * s,
                                    vertical: 10 * s,
                                  ),
                                  child: Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 14 * s,
                                    color: AppGray.shade600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _ProgressBlock extends StatelessWidget {
  const _ProgressBlock({required this.subject, required this.scale});

  final AcademicSubject subject;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Syllabus Coverage',
                style: TextStyle(
                  fontSize: 11 * s,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.supportingText,
                ),
              ),
            ),
            Text(
              '${subject.progressPercent}%',
              style: TextStyle(
                fontSize: 11 * s,
                fontWeight: FontWeight.w600,
                color: AppGray.shade800,
              ),
            ),
          ],
        ),
        SizedBox(height: 6 * s),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 6 * s,
            color: AppGray.shade100,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 0,
                  end: subject.progressPercent / 100,
                ),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (BuildContext context, double value, Widget? child) {
                  return FractionallySizedBox(
                    widthFactor: value.clamp(0.0, 1.0),
                    heightFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: subject.tint,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaTile extends StatelessWidget {
  const _MetaTile({
    required this.label,
    required this.value,
    required this.scale,
  });

  final String label;
  final String value;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      padding: EdgeInsets.all(8 * s),
      decoration: BoxDecoration(
        color: AppGray.shade50,
        borderRadius: BorderRadius.circular(10 * s),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10 * s,
              fontWeight: FontWeight.w500,
              color: AppPalette.hint,
            ),
          ),
          SizedBox(height: 2 * s),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11 * s,
              fontWeight: FontWeight.w600,
              height: 1.25,
              color: AppGray.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Faculty panel
// ─────────────────────────────────────────────────────────────────────────

class _FacultyPanel extends StatelessWidget {
  const _FacultyPanel({required this.scale, required this.onMessage});

  final double scale;
  final ValueChanged<FacultyMember> onMessage;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(16 * s),
          decoration: _cardDecoration(s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'CLASS TEACHER / MENTOR',
                style: TextStyle(
                  fontSize: 11 * s,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8 * s,
                  color: AppPalette.hint,
                ),
              ),
              SizedBox(height: 10 * s),
              Row(
                children: <Widget>[
                  Container(
                    width: 48 * s,
                    height: 48 * s,
                    decoration: BoxDecoration(
                      color: AppPalette.maroonSurface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppPalette.maroon800.withValues(alpha: 0.2),
                        width: 2 * s,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        UserAvatar.initialsOf(kFacultyMentor.name),
                        style: TextStyle(
                          fontSize: 14 * s,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.maroon800,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12 * s),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          kFacultyMentor.name,
                          style: TextStyle(
                            fontSize: 14 * s,
                            fontWeight: FontWeight.w700,
                            color: AppPalette.headingText,
                          ),
                        ),
                        SizedBox(height: 2 * s),
                        Text(
                          kFacultyMentor.role,
                          style: TextStyle(
                            fontSize: 12 * s,
                            fontWeight: FontWeight.w500,
                            color: AppPalette.supportingText,
                          ),
                        ),
                        SizedBox(height: 2 * s),
                        Text(
                          kFacultyMentor.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11 * s,
                            fontWeight: FontWeight.w500,
                            color: AppPalette.maroon800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _MessageButton(
                    scale: s,
                    onTap: () => onMessage(kFacultyMentor),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 12 * s),
        Container(
          padding: EdgeInsets.all(16 * s),
          decoration: _cardDecoration(s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'SUBJECT TEACHERS',
                style: TextStyle(
                  fontSize: 11 * s,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8 * s,
                  color: AppPalette.hint,
                ),
              ),
              SizedBox(height: 6 * s),
              for (int i = 0; i < kFacultyTeachers.length; i++) ...<Widget>[
                if (i > 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF3F4F6),
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10 * s),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              kFacultyTeachers[i].name,
                              style: TextStyle(
                                fontSize: 13.5 * s,
                                fontWeight: FontWeight.w600,
                                color: AppGray.shade800,
                              ),
                            ),
                            SizedBox(height: 2 * s),
                            Text(
                              kFacultyTeachers[i].role,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12 * s,
                                fontWeight: FontWeight.w500,
                                color: AppPalette.supportingText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8 * s),
                      Text(
                        kFacultyTeachers[i].room,
                        style: TextStyle(
                          fontSize: 11 * s,
                          fontWeight: FontWeight.w500,
                          color: AppPalette.hint,
                        ),
                      ),
                      SizedBox(width: 8 * s),
                      _MessageButton(
                        scale: s,
                        onTap: () => onMessage(kFacultyTeachers[i]),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MessageButton extends StatelessWidget {
  const _MessageButton({required this.scale, required this.onTap});

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Material(
      color: AppGray.shade100,
      borderRadius: BorderRadius.circular(10 * s),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(8 * s),
          child: Icon(
            Icons.chat_bubble_outline_rounded,
            size: 14 * s,
            color: AppGray.shade700,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// History panel
// ─────────────────────────────────────────────────────────────────────────

class _HistoryPanel extends StatelessWidget {
  const _HistoryPanel({required this.scale, required this.onOpen});

  final double scale;
  final ValueChanged<AcademicTermRecord> onOpen;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      padding: EdgeInsets.all(16 * s),
      decoration: _cardDecoration(s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Previous Terms & Grades',
            style: TextStyle(
              fontSize: 14 * s,
              fontWeight: FontWeight.w700,
              color: AppPalette.headingText,
            ),
          ),
          SizedBox(height: 12 * s),
          Container(
            padding: EdgeInsets.only(left: 20 * s),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: Color(0xFFF8E8ED), width: 2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (int i = 0; i < kAcademicHistory.length; i++) ...<Widget>[
                  if (i > 0) SizedBox(height: 16 * s),
                  _TimelineEntry(
                    record: kAcademicHistory[i],
                    scale: s,
                    onTap: () => onOpen(kAcademicHistory[i]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    required this.record,
    required this.scale,
    required this.onTap,
  });

  final AcademicTermRecord record;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned(
          left: -27 * s,
          top: 3 * s,
          child: Container(
            width: 14 * s,
            height: 14 * s,
            decoration: BoxDecoration(
              color: record.highlight ? AppPalette.maroon800 : AppGray.shade400,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2 * s),
            ),
          ),
        ),
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8 * s),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(4 * s),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          record.title,
                          style: TextStyle(
                            fontSize: 12.5 * s,
                            fontWeight: FontWeight.w700,
                            color: AppPalette.headingText,
                          ),
                        ),
                        SizedBox(height: 2 * s),
                        Text(
                          record.subtitle,
                          style: TextStyle(
                            fontSize: 11 * s,
                            fontWeight: FontWeight.w500,
                            color: AppPalette.supportingText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8 * s),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      _Pill(
                        text: record.gpa,
                        background: record.highlight
                            ? AppPalette.statusGreenBg
                            : AppGray.shade100,
                        foreground: record.highlight
                            ? AppPalette.statusGreen
                            : AppGray.shade700,
                        scale: s,
                      ),
                      SizedBox(height: 2 * s),
                      Text(
                        record.badge,
                        style: TextStyle(
                          fontSize: 10 * s,
                          fontWeight: FontWeight.w500,
                          color: AppPalette.hint,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Quick actions
// ─────────────────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.scale,
    required this.onExamRoutine,
    required this.onMarkSheet,
  });

  final double scale;
  final VoidCallback onExamRoutine;
  final VoidCallback onMarkSheet;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Row(
      children: <Widget>[
        Expanded(
          child: _QuickActionButton(
            icon: Icons.calendar_month_outlined,
            title: 'Exam Routine',
            subtitle: 'Term II Routine',
            tint: const Color(0xFFEA580C),
            tintBackground: const Color(0xFFFFF7ED),
            scale: s,
            onTap: onExamRoutine,
          ),
        ),
        SizedBox(width: 12 * s),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.description_outlined,
            title: 'Mark Sheet',
            subtitle: 'Transcript view',
            tint: AppPalette.success,
            tintBackground: const Color(0xFFECFDF5),
            scale: s,
            onTap: onMarkSheet,
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tint,
    required this.tintBackground,
    required this.scale,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color tint;
  final Color tintBackground;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      decoration: _cardDecoration(s, radius: 16),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(12 * s),
            child: Row(
              children: <Widget>[
                Container(
                  width: 40 * s,
                  height: 40 * s,
                  decoration: BoxDecoration(
                    color: tintBackground,
                    borderRadius: BorderRadius.circular(12 * s),
                  ),
                  child: Icon(icon, size: 20 * s, color: tint),
                ),
                SizedBox(width: 10 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12 * s,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.headingText,
                        ),
                      ),
                      SizedBox(height: 1 * s),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10 * s,
                          fontWeight: FontWeight.w500,
                          color: AppPalette.hint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Shared small pieces
// ─────────────────────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  const _Pill({
    required this.text,
    required this.background,
    required this.foreground,
    required this.scale,
  });

  final String text;
  final Color background;
  final Color foreground;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7 * s, vertical: 2 * s),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 9.5 * s,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}

class _CodeBadge extends StatelessWidget {
  const _CodeBadge({required this.code, required this.scale});

  final String code;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 2 * s),
      decoration: BoxDecoration(
        color: AppGray.shade100,
        borderRadius: BorderRadius.circular(6 * s),
      ),
      child: Text(
        code,
        style: TextStyle(
          fontSize: 9 * s,
          fontWeight: FontWeight.w700,
          fontFamily: 'monospace',
          color: AppGray.shade600,
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration(double s, {double radius = 18}) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius * s),
    border: Border.all(color: AppPalette.cardBorder),
    boxShadow: <BoxShadow>[
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 12 * s,
        offset: Offset(0, 4 * s),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────
// Sheets
// ─────────────────────────────────────────────────────────────────────────

/// Common chrome for the four academic sheets: rounded white surface, a drag
/// handle, a titled header with a close affordance, and a scrolling body.
class _SheetShell extends StatelessWidget {
  const _SheetShell({
    required this.title,
    this.subtitle,
    this.titleTrailing,
    this.footer,
    required this.children,
  });

  final String title;
  final String? subtitle;
  final Widget? titleTrailing;
  final Widget? footer;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);
    final double maxH = MediaQuery.sizeOf(context).height * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28 * s)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20 * s, 12 * s, 20 * s, 20 * s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 40 * s,
                height: 4 * s,
                decoration: BoxDecoration(
                  color: AppGray.shade200,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            SizedBox(height: 14 * s),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 16 * s,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                                color: AppPalette.headingText,
                              ),
                            ),
                          ),
                          if (titleTrailing != null) ...<Widget>[
                            SizedBox(width: 6 * s),
                            titleTrailing!,
                          ],
                        ],
                      ),
                      if (subtitle != null) ...<Widget>[
                        SizedBox(height: 3 * s),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12 * s,
                            fontWeight: FontWeight.w500,
                            color: AppPalette.supportingText,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 8 * s),
                SizedBox(
                  width: 32 * s,
                  height: 32 * s,
                  child: Material(
                    color: AppGray.shade100,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(
                        Icons.close_rounded,
                        size: 17 * s,
                        color: AppGray.shade600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16 * s),
            ...children,
            if (footer != null) ...<Widget>[SizedBox(height: 20 * s), footer!],
          ],
        ),
      ),
    );
  }
}

/// Two-button footer shared by the sheets: a maroon primary action and a
/// neutral dismiss.
class _SheetFooter extends StatelessWidget {
  const _SheetFooter({
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
  });

  final String primaryLabel;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);

    return Row(
      children: <Widget>[
        Expanded(
          child: SizedBox(
            height: 44 * s,
            child: FilledButton(
              onPressed: onPrimary,
              style: FilledButton.styleFrom(
                backgroundColor: AppPalette.maroon800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12 * s),
                ),
              ),
              child: Text(
                primaryLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12 * s, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
        SizedBox(width: 8 * s),
        SizedBox(
          height: 44 * s,
          child: OutlinedButton(
            onPressed: onSecondary,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppGray.shade700,
              backgroundColor: AppGray.shade100,
              side: BorderSide.none,
              padding: EdgeInsets.symmetric(horizontal: 18 * s),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12 * s),
              ),
            ),
            child: Text(
              secondaryLabel,
              style: TextStyle(fontSize: 12 * s, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

/// Term II examination routine.
class _ExamRoutineSheet extends StatelessWidget {
  const _ExamRoutineSheet();

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => const _ExamRoutineSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);

    return _SheetShell(
      title: 'Term II Examination Routine',
      subtitle: 'Grade 10 • Starting Mangsir 28, 2083',
      footer: _SheetFooter(
        primaryLabel: 'Download Routine (PDF)',
        onPrimary: () =>
            Navigator.of(context)
                .pop('Downloading Term II Exam Routine PDF...'),
        secondaryLabel: 'Close',
        onSecondary: () => Navigator.of(context).pop(),
      ),
      children: <Widget>[
        for (int i = 0; i < kExamRoutine.length; i++) ...<Widget>[
          if (i > 0) SizedBox(height: 10 * s),
          Container(
            padding: EdgeInsets.all(12 * s),
            decoration: BoxDecoration(
              color: AppGray.shade50,
              borderRadius: BorderRadius.circular(12 * s),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        kExamRoutine[i].day.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10 * s,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4 * s,
                          color: AppPalette.maroon800,
                        ),
                      ),
                      SizedBox(height: 3 * s),
                      Text(
                        kExamRoutine[i].subject,
                        style: TextStyle(
                          fontSize: 12.5 * s,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.headingText,
                        ),
                      ),
                      SizedBox(height: 2 * s),
                      Text(
                        'Time: ${kExamRoutine[i].time}',
                        style: TextStyle(
                          fontSize: 11 * s,
                          fontWeight: FontWeight.w500,
                          color: AppPalette.supportingText,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8 * s),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10 * s,
                    vertical: 5 * s,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8 * s),
                    border: Border.all(color: AppGray.shade200),
                  ),
                  child: Text(
                    kExamRoutine[i].room,
                    style: TextStyle(
                      fontSize: 11 * s,
                      fontWeight: FontWeight.w600,
                      color: AppGray.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// One subject's syllabus coverage and unit list.
class _SyllabusSheet extends StatelessWidget {
  const _SyllabusSheet({required this.subject});

  final AcademicSubject subject;

  static Future<String?> show(
    BuildContext context, {
    required AcademicSubject subject,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => _SyllabusSheet(subject: subject),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);

    return _SheetShell(
      title: subject.name,
      titleTrailing: _CodeBadge(code: subject.code, scale: s),
      subtitle: 'Faculty: ${subject.faculty}',
      footer: _SheetFooter(
        primaryLabel: 'Download Lecture Notes (.PDF)',
        onPrimary: () =>
            Navigator.of(context)
                .pop('Downloading complete notes and lecture materials...'),
        secondaryLabel: 'Dismiss',
        onSecondary: () => Navigator.of(context).pop(),
      ),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Curriculum Progress',
                style: TextStyle(
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.supportingText,
                ),
              ),
            ),
            Text(
              '${subject.progressPercent}%',
              style: TextStyle(
                fontSize: 12 * s,
                fontWeight: FontWeight.w700,
                color: AppPalette.maroon800,
              ),
            ),
          ],
        ),
        SizedBox(height: 6 * s),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: subject.progressPercent / 100),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (BuildContext context, double value, Widget? child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: value.clamp(0.0, 1.0),
                minHeight: 8 * s,
                backgroundColor: AppGray.shade100,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppPalette.maroon800,
                ),
              ),
            );
          },
        ),
        SizedBox(height: 18 * s),
        Text(
          'CHAPTERS & SYLLABUS UNITS',
          style: TextStyle(
            fontSize: 11 * s,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8 * s,
            color: AppPalette.headingText,
          ),
        ),
        SizedBox(height: 8 * s),
        for (int i = 0; i < subject.units.length; i++) ...<Widget>[
          if (i > 0) SizedBox(height: 8 * s),
          _UnitRow(index: i + 1, unit: subject.units[i], scale: s),
        ],
      ],
    );
  }
}

class _UnitRow extends StatelessWidget {
  const _UnitRow({
    required this.index,
    required this.unit,
    required this.scale,
  });

  final int index;
  final SyllabusUnit unit;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;
    final (
      Color background,
      Color foreground,
      Color border,
    ) = switch (unit.status) {
      SyllabusStatus.completed => (
        AppPalette.statusGreenBg,
        AppPalette.statusGreen,
        AppPalette.statusGreenBorder,
      ),
      SyllabusStatus.ongoing => (
        const Color(0xFFFFFBEB),
        const Color(0xFFB45309),
        const Color(0xFFFDE68A),
      ),
      SyllabusStatus.pending => (
        AppGray.shade50,
        AppGray.shade600,
        AppGray.shade200,
      ),
    };

    return Container(
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: AppGray.shade50,
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: AppPalette.cardBorder),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              'Unit $index: ${unit.title}',
              style: TextStyle(
                fontSize: 11.5 * s,
                fontWeight: FontWeight.w500,
                height: 1.3,
                color: AppGray.shade800,
              ),
            ),
          ),
          SizedBox(width: 8 * s),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 2 * s),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: border),
            ),
            child: Text(
              unit.status.label,
              style: TextStyle(
                fontSize: 9.5 * s,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Query composer for a faculty member.
class _FacultyQuerySheet extends StatefulWidget {
  const _FacultyQuerySheet({
    required this.name,
    required this.role,
    required this.email,
  });

  final String name;
  final String role;
  final String email;

  static Future<String?> show(
    BuildContext context, {
    required String name,
    required String role,
    required String email,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => _FacultyQuerySheet(name: name, role: role, email: email),
    );
  }

  @override
  State<_FacultyQuerySheet> createState() => _FacultyQuerySheetState();
}

class _FacultyQuerySheetState extends State<_FacultyQuerySheet> {
  final TextEditingController _subject = TextEditingController(
    text: 'Regarding Chapter Syllabus & Homework Clarification',
  );
  final TextEditingController _body = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  void _send() {
    if (_body.text.trim().isEmpty) {
      setState(() => _error = 'Please enter a short message for the teacher.');
      return;
    }
    Navigator.of(context).pop('Message sent successfully to teacher!');
  }

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: _SheetShell(
        title: 'Query to ${widget.name}',
        subtitle: '${widget.role} • ${widget.email}',
        footer: _SheetFooter(
          primaryLabel: 'Send Message',
          onPrimary: _send,
          secondaryLabel: 'Cancel',
          onSecondary: () => Navigator.of(context).pop(),
        ),
        children: <Widget>[
          _FieldLabel(text: 'Message Subject / Topic', scale: s),
          SizedBox(height: 6 * s),
          TextField(
            controller: _subject,
            style: TextStyle(fontSize: 12 * s, color: AppPalette.navy),
            decoration: _fieldDecoration(s),
          ),
          SizedBox(height: 12 * s),
          _FieldLabel(text: 'Your Question or Note', scale: s),
          SizedBox(height: 6 * s),
          TextField(
            controller: _body,
            minLines: 3,
            maxLines: 5,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            style: TextStyle(fontSize: 12 * s, color: AppPalette.navy),
            decoration: _fieldDecoration(
              s,
              hint: 'Write your question or request a consultation meeting...',
            ),
          ),
          if (_error != null) ...<Widget>[
            SizedBox(height: 8 * s),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 11 * s,
                fontWeight: FontWeight.w500,
                color: AppPalette.accentRed,
              ),
            ),
          ],
          SizedBox(height: 10 * s),
          Text(
            'Response will be delivered to your Guras EMS student inbox.',
            style: TextStyle(
              fontSize: 10 * s,
              fontWeight: FontWeight.w500,
              color: AppPalette.hint,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(double s, {String? hint}) {
    return InputDecoration(
      isDense: true,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 12 * s,
        vertical: 12 * s,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12 * s),
        borderSide: BorderSide(color: AppGray.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12 * s),
        borderSide: BorderSide(color: AppGray.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12 * s),
        borderSide: const BorderSide(color: AppPalette.maroon800, width: 1.4),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text, required this.scale});

  final String text;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12 * scale,
        fontWeight: FontWeight.w600,
        color: AppGray.shade700,
      ),
    );
  }
}

/// Interim transcript for one evaluation term.
class _MarkSheetSheet extends StatelessWidget {
  const _MarkSheetSheet({
    required this.title,
    required this.published,
    required this.gpa,
    required this.badge,
  });

  final String title;
  final String published;
  final String gpa;
  final String badge;

  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String published,
    required String gpa,
    required String badge,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => _MarkSheetSheet(
        title: title,
        published: published,
        gpa: gpa,
        badge: badge,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);

    return _SheetShell(
      title: title,
      subtitle: 'Published: $published • Guras EMS Exam Board',
      footer: _SheetFooter(
        primaryLabel: 'Download PDF Transcript',
        onPrimary: () =>
            Navigator.of(context).pop('Downloading Official Transcript PDF...'),
        secondaryLabel: 'Close',
        onSecondary: () => Navigator.of(context).pop(),
      ),
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(12 * s),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(12 * s),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'EVALUATION RESULT',
                      style: TextStyle(
                        fontSize: 10 * s,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6 * s,
                        color: const Color(0xFF92400E),
                      ),
                    ),
                    SizedBox(height: 3 * s),
                    Text(
                      '$gpa • $badge',
                      style: TextStyle(
                        fontSize: 14 * s,
                        fontWeight: FontWeight.w800,
                        color: AppPalette.maroon800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * s,
                  vertical: 4 * s,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(8 * s),
                ),
                child: Text(
                  'Verified',
                  style: TextStyle(
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF065F46),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 14 * s),
        for (int i = 0; i < kMarkSheetRows.length; i++) ...<Widget>[
          if (i > 0)
            const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 9 * s),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    kMarkSheetRows[i].subject,
                    style: TextStyle(
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w500,
                      color: AppGray.shade700,
                    ),
                  ),
                ),
                SizedBox(width: 8 * s),
                Text(
                  '${kMarkSheetRows[i].grade} (${kMarkSheetRows[i].score} / 100)',
                  style: TextStyle(
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.headingText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
