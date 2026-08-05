// NexaBank — Smoke test
//
// Boots the real app with its real (mock-backed) dependencies and checks
// it renders without throwing. AuthBloc's AuthCheckRequested handler
// gracefully falls back to "unauthenticated" when secure storage isn't
// available in the test environment, so this settles on the login screen.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nexa_bank/core/auth/auth_service.dart';
import 'package:nexa_bank/core/network/dio_client.dart';
import 'package:nexa_bank/core/storage/secure_token_store.dart';
import 'package:nexa_bank/features/accounts/data/account_repository.dart';
import 'package:nexa_bank/features/transfers/data/transfer_repository.dart';
import 'package:nexa_bank/main.dart';

void main() {
  testWidgets('NexaBankApp builds and settles without throwing', (tester) async {
    final tokenStore = SecureTokenStore();
    final authService = AuthService(tokenStore);
    final apiClient = ApiClient(
      getAccessToken: authService.getValidAccessToken,
      onUnauthorized: authService.logout,
    );

    await tester.pumpWidget(NexaBankApp(
      authService: authService,
      accountRepository: RemoteAccountRepository(apiClient),
      transferRepository: RemoteTransferRepository(apiClient),
    ));

    // Let async auth-check + navigation settle.
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
