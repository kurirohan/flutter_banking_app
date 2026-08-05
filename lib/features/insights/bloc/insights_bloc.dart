// NexaBank — Insights BLoC
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../accounts/data/account_repository.dart';

// Events
abstract class InsightsEvent extends Equatable {
  const InsightsEvent();
  @override List<Object?> get props => [];
}
class InsightsLoadRequested extends InsightsEvent {
  final String accountId;
  const InsightsLoadRequested(this.accountId);
  @override List<Object?> get props => [accountId];
}
class InsightsMonthChanged extends InsightsEvent {
  final DateTime month;
  const InsightsMonthChanged(this.month);
  @override List<Object?> get props => [month];
}

// Models
class CategorySpending {
  final String category;
  final double amount;
  final String emoji;
  const CategorySpending({required this.category, required this.amount, required this.emoji});
}

// States
abstract class InsightsState extends Equatable {
  const InsightsState();
  @override List<Object?> get props => [];
}
class InsightsInitial extends InsightsState { const InsightsInitial(); }
class InsightsLoading extends InsightsState { const InsightsLoading(); }
class InsightsLoaded extends InsightsState {
  final List<CategorySpending> categorySpending;
  final double totalSpent;
  final double totalIncome;
  final List<double> monthlyTotals;
  final DateTime selectedMonth;
  const InsightsLoaded({
    required this.categorySpending,
    required this.totalSpent,
    required this.totalIncome,
    required this.monthlyTotals,
    required this.selectedMonth,
  });
  @override List<Object?> get props => [categorySpending, totalSpent, selectedMonth];
}
class InsightsError extends InsightsState {
  final String message;
  const InsightsError(this.message);
  @override List<Object?> get props => [message];
}

// BLoC
class InsightsBloc extends Bloc<InsightsEvent, InsightsState> {
  final AccountRepository _repo;

  InsightsBloc(this._repo) : super(const InsightsInitial()) {
    on<InsightsLoadRequested>(_onLoad);
    on<InsightsMonthChanged>(_onMonthChanged);
  }

  Future<void> _onLoad(InsightsLoadRequested event, Emitter<InsightsState> emit) async {
    emit(const InsightsLoading());
    try {
      final txns = await _repo.fetchTransactions(event.accountId);
      emit(_buildLoadedState(txns, DateTime.now()));
    } catch (e) {
      emit(InsightsError(e.toString()));
    }
  }

  Future<void> _onMonthChanged(InsightsMonthChanged event, Emitter<InsightsState> emit) async {
    final current = state;
    if (current is InsightsLoaded) {
      // In real app: re-fetch transactions for selected month
      final txns = await _repo.fetchTransactions('acc_001');
      emit(_buildLoadedState(txns, event.month));
    }
  }

  InsightsLoaded _buildLoadedState(List<Transaction> txns, DateTime month) {
    // Summarise by category
    final Map<String, double> byCategory = {};
    double totalSpent = 0;
    double totalIncome = 0;

    for (final t in txns) {
      if (t.isCredit) {
        totalIncome += t.amount;
      } else {
        totalSpent += t.amount;
        byCategory[t.category] = (byCategory[t.category] ?? 0) + t.amount;
      }
    }

    const emojiMap = {
      'Food & Drinks': '🍔',
      'Shopping': '🛍️',
      'Transport': '🚗',
      'Utilities': '💡',
      'Entertainment': '🎬',
      'Healthcare': '🏥',
      'Other': '📋',
    };

    final categorySpending = byCategory.entries
        .map((e) => CategorySpending(
              category: e.key,
              amount: e.value,
              emoji: emojiMap[e.key] ?? '📋',
            ))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return InsightsLoaded(
      categorySpending: categorySpending,
      totalSpent: totalSpent,
      totalIncome: totalIncome,
      monthlyTotals: const [980, 1100, 890, 1250, 1300, 1150],
      selectedMonth: month,
    );
  }
}
