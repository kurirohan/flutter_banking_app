// NexaBank — GoRouter Configuration
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/ui/login_screen.dart';
import '../features/firestore_test/data/firestore_repository.dart';
import '../features/firestore_test/ui/firestore_test_screen.dart';
import '../features/home/ui/home_screen.dart';
import '../features/accounts/ui/accounts_screen.dart';
import '../features/transfers/ui/transfer_screen.dart';
import '../features/insights/ui/insights_screen.dart';

class AppRouter {
  static GoRouter createRouter({
    required AuthBloc authBloc,
    required FirestoreRepository firestoreRepository,
  }) {
    return GoRouter(
      initialLocation: '/home',
      refreshListenable: _BlocListenable(authBloc),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isLogin = state.matchedLocation == '/login';

        if (authState is AuthUnauthenticated && !isLogin) return '/login';
        if (authState is AuthAuthenticated && isLogin) return '/home';
        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        ShellRoute(
          builder: (_, state, child) =>
              _MainShell(location: state.matchedLocation, child: child),
          routes: [
            GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
            GoRoute(
                path: '/accounts', builder: (_, __) => const AccountsScreen()),
            GoRoute(
                path: '/transfer', builder: (_, __) => const TransferScreen()),
            GoRoute(
                path: '/insights', builder: (_, __) => const InsightsScreen()),
            GoRoute(
              path: '/firestore-test',
              builder: (_, __) =>
                  FirestoreTestScreen(repository: firestoreRepository),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
