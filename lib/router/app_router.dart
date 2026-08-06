// PayMaye — GoRouter Configuration
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/ui/login_screen.dart';
import '../features/auth/ui/signin_screen.dart';
import '../features/auth/ui/signup_screen.dart';
import '../features/home/ui/home_screen.dart';
import '../features/accounts/ui/accounts_screen.dart';
import '../features/transfers/ui/transfer_screen.dart';
import '../features/insights/ui/insights_screen.dart';

class AppRouter {
  static GoRouter createRouter({required AuthBloc authBloc}) {
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: _BlocListenable(authBloc),

    redirect: (context, state) {
      final authState = authBloc.state;

      // Allow all authentication-related pages
      final isAuthRoute =
          state.matchedLocation.startsWith('/login') ||
          state.matchedLocation == '/signup';

      // Unauthenticated users can only access auth pages
      if (authState is AuthUnauthenticated && !isAuthRoute) {
        return '/login';
      }

      // Authenticated users should not go back to auth pages
      if (authState is AuthAuthenticated && isAuthRoute) {
        return '/home';
      }

      return null;
    },

    routes: [
      // Authentication
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/login/signin',
        builder: (_, __) => const SignInScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (_, __) => const SignupScreen(),
      ),

      // Main app
      ShellRoute(
        builder: (_, state, child) => _MainShell(
          child: child,
          location: state.matchedLocation,
        ),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: '/accounts',
            builder: (_, __) => const AccountsScreen(),
          ),
          GoRoute(
            path: '/transfer',
            builder: (_, __) => const TransferScreen(),
          ),
          GoRoute(
            path: '/insights',
            builder: (_, __) => const InsightsScreen(),
          ),
        ],
      ),
    ],
  );
}
}

class _BlocListenable extends ChangeNotifier {
  _BlocListenable(AuthBloc bloc) {
    bloc.stream.listen((_) => notifyListeners());
  }
}

class _MainShell extends StatelessWidget {
  final Widget child;
  final String location;
  const _MainShell({required this.child, required this.location});

  static const _destinations = [
    (icon: Icons.home_rounded, label: 'Home', path: '/home'),
    (icon: Icons.account_balance_wallet_rounded, label: 'Accounts', path: '/accounts'),
    (icon: Icons.send_rounded, label: 'Transfer', path: '/transfer'),
    (icon: Icons.pie_chart_rounded, label: 'Insights', path: '/insights'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: _BubbleNavBar(
        selectedIndex: _index,
        destinations: _destinations,
        onSelected: (i) => context.go(_destinations[i].path),
      ),
    );
  }

  int get _index {
    if (location.startsWith('/accounts')) return 1;
    if (location.startsWith('/transfer')) return 2;
    if (location.startsWith('/insights')) return 3;
    return 0;
  }
}

/// A quiet, icon-only floating nav bar: the active tab gets a filled
/// rounded-square backdrop in the brand violet, everything else stays a
/// soft muted icon. Matches the flat, minimal bottom bars in the design
/// reference rather than Material's default labeled NavigationBar.
class _BubbleNavBar extends StatelessWidget {
  final int selectedIndex;
  final List<({IconData icon, String label, String path})> destinations;
  final ValueChanged<int> onSelected;

  const _BubbleNavBar({
    required this.selectedIndex,
    required this.destinations,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.large),
          boxShadow: [
            BoxShadow(
              color: AppColors.violet.withValues(alpha: 0.14),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var i = 0; i < destinations.length; i++)
              _NavItem(
                icon: destinations[i].icon,
                label: destinations[i].label,
                isSelected: i == selectedIndex,
                onTap: () => onSelected(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      selected: isSelected,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.violet : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.inkFaint,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
