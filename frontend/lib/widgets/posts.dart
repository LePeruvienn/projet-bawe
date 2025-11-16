import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/post.dart';
import '../utils.dart';
import '../api/posts.dart';
import '../auth/authProvider.dart';
import '../routes.dart';

/************************
* GLOBAL POSTS FINALS
*************************/

// Get Singleton Instance once
final authProvider = AuthProvider();


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

Future<bool> handleLikePost(BuildContext context, Post post) async {

  final id = post.id;

  bool isLiked = await likePost(id);

  if (!isLiked) {

    showSnackbar(
      context: context,
      dismissText: 'Failed to like post',
      backgroundColor: Colors.red,
      icon: Icon(Icons.close, color: Colors.white),
    );
  }

  return isLiked;
}

Future<bool> handleUnlikePost(BuildContext context, Post post) async {

  final id = post.id;

  bool isUnliked = await unlikePost(id);

  if (!isUnliked) {

    showSnackbar(
      context: context,
      dismissText: 'Failed to unlike post',
      backgroundColor: Colors.red,
      icon: Icon(Icons.close, color: Colors.white),
    );
  }

  return isUnliked;
}


void openPostForm(BuildContext context, VoidCallback onPostCreated) {

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
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

/*****************
* POSTS COMPONENTS
******************/

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

  Future<void> _createPost(BuildContext context) async {

    setState(() => isPosting = true);
    await handleCreatePost(context, _controller.text.trim());
    Navigator.pop(context);
    widget.onPostCreated();
  }

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
                onPressed: disabled || isPosting ? null : () => _createPost(context),
                child: isPosting ?
                  const SizedBox(
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

class _PostFormDesktop extends StatefulWidget {

  final VoidCallback onPostCreated;
  const _PostFormDesktop({required this.onPostCreated});

  @override
  State<_PostFormDesktop> createState() => _PostFormDesktopState();
}

class _PostFormDesktopState extends State<_PostFormDesktop> {

  final TextEditingController _controller = TextEditingController();

  bool isPosting = false;
  static const int maxLength = 280;

  Future<void> _createPost() async {

    final content = _controller.text.trim();
    if (content.isEmpty || content.length > maxLength) return;

    setState(() => isPosting = true);
    await handleCreatePost(context, content);
    _controller.clear();
    setState(() => isPosting = false);
    widget.onPostCreated();
  }

  @override
  Widget build(BuildContext context) {

    final disabled = _controller.text.trim().isEmpty || _controller.text.length > maxLength;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: "What's happening?",
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 16),
              onChanged: (_) {
                setState(() {}); // triggers rebuild to update remaining
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${maxLength - _controller.text.length}',
                  style: TextStyle(
                    color: _controller.text.length > maxLength
                        ? Colors.red
                        : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: disabled ? Colors.grey[400] : Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                ),
                onPressed: disabled || isPosting ? null : _createPost,
                child: isPosting ?
                  const SizedBox(
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
      ),
    );
  }
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

  bool get _isDesktop => MediaQuery.of(context).size.width >= 800;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _refreshPosts(),
        child: FutureBuilder<List<Post>>(
          future: futurePosts,
          builder: (context, snapshot) {

            // Loading widget ...
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());

            // Showing error if there are one
            else if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
            else if (!snapshot.hasData || snapshot.data!.isEmpty)
              return const Center(child: Text('No posts available.'));

            // Get fetched data
            final posts = snapshot.data!;

            // Widget :
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [

                // And Post Input if we are in Desktop mode and we 
                if (_isDesktop && authProvider.isLoggedIn)
                  _PostFormDesktop(onPostCreated: _refreshPosts),

                // Post items
                ...posts.map((post) => PostListItem(
                      post: post,
                      onDelete: _refreshPosts,
                    )),
              ],
            );
          },
        ),
      ),
      floatingActionButton: (!_isDesktop && authProvider.isLoggedIn)
          ? FloatingActionButton(
              onPressed: () => openPostForm(context, _refreshPosts),
              child: const Icon(Icons.create),
            )
          : null,
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
  
  int likes = 0;
  bool isLiked = false;

  bool isHandlingLike = false;

  @override
  void initState() {

    super.initState();
    likes = widget.post.likesCount;
    isLiked = widget.post.authIsLiked;
  }

  void toggleLike(BuildContext context, Post post) async {

    // Is we are actually handling a like do not process other instructions
    if (isHandlingLike)
      return;

    // Set post item handling like status to true
    isHandlingLike = true;

    // If user tries to like but is not logged in
    if (!authProvider.isLoggedIn) {

      // Redirect to login page & stop here
      context.go(LOGIN_PATH);
      isHandlingLike = false;
      return;
    }

    // Send like/unlike request to API
    bool success = isLiked ?
      await handleUnlikePost(context, post) : 
      await handleLikePost(context, post);

    // if it failed stop here
    if (!success) {
      isHandlingLike = false;
      return;
    }

    // Update current frontend item state
    setState(() {

      if (isLiked)
        likes -= 1;

      else
        likes += 1;

      isLiked = !isLiked;
    });

    // Remove handling like state
    isHandlingLike = false;
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
                    // Only show if user is admin
                    if (authProvider.isAdmin)
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
                      onPressed: () => toggleLike(context, post),
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
