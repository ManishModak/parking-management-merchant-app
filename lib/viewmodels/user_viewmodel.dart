import 'package:flutter/material.dart';
import 'package:merchant_app/models/user_model.dart';
import 'package:merchant_app/services/storage/secure_storage_service.dart';
import 'package:merchant_app/services/core/user_service.dart';

class UserViewModel extends ChangeNotifier {
  final UserService _userService;
  final SecureStorageService _secureStorageService = SecureStorageService();

  String? _error;
  User? currentUser;
  List<User> _users = [];
  bool _isLoading = false;

  // Public getters
  User? get currentOperator => currentUser;
  List<User> get operators => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  UserViewModel(this._userService);



  Future<void> fetchUserList(String userId) async {
    try {
      _setLoading(true);
      _users = await _userService.getUserList();
      // Remove user with ID 47 from the list
      _users = _users.where((user) => user.id != '47').toList();
      _error = null;
    } catch (e) {
      print('Failed to fetch operators: ${e.toString()}');
      _setError('Failed to fetch operators: ${e.toString()}');
      _users = []; // Reset users list on error
    } finally {
      _setLoading(false);
    }
  }

  void clearUserImages() {
    // userImages.clear();
    notifyListeners();
  }


  Future<void> fetchUser({required String userId,required bool isCurrentAppUser}) async {
    try {
      _setLoading(true);
      final cachedUserData = await _secureStorageService.getUserData();
      if (cachedUserData != null && isCurrentAppUser) {
        currentUser = User.fromJson(cachedUserData);
        print("STORAGE CALL");
        print(currentUser.toString());
      } else {
        currentUser = await _userService.fetchUserInfo(userId,isCurrentAppUser);
        print("API CALL");
        print(currentUser.toString());
      }
      _error = null;
    } catch (e) {
      _setError('Failed to load user profile: ${e.toString()}');
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
    required bool isCurrentAppUser
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
        subEntity: subEntity
      );

      if (success) {
        currentUser = await _userService.fetchUserInfo(currentUser!.id,isCurrentAppUser);
        _error = null;
        return true;
      } else {
        throw Exception('Update failed');
      }
    } catch (e) {
      _setError('Failed to update user: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String userId, String newPassword) async {
    try {
      _setLoading(true);
      _error = null;

      if (userId.isEmpty) {
        throw Exception('User ID is required');
      }

      final success = await _userService.resetPassword(userId, newPassword);

      if (success) {
        return true;
      } else {
        throw Exception('Password reset failed');
      }
    } catch (e) {
      _setError('Failed to reset password: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
}