// NexaBank — Complete Banking Mobile App
// BCT Mobile Applications Track — Day 9 Final Build

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexa_bank/firebase_options.dart';

import 'core/auth/auth_service.dart';
import 'services/account_firestore_service.dart';
import 'services/transaction_firestore_service.dart';
import 'services/user_firestore_service.dart';
import 'core/network/dio_client.dart';
import 'core/storage/secure_token_store.dart';
import 'core/theme/app_theme.dart';
import 'features/accounts/bloc/account_bloc.dart';
import 'repositories/account_firestore_repository.dart';
import 'repositories/transaction_firestore_repository.dart';
import 'repositories/user_firestore_repository.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/insights/bloc/insights_bloc.dart';
import 'features/transfers/bloc/transfer_bloc.dart';
import 'features/transfers/data/transfer_repository.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
  final transferRepository = RemoteTransferRepository(apiClient);
  final accountFirestoreService = AccountFirestoreService();
  final transactionFirestoreService = TransactionFirestoreService();
  final userFirestoreService = UserFirestoreService();
  final accountFirestoreRepository =
      AccountFirestoreRepository(accountFirestoreService);
  final transactionFirestoreRepository =
      TransactionFirestoreRepository(transactionFirestoreService);
  final userFirestoreRepository = UserFirestoreRepository(userFirestoreService);

  runApp(NexaBankApp(
    authService: authService,
    transferRepository: transferRepository,
    accountFirestoreRepository: accountFirestoreRepository,
    transactionFirestoreRepository: transactionFirestoreRepository,
    userFirestoreRepository: userFirestoreRepository,
  ));
}

class NexaBankApp extends StatelessWidget {
  final AuthService authService;
  final TransferRepository transferRepository;
  final AccountFirestoreRepository accountFirestoreRepository;
  final TransactionFirestoreRepository transactionFirestoreRepository;
  final UserFirestoreRepository userFirestoreRepository;

  const NexaBankApp({
    super.key,
    required this.authService,
    required this.transferRepository,
    required this.accountFirestoreRepository,
    required this.transactionFirestoreRepository,
    required this.userFirestoreRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(authService)..add(const AuthCheckRequested()),
        ),
        BlocProvider(
          create: (_) => AccountBloc(
            accountFirestoreRepository,
            transactionFirestoreRepository,
          ),
          lazy: false,
        ),
        BlocProvider(
          create: (_) => TransferBloc(transferRepository),
        ),
        BlocProvider(
          create: (_) => InsightsBloc(transactionFirestoreRepository),
        ),
      ],
      child: Builder(
        builder: (context) {
          final router = AppRouter.createRouter(
            authBloc: context.read<AuthBloc>(),
            accountFirestoreRepository: accountFirestoreRepository,
            transactionFirestoreRepository: transactionFirestoreRepository,
            userFirestoreRepository: userFirestoreRepository,
          );

          return MaterialApp.router(
            title: 'PayMaye',
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
