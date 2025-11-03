import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../auth/authProvider.dart';

//TODO: Improve the return logic of the function to have differents messages
Future<bool> login(String username, String password) async {

  try {

    final response = await http.post(Uri.parse('http://0.0.0.0:8080/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    switch (response.statusCode) {

      case 200: // OK -> Add token to shared_preferences and return true
        final tokenResponse = jsonDecode(response.body);
        final token = tokenResponse['token'];
        if (token == null) {

          print("No field 'Token' in response body");
          return false;
        }
        await AuthProvider().login(token);
        print(tokenResponse);
        return true;

      case 204: // No Content
        print("No content: User not found or incorrect password");
        return false;

      case 500: // Internal Server Error
        print('Server error: ${response.body}');
        return false;

      default:
        print('Failed to login: ${response.statusCode} - ${response.body}');
        return false;
    }

  } catch (error) {

    print('Error occurred while logging in: $error');
    return false;  // Error handling
  }
}

Future<void> logout() async {

  // Clear token from client side to logout
  await AuthProvider().logout();
}

