import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_service.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
];

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: scopes,
);

class _AccountPageState extends State<AccountPage> {
  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false;
  String _contactText = '';
  StreamSubscription<GoogleSignInAccount?>? _userChangedSubscription;

  @override
  void dispose() {
    _userChangedSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _userChangedSubscription = _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
      bool isAuthorized = account != null;
      if (kIsWeb && account != null) {
        isAuthorized = await _googleSignIn.canAccessScopes(scopes);
      }

      if (mounted) {
        setState(() {
          _currentUser = account;
          _isAuthorized = isAuthorized;
        });
      }

      // Update AuthService singleton
      authService.currentUser.value = account;

      if (isAuthorized) {
        // unawaited(_handleGetContact(account!));
      }
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
      // Update AuthService singleton
      authService.currentUser.value = _googleSignIn.currentUser;

      if (mounted) {
        setState(() {});
      }
    } catch (error) {
      print("Error signing in: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error signing in: $error")),
        );
      }
    }
  }

  Future<void> _handleSignOut() async {
    try {
      await _googleSignIn.disconnect();
      // Update AuthService singleton
      authService.currentUser.value = null;
      if (mounted) {
        setState(() {
          _currentUser = null;
          _isAuthorized = false;
        });
      }
    } catch (e) {
      print("Error signing out: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error signing out: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final GoogleSignInAccount? user =
        _currentUser ?? authService.currentUser.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Account"),
      ),
      body: user != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                ListTile(
                  leading: GoogleUserCircleAvatar(
                    identity: user,
                  ),
                  title: Text(user.displayName ?? ''),
                  subtitle: Text(user.email),
                ),
                const Text('Signed in successfully.'),
                ElevatedButton(
                  onPressed: _handleSignOut,
                  child: const Text('SIGN OUT'),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('You are not currently signed in.'),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _handleSignIn,
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            side: const BorderSide(
                              color: Colors.blue, // your color here
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.network(
                            "http://pngimg.com/uploads/google/google_PNG19635.png",
                            width: 50,
                          ),
                          const Text("Sign in with Google"),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
    );
  }
}
