class User {
  final int id;
  final String username;
  final String email;
  final String password;
  final String? title; // nullable
  final DateTime createdAt;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.title, // nullable
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
