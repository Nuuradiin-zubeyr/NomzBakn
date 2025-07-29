import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

class AppAuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userEmail;
  String? _userName;

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;
  String? get userName => _userName;

  AppAuthProvider() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email');
      final password = prefs.getString('user_password');
      final name = prefs.getString('user_name');
      
      if (email != null && password != null) {
        _isLoggedIn = true;
        _userEmail = email;
        _userName = name;
      } else {
        _isLoggedIn = false;
        _userEmail = null;
        _userName = null;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error checking login status: $e');
      _isLoggedIn = false;
      notifyListeners();
    }
  }

  Future<bool> validateLogin(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('user_email');
      final savedPassword = prefs.getString('user_password');
      final savedName = prefs.getString('user_name');
      
      if (savedEmail == null || savedPassword == null) {
        return false;
      }
      
      return savedEmail == email && savedPassword == password;
    } catch (e) {
      debugPrint('Error validating login: $e');
      return false;
    }
  }

  Future<void> login(String email, String password, String name, {String? phone, File? profileImage}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      await prefs.setString('user_password', password);
      await prefs.setString('user_name', name);
      await prefs.setString('profile_name', name);
      await prefs.setString('profile_email', email);
      if (phone != null) {
        await prefs.setString('profile_phone', phone);
      }
      if (profileImage != null) {
        final bytes = await profileImage.readAsBytes();
        final base64Image = base64Encode(bytes);
        await prefs.setString('profile_image', base64Image);
      }
      _isLoggedIn = true;
      _userEmail = email;
      _userName = name;
      notifyListeners();
    } catch (e) {
      debugPrint('Error during login: $e');
      throw Exception('Login failed');
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      _isLoggedIn = false;
      _userEmail = null;
      _userName = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  Future<void> refreshLoginStatus() async {
    await _checkLoginStatus();
  }
} 