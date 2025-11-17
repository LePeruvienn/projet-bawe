import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import '../models/user.dart';
import '../auth/tokenHandler.dart';

Future<User> fetchUser(int id) async {

  // Get user token
  final token = TokenHandler().token;

  final response = await http.get(
    Uri.parse('http://0.0.0.0:8080/users/$id'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/x-www-form-urlencoded',
    }
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);

  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load user');
  }
}

Future<List<User>> fetchUsers({int limit = 20, int offset = 0}) async {

  // Get user token
  final token = TokenHandler().token;

  final response = await http.get(
    Uri.parse('http://0.0.0.0:8080/users?limit=$limit&offset=$offset'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/x-www-form-urlencoded',
    }
  );

  if (response.statusCode == 200) {

    // Parse the response body and map it to a List of User
    List<dynamic> jsonResponse = jsonDecode(response.body);
    return jsonResponse.map<User>((user) => User.fromJson(user as Map<String, dynamic>)).toList();

  } else {

    throw Exception('Failed to load users');
  }
}

Future<bool> deleteUser(User user) async {

  final id = user.id;

  // Get user token
  final token = TokenHandler().token;

  try {

    final response = await http.delete(
      Uri.parse('http://0.0.0.0:8080/users/delete/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      }
    );

    // Check for 204 cause API is returning 204 if delete is successfull
    bool success = response.statusCode == 204;

    if (!success) {
      print('Failed to delete user: ${response.body}');
    }

    return success;
    
  } catch (error) {

    // Handle any exceptions that occur during the request
    print('Error occurred while deleting user: $error');
    return false; // Return false to indicate failure
  }
}

Future<User?> createUser(String username, String email, String password, String? title, [bool? isAdmin]) async {

  // if isAdmin var is not set, set it to false
  if (isAdmin == null)
    isAdmin = false;

  final response = await http.post(
    Uri.parse('http://0.0.0.0:8080/users/create'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'username': username,
        'email': email,
        'password': password,
        'title': title ?? 'null',
        'is_admin': isAdmin ? 'true' : 'false',
      }
  );

  print(">>>>>VVVV");
  print(response.statusCode);
  print(response.body);

  // If we did receive an OK (200) response, we return created user
  if (response.statusCode == 200)
    return await User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);

  return null;
}


Future<bool> updateUser(User user) async {

  final id = user.id;

  // Get user token
  final token = TokenHandler().token;

  try {

    final response = await http.put(
      Uri.parse('http://0.0.0.0:8080/users/update/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'username': user.username,
        'email': user.email,
        'password': user.password,
        'title': user.title ?? 'null',
        'is_admin': user.isAdmin ? 'true' : 'false'
      }
    );

    // Check for 202 : OK
    bool success = response.statusCode == 204;

    if (!success) {
      print('Failed to update user: ${response.body}');
    }

    return success;
    
  } catch (error) {

    // Handle any exceptions that occur during the request
    print('Error occurred while updating user: $error');

    return false; // Return false to indicate failure
  }
}

Future<User> fetchConnectedUser() async {

  // Get user token
  final token = TokenHandler().token;

  print(">>>>>");
  print(token);
  print(">>>>>");

  // If there is no token return error
  if (token == null)
    throw Exception('User is not connected.');

  // Try getting connected user data
  final response = await http.get(
    Uri.parse('http://0.0.0.0:8080/users/me'),
    headers: {
      'Authorization': 'Bearer $token',  // Include token in the Authorization header
      'Content-Type': 'application/json',
    },
  );

  // Handle the response
  switch (response.statusCode) {

    case 200: // Success
      return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);

    case 401: // Unauthorized
      throw Exception('Unauthorized: Invalid token');

    case 403: // Forbidden
      throw Exception('Forbidden: You do not have access to this resource');

    default: // Handle other status codes
      throw Exception('Failed to fetch data: ${response.statusCode} - ${response.body}');
  }
}
