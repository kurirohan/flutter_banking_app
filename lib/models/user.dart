class User {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String passwordHash;
  final DateTime dateOfBirth;
  final DateTime dateCreated;

  User(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.username,
      required this.passwordHash,
      required this.dateOfBirth,
      required this.dateCreated});

  factory User.fromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as String),
      firstName: (json['firstName'] as String),
      lastName: (json['lastName'] as String),
      username: (json['username'] as String),
      passwordHash: (json['passwordHash'] as String),
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      dateCreated: DateTime.parse(json['dateCreated'] as String));

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'passwordHash': passwordHash,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'dateCreated': dateCreated.toIso8601String(),
      };

  User copyWith(
          {id,
          firstName,
          lastName,
          username,
          passwordHash,
          dateOfBirth,
          dateCreated}) =>
      User(
          id: id ?? this.id,
          firstName: firstName ?? this.firstName,
          lastName: lastName ?? this.lastName,
          username: username ?? this.username,
          passwordHash: passwordHash ?? this.passwordHash,
          dateOfBirth: dateOfBirth ?? this.dateOfBirth,
          dateCreated: dateCreated ?? this.dateCreated);
}
