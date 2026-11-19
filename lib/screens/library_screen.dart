import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';
import '../core/app_routes.dart';
import '../core/app_theme.dart' show AppRadii, AppSpacing;
import '../models/library_book.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_screen_bar.dart';
import '../widgets/app_toast.dart';
import '../widgets/book_action_sheet.dart';
import '../widgets/book_detail_sheet.dart';
import '../widgets/book_spine_cover.dart';
import '../widgets/library_badge.dart';

/// Library — borrowed titles and the searchable catalogue.
///
/// Opened from the dashboard's quick actions, under the Academics section. The
/// segmented control toggles between the student's issued books (with a
/// borrowed/quota summary and the overdue fine notice) and the full catalogue
/// with live search and category filters. Card taps open the detail sheet, the
/// "more" button opens the options sheet, and every action confirms through a
/// toast. The bottom nav keeps the Academics tab active, as in the reference.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  /// Route name declared in `MaterialApp.routes`.
  static const String routeName = AppRoutes.library;

  static const Color _surface = Color(0xFFF8F9FA);

  // ── App bar geometry ──────────────────────────────────────────────────
  /// Full height of the maroon app bar, so the pinned tabs and the toast
  /// layer can clear it exactly.
  ///
  /// The bar itself is now rendered by [AppScreenBar], whose defaults
  /// reproduce this screen's geometry; the public name is kept because the
  /// toast layer positions against it.
  static double barHeightOf(BuildContext context) =>
      AppScreenBar.heightOf(context);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  /// 0 — Issued Books, 1 — All Books. The reference opens on the catalogue.
  int _tabIndex = 1;

  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _category = 'All';

  String? _toastMessage;
  Timer? _toastTimer;

  // ── Derived data ──────────────────────────────────────────────────────
  int get _overdueCount => kIssuedBooks
      .where((IssuedBook b) => b.statusTone == LibraryBadgeTone.danger)
      .length;

  List<CatalogBook> get _visibleCatalog {
    final String query = _query.trim().toLowerCase();
    return <CatalogBook>[
      for (final CatalogBook book in kCatalogBooks)
        if ((_category == 'All' || book.category == _category) &&
            (query.isEmpty ||
                book.title.toLowerCase().contains(query) ||
                book.author.toLowerCase().contains(query) ||
                book.category.toLowerCase().contains(query)))
          book,
    ];
  }

  // ── Toast ─────────────────────────────────────────────────────────────
  void _showToast(String message) {
    if (!mounted) return;
    setState(() => _toastMessage = message);
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 2400), () {
      if (mounted) setState(() => _toastMessage = null);
    });
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────────────────
  Future<void> _openIssuedBook(IssuedBook book) async {
    final BookSheetAction? action = await BookDetailSheet.show(
      context,
      title: book.title,
      author: book.author,
      cover: book.cover,
      badgeText: book.statusText,
      badgeTone: book.statusTone,
      firstLabel: 'Issued On',
      firstValue: book.issuedDate,
      secondLabel: 'Due Date',
      secondValue: book.dueDate,
      renewalsText: '${book.renewalsLeft} of ${book.renewalsTotal}',
    );
    if (!mounted || action == null) return;
    _showToast('Book renewal submitted successfully.');
  }

  Future<void> _openIssuedOptions(IssuedBook book) async {
    final BookAction? action = await BookActionSheet.show(
      context,
      title: book.title,
    );
    if (!mounted || action == null) return;

    switch (action) {
      case BookAction.renew:
        _showToast('Renewal requested for ${book.title}! Extended by 14 days.');
      case BookAction.history:
        _showToast('Loading complete issue history...');
      case BookAction.report:
        _showToast('Report filed for ${book.title}. Librarian notified.');
    }
  }

  Future<void> _openPreview(CatalogBook book) async {
    final BookSheetAction? action = await BookDetailSheet.show(
      context,
      title: book.title,
      author: book.author,
      cover: book.cover,
      badgeText: 'In Library',
      badgeTone: LibraryBadgeTone.info,
      firstLabel: 'Availability',
      firstValue: book.rack,
      secondLabel: 'Lending Term',
      secondValue: '7-day lending term',
    );
    if (!mounted || action == null) return;
    _showToast('Book renewal submitted successfully.');
  }

  void _reserve(CatalogBook book) =>
      _showToast('Reservation request sent for "${book.title}".');

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  // ── Navigation ────────────────────────────────────────────────────────
  int get _academicsIndex => kBottomNavDestinations.indexWhere(
    (BottomNavDestination d) => d.label == 'Academics',
  );

  void _onTabSelected(int index) =>
      AppRoutes.switchTab(context, index, _academicsIndex);

  // ── UI ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);
    final double barHeight = LibraryScreen.barHeightOf(context);
    final double navHeight = AppBottomNav.heightOf(context);

    return Scaffold(
      backgroundColor: LibraryScreen._surface,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          // Layer 1 — pinned segmented control above the scrolling content.
          Positioned.fill(
            child: Column(
              children: <Widget>[
                SizedBox(height: barHeight),
                _LibraryTabs(
                  index: _tabIndex,
                  scale: s,
                  onChanged: (int i) => setState(() => _tabIndex = i),
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
                        child: _tabIndex == 0
                            ? _issuedView(s)
                            : _catalogView(s),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Layer 2 — pinned maroon app bar.
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: AppScreenBar(
              title: 'Library',
              onBack: () => Navigator.of(context).maybePop(),
              // This screen's bar keeps its own 18pt w700 title with
              // letter-spacing and the round chevron at 22.
              leadingIcon: Icons.chevron_left_rounded,
              iconSize: 22,
              titleSize: 18,
              titleWeight: FontWeight.w700,
              titleLetterSpacing: 0.3,
            ),
          ),

          // Layer 3 — toast, just under the app bar.
          if (_toastMessage != null)
            Positioned(
              left: 0,
              right: 0,
              top: barHeight + AppSpacing.sm * s,
              child: Center(child: AppToast(message: _toastMessage!)),
            ),

          // Layer 4 — persistent navigation.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNav(
              selectedIndex: _academicsIndex,
              enabledIndices: <int>{0, 1, 2, 3},
              onSelected: _onTabSelected,
            ),
          ),
        ],
      ),
    );
  }

  // ── Issued books ──────────────────────────────────────────────────────
  Widget _issuedView(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _BorrowSummary(
          borrowed: kIssuedBooks.length,
          quota: kBorrowQuota,
          overdue: _overdueCount,
          scale: s,
        ),
        SizedBox(height: AppSpacing.md * s),
        for (int i = 0; i < kIssuedBooks.length; i++) ...<Widget>[
          if (i > 0) SizedBox(height: AppSpacing.md * s),
          _IssuedBookCard(
            book: kIssuedBooks[i],
            scale: s,
            onTap: () => _openIssuedBook(kIssuedBooks[i]),
            onOptions: () => _openIssuedOptions(kIssuedBooks[i]),
          ),
        ],
        SizedBox(height: AppSpacing.lg * s),
        _FineNotice(scale: s),
      ],
    );
  }

  // ── Catalogue ─────────────────────────────────────────────────────────
  Widget _catalogView(double s) {
    final List<CatalogBook> books = _visibleCatalog;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SearchField(
          controller: _searchController,
          showClear: _query.isNotEmpty,
          scale: s,
          onChanged: (String value) => setState(() => _query = value),
          onClear: _clearSearch,
        ),
        SizedBox(height: 10 * s),
        _CategoryChips(
          selected: _category,
          scale: s,
          onSelected: (String value) => setState(() => _category = value),
        ),
        SizedBox(height: AppSpacing.md * s),
        if (books.isEmpty)
          _EmptyCatalog(scale: s)
        else
          for (int i = 0; i < books.length; i++) ...<Widget>[
            if (i > 0) SizedBox(height: AppSpacing.md * s),
            _CatalogCard(
              book: books[i],
              scale: s,
              onRequest: () => _reserve(books[i]),
              onDetails: () => _openPreview(books[i]),
            ),
          ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Segmented control
// ─────────────────────────────────────────────────────────────────────────

class _LibraryTabs extends StatelessWidget {
  const _LibraryTabs({
    required this.index,
    required this.scale,
    required this.onChanged,
  });

  final int index;
  final double scale;
  final ValueChanged<int> onChanged;

  static const List<String> _labels = <String>['Issued Books', 'All Books'];

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl * s,
        AppSpacing.lg * s,
        AppSpacing.xl * s,
        AppSpacing.md * s,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppSlate.shade100)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppLayout.maxContentWidth,
          ),
          child: Container(
            padding: EdgeInsets.all(AppSpacing.xs * s),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F6),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Row(
              children: <Widget>[
                for (int i = 0; i < _labels.length; i++)
                  Expanded(
                    child: _TabButton(
                      label: _labels[i],
                      active: i == index,
                      scale: s,
                      onTap: () => onChanged(i),
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

class _TabButton extends StatelessWidget {
  const _TabButton({
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
        color: active ? AppPalette.maroon800 : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        boxShadow: active
            ? <BoxShadow>[
                BoxShadow(
                  color: AppPalette.maroon800.withValues(alpha: 0.2),
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
            padding: EdgeInsets.symmetric(vertical: 9 * s),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12 * s,
                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                color: active ? Colors.white : AppSlate.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Borrowed summary + fine notice
// ─────────────────────────────────────────────────────────────────────────

class _BorrowSummary extends StatelessWidget {
  const _BorrowSummary({
    required this.borrowed,
    required this.quota,
    required this.overdue,
    required this.scale,
  });

  final int borrowed;
  final int quota;
  final int overdue;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md * s),
      decoration: BoxDecoration(
        color: AppPalette.maroonSurface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppRadii.block * s),
        border: Border.all(color: AppPalette.maroon800.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 36 * s,
            height: 36 * s,
            decoration: BoxDecoration(
              color: AppPalette.maroon800,
              borderRadius: BorderRadius.circular(AppRadii.inner * s),
            ),
            child: Icon(
              Icons.bookmark_added_outlined,
              size: 18 * s,
              color: Colors.white,
            ),
          ),
          SizedBox(width: AppSpacing.md * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$borrowed Books Borrowed',
                  style: TextStyle(
                    fontSize: 13 * s,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                    color: AppSlate.shade900,
                  ),
                ),
                SizedBox(height: 2 * s),
                Text(
                  'Quota limit: $quota books',
                  style: TextStyle(
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w500,
                    color: AppSlate.shade500,
                  ),
                ),
              ],
            ),
          ),
          if (overdue > 0) ...<Widget>[
            SizedBox(width: AppSpacing.sm * s),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10 * s,
                vertical: 4 * s,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadii.tiny * s),
                border: Border.all(
                  color: AppPalette.maroon800.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                '$overdue Overdue',
                style: TextStyle(
                  fontSize: 11 * s,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.maroon800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FineNotice extends StatelessWidget {
  const _FineNotice({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      padding: EdgeInsets.all(14 * s),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppRadii.block * s),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.info_outline_rounded,
            size: 15 * s,
            color: const Color(0xFFD97706),
          ),
          SizedBox(width: 10 * s),
          Expanded(
            child: Text(
              kLibraryFineNotice,
              style: TextStyle(
                fontSize: 11 * s,
                height: 1.45,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF78350F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Resting lift shared by the white issued-book and catalogue rows. Both
/// cards carry the identical elevation, so the shadow lives once here.
List<BoxShadow> _libraryCardShadow(double s) => <BoxShadow>[
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.04),
    blurRadius: 10 * s,
    offset: Offset(0, 2 * s),
  ),
];

// ─────────────────────────────────────────────────────────────────────────
// Issued book card
// ─────────────────────────────────────────────────────────────────────────

class _IssuedBookCard extends StatelessWidget {
  const _IssuedBookCard({
    required this.book,
    required this.scale,
    required this.onTap,
    required this.onOptions,
  });

  final IssuedBook book;
  final double scale;
  final VoidCallback onTap;
  final VoidCallback onOptions;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadii.block * s),
            border: Border.all(color: AppPalette.cardBorder),
            boxShadow: _libraryCardShadow(s),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.block * s),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md * s),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    BookSpineCover(cover: book.cover, scale: s),
                    SizedBox(width: 14 * s),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 22 * s),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              book.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14 * s,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.1 * s,
                                color: AppSlate.shade900,
                              ),
                            ),
                            SizedBox(height: 3 * s),
                            Text(
                              'Issued: ${book.issuedDate}',
                              style: TextStyle(
                                fontSize: 11 * s,
                                fontWeight: FontWeight.w500,
                                color: AppSlate.shade500,
                              ),
                            ),
                            Text(
                              'Due: ${book.dueDate}',
                              style: TextStyle(
                                fontSize: 11 * s,
                                fontWeight: FontWeight.w500,
                                color: AppSlate.shade500,
                              ),
                            ),
                            SizedBox(height: AppSpacing.sm * s),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: LibraryBadge(
                                text: book.statusText,
                                tone: book.statusTone,
                                scale: s,
                              ),
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
        Positioned(
          right: 6 * s,
          top: 8 * s,
          child: SizedBox(
            width: 30 * s,
            height: 30 * s,
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onOptions,
                child: Icon(
                  Icons.more_vert_rounded,
                  size: 18 * s,
                  color: AppSlate.shade400,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Catalogue card
// ─────────────────────────────────────────────────────────────────────────

class _CatalogCard extends StatelessWidget {
  const _CatalogCard({
    required this.book,
    required this.scale,
    required this.onRequest,
    required this.onDetails,
  });

  final CatalogBook book;
  final double scale;
  final VoidCallback onRequest;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md * s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.block * s),
        border: Border.all(color: AppPalette.cardBorder),
        boxShadow: _libraryCardShadow(s),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          BookSpineCover(cover: book.cover, scale: s, width: 62, height: 84),
          SizedBox(width: AppSpacing.md * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  spacing: 6 * s,
                  runSpacing: AppSpacing.xs * s,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      book.rack.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10 * s,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5 * s,
                        color: AppPalette.maroon800,
                      ),
                    ),
                    LibraryBadge(
                      text: book.statusText,
                      tone: book.statusTone,
                      scale: s,
                    ),
                  ],
                ),
                SizedBox(height: 3 * s),
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5 * s,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1 * s,
                    color: AppSlate.shade900,
                  ),
                ),
                SizedBox(height: 2 * s),
                Text(
                  'Author: ${book.author}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w500,
                    color: AppSlate.shade500,
                  ),
                ),
                SizedBox(height: 10 * s),
                Wrap(
                  spacing: 6 * s,
                  runSpacing: 6 * s,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    _RequestButton(scale: s, onTap: onRequest),
                    TextButton(
                      onPressed: onDetails,
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.symmetric(
                          horizontal: 8 * s,
                          vertical: 6 * s,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: AppSlate.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppRadii.tiny * s,
                          ),
                        ),
                      ),
                      child: Text(
                        'Details',
                        style: TextStyle(
                          fontSize: 11 * s,
                          fontWeight: FontWeight.w600,
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
    );
  }
}

class _RequestButton extends StatelessWidget {
  const _RequestButton({required this.scale, required this.onTap});

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Material(
      color: AppPalette.maroon800,
      borderRadius: BorderRadius.circular(AppRadii.tiny * s),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 7 * s),
          child: Text(
            'Request Book',
            style: TextStyle(
              fontSize: 11 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyCatalog extends StatelessWidget {
  const _EmptyCatalog({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 32 * s, horizontal: 16 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.block * s),
        border: Border.all(color: AppPalette.cardBorder),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.search_off_rounded,
            size: 28 * s,
            color: AppSlate.shade300,
          ),
          SizedBox(height: AppSpacing.sm * s),
          Text(
            'No books match your search.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12 * s,
              fontWeight: FontWeight.w500,
              color: AppSlate.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Search + filters
// ─────────────────────────────────────────────────────────────────────────

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
        border: Border.all(color: AppSlate.shade200),
      ),
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 14 * s, right: 8 * s),
            child: Icon(
              Icons.search_rounded,
              size: 16 * s,
              color: AppSlate.shade400,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(
                fontSize: 12.5 * s,
                fontWeight: FontWeight.w500,
                color: AppSlate.shade800,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search by title, author, or ISBN...',
                hintStyle: TextStyle(
                  fontSize: 12.5 * s,
                  fontWeight: FontWeight.w500,
                  color: AppSlate.shade400,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: AppSpacing.md * s,
                ),
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
                  vertical: 8 * s,
                ),
                child: Icon(
                  Icons.cancel,
                  size: 16 * s,
                  color: AppSlate.shade400,
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

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.selected,
    required this.scale,
    required this.onSelected,
  });

  final String selected;
  final double scale;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (int i = 0; i < kLibraryCategories.length; i++) ...<Widget>[
            if (i > 0) SizedBox(width: AppSpacing.sm * s),
            _CategoryChip(
              label: kLibraryCategories[i],
              active: kLibraryCategories[i] == selected,
              scale: s,
              onTap: () => onSelected(kLibraryCategories[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
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
        color: active ? AppPalette.maroon800 : Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: active ? null : Border.all(color: AppSlate.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 6 * s),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11 * s,
                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                color: active ? Colors.white : AppSlate.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
