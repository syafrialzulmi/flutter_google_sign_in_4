import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  ValueNotifier<GoogleSignInAccount?> currentUser = ValueNotifier<GoogleSignInAccount?>(null);

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();
}

final AuthService authService = AuthService();