// NexaBank — Accounts Screen with Transaction History
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/account_bloc.dart';
import '../data/account_repository.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, state) {
          if (state is AccountLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AccountError) {
            return Center(child: Text(state.message));
          }
          if (state is AccountLoaded) {
            return Column(
              children: [
                // Account selector tabs
                _AccountTabs(state: state),
                // Transaction list
                Expanded(
                  child: state.transactionsLoading
                      ? const Center(child: CircularProgressIndicator())
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
      color: Theme.of(context).colorScheme.surface,
      child: Column(
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
                    onSelected: (_) => context
                        .read<AccountBloc>()
                        .add(AccountSelected(acc.id)),
                    selectedColor: AppColors.chipSelected,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (state.selectedAccount != null) ...[
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
                  colors: AppColors.accountCardPalette,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Balance',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
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
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(
                          state.selectedAccount!.availableBalance,
                          currency: state.selectedAccount!.currency,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Available',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text(
                CurrencyFormatter.format(
                  state.selectedAccount!.availableBalance,
                  currency: state.selectedAccount!.currency,
                ),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
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
      return const Center(child: Text('No transactions'));
    }

    // Group by date
    final grouped = <String, List<Transaction>>{};
    for (final txn in transactions) {
      final key = DateFormat('MMMM d, yyyy').format(txn.bookingDate);
      grouped.putIfAbsent(key, () => []).add(txn);
    }

    return ListView.builder(
      itemCount: grouped.length,
      itemBuilder: (context, i) {
        final date = grouped.keys.elementAt(i);
        final txns = grouped[date]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sticky date header
            Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
              width: double.infinity,
              child: Text(date,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  )),
            ),
            ...txns.map((t) => _TxnRow(txn: t)),
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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.xs),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isCredit ? Colors.green.withOpacity(0.1) : Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(
          isCredit ? Icons.arrow_downward : Icons.arrow_upward,
          color: isCredit ? Colors.green[700] : Colors.grey[600],
          size: 20,
        ),
      ),
      title: Text(txn.merchantName ?? txn.description,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      subtitle: Text(txn.category,
          style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      trailing: Text(
        CurrencyFormatter.formatSigned(txn.amount,
            isCredit: isCredit, currency: txn.currency),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: isCredit ? Colors.green[700] : Colors.black87,
        ),
      ),
    );
  }
}
