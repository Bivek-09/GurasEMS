import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';
import '../core/app_routes.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_feedback.dart';
import '../widgets/app_text_field.dart';

/// Destination of the splash screen.
///
/// A restrained, on-brand sign-in form that arrives with a short staggered
/// entrance. The layout is centred and width-capped so it stays comfortable on
/// tablets instead of stretching across the whole display.
///
/// There is no backend wired up yet, so [_submit] runs a clearly-labelled
/// development flow: the form validates locally, shows a loading state, then
/// enters the dashboard. Replace [_authenticate] with the real call when the
/// authentication service is available.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  /// Route name declared in `MaterialApp.routes`.
  static const String routeName = AppRoutes.login;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// Entrance timing for the login screen. Private to this file because nothing
/// outside the screen depends on it.
abstract final class _LoginTimeline {
  static const Duration total = Duration(milliseconds: 1150);

  static const Interval logo = Interval(0.00, 0.36, curve: Curves.easeOutCubic);
  static const Interval heading = Interval(
    0.18,
    0.58,
    curve: Curves.easeOutCubic,
  );
  static const Interval form = Interval(0.38, 0.78, curve: Curves.easeOutCubic);
  static const Interval actions = Interval(
    0.58,
    1.00,
    curve: Curves.easeOutCubic,
  );
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  /// Widest the form is allowed to get, so tablets stay readable.
  static const double _maxFormWidth = 420;

  /// Unscaled dimensions, multiplied by the responsive scale factor.
  static const double _logoHeight = 74;
  static const double _titleSize = 28;
  static const double _subtitleSize = 15;

  /// How far each entrance starts below its final position.
  static const double _riseOffset = 0.14;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final AnimationController _controller;

  /// Set from `MediaQuery` in [didChangeDependencies]; when the platform has
  /// animations switched off the entrance is resolved immediately.
  bool _reduceMotionApplied = false;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _LoginTimeline.total,
    )..forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion && !_reduceMotionApplied) {
      _reduceMotionApplied = true;
      // Jump to the end so the form is present and usable straight away.
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Maps an entrance interval onto the controller.
  Animation<double> _stage(Interval interval) =>
      _controller.drive(CurveTween(curve: interval));

  /// Fades [child] in while it rises into place.
  Widget _reveal({required Animation<double> stage, required Widget child}) {
    return FadeTransition(
      opacity: stage,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, _riseOffset),
          end: Offset.zero,
        ).animate(stage),
        child: child,
      ),
    );
  }

  String? _validateId(String? value) {
    final String id = (value ?? '').trim();
    if (id.isEmpty) return 'Please enter your student ID or email';
    if (id.length < 5) return 'That ID looks too short';
    return null;
  }

  String? _validatePassword(String? value) {
    final String password = value ?? '';
    if (password.isEmpty) return 'Please enter your password';
    if (password.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  /// Development authentication step.
  ///
  /// Deliberately does not fabricate a server round-trip beyond a short delay;
  /// it exists so the loading state, validation and navigation are exercised
  /// end to end until the real service replaces it.
  Future<bool> _authenticate() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return true;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_loading) return;

    final bool valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      showAppSnackBar(
        context,
        'Please fix the highlighted fields.',
        isError: true,
      );
      return;
    }

    setState(() => _loading = true);
    final bool ok = await _authenticate();
    if (!mounted) return;
    setState(() => _loading = false);

    if (!ok) {
      showAppSnackBar(
        context,
        'We could not sign you in. Check your details and try again.',
        isError: true,
      );
      return;
    }

    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  Future<void> _showForgotPassword() async {
    FocusScope.of(context).unfocus();
    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text(
          'Reset your password',
          style: TextStyle(fontWeight: FontWeight.w700, color: AppPalette.navy),
        ),
        content: const Text(
          'A reset link is sent to the email registered with the school '
          'office. Automatic reset is not connected yet — for now, please '
          'contact the office and they will re-issue your password.',
          style: TextStyle(height: 1.45, color: AppPalette.supportingText),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              showAppSnackBar(context, 'School office: support@guras.edu.np');
            },
            child: const Text('Contact office'),
          ),
        ],
      ),
    );
  }

  Future<void> _showHelp() async {
    FocusScope.of(context).unfocus();
    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text(
          'Sign-in help',
          style: TextStyle(fontWeight: FontWeight.w700, color: AppPalette.navy),
        ),
        content: const Text(
          'Use the student ID printed on your ID card, or the email address '
          'registered with the school. If you have forgotten your password, '
          'tap "Forgot password?" to request a reset.\n\n'
          'Still stuck? Email support@guras.edu.np or call the school office '
          'at +977 9800000000.',
          style: TextStyle(height: 1.5, color: AppPalette.supportingText),
        ),
        actions: <Widget>[
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double scale = AppLayout.scaleOf(context);

    return Scaffold(
      backgroundColor: AppPalette.background,
      body: SafeArea(
        child: Center(
          // Scrolls instead of overflowing when the keyboard opens on a short
          // device.
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxFormWidth),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _reveal(
                      stage: _stage(_LoginTimeline.logo),
                      child: Center(
                        child: Image.asset(
                          AppAssets.logo,
                          height: _logoHeight * scale,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    SizedBox(height: 30 * scale),

                    _reveal(
                      stage: _stage(_LoginTimeline.heading),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Welcome back',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: _titleSize * scale,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                              color: AppPalette.navy,
                              letterSpacing: -0.02 * _titleSize * scale,
                            ),
                          ),
                          SizedBox(height: 8 * scale),
                          Text(
                            'Sign in to continue your learning journey.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: _subtitleSize * scale,
                              height: 1.45,
                              color: AppPalette.muted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 34 * scale),

                    _reveal(
                      stage: _stage(_LoginTimeline.form),
                      child: Column(
                        children: <Widget>[
                          AppTextField(
                            label: 'Student ID or email',
                            hint: 'STU-2083-0156 or you@school.edu',
                            icon: Icons.badge_outlined,
                            controller: _idController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const <String>[
                              AutofillHints.username,
                            ],
                            validator: _validateId,
                          ),
                          SizedBox(height: 18 * scale),
                          AppTextField(
                            label: 'Password',
                            hint: 'Enter your password',
                            icon: Icons.lock_outline,
                            controller: _passwordController,
                            obscure: true,
                            textInputAction: TextInputAction.done,
                            autofillHints: const <String>[
                              AutofillHints.password,
                            ],
                            validator: _validatePassword,
                            onSubmitted: (_) => _submit(),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 6 * scale),

                    Align(
                      alignment: Alignment.centerRight,
                      child: _reveal(
                        stage: _stage(_LoginTimeline.form),
                        child: TextButton(
                          onPressed: _showForgotPassword,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          child: const Text('Forgot password?'),
                        ),
                      ),
                    ),

                    SizedBox(height: 8 * scale),

                    _reveal(
                      stage: _stage(_LoginTimeline.actions),
                      child: PrimaryButton(
                        label: 'Sign in',
                        onPressed: _submit,
                        loading: _loading,
                      ),
                    ),

                    SizedBox(height: 6 * scale),

                    _reveal(
                      stage: _stage(_LoginTimeline.actions),
                      child: TextButton(
                        onPressed: _showHelp,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text('Need help signing in?'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
