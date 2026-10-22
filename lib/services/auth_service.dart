import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String _userId = 'user_me';
  String _displayName = 'You';
  String _phoneNumber = '';
  bool _isLoggedIn = true;

  String get userId => _userId;
  String get displayName => _displayName;
  String get phoneNumber => _phoneNumber;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('auth_user_id') ?? 'user_me';
    _displayName = prefs.getString('auth_display_name') ?? 'You';
    _phoneNumber = prefs.getString('auth_phone_number') ?? '';
    _isLoggedIn = prefs.getBool('auth_is_logged_in') ?? true;
  }

  Future<void> updateProfile({required String displayName, required String phoneNumber}) async {
    _displayName = displayName;
    _phoneNumber = phoneNumber;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_display_name', displayName);
    await prefs.setString('auth_phone_number', phoneNumber);
  }
}
