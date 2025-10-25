import 'package:flutter/material.dart';

import '../models/post.dart';
import '../utils.dart';
import '../api/posts.dart';

/************************
* GLOBALS POSTS FUNCTIONS
*************************/

void handleCreatePost(BuildContext context, int postId, String content) async {

  // Try to create post
  bool res = await createPost(postId, content);

  // Show message depending of sucess
  showSnackbar(
    context: context,
    dismissText: res ? 'Post created successfully' : 'Failed to create post',
    backgroundColor: res ? Colors.deepPurple : Colors.red,
    icon: Icon(res ? Icons.done : Icons.close, color: Colors.white),
  );
}

void handleDeletePost(BuildContext context, Post post) async {

  bool res = await deletePost(post);

  showSnackbar(
    context: context,
    dismissText: res ? 'Post successfully deleted' : 'Failed to delete post',
    backgroundColor: res ? Colors.deepPurple : Colors.red,
    icon: Icon(res ? Icons.done : Icons.close, color: Colors.white),
  );
}

void handleInfoPost(BuildContext context, Post post) {

}

/************************
* GLOBALS POSTS CLASSES
*************************/

/*
* BASE USER PAGE
* - This is the container of the user list page
*/
class PostsPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posts'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  print('Refresh Pressed'); // Example action
                },
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("Create Post");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PostList extends StatefulWidget {

  PostList({super.key});
  
  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {

  late Future<List<Post>> futurePosts;

  @override
  void initState() {
    super.initState();
    futurePosts = fetchPosts();
  }

  // Used to refrech the users after delete / update
  void _refreshPosts() async {
    setState(() {
      futurePosts = fetchPosts();
    });
  }

  @override Widget build(BuildContext context) {

    return FutureBuilder<List<Post>> (
      future: futurePosts,
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {

          return Center(child: CircularProgressIndicator());

        } else if (snapshot.hasError) {

          return Center(child: Text('Error: ${snapshot.error}'));

        } else {

          return ListView(
            children: snapshot.data!.map((post) {
              return PostListItem(post: post);
            }).toList(),
          );
        }
      },
    );
  }
}

class PostListItem extends StatefulWidget {

  final Post post;

  PostListItem({ required this.post }) : super(key: ObjectKey(post));

  @override
  State<PostListItem> createState() => _PostListItemState();
}

class _PostListItemState extends State<PostListItem> {

  @override
  Widget build(BuildContext context) {

    return Card(

    );
  }
}
