import 'package:flutter/material.dart';
import 'package:flutter_google_sign_in_4/account_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign in using Google"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return const AccountPage();
                },
              ));
            },
            icon: const Icon(Icons.manage_accounts),
          ),
        ],
      ),
      body: Center(
        child: ValueListenableBuilder<GoogleSignInAccount?>(
          valueListenable: authService.currentUser,
          builder: (context, user, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user != null
                      ? "Welcome back, ${user.displayName}"
                      : "Welcome back",
                  style: const TextStyle(
                    fontSize: 24,
                  ),
                ),
                Text(user != null ? "Signed in as ${user.email}" : "new user"),
              ],
            );
          },
        ),
      ),
    );
  }
}
