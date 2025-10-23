import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import '../models/post.dart';

Future<Post> fetchPost(int id) async {
  final response = await http.get(
    Uri.parse('http://0.0.0.0:8080/posts/$id'),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Post.fromJson(jsonDecode(response.body) as Map<String, dynamic>);

  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load post');
  }
}

Future<List<Post>> fetchPosts() async {

  final response = await http.get(
    Uri.parse('http://0.0.0.0:8080/posts/'),
  );

  if (response.statusCode == 200) {

    // Parse the response body and map it to a List of Post
    List<dynamic> jsonResponse = jsonDecode(response.body);
    return jsonResponse.map<Post>((post) => Post.fromJson(post as Map<String, dynamic>)).toList();

  } else {

    throw Exception('Failed to load posts');
  }
}

Future<bool> deletePost(Post post) async {

  final id = post.id;

  try {

    final response = await http.delete(
      Uri.parse('http://0.0.0.0:8080/posts/delete/$id'),
    );

    // Check for 204 cause API is returning 204 if delete is successfull
    bool success = response.statusCode == 204;

    if (!success) {
      print('Failed to delete post: ${response.body}');
    }

    return success;
    
  } catch (error) {

    // Handle any exceptions that occur during the request
    print('Error occurred while deleting post: $error');
    return false; // Return false to indicate failure
  }
}

Future<bool> createPost(int userId, String content) async {

  try {

    final response = await http.post(

    Uri.parse('http://0.0.0.0:8080/posts/create'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'user_id': userId,
        'content': content
      }
    );

    // Supposons que le backend renvoie 201 pour succès
    final success = response.statusCode == 201;

    if (!success)
      print('Failed to create post: ${response.statusCode} - ${response.body}');

    return success;

  } catch (error) {

    print('Error occurred while creating post: $error');
    return false;
  }
}
