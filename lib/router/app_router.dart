// PayMaye — GoRouter Configuration
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/ui/login_screen.dart';
import '../features/auth/ui/signup_screen.dart';
import '../repositories/account_firestore_repository.dart';
import '../repositories/transaction_firestore_repository.dart';
import '../repositories/user_firestore_repository.dart';
import '../features/home/ui/home_screen.dart';
import '../features/accounts/ui/accounts_screen.dart';
import '../features/insights/ui/insights_screen.dart';

class AppRouter {
  static GoRouter createRouter({
    required AuthBloc authBloc,
    required AccountFirestoreRepository accountFirestoreRepository,
    required TransactionFirestoreRepository transactionFirestoreRepository,
    required UserFirestoreRepository userFirestoreRepository,
  }) {
    return GoRouter(
      initialLocation: '/firestore-test',
      refreshListenable: _BlocListenable(authBloc),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isLogin = state.matchedLocation == '/login';
        final isSignup = state.matchedLocation == '/signup';

        if (authState is AuthUnauthenticated && !isLogin && !isSignup)
          return '/login';
        if (authState is AuthAuthenticated && (isLogin || isSignup))
          return '/home';
        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
        ShellRoute(
          builder: (_, state, child) =>
              _MainShell(child: child, location: state.matchedLocation),
          routes: [
            GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
            GoRoute(
                path: '/accounts', builder: (_, __) => const AccountsScreen()),
            GoRoute(
                path: '/insights', builder: (_, __) => const InsightsScreen()),
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
    (
      icon: Icons.account_balance_wallet_rounded,
      label: 'Accounts',
      path: '/accounts'
    ),
    (icon: Icons.send_rounded, label: 'Transfer', path: '/transfer'),
    (icon: Icons.pie_chart_rounded, label: 'Insights', path: '/insights'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go('/home');
            case 1:
              context.go('/accounts');
            case 2:
              context.go('/transfer');
            case 3:
              context.go('/insights');
          }
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.account_balance_outlined),
              selectedIcon: Icon(Icons.account_balance),
              label: 'Accounts'),
          NavigationDestination(
              icon: Icon(Icons.send_outlined),
              selectedIcon: Icon(Icons.send),
              label: 'Transfer'),
          NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Insights'),
        ],
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
