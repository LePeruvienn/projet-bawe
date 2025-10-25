import '../models/user.dart';
import '../api/users.dart';

// Post table class
class Post {

  final int id;
  final User user;
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

  //TODO: IMPROVE THIS
  static Future<Post> fromJson(Map<String, dynamic> json) async {
  
    final userId = json['user_id'] as int;

    final user = await fetchUser(userId);

    return Post(
      id: json['id'] as int,
      user: user,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      likesCount: json['likes_count'] as int,
    );
  }
}
