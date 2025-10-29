import 'package:flutter/material.dart';
import '../models/post.dart';
import '../utils.dart';
import '../api/posts.dart';

/************************
* GLOBAL POSTS FUNCTIONS
*************************/

Future<void> handleCreatePost(BuildContext context, String content) async {

  final res = await createPost(content);

  showSnackbar(
    context: context,
    dismissText: res ? 'Post created successfully' : 'Failed to create post',
    backgroundColor: res ? Colors.deepPurple : Colors.red,
    icon: Icon(res ? Icons.done : Icons.close, color: Colors.white),
  );
}

void handleDeletePost(BuildContext context, Post post, VoidCallback onDeleted) async {

  final res = await deletePost(post);

  showSnackbar(
    context: context,
    dismissText: res ? 'Post successfully deleted' : 'Failed to delete post',
    backgroundColor: res ? Colors.deepPurple : Colors.red,
    icon: Icon(res ? Icons.done : Icons.close, color: Colors.white),
  );

  if (res)
    onDeleted();
}

/************************
* POSTS PAGE
*************************/

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  late Future<List<Post>> futurePosts;

  @override
  void initState() {
    super.initState();
    futurePosts = fetchPosts();
  }

  void _refreshPosts() {
    setState(() {
      futurePosts = fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text(
          "FeurX",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 32,
            color: Colors.deepPurple,
          ),
        )),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.4,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshPosts(),
        child: FutureBuilder<List<Post>>(
          future: futurePosts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No posts available.'));
            } else {
              final posts = snapshot.data!;
              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return PostListItem(
                    post: posts[index],
                    onDelete: _refreshPosts,
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openPostForm(context, _refreshPosts),
        child: const Icon(Icons.create),
      ),
    );
  }
}

/************************
* POST LIST ITEM
*************************/

class PostListItem extends StatefulWidget {

  final Post post;
  final VoidCallback onDelete;

  const PostListItem({
    super.key,
    required this.post,
    required this.onDelete,
  });

  @override
  State<PostListItem> createState() => _PostListItemState();
}

class _PostListItemState extends State<PostListItem> {
  
  late int likes;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    likes = widget.post.likesCount;
  }

  void toggleLike() {
    setState(() {
      if (isLiked) {
        likes -= 1;
      } else {
        likes += 1;
      }
      isLiked = !isLiked;
    });
    // TODO: send like/unlike to backend
    // likePost(widget.post.id, isLiked);
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            backgroundColor: Colors.deepPurple,
            child: Text(
              post.user.username[0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),

          // Main post content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username and more menu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          post.user.title ?? '@${post.user.username}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        if (post.user.title != null) ...[
                          const SizedBox(width: 2),
                          Text(
                            '@${post.user.username}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                    IconButton(
                      iconSize: 20,
                      icon: Icon(Icons.delete),
                      onPressed: () => handleDeletePost(context, post, widget.onDelete),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Post content
                Text(
                  post.content,
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 6),

                // Date and like row
                Row(
                  children: [
                    IconButton(
                      iconSize: 20,
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey[600],
                      ),
                      onPressed: toggleLike,
                    ),
                    Text('$likes', style: TextStyle(color: Colors.grey[700])),
                    const Spacer(),
                    Text(
                      formatTimeAgo(post.createdAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void openPostForm(BuildContext context, VoidCallback onPostCreated) {

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _PostForm(onPostCreated: onPostCreated),
    ),
  );
}

class _PostForm extends StatefulWidget {
  final VoidCallback onPostCreated;
  const _PostForm({required this.onPostCreated});

  @override
  State<_PostForm> createState() => _PostFormState();
}

class _PostFormState extends State<_PostForm> {
  final TextEditingController _controller = TextEditingController();
  bool isPosting = false;
  static const int maxLength = 280;

  @override
  Widget build(BuildContext context) {
    final remaining = maxLength - _controller.text.length;
    final disabled = _controller.text.trim().isEmpty || _controller.text.length > maxLength;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.deepPurple,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: "What's happening?",
                    border: InputBorder.none,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$remaining',
                style: TextStyle(
                  color: remaining < 0 ? Colors.red : Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: disabled ? Colors.grey[400] : Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                ),
                onPressed: disabled || isPosting
                    ? null
                    : () async {
                        setState(() => isPosting = true);
                        await handleCreatePost(context, _controller.text.trim());
                        Navigator.pop(context);
                        widget.onPostCreated();
                      },
                child: isPosting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Post', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
