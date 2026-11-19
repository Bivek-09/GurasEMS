import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';
import '../core/app_routes.dart';
import '../core/app_theme.dart' show AppRadii, AppSpacing;
import '../models/school_notice.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/notice_detail_sheet.dart';

/// Notices — the school notice board.
///
/// The third bottom-nav destination. A maroon bar carries the title and a
/// collapsible search drawer, a pinned row of category pills filters the list,
/// and each card opens the full notice in a bottom sheet. Pinned notices carry
/// the maroon pin marker. The bottom nav keeps the Notices tab active.
class NoticesScreen extends StatefulWidget {
  const NoticesScreen({super.key});

  /// Route name declared in `MaterialApp.routes`.
  static const String routeName = AppRoutes.notices;

  // ── Header geometry ───────────────────────────────────────────────────
  static const double _barTopPadding = 12;
  static const double _control = 40;
  static const double _barBottomPadding = 10;

  /// Extra height the search drawer adds when it is open.
  static const double _searchBlock = 52;

  /// Full height of the maroon header, including the status-bar inset and the
  /// search drawer when [searchOpen].
  static double barHeightOf(BuildContext context, {required bool searchOpen}) {
    final double s = AppLayout.scaleOf(context);
    return MediaQuery.paddingOf(context).top +
        (_barTopPadding +
                _control +
                (searchOpen ? _searchBlock : 0) +
                _barBottomPadding) *
            s;
  }

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  /// Currently selected filter; `null` means "All".
  NoticeCategory? _category;

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  /// The reference's drawer starts collapsed; the search button opens it.
  bool _searchOpen = false;

  List<SchoolNotice> get _visibleNotices {
    final String query = _query.trim().toLowerCase();
    return <SchoolNotice>[
      for (final SchoolNotice notice in kNotices)
        if ((_category == null || notice.category == _category) &&
            (query.isEmpty ||
                notice.title.toLowerCase().contains(query) ||
                notice.summary.toLowerCase().contains(query) ||
                notice.body.toLowerCase().contains(query) ||
                notice.date.contains(query)))
          notice,
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Navigation ────────────────────────────────────────────────────────
  int get _noticesIndex => kBottomNavDestinations.indexWhere(
    (BottomNavDestination d) => d.label == 'Notices',
  );

  void _onTabSelected(int index) =>
      AppRoutes.switchTab(context, index, _noticesIndex);

  // ── Actions ───────────────────────────────────────────────────────────
  void _toggleSearch() {
    setState(() {
      _searchOpen = !_searchOpen;
      if (!_searchOpen) {
        _query = '';
        _searchController.clear();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  Future<void> _openNotice(SchoolNotice notice) =>
      NoticeDetailSheet.show(context, notice: notice);

  // ── UI ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);
    final double barHeight = NoticesScreen.barHeightOf(
      context,
      searchOpen: _searchOpen,
    );
    final double navHeight = AppBottomNav.heightOf(context);
    final List<SchoolNotice> notices = _visibleNotices;

    return Scaffold(
      backgroundColor: AppPalette.dashboardBg,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          // Layer 1 — pinned filter row above the scrolling list.
          Positioned.fill(
            child: Column(
              children: <Widget>[
                SizedBox(height: barHeight),
                _FilterTabs(
                  selected: _category,
                  scale: s,
                  onSelected: (NoticeCategory? category) =>
                      setState(() => _category = category),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg * s,
                      AppSpacing.md * s,
                      AppSpacing.lg * s,
                      navHeight + AppSpacing.block * s,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppLayout.maxContentWidth,
                        ),
                        child: notices.isEmpty
                            ? _EmptyState(scale: s)
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  for (
                                    int i = 0;
                                    i < notices.length;
                                    i++
                                  ) ...<Widget>[
                                    if (i > 0)
                                      SizedBox(height: AppSpacing.md * s),
                                    _NoticeCard(
                                      notice: notices[i],
                                      scale: s,
                                      onTap: () => _openNotice(notices[i]),
                                    ),
                                  ],
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Layer 2 — pinned maroon app bar + search drawer.
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: _AppBar(
              scale: s,
              searchOpen: _searchOpen,
              controller: _searchController,
              query: _query,
              onBack: () => Navigator.of(context).maybePop(),
              onToggleSearch: _toggleSearch,
              onSearchChanged: (String value) => setState(() => _query = value),
              onClearSearch: _clearSearch,
            ),
          ),

          // Layer 3 — persistent navigation.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNav(
              selectedIndex: _noticesIndex,
              enabledIndices: <int>{0, 1, 2, 3},
              onSelected: _onTabSelected,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// App bar + search drawer
// ─────────────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  const _AppBar({
    required this.scale,
    required this.searchOpen,
    required this.controller,
    required this.query,
    required this.onBack,
    required this.onToggleSearch,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  final double scale;
  final bool searchOpen;
  final TextEditingController controller;
  final String query;
  final VoidCallback onBack;
  final VoidCallback onToggleSearch;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    final double s = scale;
    final double inset = MediaQuery.paddingOf(context).top;

    return Container(
      padding: EdgeInsets.only(
        top: inset + NoticesScreen._barTopPadding * s,
        bottom: NoticesScreen._barBottomPadding * s,
        left: AppSpacing.lg * s,
        right: AppSpacing.lg * s,
      ),
      decoration: const BoxDecoration(color: AppPalette.maroon800),
      child: Column(
        children: <Widget>[
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppLayout.maxContentWidth,
              ),
              child: Row(
                children: <Widget>[
                  _IconButton(
                    icon: Icons.arrow_back_rounded,
                    scale: s,
                    onTap: onBack,
                    semanticLabel: 'Go Back',
                  ),
                  Expanded(
                    child: Text(
                      'Notices',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18 * s,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2 * s,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  _IconButton(
                    icon: searchOpen
                        ? Icons.search_off_rounded
                        : Icons.search_rounded,
                    scale: s,
                    onTap: onToggleSearch,
                    semanticLabel: 'Search Notices',
                  ),
                ],
              ),
            ),
          ),
          if (searchOpen)
            Padding(
              padding: EdgeInsets.only(top: 10 * s),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppLayout.maxContentWidth,
                  ),
                  child: _SearchField(
                    controller: controller,
                    showClear: query.isNotEmpty,
                    scale: s,
                    onChanged: onSearchChanged,
                    onClear: onClearSearch,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
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
      width: NoticesScreen._control * s,
      height: NoticesScreen._control * s,
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

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.showClear,
    required this.scale,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final bool showClear;
  final double scale;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.inner * s),
      ),
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 14 * s, right: AppSpacing.sm * s),
            child: Icon(
              Icons.search_rounded,
              size: 15 * s,
              color: AppGray.shade400,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(
                fontSize: 12.5 * s,
                fontWeight: FontWeight.w500,
                color: AppGray.shade800,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search notices, exams, holidays...',
                hintStyle: TextStyle(
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w500,
                  color: AppGray.shade400,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 11 * s),
              ),
            ),
          ),
          if (showClear)
            InkWell(
              onTap: onClear,
              borderRadius: BorderRadius.circular(AppRadii.pill),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * s,
                  vertical: AppSpacing.sm * s,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 15 * s,
                  color: AppGray.shade400,
                ),
              ),
            )
          else
            SizedBox(width: AppSpacing.md * s),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Category filter pills
// ─────────────────────────────────────────────────────────────────────────

class _FilterOption {
  const _FilterOption(this.label, this.category);
  final String label;
  final NoticeCategory? category;
}

const List<_FilterOption> _filters = <_FilterOption>[
  _FilterOption('All', null),
  _FilterOption('Academic', NoticeCategory.academic),
  _FilterOption('Events', NoticeCategory.events),
  _FilterOption('Other', NoticeCategory.other),
];

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({
    required this.selected,
    required this.scale,
    required this.onSelected,
  });

  final NoticeCategory? selected;
  final double scale;
  final ValueChanged<NoticeCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg * s,
        vertical: AppSpacing.md * s,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppGray.shade100)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppLayout.maxContentWidth,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                for (int i = 0; i < _filters.length; i++) ...<Widget>[
                  if (i > 0) SizedBox(width: AppSpacing.sm * s),
                  _FilterPill(
                    label: _filters[i].label,
                    active: _filters[i].category == selected,
                    scale: s,
                    onTap: () => onSelected(_filters[i].category),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
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

    return Container(
      decoration: BoxDecoration(
        color: active ? AppPalette.maroon800 : AppGray.shade100,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        boxShadow: active
            ? <BoxShadow>[
                BoxShadow(
                  color: AppPalette.maroon800.withValues(alpha: 0.18),
                  blurRadius: 6 * s,
                  offset: Offset(0, 1 * s),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg * s,
              vertical: 7 * s,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12 * s,
                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                color: active ? Colors.white : AppGray.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Notice card + empty state
// ─────────────────────────────────────────────────────────────────────────

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    required this.notice,
    required this.scale,
    required this.onTap,
  });

  final SchoolNotice notice;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20 * s),
            border: Border.all(color: AppPalette.cardBorder),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10 * s,
                offset: Offset(0, 2 * s),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20 * s),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.all(14 * s),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 44 * s,
                      height: 44 * s,
                      decoration: BoxDecoration(
                        color: notice.iconTintBackground,
                        borderRadius: BorderRadius.circular(AppRadii.block * s),
                        border: Border.all(color: notice.iconBorder),
                      ),
                      child: Icon(
                        notice.icon,
                        size: 20 * s,
                        color: notice.iconTint,
                      ),
                    ),
                    SizedBox(width: 14 * s),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: AppSpacing.lg * s),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              notice.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13 * s,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                                color: AppPalette.headingText,
                              ),
                            ),
                            SizedBox(height: 3 * s),
                            Text(
                              notice.summary,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11 * s,
                                height: 1.45,
                                fontWeight: FontWeight.w500,
                                color: AppPalette.supportingText,
                              ),
                            ),
                            SizedBox(height: AppSpacing.sm * s),
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 11 * s,
                                  color: AppGray.shade400,
                                ),
                                SizedBox(width: AppSpacing.xs * s),
                                Text(
                                  notice.date,
                                  style: TextStyle(
                                    fontSize: 10 * s,
                                    fontWeight: FontWeight.w500,
                                    color: AppGray.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (notice.pinned)
          Positioned(
            top: AppSpacing.md * s,
            right: AppSpacing.md * s,
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Icon(
                Icons.push_pin,
                size: 14 * s,
                color: AppPalette.maroon800,
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 56 * s,
        horizontal: AppSpacing.lg * s,
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 64 * s,
            height: 64 * s,
            decoration: const BoxDecoration(
              color: AppGray.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 26 * s,
              color: AppGray.shade400,
            ),
          ),
          SizedBox(height: 14 * s),
          Text(
            'No notices found',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14 * s,
              fontWeight: FontWeight.w600,
              color: AppGray.shade700,
            ),
          ),
          SizedBox(height: AppSpacing.xs * s),
          Text(
            'Try changing category filter or search keywords',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12 * s,
              fontWeight: FontWeight.w500,
              color: AppGray.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
