// PayMaye — Profile Screen
//
// Reached by tapping the avatar on the Home dashboard. Shows the signed-in
// user's details and lets them log out. User fields are mocked for the
// prototype (see _ProfileDetails below) since there's no real identity
// backend yet — AuthBloc already exposes a userId on AuthAuthenticated,
// which is what a real profile fetch would key off of.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../accounts/bloc/account_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/constants/app_spacing.dart';

/// Mock profile fields for the prototype. Swapping in a real identity
/// backend later just means populating this from a `UserRepository` keyed
/// off `AuthAuthenticated.userId` instead of hardcoding it here.
class _ProfileDetails {
  static const name = 'Alex Johnson';
  static const initials = 'AJ';
  static const email = 'alex.johnson@paymaye.app';
  static const phone = '+63 917 123 4567';
  static const payMayeId = 'PM-20481';
  static const memberSince = 'March 2023';
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl, AppSpacing.md, AppSpacing.xxl, AppSpacing.huge),
        children: [
          const _ProfileHeader(),
          const SizedBox(height: AppSpacing.xxl),
          Text('Account details', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          _DetailCard(
            children: [
              _DetailRow(icon: Icons.badge_rounded, label: 'PayMaye ID', value: _ProfileDetails.payMayeId),
              _DetailRow(icon: Icons.mail_rounded, label: 'Email', value: _ProfileDetails.email),
              _DetailRow(icon: Icons.phone_rounded, label: 'Phone', value: _ProfileDetails.phone),
              _DetailRow(
                icon: Icons.calendar_today_rounded,
                label: 'Member since',
                value: _ProfileDetails.memberSince,
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Your accounts', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          const _AccountsSummaryCard(),
          const SizedBox(height: AppSpacing.xxxl),
          _LogoutButton(),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.violet, AppColors.bubblegum],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
            ),
            child: Center(
              child: Text(_ProfileDetails.initials,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800, fontSize: 26)),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(_ProfileDetails.name,
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(_ProfileDetails.email,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final List<Widget> children;
  const _DetailCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(children: children),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: isLast
          ? null
          : const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.outline)),
            ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: AppColors.fog, borderRadius: BorderRadius.circular(AppRadius.avatarSquare)),
            child: Icon(icon, color: AppColors.violet, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(label, style: const TextStyle(color: AppColors.inkMuted, fontSize: 13)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountsSummaryCard extends StatelessWidget {
  const _AccountsSummaryCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        if (state is! AccountLoaded || state.accounts.isEmpty) {
          return const _DetailCard(children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text('No accounts to show', style: TextStyle(color: AppColors.inkMuted)),
            ),
          ]);
        }
        final accounts = state.accounts;
        return _DetailCard(
          children: [
            for (var i = 0; i < accounts.length; i++)
              _DetailRow(
                icon: accounts[i].type == 'savings'
                    ? Icons.savings_rounded
                    : Icons.account_balance_wallet_rounded,
                label: accounts[i].name,
                value: CurrencyFormatter.format(accounts[i].balance, currency: accounts[i].currency),
                isLast: i == accounts.length - 1,
              ),
          ],
        );
      },
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
        ),
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Log out', style: TextStyle(fontWeight: FontWeight.w700)),
        onPressed: () => _confirmLogout(context),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.dialog)),
        title: const Text('Log out?', style: TextStyle(color: AppColors.ink)),
        content: const Text(
          'You\'ll need to sign in again to access your accounts.',
          style: TextStyle(color: AppColors.inkMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              // The router's redirect (see app_router.dart) sends
              // unauthenticated users to /login automatically once
              // AuthBloc emits AuthUnauthenticated — no manual navigation
              // needed here.
            },
            child: const Text('Log out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
