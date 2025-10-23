// Post table class
class Post {

  final int id;
  final int userId;
  final String content;
  final DateTime createdAt;
  final int likesCount;

  const Post({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.likesCount
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      likesCount: json['likes_count'] as int,
    );
  }
}
