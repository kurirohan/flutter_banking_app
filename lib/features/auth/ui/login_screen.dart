// NexaBank — Login Screen with PKCE OAuth flow
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (_, curr) => curr is AuthFailure,
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(),
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.large),
                  ),
                  child: const Center(
                    child: Text('N',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('NexaBank',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Secure mobile banking',
                    style: TextStyle(color: Colors.white60, fontSize: 16)),
                const Spacer(),
                // Features
                const _FeatureRow(icon: Icons.security, text: 'Bank-level security & encryption'),
                const SizedBox(height: 16),
                const _FeatureRow(icon: Icons.speed, text: 'Instant transfers & payments'),
                const SizedBox(height: 16),
                const _FeatureRow(icon: Icons.bar_chart, text: 'AI-powered spending insights'),
                const Spacer(),
                // Login button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoginInProgress;
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.button)),
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
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                        AppColors.primary)),
                              )
                            : const Text('Sign in with NexaBank ID',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Protected by OAuth 2.0 + PKCE',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.avatarSquare),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 16),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }
}
