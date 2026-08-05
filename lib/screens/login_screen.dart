import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/password_requirement_tile.dart';
import 'welcome_screen.dart';


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
        return AppColors.focus;
      case ValidationState.normal:
        return AppColors.border;
    }
  }

  void _login() {
    setState(() {
      _submitted = true;
    });

    if (_isEmailValid && _isPasswordValid) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          const _BackgroundDecor(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryDark,
                              AppColors.primary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryDark.withValues(alpha: 0.18),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
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
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  Text(
                    'Welcome back',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Securely access your account with a clean and protected sign in experience.',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDark.withValues(alpha: 0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
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
                              color: AppColors.textSecondary,
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
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Transform.scale(
                              scale: 0.95,
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: AppColors.primary,
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
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(
                                  color: AppColors.primary,
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
                              color: AppColors.error.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.25),
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
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primaryDark,
                                    AppColors.primary,
                                    AppColors.primaryLight,
                                  ],
                                ),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                constraints: const BoxConstraints(minHeight: 56),
                                child: const Text(
                                  'Log In',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              side: const BorderSide(
                                color: AppColors.primaryLight,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
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
        ],
      ),
    );
  }
}

class _BackgroundDecor extends StatelessWidget {
  const _BackgroundDecor();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -50,
          child: Container(
            width: 220,
            height: 220,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentYellow,
            ),
          ),
        ),
        Positioned(
          top: 140,
          left: -70,
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentBlue.withValues(alpha: 0.28),
            ),
          ),
        ),
        Positioned(
          bottom: 60,
          right: -50,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentPink.withValues(alpha: 0.22),
            ),
          ),
        ),
      ],
    );
  }
}

