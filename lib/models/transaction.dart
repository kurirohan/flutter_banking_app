enum TransactionType { credit, debit }

class Transaction {
  final String id;
  final String? sourceAcctId;
  final String destAcctId;
  final TransactionType type;
  final double amount;
  final String currency;
  final String description;
  final String category;
  final DateTime dateCreated;

  Transaction(
      {required this.id,
      this.sourceAcctId,
      required this.destAcctId,
      required this.type,
      required this.amount,
      required this.currency,
      required this.description,
      required this.category,
      required this.dateCreated});

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as String,
        sourceAcctId: json['sourceAcctId'] as String?,
        destAcctId: json['destAcctId'] as String,
        type: (json['type'] as String) == 'credit'
            ? TransactionType.credit
            : TransactionType.debit,
        amount: (json['amount'] as num).toDouble(),
        currency: json['currency'] as String,
        description: json['description'] as String,
        category: json['category'] as String,
        dateCreated: DateTime.parse(json['dateCreated'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceAcctId': sourceAcctId,
        'destAcctId': destAcctId,
        'type': type == TransactionType.credit ? 'credit' : 'debit',
        'amount': amount.toDouble(),
        'currency': currency,
        'description': description,
        'category': category,
        'dateCreated': dateCreated.toIso8601String(),
      };

  Transaction copyWith({
    id,
    sourceAcctId,
    destAcctId,
    type,
    amount,
    currency,
    description,
    category,
    dateCreated,
  }) =>
      Transaction(
          id: id ?? this.id,
          destAcctId: destAcctId ?? this.destAcctId,
          type: type ?? this.type,
          amount: amount ?? this.amount,
          currency: currency ?? this.currency,
          description: description ?? this.description,
          category: category ?? this.category,
          dateCreated: dateCreated ?? this.dateCreated);

  bool isCredit() => this.type == TransactionType.credit;
}
