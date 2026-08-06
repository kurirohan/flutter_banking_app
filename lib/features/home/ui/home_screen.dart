// PayMaye — Home Screen (Account Dashboard)
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '/models/account.dart';
import '/models/transaction.dart' as txn_model;
import '../../accounts/bloc/account_bloc.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/utils/transaction_style.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';

/// Home screen colors come from `AppColors.home*` — the "Soft Premium
/// Banking / Modern Plum Fintech" palette (deep plum / purple / lavender
/// branding on a warm off-white background), defined in app_colors.dart
/// alongside the rest of the app's screen-scoped palettes (see `auth*`).

// Shared category → icon/color mapping, used by both the transaction list
// and the spending insights preview so the two stay visually consistent.
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

const _kCategoryColors = {
  'Food & Drinks': Color(0xFFF7B0A8),
  'Shopping': Color(0xFFB9B3FF),
  'Transport': Color(0xFFA9D8F5),
  'Entertainment': Color(0xFFF3C5E8),
  'Income': Color(0xFFA8E0BE),
  'Utilities': Color(0xFFF6E3A1),
  'Healthcare': Color(0xFFF6B8C4),
  'Other': Color(0xFFD9D6E3),
};

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

  // NexaBank's UI is designed at phone width. On a real phone this is a
  // no-op (device width is always under the cap), but on wide desktop/web
  // viewports it stops the balance card, spacing, and everything else from
  // stretching edge-to-edge and looking broken — content stays phone-sized
  // and centered instead.
  static const double _maxContentWidth = 480;

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
                context
                    .read<AccountBloc>()
                    .add(const AccountRefreshRequested());
                await Future.delayed(const Duration(seconds: 1));
              },
              child: BlocBuilder<AccountBloc, AccountState>(
                builder: (context, state) {
                  return switch (state) {
                    AccountLoading() => const _HomeShimmer(),
                    AccountLoaded() => _HomeContent(state: state),
                    AccountError(:final message) =>
                      _HomeError(message: message),
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
        SliverToBoxAdapter(
            child: _InsightsPreview(transactions: state.transactions)),
        SliverToBoxAdapter(child: _TransactionHeader()),
        state.transactionsLoading
            ? const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.homePrimaryPurple,
                    ),
                  ),
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
      padding:
          EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative sunburst circle. Positioned behind the name text
          // rather than flush in the top-right corner, since the
          // notification bell now lives there — keeping the circle out
          // from under it avoids the "bell floating inside a blob" look.
          Positioned(
            top: -18,
            right: 64,
            child: Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: AppColors.homeAccentYellow,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.homeSurface,
                    child: Text(
                      'AJ',
                      style: TextStyle(
                        color: AppColors.homePrimaryDeepPlum,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -1,
                    right: -1,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.homeError,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.homeSurface, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good ${_greeting()}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.homeTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text(
                      'Alex Johnson',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.homeTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => context.go('/notifications'),
                icon: const Icon(Icons.notifications_none_rounded),
                color: AppColors.homePrimaryPurple,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.homeSurface,
                  shape: const CircleBorder(),
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

class _AccountCardsSection extends StatefulWidget {
  final AccountLoaded state;
  const _AccountCardsSection({required this.state});

  @override
  State<_AccountCardsSection> createState() => _AccountCardsSectionState();
}

class _AccountCardsSectionState extends State<_AccountCardsSection> {
  // Hoisted so the controller survives rebuilds triggered by bloc state
  // changes (e.g. AccountSelected) — previously a new PageController was
  // created on every build, which snapped the carousel back to page 0
  // any time the user swiped.
  late final PageController _controller =
      PageController(viewportFraction: 0.88);

  // Shared across every card in the carousel so toggling "hide balance"
  // once hides it everywhere, like a real banking app — not per-card.
  final ValueNotifier<bool> _balanceHidden = ValueNotifier(false);

  @override
  void dispose() {
    _controller.dispose();
    _balanceHidden.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = widget.state.accounts;
    final selectedIndex =
        accounts.indexWhere((a) => a.id == widget.state.selectedAccountId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xxl),
        SizedBox(
          height: 236,
          child: PageView.builder(
            controller: _controller,
            itemCount: accounts.length,
            onPageChanged: (i) {
              final accounts =
                  widget.state.accounts.whereType<Account>().toList();
              context.read<AccountBloc>().add(
                    AccountSelected(accounts[i].id),
                  );
            },
            itemBuilder: (context, i) {
              final acc = accounts[i];
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
            final activeIndex = state.accounts
                .indexWhere((a) => a.id == state.selectedAccountId);
            final isActive = e.key == activeIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: e.key ==
                      state.accounts
                          .indexWhere((a) => a.id == state.selectedAccountId)
                  ? 20
                  : 6,
              height: 6,
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

/// A single account card with a real front/back flip (tap anywhere on the
/// card), a freeze toggle, and copy-to-clipboard for the account number.
class _AccountCard extends StatefulWidget {
  final Account account;
  final int paletteIndex;
  final bool isSelected;
  final ValueNotifier<bool> balanceHidden;
  const _AccountCard({
    required this.account,
    required this.isSelected,
    required this.balanceHidden,
  });

  @override
  State<_AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<_AccountCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flipController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  bool _frozen = false;

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    HapticFeedback.selectionClick();
    if (_flipController.value == 0) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  void _toggleFrozen() {
    HapticFeedback.mediumImpact();
    setState(() => _frozen = !_frozen);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_frozen ? 'Card frozen' : 'Card unfrozen'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _copyNumber() {
    HapticFeedback.selectionClick();
    Clipboard.setData(ClipboardData(text: widget.account.accountNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account number copied'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleFlip,
      child: AnimatedBuilder(
        animation: _flipController,
        builder: (context, _) {
          final angle = _flipController.value * math.pi;
          final showBack = _flipController.value > 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(angle),
            child: showBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _buildBack(),
                  )
                : _buildFront(),
          );
        },
      ),
    );
  }

  BoxDecoration _cardDecoration({bool reversed = false}) {
    final colors = reversed
        ? AppColors.homePrimaryGradient.reversed.toList()
        : AppColors.homePrimaryGradient;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ),
      border: Border.all(
        color: widget.isSelected ? Colors.white : Colors.transparent,
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.homePrimaryDeepPlum.withOpacity(.18),
          blurRadius: 30,
          spreadRadius: 2,
          offset: const Offset(0, 14),
        ),
      ],
    );
  }

  Widget _cardActionButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.18),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildFront() {
    return Container(
      key: const ValueKey('front'),
      height: 224,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.account.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (_frozen)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_rounded, color: Colors.white, size: 11),
                      SizedBox(width: 4),
                      Text('Frozen',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Opacity(
            opacity: _frozen ? 0.45 : 1,
            child: ValueListenableBuilder<bool>(
              valueListenable: widget.balanceHidden,
              builder: (context, hidden, _) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Balance',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _AnimatedBalance(
                            amount: widget.account.balance,
                            currency: widget.account.currency,
                            hidden: hidden,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        widget.balanceHidden.value = !hidden;
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          hidden
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Spacer(),
          Opacity(
            opacity: _frozen ? 0.45 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.account.accountNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '05/2028',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _cardActionButton(icon: Icons.copy_rounded, onTap: _copyNumber),
              const SizedBox(width: 8),
              _cardActionButton(
                icon: _frozen ? Icons.lock_open_rounded : Icons.lock_rounded,
                onTap: _toggleFrozen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      key: const ValueKey('back'),
      height: 224,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(reversed: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACCOUNT DETAILS',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          _backRow('Account Type', widget.account.name),
          const SizedBox(height: 10),
          _backRow('Account Number', widget.account.accountNumber),
          const SizedBox(height: 10),
          _backRow(
            'Available Balance',
            CurrencyFormatter.format(
              widget.account.balance,
              currency: widget.account.currency,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.touch_app_rounded, color: Colors.white70, size: 14),
              SizedBox(width: 6),
              Text('Tap to flip back',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _backRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                TextStyle(color: Colors.white.withOpacity(.65), fontSize: 11)),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Animates the balance counting up from 0 once, on first mount, rather
/// than re-animating on every rebuild (e.g. when the freeze state or the
/// hidden toggle changes elsewhere on the card).
class _AnimatedBalance extends StatefulWidget {
  final double amount;
  final String currency;
  final bool hidden;
  const _AnimatedBalance({
    required this.amount,
    required this.currency,
    required this.hidden,
  });

  @override
  State<_AnimatedBalance> createState() => _AnimatedBalanceState();
}

class _AnimatedBalanceState extends State<_AnimatedBalance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final Animation<double> _animation =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hidden) {
      return const Text(
        '••••••',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 3,
        ),
      );
    }
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final value = widget.amount * _animation.value;
        return Text(
          CurrencyFormatter.format(value, currency: widget.currency),
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      },
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
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.homeTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _QuickAction(
                  icon: Icons.send_rounded,
                  label: 'Transfer',
                  onTap: () => context.go('/transfer')),
              _QuickAction(
                  icon: Icons.receipt_long_rounded,
                  label: 'Pay Bills',
                  onTap: () => context.go('/bills')),
              _QuickAction(
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'QR Pay',
                  onTap: () => context.go('/qr-pay')),
              _QuickAction(
                  icon: Icons.bar_chart_rounded,
                  label: 'Insights',
                  onTap: () => context.go('/insights')),
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
  const _QuickAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pair =
        AppColors.pastelPalette[paletteIndex % AppColors.pastelPalette.length];
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.homePrimaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppColors.homePrimaryPurple, size: 26),
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
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.homeTextPrimary,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/accounts'),
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.homePrimaryPurple),
              child: const Text('See All'),
            ),
          ],
        ),
      );
}

class _TransactionList extends StatelessWidget {
  final List<txn_model.Transaction> transactions;
  const _TransactionList({required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'No transactions yet',
              style: TextStyle(color: AppColors.homeTextSecondary),
            ),
          ),
        ),
      );
    }

    return SliverList.separated(
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _TransactionTile(txn: transactions[i]),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final txn_model.Transaction txn;
  const _TransactionTile({required this.txn});

  @override
  Widget build(BuildContext context) {
    final isCredit = txn.type == txn_model.TransactionType.credit;
    final icon = _kCategoryIcons[txn.category] ?? Icons.receipt_rounded;
    final chipColor = _kCategoryColors[txn.category] ?? const Color(0xFFD9D6E3);
    final amountColor =
        isCredit ? AppColors.homeSuccess : AppColors.homeTextPrimary;
    final title = txn.sourceAcctId ?? txn.description;
    final formattedAmount = CurrencyFormatter.formatSigned(
      txn.amount,
      isCredit: isCredit,
      currency: txn.currency,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.homeSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.homeBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.homePrimaryDeepPlum.withOpacity(.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: chipColor.withOpacity(0.35),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.homePrimaryPurple, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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
                  DateFormat('EEE dd.MM.yyyy').format(txn.dateCreated),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.homeTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formattedAmount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: amountColor,
            ),
          ),
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
            Container(
                height: 190,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20))),
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
