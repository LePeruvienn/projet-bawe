import '../models/user.dart';
import '../api/users.dart';

// Post table class
class Post {

  final int id;
  final UserBasic user;
  final String content;
  final DateTime createdAt;
  final int likesCount;
  final bool authIsLiked;

  const Post({
    required this.id,
    required this.user,
    required this.content,
    required this.createdAt,
    required this.likesCount,
    required this.authIsLiked
  });

  factory Post.fromJson(Map<String, dynamic> json) {

    final user = UserBasic(
      id: json['user_id'] as int,
      username: json['user_username'] as String,
      title: json['user_title'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

    // Small trick to force date to be considered in UTC timezone
    final createdAtString = json['created_at'] as String;
    final utcDate = DateTime.parse('${createdAtString}Z');

    return Post(
      id: json['id'] as int,
      user: user,
      content: json['content'] as String,
      createdAt: utcDate,
      likesCount: json['likes_count'] as int,
      authIsLiked: json['auth_is_liked'] as bool,
    );
  }
}
