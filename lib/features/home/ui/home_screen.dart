// NexaBank — Home Screen (Account Dashboard)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../accounts/bloc/account_bloc.dart';
import '../../accounts/data/account_repository.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/constants/app_spacing.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AccountBloc>().add(const AccountFetchRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<AccountBloc>().add(const AccountRefreshRequested());
            await Future.delayed(const Duration(seconds: 1));
          },
          child: BlocBuilder<AccountBloc, AccountState>(
            builder: (context, state) {
              return switch (state) {
                AccountLoading() => const _HomeShimmer(),
                AccountLoaded() => _HomeContent(state: state),
                AccountError(:final message) => _HomeError(message: message),
                _ => const _HomeShimmer(),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final AccountLoaded state;
  const _HomeContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _Header(state: state)),
        SliverToBoxAdapter(child: _AccountCardsSection(state: state)),
        SliverToBoxAdapter(child: _QuickActionsSection()),
        SliverToBoxAdapter(child: _TransactionHeader()),
        state.transactionsLoading
            ? const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()))
            : _TransactionList(transactions: state.transactions),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final AccountLoaded state;
  const _Header({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good ${_greeting()},',
                  style: Theme.of(context).textTheme.bodyMedium),
              const Text('Alex Johnson',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary,
                child: const Text('AJ',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              if (state.isRefreshing)
                const Positioned.fill(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}

class _AccountCardsSection extends StatelessWidget {
  final AccountLoaded state;
  const _AccountCardsSection({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.88),
            itemCount: state.accounts.length,
            onPageChanged: (i) {
              context.read<AccountBloc>().add(
                    AccountSelected(state.accounts[i].id),
                  );
            },
            itemBuilder: (context, i) {
              final acc = state.accounts[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: _AccountCard(
                  account: acc,
                  isSelected: acc.id == state.selectedAccountId,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Page indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: state.accounts.asMap().entries.map((e) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: e.key ==
                      state.accounts
                          .indexWhere((a) => a.id == state.selectedAccountId)
                  ? 20
                  : 6,
              height: 6,
              decoration: BoxDecoration(
                color: e.key ==
                        state.accounts
                            .indexWhere((a) => a.id == state.selectedAccountId)
                    ? AppColors.primary
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _AccountCard extends StatelessWidget {
  final Account account;
  final bool isSelected;
  const _AccountCard({required this.account, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.accountCardPalette;
    final color = colors[account.type == 'savings' ? 1 : 0];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withBlue(color.blue + 30)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(account.name,
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const Icon(Icons.credit_card, color: Colors.white54, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(account.balance,
                currency: account.currency),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Available: ${CurrencyFormatter.format(account.availableBalance, currency: account.currency)}',
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const Spacer(),
          Text(account.accountNumber,
              style: const TextStyle(
                  color: Colors.white54, fontSize: 13, letterSpacing: 1)),
        ],
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.xxl, AppSpacing.xxxl, AppSpacing.xxl, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _QuickAction(
                  icon: Icons.send,
                  label: 'Transfer',
                  onTap: () => context.go('/transfer')),
              _QuickAction(
                  icon: Icons.receipt_long, label: 'Pay Bills', onTap: () {}),
              _QuickAction(
                  icon: Icons.qr_code_scanner, label: 'QR Pay', onTap: () {}),
              _QuickAction(
                  icon: Icons.bar_chart,
                  label: 'Insights',
                  onTap: () => context.go('/insights')),
              _QuickAction(
                  icon: Icons.storage,
                  label: 'Firestore Test',
                  onTap: () => context.go('/firestore-test')),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _TransactionHeader extends StatelessWidget {
  const _TransactionHeader();
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(
            AppSpacing.xxl, AppSpacing.xxxl, AppSpacing.xxl, AppSpacing.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Transactions',
                style: Theme.of(context).textTheme.titleLarge),
            TextButton(
                onPressed: () => context.go('/accounts'),
                child: const Text('See All')),
          ],
        ),
      );
}

class _TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  const _TransactionList({required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text('No transactions yet'),
          ),
        ),
      );
    }

    return SliverList.builder(
      itemCount: transactions.length,
      itemBuilder: (context, i) => _TransactionTile(txn: transactions[i]),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction txn;
  const _TransactionTile({required this.txn});

  static const _categoryIcons = {
    'Food & Drinks': Icons.restaurant,
    'Shopping': Icons.shopping_bag,
    'Transport': Icons.directions_car,
    'Entertainment': Icons.movie,
    'Income': Icons.account_balance,
    'Utilities': Icons.bolt,
    'Healthcare': Icons.local_hospital,
    'Other': Icons.receipt,
  };

  @override
  Widget build(BuildContext context) {
    final isCredit = txn.isCredit;
    final icon = _categoryIcons[txn.category] ?? Icons.receipt;
    final amountColor = isCredit ? Colors.green[700]! : Colors.black87;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl, vertical: AppSpacing.xs),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.grey[600], size: 22),
      ),
      title: Text(txn.merchantName ?? txn.description,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(
        DateFormat('MMM d, h:mm a').format(txn.bookingDate),
        style: TextStyle(color: Colors.grey[500], fontSize: 12),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            CurrencyFormatter.formatSigned(txn.amount,
                isCredit: isCredit, currency: txn.currency),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: amountColor,
            ),
          ),
          Text(txn.category,
              style: TextStyle(color: Colors.grey[400], fontSize: 11)),
        ],
      ),
    );
  }
}

class _HomeShimmer extends StatelessWidget {
  const _HomeShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _box(160, 20),
            const SizedBox(height: 8),
            _box(200, 28),
            const SizedBox(height: 32),
            Container(
                height: 190,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20))),
            const SizedBox(height: 32),
            for (int i = 0; i < 5; i++) ...[
              Row(children: [
                _box(48, 48, radius: 14),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _box(160, 14),
                  const SizedBox(height: 8),
                  _box(100, 12),
                ]),
                const Spacer(),
                _box(80, 16),
              ]),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _box(double w, double h, {double radius = 8}) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}

class _HomeError extends StatelessWidget {
  final String message;
  const _HomeError({required this.message});
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context
                  .read<AccountBloc>()
                  .add(const AccountFetchRequested()),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
}
