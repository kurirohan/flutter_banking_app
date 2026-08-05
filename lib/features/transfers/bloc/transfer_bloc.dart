// NexaBank — Transfer BLoC (full state machine)
//
// Flow: choose source account -> choose beneficiary -> enter amount
//       -> review -> submit -> success/failed
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/account.dart';
import '../data/transfer_repository.dart';

// Events
abstract class TransferEvent extends Equatable {
  const TransferEvent();
  @override
  List<Object?> get props => [];
}

class TransferAccountSelected extends TransferEvent {
  final Account account;
  const TransferAccountSelected(this.account);
  @override
  List<Object?> get props => [account.id];
}

class TransferBeneficiarySelected extends TransferEvent {
  final Beneficiary beneficiary;
  const TransferBeneficiarySelected(this.beneficiary);
  @override
  List<Object?> get props => [beneficiary.id];
}

class TransferAmountSet extends TransferEvent {
  final double amount;
  const TransferAmountSet(this.amount);
  @override
  List<Object?> get props => [amount];
}

class TransferReferenceSet extends TransferEvent {
  final String? reference;
  const TransferReferenceSet(this.reference);
  @override
  List<Object?> get props => [reference];
}

class TransferSubmitted extends TransferEvent {
  const TransferSubmitted();
}

class TransferReset extends TransferEvent {
  const TransferReset();
}

// States
abstract class TransferState extends Equatable {
  const TransferState();
  @override
  List<Object?> get props => [];
}

/// Step 1: pick which account to send from.
class TransferSelectingAccount extends TransferState {
  const TransferSelectingAccount();
}

/// Step 2: pick who to send to.
class TransferSelectingBeneficiary extends TransferState {
  final Account account;
  final List<Beneficiary> beneficiaries;
  final bool isLoading;
  const TransferSelectingBeneficiary({
    required this.account,
    this.beneficiaries = const [],
    this.isLoading = false,
  });
  @override
  List<Object?> get props => [account.id, beneficiaries, isLoading];
}

/// Step 3: enter the amount (and optional reference).
class TransferEnteringAmount extends TransferState {
  final Account account;
  final Beneficiary beneficiary;
  const TransferEnteringAmount(
      {required this.account, required this.beneficiary});
  @override
  List<Object?> get props => [account.id, beneficiary.id];
}

/// Step 4: review before confirming.
class TransferReadyToSubmit extends TransferState {
  final Account account;
  final Beneficiary beneficiary;
  final double amount;
  final String? reference;
  const TransferReadyToSubmit({
    required this.account,
    required this.beneficiary,
    required this.amount,
    this.reference,
  });
  @override
  List<Object?> get props => [account.id, beneficiary.id, amount, reference];
}

class TransferInProgress extends TransferState {
  const TransferInProgress();
}

class TransferSuccess extends TransferState {
  final TransferResult result;
  const TransferSuccess(this.result);
  @override
  List<Object?> get props => [result.transferId];
}

class TransferFailed extends TransferState {
  final String reason;
  const TransferFailed(this.reason);
  @override
  List<Object?> get props => [reason];
}

// BLoC
class TransferBloc extends Bloc<TransferEvent, TransferState> {
  final TransferRepository _repo;

  TransferBloc(this._repo) : super(const TransferSelectingAccount()) {
    on<TransferAccountSelected>(_onAccountSelected);
    on<TransferBeneficiarySelected>(_onBeneficiary);
    on<TransferAmountSet>(_onAmount);
    on<TransferReferenceSet>(_onReference);
    on<TransferSubmitted>(_onSubmit);
    on<TransferReset>(_onReset);
  }

  Future<void> _onAccountSelected(
    TransferAccountSelected e,
    Emitter<TransferState> emit,
  ) async {
    emit(TransferSelectingBeneficiary(account: e.account, isLoading: true));
    try {
      final beneficiaries = await _repo.getBeneficiaries();
      emit(TransferSelectingBeneficiary(
        account: e.account,
        beneficiaries: beneficiaries,
        isLoading: false,
      ));
    } catch (_) {
      emit(TransferSelectingBeneficiary(account: e.account, isLoading: false));
    }
  }

  void _onBeneficiary(
      TransferBeneficiarySelected e, Emitter<TransferState> emit) {
    final current = state;
    if (current is TransferSelectingBeneficiary) {
      emit(TransferEnteringAmount(
          account: current.account, beneficiary: e.beneficiary));
    }
  }

  void _onAmount(TransferAmountSet e, Emitter<TransferState> emit) {
    final current = state;
    if (current is TransferEnteringAmount) {
      emit(TransferReadyToSubmit(
        account: current.account,
        beneficiary: current.beneficiary,
        amount: e.amount,
      ));
    }
  }

  void _onReference(TransferReferenceSet e, Emitter<TransferState> emit) {
    final current = state;
    if (current is TransferReadyToSubmit) {
      emit(TransferReadyToSubmit(
        account: current.account,
        beneficiary: current.beneficiary,
        amount: current.amount,
        reference: e.reference,
      ));
    }
  }

  Future<void> _onSubmit(
      TransferSubmitted e, Emitter<TransferState> emit) async {
    final current = state;
    if (current is! TransferReadyToSubmit) return;

    emit(const TransferInProgress());
    try {
      final result = await _repo.submitTransfer(TransferRequest(
        sourceAccountId: current.account.id,
        destinationAccount: current.beneficiary.accountNumber,
        beneficiaryName: current.beneficiary.name,
        amount: current.amount,
        reference: current.reference,
      ));
      emit(TransferSuccess(result));
    } on TransferDeclinedException catch (ex) {
      emit(TransferFailed(ex.reason));
    } catch (_) {
      emit(const TransferFailed('Transfer failed. Please try again.'));
    }
  }

  void _onReset(TransferReset _, Emitter<TransferState> emit) {
    emit(const TransferSelectingAccount());
  }
}
