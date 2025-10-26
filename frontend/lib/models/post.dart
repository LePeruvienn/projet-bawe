import '../models/user.dart';
import '../api/users.dart';

// Post table class
class Post {

  final int id;
  final UserBasic user;
  final String content;
  final DateTime createdAt;
  final int likesCount;

  const Post({
    required this.id,
    required this.user,
    required this.content,
    required this.createdAt,
    required this.likesCount
  });

  factory Post.fromJson(Map<String, dynamic> json) {

    final user = UserBasic(
      id: json['user_id'] as int,
      username: json['user_username'] as String,
      title: json['user_title'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

    return Post(
      id: json['id'] as int,
      user: user,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      likesCount: json['likes_count'] as int,
    );
  }
}
