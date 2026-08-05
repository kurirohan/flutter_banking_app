import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const NexaBankApp());
}

class NexaBankApp extends StatelessWidget {
  const NexaBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(authService)..add(const AuthCheckRequested()),
        ),
        BlocProvider(
          create: (_) => AccountBloc(accountRepository),
          lazy: false,
        ),
        BlocProvider(
          create: (_) => TransferBloc(transferRepository),
        ),
        BlocProvider(
          create: (_) => InsightsBloc(accountRepository),
        ),
      ],
      child: Builder(
        builder: (context) {
          final router = AppRouter.createRouter(
            authBloc: context.read<AuthBloc>(),
          );

          return MaterialApp.router(
            title: 'NexaBank',
            debugShowCheckedModeBanner: false,
            theme: PayMayeTheme.light(),
            darkTheme: PayMayeTheme.dark(),
            themeMode: ThemeMode.system,
            routerConfig: router,
          );
        },
      ),
    );
  }
}

