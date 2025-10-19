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
