import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class TokenHandler {

  static const _key = 'token';

  static final TokenHandler _instance = TokenHandler._internal();

  factory TokenHandler() => _instance;

  TokenHandler._internal();

  String? _token;
  bool _initialized = false;

  Future<void> init() async {

    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_key);

    _initialized = true;

    print("TokenHandler Intialized.");
  }

  // synchronous fast getter after init()
  String? get token => _token;

  Future<void> setToken(String? value) async {

    _token = value;

    final prefs = await SharedPreferences.getInstance();

    if (value == null)
      await prefs.remove(_key);

    else
      await prefs.setString(_key, value);
  }

  Future<void> clear() async {

    await setToken(null);
  }
}
