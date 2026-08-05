// NexaBank — Accounts Screen with Transaction History
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nexa_bank/models/account.dart';
import 'package:nexa_bank/models/transaction.dart' as txn_model;
import '../bloc/account_bloc.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

// Category → icon mapping for transaction rows. Kept in sync with the
// mapping in home_screen.dart so a given category renders with the same
// icon everywhere in the app.
const _kCategoryIcons = {
  'Food & Drinks': Icons.restaurant_rounded,
  'Shopping': Icons.shopping_bag_rounded,
  'Transport': Icons.directions_car_rounded,
  'Entertainment': Icons.movie_rounded,
  'Income': Icons.account_balance_rounded,
  'Utilities': Icons.bolt_rounded,
  'Healthcare': Icons.local_hospital_rounded,
  'Other': Icons.receipt_rounded,
};

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  // Matches the phone-width cap used on the Home screen so this screen
  // doesn't stretch edge-to-edge on wide desktop/web viewports.
  static const double _maxContentWidth = 480;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text('Accounts'),
        titleTextStyle: const TextStyle(
          color: AppColors.homeTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: AppColors.homePrimaryPurple),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: BlocBuilder<AccountBloc, AccountState>(
              builder: (context, state) {
                return switch (state) {
                  AccountLoading() => const _AccountsLoading(),
                  AccountLoaded() => _AccountsContent(state: state),
                  AccountError(:final message) =>
                    _AccountsError(message: message),
                  _ => const _AccountsLoading(),
                };
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountsContent extends StatelessWidget {
  final AccountLoaded state;
  const _AccountsContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AccountTabs(state: state),
        Expanded(
          child: state.transactionsLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.homePrimaryPurple,
                  ),
                )
              : _TransactionHistory(transactions: state.transactions),
        ),
      ],
    );
  }
}

class _AccountTabs extends StatelessWidget {
  final AccountLoaded state;
  const _AccountTabs({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Row(
            children: state.accounts.map((acc) {
              final isSelected = acc.id == state.selectedAccountId;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: ChoiceChip(
                  label: Text(acc.name),
                  selected: isSelected,
                  onSelected: (_) =>
                      context.read<AccountBloc>().add(AccountSelected(acc.id)),
                  selectedColor: AppColors.homePrimaryPurple,
                  backgroundColor: AppColors.homeSurface,
                  side: BorderSide(
                    color:
                        isSelected ? Colors.transparent : AppColors.homeBorder,
                  ),
                  labelStyle: TextStyle(
                    color:
                        isSelected ? Colors.white : AppColors.homeTextPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Balance summary card for the selected account. This is the only
        // place the balance is shown — a second, unguarded copy used to
        // live below this (behind a `Spacer()` with no bounded height,
        // which throws at runtime, and force-unwrapping `selectedAccount!`
        // with no null check). Removed rather than fixed in place, since
        // the info is already shown here.
        if (state.selectedAccount != null)
          Container(
            margin: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              0,
              AppSpacing.xl,
              AppSpacing.lg,
            ),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.homePrimaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.homePrimaryDeepPlum.withOpacity(.18),
                  blurRadius: 24,
                  spreadRadius: 1,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Balance',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormatter.format(
                          state.selectedAccount!.balance,
                          currency: state.selectedAccount!.currency,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Available',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyFormatter.format(
                        state.selectedAccount!.balance,
                        currency: state.selectedAccount!.currency,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TransactionHistory extends StatelessWidget {
  final List<txn_model.Transaction> transactions;
  const _TransactionHistory({required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text(
          'No transactions',
          style: TextStyle(color: AppColors.homeTextSecondary),
        ),
      );
    }

    // Group by date
    final grouped = <String, List<txn_model.Transaction>>{};
    for (final txn in transactions) {
      final key = DateFormat('MMMM d, yyyy').format(txn.dateCreated);
      grouped.putIfAbsent(key, () => []).add(txn);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: grouped.length,
      itemBuilder: (context, i) {
        final date = grouped.keys.elementAt(i);
        final txns = grouped[date]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Container(
              color: AppColors.homeBackground,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
              width: double.infinity,
              child: Text(
                date,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.homeTextSecondary,
                ),
              ),
            ),
            ...txns.map((t) => _TxnRow(txn: t)),
          ],
        );
      },
    );
  }
}

class _TxnRow extends StatelessWidget {
  final txn_model.Transaction txn;
  const _TxnRow({required this.txn});

  @override
  Widget build(BuildContext context) {
    final isCredit = txn.type == txn_model.TransactionType.credit;
    final icon = _kCategoryIcons[txn.category] ?? Icons.receipt_rounded;
    final tintColor =
        isCredit ? AppColors.homeSuccess : AppColors.homePrimaryPurple;
    final amountColor =
        isCredit ? AppColors.homeSuccess : AppColors.homeTextPrimary;

    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.sm),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.homeSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.homeBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tintColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: tintColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.sourceAcctId ?? txn.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.homeTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  txn.category,
                  style: const TextStyle(
                    color: AppColors.homeTextSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            CurrencyFormatter.formatSigned(
              txn.amount,
              isCredit: isCredit,
              currency: txn.currency,
            ),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountsLoading extends StatelessWidget {
  const _AccountsLoading();

  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator(color: AppColors.homePrimaryPurple),
      );
}

class _AccountsError extends StatelessWidget {
  final String message;
  const _AccountsError({required this.message});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.homeError.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline_rounded,
                    size: 36, color: AppColors.homeError),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.homeTextPrimary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.homePrimaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () => context
                    .read<AccountBloc>()
                    .add(const AccountFetchRequested()),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
}
