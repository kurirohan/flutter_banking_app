// PayMaye — Login Screen with PKCE OAuth flow
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/constants/app_spacing.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.violetDeep,
                AppColors.violet,
                AppColors.orchid,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Decorative bubbly blobs — the one bold flourish on an
              // otherwise quiet, disciplined screen.
              Positioned(
                top: -60,
                right: -40,
                child: _blob(180, AppColors.sunshine.withValues(alpha: 0.35)),
              ),
              Positioned(
                bottom: 120,
                left: -70,
                child: _blob(200, AppColors.bubblegum.withValues(alpha: 0.35)),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.huge),
                  child: Column(
                    children: [
                      const Spacer(flex: 3),
                      // Logo mark
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.large),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [AppColors.violet, AppColors.bubblegum],
                          ).createShader(bounds),
                          child: const Center(
                            child: Icon(Icons.savings_rounded,
                                color: Colors.white, size: 38),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      const Text('PayMaye',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5)),
                      const SizedBox(height: AppSpacing.xs),
                      Text('Money, made friendly',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 16)),
                      const Spacer(flex: 3),
                      // Features
                      const _FeatureRow(
                        icon: Icons.shield_rounded,
                        text: 'Bank-level security & encryption',
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const _FeatureRow(
                        icon: Icons.bolt_rounded,
                        text: 'Instant transfers & payments',
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const _FeatureRow(
                        icon: Icons.insights_rounded,
                        text: 'Friendly spending insights',
                      ),
                      const Spacer(flex: 4),
                      // Login button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoginInProgress;
                          return SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.violetDeep,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.button)),
                                elevation: 0,
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () => context
                                      .read<AuthBloc>()
                                      .add(const AuthLoginRequested()),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation(
                                              AppColors.violet)),
                                    )
                                  : const Text('Sign in with PayMaye ID',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16)),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Protected by OAuth 2.0 + PKCE',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12),
                      ),
                      const SizedBox(height: AppSpacing.huge),
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

  Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppRadius.avatarSquare),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Text(text,
              style: const TextStyle(color: Colors.white, fontSize: 14)),
        ),
      ],
    );
  }
}
