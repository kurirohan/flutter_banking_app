// PayMaye — Spending Insights Screen
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/insights_bloc.dart';
import '../../accounts/bloc/account_bloc.dart';
import '../../../core/theme/app_colors.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});
  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  @override
  void initState() {
    super.initState();
    _maybeLoadInsights(context.read<AccountBloc>().state);
  }

  // Only fetch if we don't already have insights loaded — revisiting this
  // tab shouldn't discard state any more than Home should (same fix as
  // HomeScreen's initState; see the comment there for why it matters).
  // Also handles the case where AccountBloc is still loading when this
  // screen first mounts: the BlocListener below re-checks once it resolves.
  void _maybeLoadInsights(AccountState accountState) {
    if (accountState is! AccountLoaded) return;
    final insightsBloc = context.read<InsightsBloc>();
    if (insightsBloc.state is InsightsLoaded) return;
    final accountId = accountState.selectedAccountId ??
        (accountState.accounts.isNotEmpty ? accountState.accounts.first.id : null);
    if (accountId != null) {
      insightsBloc.add(InsightsLoadRequested(accountId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountBloc, AccountState>(
      listener: (context, accountState) => _maybeLoadInsights(accountState),
      child: Scaffold(
        appBar: AppBar(title: const Text('Spending Insights')),
        body: BlocBuilder<InsightsBloc, InsightsState>(
          builder: (context, state) {
            return switch (state) {
              InsightsLoading() => const Center(child: CircularProgressIndicator()),
              InsightsLoaded() => _InsightsContent(state: state),
              InsightsError(:final message) => Center(child: Text(message)),
              _ => const SizedBox(),
            };
          },
        ),
      ),
    );
  }
}

class _InsightsContent extends StatefulWidget {
  final InsightsLoaded state;
  const _InsightsContent({required this.state});
  @override
  State<_InsightsContent> createState() => _InsightsContentState();
}

class _InsightsContentState extends State<_InsightsContent> {
  int _touchedIndex = -1;

  double get _totalSpending =>
      widget.state.categorySpending.fold(0.0, (s, c) => s + c.amount);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month selector
          _MonthBar(
            month: widget.state.selectedMonth,
            onChanged: (m) =>
                context.read<InsightsBloc>().add(InsightsMonthChanged(m)),
          ),
          const SizedBox(height: 24),

          // Summary row
          Row(
            children: [
              _StatCard(
                label: 'Total Spent',
                value: '₱${widget.state.totalSpent.toStringAsFixed(0)}',
                color: Colors.red,
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'Total Income',
                value: '₱${widget.state.totalIncome.toStringAsFixed(0)}',
                color: Colors.green,
              ),
            ],
          ),

          const SizedBox(height: 28),
          Text('Spending Breakdown', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          // Donut chart
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(PieChartData(
                  sections: widget.state.categorySpending.asMap().entries.map((e) {
                    final isTouched = e.key == _touchedIndex;
                    return PieChartSectionData(
                      value: e.value.amount,
                      color: AppColors.chartPalette[e.key % AppColors.chartPalette.length],
                      radius: isTouched ? 72 : 60,
                      title: isTouched ? '₱${e.value.amount.toStringAsFixed(0)}' : '',
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    );
                  }).toList(),
                  pieTouchData: PieTouchData(
                    touchCallback: (evt, res) => setState(() =>
                      _touchedIndex = evt.isInterestedForInteractions &&
                              res?.touchedSection != null
                          ? res!.touchedSection!.touchedSectionIndex
                          : -1),
                  ),
                  centerSpaceRadius: 55,
                  sectionsSpace: 2,
                )),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Spent', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(
                      '₱${_totalSpending.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          Text('Monthly Trend', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
    // Bar chart
          SizedBox(
            height: 180,
            child: BarChart(BarChartData(
              maxY: widget.state.monthlyTotals.reduce((a, b) => a > b ? a : b) * 1.3,
              barGroups: widget.state.monthlyTotals.asMap().entries.map((e) =>
                BarChartGroupData(x: e.key, barRods: [
                  BarChartRodData(
                    toY: e.value,
                    color: e.key == widget.state.monthlyTotals.length - 1
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.3),
                    width: 30,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ])).toList(),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) {
                      const months = ['Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
                      final i = v.toInt();
                      if (i < 0 || i >= months.length) return const SizedBox();
                      return Text(months[i], style: const TextStyle(fontSize: 11, color: Colors.grey));
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
            )),
          ),

          const SizedBox(height: 28),
          Text('By Category', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          ...widget.state.categorySpending.asMap().entries.map((e) =>
            _CategoryRow(
              spending: e.value,
              total: _totalSpending,
              color: AppColors.chartPalette[e.key % AppColors.chartPalette.length],
            )),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _MonthBar extends StatelessWidget {
  final DateTime month;
  final void Function(DateTime) onChanged;
  const _MonthBar({required this.month, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => onChanged(
              DateTime(month.year, month.month - 1)),
        ),
        Text(DateFormat('MMMM yyyy').format(month),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: month.month < DateTime.now().month
              ? () => onChanged(DateTime(month.year, month.month + 1))
              : null,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final CategorySpending spending;
  final double total;
  final Color color;
  const _CategoryRow({required this.spending, required this.total, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(spending.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(child: Text(spending.category, style: const TextStyle(fontSize: 14))),
              Text('₱${spending.amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 0 ? spending.amount / total : 0,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
