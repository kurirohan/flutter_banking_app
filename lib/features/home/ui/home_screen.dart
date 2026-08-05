// PayMaye — Home Screen (Account Dashboard)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../accounts/bloc/account_bloc.dart';
import '../../accounts/data/account_repository.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/utils/transaction_style.dart';
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
    // AccountBloc is booted once at app startup (see main.dart). This is a
    // fallback only — e.g. if the initial boot fetch is still in flight or
    // failed before this screen ever mounted — so revisiting the Home tab
    // never re-triggers a full refetch that would clobber local state
    // (like a just-completed transfer's balance/transaction update).
    final bloc = context.read<AccountBloc>();
    if (bloc.state is! AccountLoaded) {
      bloc.add(const AccountFetchRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          // A single soft, blurred glow behind the greeting — the one
          // decorative flourish on the dashboard, echoing the login screen.
          Positioned(
            top: -70,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.sunshine.withValues(alpha: 0.25),
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              color: AppColors.violet,
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
        ],
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
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator(color: AppColors.violet)),
                ),
              )
            : _TransactionList(transactions: state.transactions),
        const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
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
      padding: EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good ${_greeting()} 👋',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 2),
              const Text('Alex Johnson',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink)),
            ],
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.violet, AppColors.bubblegum],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.violet.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('AJ',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ),
              if (state.isRefreshing)
                const Positioned.fill(
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                ),
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.bubblegum,
                    border: Border.all(color: AppColors.lightBackground, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
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
        const SizedBox(height: AppSpacing.xxl),
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
                  paletteIndex: i,
                  isSelected: acc.id == state.selectedAccountId,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Page indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: state.accounts.asMap().entries.map((e) {
            final activeIndex = state.accounts.indexWhere(
                (a) => a.id == state.selectedAccountId);
            final isActive = e.key == activeIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 22 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: isActive ? AppColors.violet : AppColors.outline,
                borderRadius: BorderRadius.circular(AppRadius.pill),
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
  final int paletteIndex;
  final bool isSelected;
  const _AccountCard({
    required this.account,
    required this.paletteIndex,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final gradients = AppColors.accountCardGradients;
    final pair = gradients[paletteIndex % gradients.length];

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: pair,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        boxShadow: [
          BoxShadow(
            color: pair.first.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        children: [
          // Decorative blob, echoing the brand's rounded, bubbly language.
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(account.name,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    Container(
                      width: 30,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.wifi, color: Colors.white, size: 14),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  CurrencyFormatter.format(account.balance, currency: account.currency),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Available: ${CurrencyFormatter.format(account.availableBalance, currency: account.currency)}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12),
                ),
                const Spacer(),
                Text(account.accountNumber,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                        letterSpacing: 1.5)),
              ],
            ),
          ),
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
      padding: EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xxxl, AppSpacing.xxl, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick actions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _QuickAction(
                  icon: Icons.send_rounded, label: 'Transfer',
                  paletteIndex: 0, onTap: () => context.go('/transfer')),
              _QuickAction(
                  icon: Icons.receipt_long_rounded, label: 'Pay Bills',
                  paletteIndex: 1, onTap: () {}),
              _QuickAction(
                  icon: Icons.qr_code_scanner_rounded, label: 'QR Pay',
                  paletteIndex: 2, onTap: () {}),
              _QuickAction(
                  icon: Icons.pie_chart_rounded, label: 'Insights',
                  paletteIndex: 3, onTap: () => context.go('/insights')),
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
  final int paletteIndex;
  final VoidCallback onTap;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.paletteIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pair = AppColors.pastelPalette[paletteIndex % AppColors.pastelPalette.length];
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: pair[0],
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Icon(icon, color: pair[1], size: 26),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.inkMuted)),
        ],
      ),
    );
  }
}

class _TransactionHeader extends StatelessWidget {
  const _TransactionHeader();
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xxxl, AppSpacing.xxl, AppSpacing.md),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Recent activity', style: Theme.of(context).textTheme.titleLarge),
        TextButton(onPressed: () => context.go('/accounts'), child: const Text('See all')),
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
        child: _EmptyState(
          icon: Icons.receipt_long_rounded,
          title: 'No activity yet',
          message: 'Transfers and payments will show up here.',
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      sliver: SliverList.separated(
        itemCount: transactions.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, i) => _TransactionTile(txn: transactions[i]),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction txn;
  const _TransactionTile({required this.txn});

  @override
  Widget build(BuildContext context) {
    final isCredit = txn.isCredit;
    final icon = TransactionStyle.iconFor(txn.category);
    final pair = TransactionStyle.colorsFor(txn.category);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: pair[0],
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Icon(icon, color: pair[1], size: 21),
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
                Text(
                  DateFormat('MMM d, h:mm a').format(txn.bookingDate),
                  style: const TextStyle(color: AppColors.inkFaint, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.formatSigned(txn.amount, isCredit: isCredit, currency: txn.currency),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: isCredit ? AppColors.success : AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(txn.category,
                  style: const TextStyle(color: AppColors.inkFaint, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const _EmptyState({required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.huge),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: AppColors.fog, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.inkFaint, size: 32),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.ink)),
          const SizedBox(height: AppSpacing.xs),
          Text(message,
              style: const TextStyle(color: AppColors.inkMuted, fontSize: 13),
              textAlign: TextAlign.center),
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
      baseColor: AppColors.fog,
      highlightColor: Colors.white,
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
            Container(height: 190, decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.cardLarge))),
            const SizedBox(height: 32),
            for (int i = 0; i < 5; i++) ...[
              Row(children: [
                _box(46, 46, radius: AppRadius.medium),
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
    width: w, height: h,
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
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.huge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(color: AppColors.errorBackground, shape: BoxShape.circle),
            child: const Icon(Icons.wifi_off_rounded, size: 32, color: AppColors.error),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(message, textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.inkMuted)),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: () =>
                context.read<AccountBloc>().add(const AccountFetchRequested()),
            child: const Text('Try again'),
          ),
        ],
      ),
    ),
  );
}
