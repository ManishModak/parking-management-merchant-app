import 'package:flutter/material.dart';
import 'package:merchant_app/models/user_model.dart';
import 'package:merchant_app/services/storage/secure_storage_service.dart';
import 'package:merchant_app/services/core/user_service.dart';
import 'package:merchant_app/utils/exceptions.dart'; // Import exceptions

class UserViewModel extends ChangeNotifier {
  final UserService _userService;
  final SecureStorageService _secureStorageService = SecureStorageService();

  Exception? _error; // Changed to Exception?
  User? currentUser;
  List<User> _users = [];
  bool _isLoading = false;

  // Public getters
  User? get currentOperator => currentUser;
  List<User> get operators => _users;
  bool get isLoading => _isLoading;
  Exception? get error => _error; // Updated getter

  UserViewModel(this._userService);

  Future<void> fetchUserList(String userId) async {
    try {
      _setLoading(true);
      _users = await _userService.getUserList();
      _users = _users.where((user) => user.id != '47').toList();
      _error = null;
    } catch (e) {
      // Assume UserService throws specific exceptions; rethrow or wrap if needed
      _error = e is Exception ? e : Exception('Failed to fetch operators: $e');
      _users = [];
      print('Failed to fetch operators: $_error');
    } finally {
      _setLoading(false);
    }
  }

  void clearUserImages() {
    notifyListeners();
  }

  Future<void> fetchUser({required String userId, required bool isCurrentAppUser}) async {
    try {
      _setLoading(true);
      final cachedUserData = await _secureStorageService.getUserData();
      if (cachedUserData != null && isCurrentAppUser) {
        currentUser = User.fromJson(cachedUserData);
        print("STORAGE CALL: $currentUser");
      } else {
        currentUser = await _userService.fetchUserInfo(userId, isCurrentAppUser);
        print("API CALL: $currentUser");
      }
      _error = null;
    } catch (e) {
      _error = e is Exception ? e : Exception('Failed to load user profile: $e');
      print('Error: $_error');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateUser({
    required String username,
    required String email,
    String? mobileNumber,
    String? address,
    String? city,
    String? state,
    String? role,
    String? subEntity,
    required bool isCurrentAppUser,
  }) async {
    try {
      _setLoading(true);
      if (currentUser?.id == null) {
        throw Exception('No user selected for update');
      }

      final success = await _userService.updateUserInfo(
        currentUser!.id,
        username: username,
        email: email,
        mobileNumber: mobileNumber,
        address: address,
        city: city,
        state: state,
        role: role,
        subEntity: subEntity,
      );

      if (success) {
        currentUser = await _userService.fetchUserInfo(currentUser!.id, isCurrentAppUser);
        _error = null;
        return true;
      } else {
        throw Exception('Update failed');
      }
    } catch (e) {
      _error = e is Exception ? e : Exception('Failed to update user: $e');
      print('Error: $_error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String userId, String newPassword) async {
    try {
      _setLoading(true);
      if (userId.isEmpty) {
        throw Exception('User ID is required');
      }

      final success = await _userService.resetPassword(userId, newPassword);

      if (success) {
        _error = null;
        return true;
      } else {
        throw Exception('Password reset failed');
      }
    } catch (e) {
      _error = e is Exception ? e : Exception('Failed to reset password: $e');
      print('Error: $_error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(Exception? error) {
    _error = error;
    notifyListeners();
  }
}