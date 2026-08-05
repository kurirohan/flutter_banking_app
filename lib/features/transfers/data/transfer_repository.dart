// NexaBank — Transfer Repository
import 'package:uuid/uuid.dart';
import '../../../core/network/dio_client.dart';

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

class RemoteTransferRepository implements TransferRepository {
  // Not read yet: this repository returns mock data for the prototype.
  // Kept so swapping in real Dio calls later doesn't change the constructor.
  // ignore: unused_field
  final ApiClient _client;
  RemoteTransferRepository(this._client);

  @override
  Future<TransferResult> submitTransfer(TransferRequest request) async {
    await Future.delayed(const Duration(seconds: 2));
    if (request.amount > 10000) {
      throw const TransferDeclinedException(
        reason: 'Transfer limit exceeded',
        reasonCode: 'LIMIT_EXCEEDED',
      );
    }
    return TransferResult(
      transferId: const Uuid().v4(),
      status: 'PENDING',
      rail: request.amount < 1000 ? 'INSTANT' : 'ACH',
      estimatedArrival: DateTime.now().add(
        request.amount < 1000
            ? const Duration(minutes: 2)
            : const Duration(hours: 24),
      ),
    );
  }

  @override
  Future<TransferResult> getStatus(String transferId) async {
    await Future.delayed(const Duration(seconds: 1));
    return TransferResult(transferId: transferId, status: 'COMPLETED', rail: 'INSTANT');
  }

  @override
  Future<List<Beneficiary>> getBeneficiaries() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const [
      Beneficiary(id: 'b1', name: 'John Smith', accountNumber: '**** 1234', bankName: 'Chase Bank'),
      Beneficiary(id: 'b2', name: 'Sarah Johnson', accountNumber: '**** 5678', bankName: 'Bank of America'),
      Beneficiary(id: 'b3', name: 'Mike Williams', accountNumber: '**** 9012', bankName: 'Wells Fargo'),
    ];
  }
}
