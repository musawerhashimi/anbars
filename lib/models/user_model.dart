class UserModel {
  final int? id;
  final String username;
  final String password;
  final String? email;
  final String? createdAt;

  const UserModel({
    this.id,
    required this.username,
    required this.password,
    this.email,
    this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'] as int?,
        username: map['username'] as String,
        password: map['password'] as String,
        email: map['email'] as String?,
        createdAt: map['created_at'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'username': username,
        'password': password,
        'email': email,
        'created_at': createdAt,
      };

  UserModel copyWith({
    int? id,
    String? username,
    String? password,
    String? email,
    String? createdAt,
  }) =>
      UserModel(
        id: id ?? this.id,
        username: username ?? this.username,
        password: password ?? this.password,
        email: email ?? this.email,
        createdAt: createdAt ?? this.createdAt,
      );
}
