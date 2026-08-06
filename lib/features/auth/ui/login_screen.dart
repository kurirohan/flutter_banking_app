import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/password_requirement_tile.dart';
import '../../../screens/welcome_screen.dart';
import '../bloc/auth_bloc.dart';
import 'package:go_router/go_router.dart';

enum ValidationState { normal, valid, invalid, focused }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_refresh);
    _passwordController.addListener(_refresh);
    _emailFocus.addListener(_refresh);
    _passwordFocus.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  bool get _isEmailValid {
    final text = _emailController.text.trim();
    if (text.isEmpty) return false;

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    final usernameRegex = RegExp(r'^[a-zA-Z0-9._-]{4,}$');

    return emailRegex.hasMatch(text) || usernameRegex.hasMatch(text);
  }

  bool get _hasMinLength => _passwordController.text.length >= 8;
  bool get _hasUppercase => RegExp(r'[A-Z]').hasMatch(_passwordController.text);
  bool get _hasLowercase => RegExp(r'[a-z]').hasMatch(_passwordController.text);
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_passwordController.text);
  bool get _hasSpecial =>
      RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-\\/\[\]=+;]')
          .hasMatch(_passwordController.text);

  bool get _isPasswordValid =>
      _hasMinLength &&
      _hasUppercase &&
      _hasLowercase &&
      _hasNumber &&
      _hasSpecial;

  Color get _neutralBorder => Colors.grey.shade300;
  Color get _mutedText => Colors.grey.shade600;

  ValidationState _emailState() {
    if (_emailFocus.hasFocus) return ValidationState.focused;
    if (_emailController.text.isEmpty) return ValidationState.normal;
    return _isEmailValid ? ValidationState.valid : ValidationState.invalid;
  }

  ValidationState _passwordState() {
    if (_passwordFocus.hasFocus) return ValidationState.focused;
    if (_passwordController.text.isEmpty) return ValidationState.normal;
    return _isPasswordValid ? ValidationState.valid : ValidationState.invalid;
  }

  Color _borderColor(ValidationState state) {
    switch (state) {
      case ValidationState.valid:
        return AppColors.success;
      case ValidationState.invalid:
        return AppColors.error;
      case ValidationState.focused:
        return AppColors.authGradientEnd;
      case ValidationState.normal:
        return _neutralBorder;
    }
  }

  void _login() {
    setState(() {
      _submitted = true;
    });

    if (_isEmailValid && _isPasswordValid) {
      // Dispatch to AuthBloc instead of navigating directly.
      // The router's redirect will send us to /home once
      // AuthBloc emits AuthAuthenticated.
      context.read<AuthBloc>().add(const AuthLoginRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        inputDecorationTheme: PayMayeTheme.authInputDecorationTheme,
      ),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.authBackground,
          body: Stack(
            children: [
              const _AuthBackgroundDecor(),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button papuntang Welcome Screen
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => context.go('/'),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.small),
                              ),
                            ),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Container(
                            height: 56,
                            width: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppRadius.card),
                              gradient: const LinearGradient(
                                colors: AppColors.authGradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.authGradientEnd.withOpacity(0.30),
                                  blurRadius: 22,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'PayMaye',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 42),

                      Text(
                        'Welcome back',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Securely access your account with a clean and protected sign in experience.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.78),
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 28),

                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.cardLarge),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.16),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextField(
                              controller: _emailController,
                              focusNode: _emailFocus,
                              label: 'Username or Email',
                              hint: 'Enter username or email',
                              icon: Icons.person_outline_rounded,
                              borderColor: _borderColor(_emailState()),
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              label: 'Password',
                              hint: 'Enter your password',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              borderColor: _borderColor(_passwordState()),
                              suffix: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: _mutedText,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            PasswordRequirementTile(
                              text: 'At least 8 characters',
                              met: _hasMinLength,
                            ),
                            PasswordRequirementTile(
                              text: 'Contains uppercase and lowercase letters',
                              met: _hasUppercase && _hasLowercase,
                            ),
                            PasswordRequirementTile(
                              text: 'Contains at least one number',
                              met: _hasNumber,
                            ),
                            PasswordRequirementTile(
                              text: 'Contains at least one special character',
                              met: _hasSpecial,
                            ),

                            const SizedBox(height: 18),

                            Row(
                              children: [
                                Transform.scale(
                                  scale: 0.95,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    activeColor: AppColors.authGradientEnd,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Remember me',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      color: AppColors.authGradientEnd,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            if (_submitted && (!_isEmailValid || !_isPasswordValid))
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 14),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(AppRadius.medium),
                                  border: Border.all(
                                    color: AppColors.error.withOpacity(0.25),
                                  ),
                                ),
                                child: const Text(
                                  'Please enter a valid username/email and a strong password.',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                            SizedBox(
                              width: double.infinity,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: AppColors.authGradient,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(AppRadius.button),
                                ),
                                child: BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, state) {
                                    final isLoading = state is AuthLoginInProgress;
                                    return ElevatedButton(
                                      onPressed: isLoading ? null : _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(AppRadius.button),
                                        ),
                                      ),
                                      child: isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : const Text('Log In'),
                                    );
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  context.go('/signup');
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppColors.authGradientEnd,
                                    width: 1.4,
                                  ),
                                  foregroundColor: AppColors.authGradientEnd,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.button),
                                  ),
                                ),
                                child: const Text('Sign Up'),
                              ),
                            ),
                          ],
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
    );
  }
}

class _AuthBackgroundDecor extends StatelessWidget {
  const _AuthBackgroundDecor();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -70,
          right: -50,
          child: Container(
            width: 220,
            height: 220,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.authAccentYellow,
            ),
          ),
        ),
        Positioned(
          top: 180,
          left: -60,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.authGradientStart.withOpacity(0.18),
            ),
          ),
        ),
        Positioned(
          bottom: 60,
          right: -40,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.authGradientEnd.withOpacity(0.18),
            ),
          ),
        ),
      ],
    );
  }
}