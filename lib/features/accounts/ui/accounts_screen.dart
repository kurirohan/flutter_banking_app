// PayMaye — Accounts Screen with Transaction History
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/account_bloc.dart';
import '../data/account_repository.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/utils/transaction_style.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/constants/app_spacing.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(title: const Text('Accounts')),
      body: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, state) {
          if (state is AccountLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.violet));
          }
          if (state is AccountError) {
            return Center(
              child: Text(state.message, style: const TextStyle(color: AppColors.inkMuted)),
            );
          }
          if (state is AccountLoaded) {
            return Column(
              children: [
                // Account selector pills + balance summary
                _AccountTabs(state: state),
                // Transaction list
                Expanded(
                  child: state.transactionsLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.violet))
                      : _TransactionHistory(transactions: state.transactions),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _AccountTabs extends StatelessWidget {
  final AccountLoaded state;
  const _AccountTabs({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.lightBackground,
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
            child: Row(
              children: state.accounts.map((acc) {
                final isSelected = acc.id == state.selectedAccountId;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    label: Text(acc.name),
                    selected: isSelected,
                    onSelected: (_) => context.read<AccountBloc>().add(AccountSelected(acc.id)),
                    selectedColor: AppColors.chipSelected,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.inkMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (state.selectedAccount != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xs, AppSpacing.xl, AppSpacing.lg),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Balance',
                              style: TextStyle(color: AppColors.inkFaint, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text(
                            CurrencyFormatter.format(
                              state.selectedAccount!.balance,
                              currency: state.selectedAccount!.currency,
                            ),
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.ink),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 34, color: AppColors.outline),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Available',
                                style: TextStyle(color: AppColors.inkFaint, fontSize: 12)),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(
                                state.selectedAccount!.availableBalance,
                                currency: state.selectedAccount!.currency,
                              ),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TransactionHistory extends StatelessWidget {
  final List<Transaction> transactions;
  const _TransactionHistory({required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(color: AppColors.fog, shape: BoxShape.circle),
              child: const Icon(Icons.history_rounded, color: AppColors.inkFaint, size: 32),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('No transactions yet',
                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink)),
          ],
        ),
      );
    }

    // Group by date
    final grouped = <String, List<Transaction>>{};
    for (final txn in transactions) {
      final key = DateFormat('MMMM d, yyyy').format(txn.bookingDate);
      grouped.putIfAbsent(key, () => []).add(txn);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: grouped.length,
      itemBuilder: (context, i) {
        final date = grouped.keys.elementAt(i);
        final txns = grouped[date]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section date header
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.sm),
              child: Text(date,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkFaint,
                    letterSpacing: 0.4,
                  )),
            ),
            ...txns.map((t) => Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl, vertical: AppSpacing.xs),
                  child: _TxnRow(txn: t),
                )),
          ],
        );
      },
    );
  }
}

class _TxnRow extends StatelessWidget {
  final Transaction txn;
  const _TxnRow({required this.txn});

  @override
  Widget build(BuildContext context) {
    final isCredit = txn.isCredit;
    final pair = TransactionStyle.colorsFor(txn.category);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: pair[0], shape: BoxShape.circle),
            child: Icon(TransactionStyle.iconFor(txn.category), color: pair[1], size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(txn.merchantName ?? txn.description,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
                const SizedBox(height: 2),
                Text(txn.category,
                    style: const TextStyle(color: AppColors.inkFaint, fontSize: 12)),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.formatSigned(txn.amount, isCredit: isCredit, currency: txn.currency),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: isCredit ? AppColors.success : AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
