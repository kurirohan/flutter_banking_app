// PayMaye — Transfer Repository
import 'package:uuid/uuid.dart';
import '../../../core/constants/demo_data.dart';
import '../../../core/network/dio_client.dart';
import '../../../shared/services/mock_bank_data_source.dart';
import '../../accounts/data/account_repository.dart';

class TransferRequest {
  final String idempotencyKey;
  final String sourceAccountId;
  final String destinationAccount;
  final String beneficiaryName;
  final double amount;
  final String currency;
  final String? reference;

  TransferRequest({
    String? idempotencyKey,
    required this.sourceAccountId,
    required this.destinationAccount,
    required this.beneficiaryName,
    required this.amount,
    this.currency = 'PHP',
    this.reference,
  }) : idempotencyKey = idempotencyKey ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'idempotencyKey': idempotencyKey,
        'sourceAccountId': sourceAccountId,
        'destinationAccount': destinationAccount,
        'beneficiaryName': beneficiaryName,
        'amount': amount,
        'currency': currency,
        if (reference != null) 'reference': reference,
      };
}

class TransferResult {
  final String transferId;
  final String status;
  final String? rail;
  final DateTime? estimatedArrival;

  const TransferResult({
    required this.transferId,
    required this.status,
    this.rail,
    this.estimatedArrival,
  });
}

class TransferDeclinedException implements Exception {
  final String reason;
  final String reasonCode;
  const TransferDeclinedException({required this.reason, required this.reasonCode});
}

abstract class TransferRepository {
  Future<TransferResult> submitTransfer(TransferRequest request);
  Future<TransferResult> getStatus(String transferId);
  Future<List<Beneficiary>> getBeneficiaries();
}

class Beneficiary {
  final String id;
  final String name;
  final String accountNumber;
  final String bankName;

  const Beneficiary({
    required this.id,
    required this.name,
    required this.accountNumber,
    required this.bankName,
  });
}

/// Offline implementation backed by the shared [MockBankDataSource].
/// Business logic (limit checks, building the resulting [Transaction],
/// debiting the balance) lives here — not in the UI — so the widget layer
/// only ever reacts to a [TransferResult]/[TransferDeclinedException],
/// the same shape a real API call would produce.
class MockTransferRepository implements TransferRepository {
  final MockBankDataSource _dataSource;
  MockTransferRepository(this._dataSource);

  @override
  Future<TransferResult> submitTransfer(TransferRequest request) async {
    await Future.delayed(DemoData.transferSubmitDelay);

    if (request.amount > DemoData.transferLimit) {
      throw const TransferDeclinedException(
        reason: 'Transfer limit exceeded',
        reasonCode: 'LIMIT_EXCEEDED',
      );
    }

    Account? account;
    for (final a in _dataSource.accounts) {
      if (a.id == request.sourceAccountId) {
        account = a;
        break;
      }
    }
    if (account == null) {
      throw const TransferDeclinedException(
        reason: 'Source account not found',
        reasonCode: 'ACCOUNT_NOT_FOUND',
      );
    }
    if (request.amount > account.availableBalance) {
      throw const TransferDeclinedException(
        reason: 'Insufficient funds in the selected account',
        reasonCode: 'INSUFFICIENT_FUNDS',
      );
    }

    final isInstant = request.amount < DemoData.instantRailThreshold;
    final transferId = const Uuid().v4();
    final memo = request.reference?.trim();
    final description = (memo == null || memo.isEmpty)
        ? 'Transfer to ${request.beneficiaryName}'
        : 'Transfer to ${request.beneficiaryName} — $memo';

    _dataSource.applyTransfer(
      accountId: request.sourceAccountId,
      amount: request.amount,
      transaction: Transaction(
        id: transferId,
        type: 'DEBIT',
        amount: request.amount,
        currency: request.currency,
        bookingDate: DateTime.now(),
        description: description,
        merchantName: request.beneficiaryName,
        category: 'Transfer',
      ),
    );

    return TransferResult(
      transferId: transferId,
      status: isInstant ? 'COMPLETED' : 'PENDING',
      rail: isInstant ? 'INSTANT' : 'ACH',
      estimatedArrival: DateTime.now().add(
        isInstant ? DemoData.instantEta : DemoData.standardEta,
      ),
    );
  }

  @override
  Future<TransferResult> getStatus(String transferId) async {
    await Future.delayed(DemoData.transferStatusDelay);
    return TransferResult(transferId: transferId, status: 'COMPLETED', rail: 'INSTANT');
  }

  @override
  Future<List<Beneficiary>> getBeneficiaries() async {
    await Future.delayed(DemoData.beneficiariesFetchDelay);
    return _dataSource.beneficiaries;
  }
}

/// Placeholder for a real backend integration. Implement against
/// [ApiClient] and swap the instance constructed in main.dart when a
/// payments API exists.
class ApiTransferRepository implements TransferRepository {
  final ApiClient _client;
  ApiTransferRepository(this._client);

  @override
  Future<TransferResult> submitTransfer(TransferRequest request) {
    // TODO(backend): _client.post('/transfers', data: request.toJson(), ...)
    throw UnimplementedError('ApiTransferRepository.submitTransfer is not wired up yet.');
  }

  @override
  Future<TransferResult> getStatus(String transferId) {
    // TODO(backend): _client.get('/transfers/$transferId', ...)
    throw UnimplementedError('ApiTransferRepository.getStatus is not wired up yet.');
  }

  @override
  Future<List<Beneficiary>> getBeneficiaries() {
    // TODO(backend): _client.get('/beneficiaries', ...)
    throw UnimplementedError('ApiTransferRepository.getBeneficiaries is not wired up yet.');
  }
}
