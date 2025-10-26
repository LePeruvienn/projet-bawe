// Users Table class
// Only admins can have access to all data
class User {

  final int id;
  final String username;
  final String email;
  final String password;
  final String? title;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.title,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      title: json['title'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

// Basic User data that frontend client can have access
class UserBasic {

  final int id;
  final String username;
  final String? title;
  final DateTime createdAt;

  const UserBasic({
    required this.id,
    required this.username,
    this.title,
    required this.createdAt,
  });

  factory UserBasic.fromJson(Map<String, dynamic> json) {
    return UserBasic(
      id: json['id'] as int,
      username: json['username'] as String,
      title: json['title'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
