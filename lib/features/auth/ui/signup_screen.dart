// PayMaye — Sign Up Screen
//
// Standalone screen for new-account creation. Not yet wired into
// AuthBloc (the app currently uses an OAuth + PKCE-only login flow —
// see login_screen.dart / auth_bloc.dart), so this screen collects and
// validates the form locally. To go live, connect `_handleSubmit` to a
// real registration call (e.g. a new AuthSignupRequested event on
// AuthBloc).
//
// Palette matches login_screen.dart / the reference Figma UI kit:
// deep navy header + pink-violet gradient + yellow accent, and the
// colorful pastel field badges echo the contact avatars (ES/EA/OW/SB)
// from the reference kit's Transfer screen. All defined centrally in
// AppColors.auth*.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_spacing.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthdayController = TextEditingController();

  DateTime? _selectedBirthday;


  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter your full name';
    if (value.trim().length < 2) return 'Name looks too short';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter your email';
    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your phone number';
    }
    final phoneRegex = RegExp(r'^09\d{9}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Enter a valid 11-digit mobile number';
    }
    return null;
  }

  String? _validateBirthday(String? value) {
    if (_selectedBirthday == null) {
      return 'Select your birthday';
    }
    final now = DateTime.now();
    int age = now.year - _selectedBirthday!.year;

    if (now.month < _selectedBirthday!.month ||
        (now.month == _selectedBirthday!.month &&
            now.day < _selectedBirthday!.day)) {
      age--;
    }
    if (age < 18) {
      return 'You must be at least 18 years old';
    }
    return null;
  }

  Future<void> _pickBirthday() async {
  final pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now().subtract(
      const Duration(days: 365 * 18),
    ),
    firstDate: DateTime(1900),
    lastDate: DateTime.now(),
  );

  if (pickedDate != null) {
    setState(() {
      _selectedBirthday = pickedDate;
      _birthdayController.text =
          "${pickedDate.month.toString().padLeft(2, '0')}/"
          "${pickedDate.day.toString().padLeft(2, '0')}/"
          "${pickedDate.year}";
    });
  }
}

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter a password';
    if (value.length < 8) return 'Use at least 8 characters';
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
    final hasDigit = RegExp(r'\d').hasMatch(value);
    if (!hasLetter || !hasDigit) return 'Mix letters and numbers';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Confirm your password';
    if (value != _passwordController.text) return 'Passwords don\'t match';
    return null;
  }

  Future<void> _handleSubmit() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) return;

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms & Privacy Policy to continue'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // TODO: replace with a real registration call, e.g.:
    // context.read<AuthBloc>().add(AuthSignupRequested(
    //   name: _nameController.text.trim(),
    //   email: _emailController.text.trim(),
    //   password: _passwordController.text,
    // ));
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account created — you can now sign in'),
        backgroundColor: AppColors.success,
      ),
    );
    context.go('/login');
  }

  /// Small colored circle badge for a field's leading icon — echoes the
  /// pastel contact-avatar circles (ES, EA, OW, SB...) from the
  /// reference kit's Transfer screen.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  // Logo with the yellow accent blob peeking out behind it,
                  // same treatment as login_screen.dart.
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
                          'Create account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Your PayMaye journey starts here',
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
                            bodyLarge: const TextStyle(
                              color: Colors.black87,
                              ),
                            ),
                        ),
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Full name',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: AppColors.authGradientEnd,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              TextFormField(
                                controller: _nameController,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  hintText: 'Juan Dela Cruz',
                                  prefixIcon: _fieldBadge(
                                      Icons.person_outline, AppColors.authBadgeBlue),
                                ),
                                validator: _validateName,
                              ),
                              const SizedBox(height: AppSpacing.xl),

                              Text(
                                'Email address',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: AppColors.authGradientEnd,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  hintText: 'you@example.com',
                                  prefixIcon: _fieldBadge(
                                      Icons.mail_outline, AppColors.authBadgePink),
                                ),
                                validator: _validateEmail,
                              ),
                              const SizedBox(height: AppSpacing.xl),

                              Text(
                                'Phone number',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: AppColors.authGradientEnd,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                maxLength: 11,
                                decoration: InputDecoration(
                                  hintText: '09XXXXXXXXX',
                                  counterText: '',
                                  prefixIcon: _fieldBadge(
                                    Icons.phone_outlined,
                                    AppColors.authBadgeTeal,
                                  ),
                                ),
                                validator: _validatePhone,
                              ),
                              const SizedBox(height: AppSpacing.xl),

                              Text(
                                'Birthday',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: AppColors.authGradientEnd,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              TextFormField(
                                controller: _birthdayController,
                                readOnly: true,
                                validator: _validateBirthday,
                                onTap: _pickBirthday,
                                decoration: InputDecoration(
                                  hintText: 'Select your birth date',
                                  prefixIcon: _fieldBadge(
                                    Icons.cake_outlined,
                                    AppColors.authBadgeLavender,
                                  ),
                                  suffixIcon: const Icon(Icons.calendar_month_outlined),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),

                              Text(
                                'Password',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: AppColors.authGradientEnd,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  hintText: 'At least 8 characters',
                                  prefixIcon: _fieldBadge(
                                      Icons.lock_outline, AppColors.authBadgeTeal),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined),
                                    onPressed: () => setState(
                                        () => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                validator: _validatePassword,
                              ),
                              const SizedBox(height: AppSpacing.xl),

                              Text(
                                'Confirm password',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: AppColors.authGradientEnd,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  hintText: 'Re-enter your password',
                                  prefixIcon: _fieldBadge(
                                      Icons.lock_outline, AppColors.authBadgeLavender),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscureConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined),
                                    onPressed: () => setState(() =>
                                        _obscureConfirmPassword = !_obscureConfirmPassword),
                                  ),
                                ),
                                validator: _validateConfirmPassword,
                                onFieldSubmitted: (_) => _handleSubmit(),
                              ),
                              const SizedBox(height: AppSpacing.xl),

                              // Terms checkbox
                              InkWell(
                                borderRadius: BorderRadius.circular(AppRadius.small),
                                onTap: () =>
                                    setState(() => _agreedToTerms = !_agreedToTerms),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                      value: _agreedToTerms,
                                      activeColor: AppColors.authGradientEnd,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.pillActive),
                                      ),
                                      onChanged: (v) =>
                                          setState(() => _agreedToTerms = v ?? false),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 14),
                                        child: RichText(
                                          text: TextSpan(
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                    color: Colors.black87, height: 1.4),
                                            children: const [
                                              TextSpan(text: 'I agree to the '),
                                              TextSpan(
                                                text: 'Terms of Service',
                                                style: TextStyle(
                                                  color: AppColors.authGradientEnd,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              TextSpan(text: ' and '),
                                              TextSpan(
                                                text: 'Privacy Policy',
                                                style: TextStyle(
                                                  color: AppColors.authGradientEnd,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxl),

                              // Create account button — gradient, matches login
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: AppColors.authGradient,
                                    ),
                                    borderRadius: BorderRadius.circular(AppRadius.button),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.authGradientEnd.withOpacity(0.35),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(AppRadius.button),
                                      onTap: _isSubmitting ? null : _handleSubmit,
                                      child: Center(
                                        child: _isSubmitting
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation(
                                                      Colors.white),
                                                ),
                                              )
                                            : const Text(
                                                'Create account',
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
                              ),
                              const SizedBox(height: AppSpacing.xl),

                              // Sign in link
                              Center
                              (
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Already have an account? ',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Colors.grey.shade600,
                                          ),
                                    ),
                                    GestureDetector(
                                      onTap: () => context.go('/login'),
                                      child: const Text(
                                        'Sign in',
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
                  // Small yellow accent blob straddling the header/form
                  // seam — echoes the yellow blob behind the avatar on
                  // the reference kit's "Good morning" account screen.
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
    );
  }
}