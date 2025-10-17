class User {

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.created_at,
  });

  final int id;
  final String username;
  final String email;
  final String password;
  final DateTime created_at;
}
