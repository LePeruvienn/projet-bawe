import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/post.dart';
import '../utils.dart';
import '../api/posts.dart'; // ASSUMES: createPost returns Future<Post?>
import '../auth/authProvider.dart';
import '../routes.dart';

/************************
* GLOBAL POSTS CONSTANTS
*************************/

// To get Lazy Loading config
const POST_LIMIT = 20;
const POST_MAX_LENGTH = 280;
const REFRESH_WHEN_CLOSE_TO = 300;

/************************
* GLOBAL POSTS FINALS
*************************/

// Get Singleton Instance once
final authProvider = AuthProvider();

/************************
* GLOBAL POSTS FUNCTIONS
*************************/

Future<Post?> handleCreatePost(BuildContext context, String content) async {

  // Get created Post
  final Post? newPost = await createPost(content);

  // Get current context location (for translating)
  final loc = context.loc;

  // Check if success
  final res = newPost != null;

  // Show message on showSnackbar depending of sucess
  showSnackbar(
    context: context,
    dismissText: res ? loc.postCreatedSuccess : loc.postCreationFailed,
    backgroundColor: res ? Colors.deepPurple : Colors.red,
    icon: Icon(res ? Icons.done : Icons.close, color: Colors.white),
  );

  // Return created post
  return newPost;
}

void handleDeletePost(BuildContext context, Post post, VoidCallback onDeleted) async {

  // Try to delete post
  final res = await deletePost(post);

  // Get current context location (for translating)
  final loc = context.loc;

  // Show message on showSnackbar depending of sucess
  showSnackbar(
    context: context,
    dismissText: res ? loc.postDeletedSuccess : loc.postDeletedFailed,
    backgroundColor: res ? Colors.deepPurple : Colors.red,
    icon: Icon(res ? Icons.done : Icons.close, color: Colors.white),
  );

  // Call onDeleted function if sucess
  if (res)
    onDeleted();
}

Future<bool> handleLikePost(BuildContext context, Post post) async {

  final id = post.id;

  // Try to like post
  bool isLiked = await likePost(id);

  // If not succeded show error message
  if (!isLiked) {

    showSnackbar(
      context: context,
      dismissText: context.loc.likePostFailed,
      backgroundColor: Colors.red,
      icon: Icon(Icons.close, color: Colors.white),
    );
  }

  return isLiked;
}

Future<bool> handleUnlikePost(BuildContext context, Post post) async {

  final id = post.id;

  // Try to unlike post
  bool isUnliked = await unlikePost(id);

  // If not succeded show error message
  if (!isUnliked) {

    showSnackbar(
      context: context,
      dismissText: context.loc.unlikePostFailed,
      backgroundColor: Colors.red,
      icon: Icon(Icons.close, color: Colors.white),
    );
  }

  return isUnliked;
}

void openMobilePostForm(BuildContext context, void Function(Post) onPostCreated) {

  // Open Post form Interface, and on create call onPostCreated
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
      child: _PostFormMobile(onPostCreated: onPostCreated),
    ),
  );
}

/*****************
* POSTS COMPONENTS
******************/

class _PostFormMobile extends StatefulWidget {

  final void Function(Post) onPostCreated;
  const _PostFormMobile({required this.onPostCreated});

  @override
  State<_PostFormMobile> createState() => _PostFormMobileState();
}

class _PostFormMobileState extends State<_PostFormMobile> {

  final TextEditingController _controller = TextEditingController();

  bool isPosting = false;

  Future<void> _createPost(BuildContext context) async {

    // Get content
    final content = _controller.text.trim();

    // Set state to posting
    setState(() => isPosting = true);

    // Try to create post
    final newPost = await handleCreatePost(context, content);

    _controller.clear();

    // Remove form
    Navigator.pop(context);

    // Reomove posting
    setState(() => isPosting = false);

    // If sucess call callback
    if (newPost != null)
      widget.onPostCreated(newPost);
  }

  @override
  Widget build(BuildContext context) {

    final remaining = POST_MAX_LENGTH - _controller.text.length;
    final disabled = _controller.text.trim().isEmpty || _controller.text.length > POST_MAX_LENGTH;

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
                  decoration: InputDecoration(
                    hintText: context.loc.postHint,
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
                : Text(context.loc.createPost, style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostFormDesktop extends StatefulWidget {

  final void Function(Post) onPostCreated;
  const _PostFormDesktop({required this.onPostCreated});

  @override
  State<_PostFormDesktop> createState() => _PostFormDesktopState();
}

class _PostFormDesktopState extends State<_PostFormDesktop> {

  final TextEditingController _controller = TextEditingController();

  bool isPosting = false;

  Future<void> _createPost() async {

    // Get input data
    final content = _controller.text.trim();

    // Check if empty
    if (content.isEmpty || content.length > POST_MAX_LENGTH)
      return;

    // Set current state to posting
    setState(() => isPosting = true);

    // Try to create new post
    final newPost = await handleCreatePost(context, content);

    _controller.clear();

    // Remove posting state
    setState(() => isPosting = false);

    // if we succeded call callback
    if (newPost != null)
      widget.onPostCreated(newPost);
  }

  @override
  Widget build(BuildContext context) {

    final disabled = _controller.text.trim().isEmpty || _controller.text.length > POST_MAX_LENGTH;

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
              decoration: InputDecoration(
                hintText: context.loc.postHint,
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
                  '${POST_MAX_LENGTH - _controller.text.length}',
                  style: TextStyle(
                    color: _controller.text.length > POST_MAX_LENGTH
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
                : Text(context.loc.createPost, style: TextStyle(color: Colors.white)),
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

  final ScrollController _scrollController = ScrollController();

  final int _limit = POST_LIMIT;
  int _offset = 0;

  bool _isLoading = false;
  bool _hasMore = true;
  bool _hasError = false;

  List<Post> _posts = [];

  // Future that represents the initial/refresh load
  Future<void>? _initialLoadFuture; 

  @override
  void initState() {

    super.initState();
    _initialLoadFuture = _loadPosts(initial: true); 
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {

    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {

    final pos = _scrollController.position.pixels;
    final treshold = _scrollController.position.maxScrollExtent - REFRESH_WHEN_CLOSE_TO;

    // If we scrolled out of the treshold and we are loading and there is more to load
    // => Load more :O
    if (pos >= treshold && !_isLoading && _hasMore)
      _loadPosts();
  }

  Future<void> _loadPosts({bool initial = false}) async {

    // If we are already loading do not load more
    if (_isLoading)
      return;

    // Update State to loading
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    if (initial) {
      // Reset for a full refresh
      _posts.clear();
      _offset = 0;
      _hasMore = true;
    }

    // NOW TRYING TO LOAD MORE POSTS :
    try {

      // Do the API call
      final newPosts = await fetchPosts(limit: _limit, offset: _offset);

      setState(() {
        // Add new posts to posts list
        _posts.addAll(newPosts);
        // Move offset cursor
        _offset += newPosts.length;
        // Check if we right the limit
        _hasMore = newPosts.length == _limit; 
        // Update loading state
        _isLoading = false;
      });

    // IF WE CATCH A ERROR WHILE LOADING POSTS :
    } catch (e) {

      // Update loading state to false
      setState(() {
        _isLoading = false;
        _hasError = true;
      });

      // Show error to snackbar if it's not the inital fetch
      if (!initial)
        showSnackbar(
          context: context, 
          dismissText: 'context.loc.postsLoadFailed',
          backgroundColor: Colors.red,
          icon: const Icon(Icons.close, color: Colors.white),
        );

      // Throw error
      throw(e);
    }
  }

  void _removePostLocally(Post post) {

    setState(() {
      // Remove post from list and update offset
      _posts.removeWhere((p) => p.id == post.id);
      if (_offset > 0)
        _offset--;
    });
  }

  void _addPostLocally(Post newPost) {

    // Add the new post at the top of the page and update offset
    setState(() {
      _posts.insert(0, newPost);
      _offset++;
    });
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Check for responsive
    final _isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _loadPosts(initial: true), // Trigger a full refresh
        child: FutureBuilder<void>(
          future: _initialLoadFuture, 
          builder: (context, snapshot) {

            // vvv explained after
            final bool _showDesktopForm = _isDesktop && authProvider.isLoggedIn;
            int _totalItems = _posts.length + (_isLoading ? 1 : 0) + (_showDesktopForm ? 1 : 0);

            // Handling errors and loading
            if (snapshot.connectionState == ConnectionState.waiting && _posts.isEmpty && !_showDesktopForm)
                return Center(child: CircularProgressIndicator());

            if (!_isLoading && (_hasError || snapshot.hasError) && _posts.isEmpty)
                return Center(child: ErrorText(header: "Failed to load posts", message: 'Error: ${snapshot.error}'));

            // If there is no more post to shown
            if (!_isLoading && _posts.isEmpty && !_hasMore) {

              // If we have nothing to show, we can just return a loading, otherwise we add this item at the end of the list
              if (!_showDesktopForm)
                return Center(child: ErrorText(
                  header: 'Nothing there ...',
                  message: 'Be the first one to create a post !',
                  color: colorScheme.primary
                ));

              else
                _totalItems++;
            }

            // Ok this is weird but let me expalin,
            // We must manage the ListItem length depeding of :
            // - If we are loading the page (cause it adds +1 to list cause the loading Circle count as an item)
            // - If we are in desktop (cause it adds +1 to list cause the _PostFormDesktop count as an item)
            //
            // We also need so to dynamicly change the post indexs depending if we have added the DesktopForm at the top
            //
            // So we must to compute this dynamicly it's weid and can make some pretty bad bugs 
            // - _showDesktopForm
            // - _totalItems

            // Main List View
            return ListView.builder(
              controller: _scrollController, 
              padding: const EdgeInsets.all(16),
              itemCount: _totalItems, 
              itemBuilder: (context, index) {

                // Last item is the loading indicator or the message
                if (index ==_totalItems - 1) {

                  // If we are loading add loading circle
                  if (_isLoading) {

                    return _hasMore ?
                      const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator())) : 
                      const SizedBox.shrink(); 

                  // If we are NOT loading add and have no post to shown
                  } else if (_posts.isEmpty && !_hasMore) {

                    return Center(child: ErrorText(
                      header: 'Nothing there ...',
                      message: 'Be the first one to create a post !',
                      color: colorScheme.primary
                    ));
                  }
                }

                // First item is the desktop post form
                if (index == 0 && _isDesktop && authProvider.isLoggedIn)
                  return _PostFormDesktop(onPostCreated: _addPostLocally);

                // BE CAREFUL : You must do the index - 1 otherwise all post will bot be shown in showDesktopForm (as i say before)
                final postIndex = _showDesktopForm ? index - 1 : index;
                final post = _posts[postIndex];

                // Standard post item
                return PostListItem(
                  key: ValueKey(post.id),
                  post: post,
                  onDelete: () => _removePostLocally(post),
                );
              },
            );
          },
        ),
      ),
      // Mobile FAB
      floatingActionButton: (!_isDesktop && authProvider.isLoggedIn)
          ? FloatingActionButton(
              onPressed: () => openMobilePostForm(context, _addPostLocally), 
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

    // If we are already handling the like return
    if (isHandlingLike)
      return;

    // If we are not logged in go to login page and return
    if (!authProvider.isLoggedIn) {
      context.go(LOGIN_PATH);
      return;
    }

    // Update like status
    isHandlingLike = true;

    // Try to like/unlike post
    bool success = isLiked ?
      await handleUnlikePost(context, post) : 
      await handleLikePost(context, post);

    // if we failed stop here and update handling status
    if (!success) {
      isHandlingLike = false;
      return;
    }

    // If sucess Update like data
    setState(() {
      if (isLiked)
        likes -= 1;
      else
        likes += 1;
      isLiked = !isLiked;
    });

    // Not handling like anymore
    isHandlingLike = false;
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final post = widget.post;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.onSurface.withOpacity(0.12),
          ),
        ),
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
