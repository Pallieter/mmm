import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'MMM Task Manager',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('Please sign in to continue'),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                context.read<AuthProvider>().signIn();
              },
              icon: const Icon(Icons.login),
              label: const Text('Sign in with Google'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Bypass logic could go here
              },
              child: const Text('Dev Bypass (Not implemented)'),
            ),
          ],
        ),
      ),
    );
  }
}
