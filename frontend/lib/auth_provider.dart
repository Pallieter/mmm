import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

// Mock Auth Provider to bypass dependency issues for PoC
class AuthProvider extends ChangeNotifier {
  User? _appUser;

  User? get appUser => _appUser;
  bool get isLcggedIn => _appUser != null;

  AuthProvider() {
    // Auto-login for demo
    signIn();
  }

  Future<void> signIn() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    _appUser = User(
      id: 'mock-user-id',
      email: 'demo@example.com',
      displayName: 'Demo User',
      role: UserRole.owner,
    );
    notifyListeners();
  }

  Future<void> signOut() async {
    _appUser = null;
    notifyListeners();
  }
}
