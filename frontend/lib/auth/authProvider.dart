import 'package:flutter/foundation.dart';
import 'token_handler.dart';

import '../models/user.dart';
import '../api/users.dart';

class AuthProvider extends ChangeNotifier {

  User? _user;

  bool _initialized = false;

  bool get isLoggedIn => _user != null;

  User? get user => _user;

  // Initialisation depuis le token
  Future<void> init() async {

    if (_initialized)
      return;

    _initialized = true;

    final token = TokenHandler().token;

    if (token != null) {

      try {

        _user = await fetchConnectedUser();

      } catch(e) {

        print("AuthProvider->Init() : Failed to get user data of current token. Deleting token & logging out");

        TokenHandler().clear();
      }
    }

    notifyListeners();
  }

  // Connexion (après login)
  Future<void> login(String token) async {

    await TokenHandler().setToken(token);

    try {

      _user = await fetchConnectedUser();

    } catch(e) {

      print("AuthProvider->login() : Failed to get user data of current token. Deleting token & logging out");

      TokenHandler().clear();
    }

    notifyListeners();
  }

  // Déconnexion
  Future<void> logout() async {

    await TokenHandler().clear();

    _user = null;

    notifyListeners();
  }
}
