import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import 'models.dart';

Future<User> fetchUser(int id) async {
  final response = await http.get(
    Uri.parse('http://0.0.0.0:8080/users/$id'),
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

Future<List<User>> fetchUsers() async {

  final response = await http.get(
    Uri.parse('http://0.0.0.0:8080/users/'),
  );

  if (response.statusCode == 200) {

    // Parse the response body and map it to a List of User
    List<dynamic> jsonResponse = jsonDecode(response.body);
    return jsonResponse.map<User>((user) => User.fromJson(user as Map<String, dynamic>)).toList();

  } else {

    throw Exception('Failed to load users');
  }
}

Future<bool> deleteUser(int id) async {

  try {

    final response = await http.delete(
      Uri.parse('http://0.0.0.0:8080/users/delete/$id'),
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

Future<bool> createUser(String username, String email, String password, String? title) async {

  try {

    final response = await http.post(

    Uri.parse('http://0.0.0.0:8080/users/create'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'username': username,
        'email': email,
        'password': password,
        'title': title,
      }
    );

    // Supposons que le backend renvoie 201 pour succès
    final success = response.statusCode == 201;

    if (!success)
      print('Failed to create user: ${response.statusCode} - ${response.body}');

    return success;

  } catch (error) {

    print('Error occurred while creating user: $error');
    return false;
  }
}

