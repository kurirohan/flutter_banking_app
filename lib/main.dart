// NexaBank — Complete Banking Mobile App
// BCT Mobile Applications Track — Day 9 Final Build

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/auth/auth_service.dart';
import 'core/network/dio_client.dart';
import 'core/storage/secure_token_store.dart';
import 'core/theme/app_theme.dart';
import 'features/accounts/bloc/account_bloc.dart';
import 'features/accounts/data/account_repository.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/insights/bloc/insights_bloc.dart';
import 'features/transfers/bloc/transfer_bloc.dart';
import 'features/transfers/data/transfer_repository.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Initialize dependencies
  final tokenStore = SecureTokenStore();
  final authService = AuthService(tokenStore);
  final apiClient = ApiClient(
    getAccessToken: authService.getValidAccessToken,
    onUnauthorized: authService.logout,
  );

  // Repositories
  final accountRepository = RemoteAccountRepository(apiClient);
  final transferRepository = RemoteTransferRepository(apiClient);

  runApp(NexaBankApp(
    authService: authService,
    accountRepository: accountRepository,
    transferRepository: transferRepository,
  ));
}

class NexaBankApp extends StatelessWidget {
  final AuthService authService;
  final AccountRepository accountRepository;
  final TransferRepository transferRepository;

  const NexaBankApp({
    super.key,
    required this.authService,
    required this.accountRepository,
    required this.transferRepository,
  });

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
            theme: NexaBankTheme.light(),
            darkTheme: NexaBankTheme.dark(),
            themeMode: ThemeMode.system,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
