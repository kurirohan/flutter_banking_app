import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_spacing.dart';

/// Username / password sign-in screen.
///
/// Reached from [LoginScreen] via the "Sign In" button. Visually mirrors
/// SignupScreen: same header treatment (back button + logo), same rounded
/// form sheet, same field-badge + gradient-button styling.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  static const double _labelGap = AppSpacing.sm;
  static const double _fieldGap = AppSpacing.xl;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your username';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter your password';
    }
    return null;
  }

  void _handleSubmit(BuildContext context) {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) return;

    // NOTE: adjust the event name/fields to whatever your AuthBloc exposes
    // for credential-based sign-in (this repo's AuthBloc currently only
    // shows an OAuth `AuthLoginRequested()` with no args — you'll likely
    // want a new event, e.g. AuthCredentialsLoginRequested).
    context.read<AuthBloc>().add(
          AuthCredentialsLoginRequested(
            username: _usernameController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  Widget _fieldBadge(IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.all(10),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }

  Widget _fieldLabel(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.authGradientEnd,
          ),
    );
  }

  Widget _buildField({
    required BuildContext context,
    required String label,
    required Widget field,
    bool trailingGap = true,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: trailingGap ? _fieldGap : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(context, label),
          const SizedBox(height: _labelGap),
          field,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (_, curr) => curr is AuthFailure,
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
        if (state is AuthAuthenticated) {
          context.go('/home');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.authBackground,
        body: SafeArea(
          child: Column(
            children: [
              // ── Header ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl, AppSpacing.lg, AppSpacing.xxl, AppSpacing.xxl,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go('/login'),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.avatarSquare),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                color: AppColors.authAccentYellow,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: AppColors.authGradient,
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.medium),
                            ),
                            child: const Center(
                              child: Text(
                                'P',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sign in',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Enter your username and password',
                            style: TextStyle(color: Colors.white60, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Form sheet ────────────────────────────────────
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: AppColors.lightBackground,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(AppRadius.cardLarge),
                          topRight: Radius.circular(AppRadius.cardLarge),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xxl, AppSpacing.huge, AppSpacing.xxl, AppSpacing.xxl,
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            inputDecorationTheme: PayMayeTheme.authInputDecorationTheme,
                            textTheme: Theme.of(context).textTheme.copyWith(
                                  bodyLarge: const TextStyle(color: Colors.black87),
                                ),
                          ),
                          child: Form(
                            key: _formKey,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildField(
                                  context: context,
                                  label: 'Username',
                                  field: TextFormField(
                                    controller: _usernameController,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      hintText: 'Enter your username',
                                      prefixIcon: _fieldBadge(
                                        Icons.person_outline,
                                        AppColors.authBadgeBlue,
                                      ),
                                    ),
                                    validator: _validateUsername,
                                  ),
                                ),

                                _buildField(
                                  context: context,
                                  label: 'Password',
                                  trailingGap: false,
                                  field: TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    decoration: InputDecoration(
                                      hintText: 'Enter your password',
                                      prefixIcon: _fieldBadge(
                                        Icons.lock_outline,
                                        AppColors.authBadgeTeal,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(_obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined),
                                        onPressed: () => setState(
                                            () => _obscurePassword = !_obscurePassword),
                                      ),
                                    ),
                                    validator: _validatePassword,
                                    onFieldSubmitted: (_) => _handleSubmit(context),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => context.go('/login/forgot-password'),
                                    child: const Text(
                                      'Forgot password?',
                                      style: TextStyle(
                                        color: AppColors.authGradientEnd,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xl),

                                // Sign in button — gradient, matches signup
                                BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, state) {
                                    final isLoading = state is AuthLoginInProgress;
                                    return SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: AppColors.authGradient,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(AppRadius.button),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.authGradientEnd
                                                  .withOpacity(0.35),
                                              blurRadius: 16,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(AppRadius.button),
                                            onTap: isLoading
                                                ? null
                                                : () => _handleSubmit(context),
                                            child: Center(
                                              child: isLoading
                                                  ? const SizedBox(
                                                      width: 24,
                                                      height: 24,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            AlwaysStoppedAnimation(
                                                                Colors.white),
                                                      ),
                                                    )
                                                  : const Text(
                                                      'Sign in',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: AppSpacing.xl),

                                // Sign up link
                                Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Don't have an account? ",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: Colors.grey.shade600),
                                      ),
                                      GestureDetector(
                                        onTap: () => context.go('/signup'),
                                        child: const Text(
                                          'Create one',
                                          style: TextStyle(
                                            color: AppColors.authGradientEnd,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: -18,
                      right: 28,
                      child: IgnorePointer(
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.authAccentYellow.withOpacity(0.85),
                            shape: BoxShape.circle,
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