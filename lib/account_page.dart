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
        });
      }

      if (isAuthorized) {
        final user = {
          'email': account!.email,
          'displayName': account.displayName,
          'photoUrl': account.photoUrl,
        };
        authService.currentUser.value = user;
        await authService.saveUser(user);
      } else {
        authService.currentUser.value = null;
        await authService.saveUser(null);
      }
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
      final account = _googleSignIn.currentUser;
      if (account != null) {
        final user = {
          'email': account.email,
          'displayName': account.displayName,
          'photoUrl': account.photoUrl,
        };
        authService.currentUser.value = user;
        await authService.saveUser(user);
      }

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
      final account = _googleSignIn.currentUser;
      if (account != null) {
        await _googleSignIn.disconnect();
      } else {
        print("No user signed in.");
      }

      authService.currentUser.value = null;
      await authService.saveUser(null);

      if (mounted) {
        setState(() {
          _currentUser = null;
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
    final Map<String, String?>? user = _currentUser != null
        ? {
            'email': _currentUser!.email,
            'displayName': _currentUser!.displayName,
            'photoUrl': _currentUser!.photoUrl,
          }
        : authService.currentUser.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Account"),
      ),
      body: user != null
          ? SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(user['photoUrl'] ?? ''),
                        radius: 50,
                      ),
                      Text(user['displayName'] ?? ''),
                      Text(user['email']!),
                    ],
                  ),
                  const Text('Signed in successfully.'),
                  ElevatedButton(
                    onPressed: _handleSignOut,
                    child: const Text('SIGN OUT'),
                  ),
                ],
              ),
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
