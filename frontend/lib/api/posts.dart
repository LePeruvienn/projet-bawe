import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import '../models/post.dart';
import '../auth/tokenHandler.dart';

Future<Post> fetchPost(int id) async {

  final response = await http.get(
    Uri.parse('http://0.0.0.0:8080/posts/$id'),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return await Post.fromJson(jsonDecode(response.body) as Map<String, dynamic>);

  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load post');
  }
}

Future<List<Post>> fetchPosts({int limit = 20, int offset = 0}) async {

  // Get user token
  final token = TokenHandler().token;

  final response = await http.get(
    Uri.parse('http://0.0.0.0:8080/posts?limit=$limit&offset=$offset'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/x-www-form-urlencoded',
    },
  );

  if (response.statusCode == 200) {

    // Parse the response body and map it to a List of User
    List<dynamic> jsonResponse = jsonDecode(response.body);
    return jsonResponse.map<Post>((post) => Post.fromJson(post as Map<String, dynamic>)).toList();

  } else {

    throw Exception('Failed to load posts');
  }
}

Future<bool> deletePost(Post post) async {

  final id = post.id;

  // Get user token
  final token = TokenHandler().token;

  try {

    final response = await http.delete(
      Uri.parse('http://0.0.0.0:8080/posts/delete/$id'),
      headers: {
        'Authorization': 'Bearer $token',  // Include token in the Authorization header
        'Content-Type': 'application/x-www-form-urlencoded',
      }
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

Future<bool> createPost(String content) async {

  // Get user token
  final token = TokenHandler().token;

  // If there is no token return error
  if (token == null) {
    print('CreatePost > NoToken: User must be connected to create a post.');
    return false;
  }

  try {

    final response = await http.post(

    Uri.parse('http://0.0.0.0:8080/posts/create'),
      headers: {
        'Authorization': 'Bearer $token',  // Include token in the Authorization header
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'content': content
      }
    );

    // Log status code
    switch (response.statusCode) {

      case 201: // Success
        print('CreatePost > Created: Successfully create a post');

      case 401: // Unauthorized
        print('CreatePost > Unauthorized: Invalid token');

      case 403: // Forbidden
        print('CreatePost > Forbidden: You do not have access to this resource');

      default: // Handle other status codes
        print('CreatePost > Failed to fetch data: ${response.statusCode} - ${response.body}');
    }

    // Return treu if response was 201 - CREATED
    return response.statusCode == 201;

  } catch (error) {

    print('Error occurred while creating post: $error');
    return false;
  }
}


Future<bool> likePost(int id) async {

  // Get user token
  final token = TokenHandler().token;

  // If there is no token return error
  if (token == null) {
    print('LikePost > NoToken: User must be connected to create a post.');
    return false;
  }

  try {

    final response = await http.get(

    Uri.parse('http://0.0.0.0:8080/posts/like/$id'),
      headers: {
        'Authorization': 'Bearer $token',  // Include token in the Authorization header
        'Content-Type': 'application/x-www-form-urlencoded',
      }
    );

    // Log status code
    switch (response.statusCode) {

      case 201: // Success
        print('LikePost > Created: Successfully liked the post');

      case 401: // Unauthorized
        print('LikePost > Unauthorized: Invalid token');

      case 404: // Not Found
        print('LikePost > Not Found: Post doesnt exist');

      case 409: // Conflict
        print('LikePost > Conflict: User already liked this post');

      default: // Handle other status codes
        print('LikePost > Failed to fetch data: ${response.statusCode} - ${response.body}');
    }

    return response.statusCode == 201;

  } catch (error) {

    print('Error occurred while creating post: $error');
    return false;
  }
}

Future<bool> unlikePost(int id) async {

  // Get user token
  final token = TokenHandler().token;

  // If there is no token return error
  if (token == null) {
    print('LikePost > NoToken: User must be connected to create a post.');
    return false;
  }

  try {

    final response = await http.get(

    Uri.parse('http://0.0.0.0:8080/posts/unlike/$id'),
      headers: {
        'Authorization': 'Bearer $token',  // Include token in the Authorization header
        'Content-Type': 'application/x-www-form-urlencoded',
      }
    );

    // Log status code
    switch (response.statusCode) {

      case 200: // Success
        print('UnlikePost > Created: Successfully unliked the post');

      case 401: // Unauthorized
        print('UnlikePost > Unauthorized: Invalid token');

      case 404: // Not Found
        print('UnlikePost > Not Found: Post doesnt exist OR no like for this post exist');

      default: // Handle other status codes
        print('UnlikePost > Failed to fetch data: ${response.statusCode} - ${response.body}');
    }

    return response.statusCode == 200;

  } catch (error) {

    print('Error occurred while creating post: $error');
    return false;
  }
}
