enum AccountType { savings, current }

class Account {
  final String id;
  final String userId;
  final String accountNumber;
  final String name;
  final AccountType type;
  final String currency;
  final double balance;
  final bool isLocked;
  final DateTime dateCreated;

  Account(
      {required this.id,
      required this.userId,
      required this.accountNumber,
      required this.name,
      required this.type,
      required this.currency,
      required this.balance,
      required this.isLocked,
      required this.dateCreated});

  factory Account.fromJson(Map<String, dynamic> json) => Account(
      id: (json['id'] as String),
      userId: (json['userId'] as String),
      accountNumber: (json['accountNumber'] as String),
      name: (json['name'] as String),
      type: (json['type'] as String).toLowerCase() == 'savings'
          ? AccountType.savings
          : AccountType.current,
      currency: (json['currency'] as String),
      balance: (json['balance'] as num).toDouble(),
      isLocked: bool.tryParse(json['isLocked']) ?? false,
      dateCreated: DateTime.parse(json['dateCreated'] as String));

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'accountNumber': accountNumber,
        'name': name,
        'type': type == AccountType.savings ? 'savings' : 'current',
        'currency': currency,
        'balance': balance.toString(),
        'isLocked': isLocked.toString(),
        'dateCreated': dateCreated.toIso8601String(),
      };

  Account copyWith(
          {id,
          userId,
          accountNumber,
          name,
          type,
          currency,
          balance,
          isLocked,
          dateCreated}) =>
      Account(
          id: id ?? this.id,
          userId: userId ?? this.userId,
          accountNumber: accountNumber ?? this.accountNumber,
          name: name ?? this.name,
          type: type ?? this.type,
          currency: currency ?? this.currency,
          balance: balance ?? this.balance,
          isLocked: isLocked ?? this.isLocked,
          dateCreated: dateCreated ?? this.dateCreated);
}
