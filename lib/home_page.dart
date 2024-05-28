import 'package:flutter/material.dart';
import 'package:flutter_google_sign_in_4/account_page.dart';

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
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome back",
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            Text("new user"),
          ],
        ),
      ),
    );
  }
}
