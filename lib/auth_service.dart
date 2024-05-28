import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  ValueNotifier<Map<String, String?>?> currentUser = ValueNotifier<Map<String, String?>?>(null);

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  Future<void> saveUser(Map<String, String?>? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user != null) {
      await prefs.setString('userEmail', user['email']!);
      await prefs.setString('userDisplayName', user['displayName'] ?? '');
      await prefs.setString('userPhotoUrl', user['photoUrl'] ?? '');
    } else {
      await prefs.remove('userEmail');
      await prefs.remove('userDisplayName');
      await prefs.remove('userPhotoUrl');
    }
  }

  Future<Map<String, String?>?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('userEmail');
    final displayName = prefs.getString('userDisplayName');
    final photoUrl = prefs.getString('userPhotoUrl');

    if (email != null) {
      return {
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
      };
    }
    return null;
  }
}

final AuthService authService = AuthService();
