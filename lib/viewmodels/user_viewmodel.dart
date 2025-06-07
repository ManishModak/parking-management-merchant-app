import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:merchant_app/models/plaza.dart';
import 'package:merchant_app/models/user_model.dart';
import 'package:merchant_app/services/core/plaza_service.dart';
import 'package:merchant_app/services/core/user_service.dart';
import 'package:merchant_app/services/security/otp_verification_service.dart';
import 'package:merchant_app/services/storage/secure_storage_service.dart';
import 'package:merchant_app/utils/exceptions.dart';
import 'package:merchant_app/utils/validation.dart';

class UserViewModel extends ChangeNotifier {
  final UserService _userService;
  final PlazaService _plazaService;
  final SecureStorageService _secureStorageService;
  final VerificationService _verificationService;

  UserViewModel({
    UserService? userService,
    PlazaService? plazaService,
    SecureStorageService? secureStorageService,
    VerificationService? verificationService,
  })  : _userService = userService ?? UserService(),
        _plazaService = plazaService ?? PlazaService(),
        _secureStorageService = secureStorageService ?? SecureStorageService(),
        _verificationService = verificationService ?? VerificationService();

  User? _currentUser;
  User? _currentOperator;
  List<User> _users = [];
  List<Plaza> _userPlazas = [];
  bool _isLoading = false;
  Exception? _error;
  final Map<String, String> _errors = {};

  // Getters
  User? get currentUser => _currentUser;
  User? get currentOperator => _currentOperator;
  List<User> get users => _users;
  List<Plaza> get userPlazas => _userPlazas;
  bool get isLoading => _isLoading;
  Exception? get error => _error;
  String? getError(String field) => _errors[field];

  // State Management
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String field, String error) {
    _errors[field] = error;
    notifyListeners();
  }

  void clearError(String field) {
    _errors.remove(field);
    notifyListeners();
  }

  void clearErrors() {
    _errors.clear();
    notifyListeners();
  }

  /// Fetches the current user's data without caching.
  Future<void> fetchCurrentUser(String userId) async {
    try {
      _setLoading(true);
      _error = null;
      _currentUser = await _userService.fetchUserInfo(userId, true);
      developer.log('Fetched current user: ${_currentUser?.id}',
          name: 'UserViewModel');
    } on NoInternetException catch (e) {
      _error = e;
      developer.log('No internet: $e', name: 'UserViewModel');
    } on RequestTimeoutException catch (e) {
      _error = e;
      developer.log('Request timeout: $e', name: 'UserViewModel');
    } on HttpException catch (e) {
      _error = e;
      developer.log('HTTP error: $e', name: 'UserViewModel');
    } catch (e) {
      _error = ServiceException('Failed to fetch user: $e');
      developer.log('Unexpected error: $e', name: 'UserViewModel');
    } finally {
      _setLoading(false);
    }
  }

  /// Fetches user data and associated plazas based on the user's role.
  Future<void> fetchUser({
    required String userId,
    required bool isCurrentAppUser,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      final user = await _userService.fetchUserInfo(userId, isCurrentAppUser);
      if (isCurrentAppUser) {
        _currentUser = user;
      } else {
        _currentOperator = user;
      }

      // Populate _userPlazas based on role
      if (user.role == 'Plaza Owner') {
        _userPlazas = await _plazaService.fetchUserPlazas(user.entityId!);
      } else if (user.subEntity.isNotEmpty) {
        // Use subEntity objects from response
        _userPlazas = user.subEntity.map((subEntityItem) {
          final data = subEntityItem as Map<String, dynamic>;
          return Plaza(
            plazaId: data['plazaId'].toString(),
            plazaName: data['plazaName'] ?? 'Unnamed Plaza',
          );
        }).toList();
      } else {
        _userPlazas = [];
      }

      developer.log(
          'Fetched user: ${isCurrentAppUser ? 'Current user' : 'Operator'} ${user.name}, plazas: ${_userPlazas.length}',
          name: 'UserViewModel');
    } on NoInternetException catch (e) {
      _error = e;
      developer.log('No internet: $e', name: 'UserViewModel');
    } on RequestTimeoutException catch (e) {
      _error = e;
      developer.log('Request timeout: $e', name: 'UserViewModel');
    } on HttpException catch (e) {
      _error = e;
      developer.log('HTTP error: $e', name: 'UserViewModel');
    } catch (e) {
      _error = ServiceException('Failed to fetch user: $e');
      developer.log('Unexpected error: $e', name: 'UserViewModel');
    } finally {
      _setLoading(false);
    }
  }

  /// Fetches plazas for the current app user based on their role.
  Future<void> fetchPlazasForCurrentUser() async {
    try {
      _setLoading(true);
      _error = null;

      final role = await _secureStorageService.getUserRole();
      final userId = await _secureStorageService.getUserId();
      if (userId == null) {
        throw ServiceException('No user ID found for current user');
      }

      if (_currentUser == null) {
        await fetchCurrentUser(userId);
      }

      if (role == 'Plaza Owner') {
        if (_currentUser?.entityId == null) {
          throw ServiceException('No entity ID found for Plaza Owner');
        }
        _userPlazas =
        await _plazaService.fetchUserPlazas(_currentUser!.entityId!);
      } else if (_currentUser != null && _currentUser!.subEntity.isNotEmpty) {
        // Use subEntity objects from response
        _userPlazas = _currentUser!.subEntity.map((subEntityItem) {
          final data = subEntityItem as Map<String, dynamic>;
          return Plaza(
            plazaId: data['plazaId'].toString(),
            plazaName: data['plazaName'] ?? 'Unnamed Plaza',
          );
        }).toList();
      } else {
        _userPlazas = [];
      }

      developer.log(
          'Fetched ${_userPlazas.length} plazas for current user (role: $role)',
          name: 'UserViewModel');
    } on NoInternetException catch (e) {
      _error = e;
      developer.log('No internet: $e', name: 'UserViewModel');
    } on RequestTimeoutException catch (e) {
      _error = e;
      developer.log('Request timeout: $e', name: 'UserViewModel');
    } on HttpException catch (e) {
      _error = e;
      developer.log('HTTP error: $e', name: 'UserViewModel');
    } catch (e) {
      _error = ServiceException('Failed to fetch plazas: $e');
      developer.log('Unexpected error: $e', name: 'UserViewModel');
    } finally {
      _setLoading(false);
    }
  }

  /// Prepares available plazas for editing a user's sub-entity based on the current app user's role.
  Future<void> prepareForUserEdit() async {
    try {
      _setLoading(true);
      _error = null;

      final role = await _secureStorageService.getUserRole();
      final userId = await _secureStorageService.getUserId();
      if (userId == null) {
        throw ServiceException('No user ID found for current user');
      }

      if (_currentUser == null) {
        await fetchCurrentUser(userId);
      }

      if (role == 'Plaza Owner') {
        if (_currentUser?.entityId == null) {
          throw ServiceException('No entity ID found for Plaza Owner');
        }
        _userPlazas =
        await _plazaService.fetchUserPlazas(_currentUser!.entityId!);
      } else if (_currentUser != null && _currentUser!.subEntity.isNotEmpty) {
        // Use subEntity objects from response
        _userPlazas = _currentUser!.subEntity.map((subEntityItem) {
          final data = subEntityItem as Map<String, dynamic>;
          return Plaza(
            plazaId: data['plazaId'].toString(),
            plazaName: data['plazaName'] ?? 'Unnamed Plaza',
          );
        }).toList();
      } else {
        _userPlazas = [];
      }

      developer.log(
          'Prepared for user edit: plazas=${_userPlazas.length}, role=$role',
          name: 'UserViewModel');
    } catch (e) {
      _error = e as Exception?;
      developer.log('Error preparing for user edit: $e',
          name: 'UserViewModel', error: e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Fetches the list of users for a given entity ID.
  Future<void> fetchUserList(String entityId) async {
    try {
      _setLoading(true);
      _error = null;
      _users = await _userService.getUsersList();
      developer.log('Fetched ${_users.length} users for entity: $entityId',
          name: 'UserViewModel');
    } on NoInternetException catch (e) {
      _error = e;
      developer.log('No internet: $e', name: 'UserViewModel');
    } on RequestTimeoutException catch (e) {
      _error = e;
      developer.log('Request timeout: $e', name: 'UserViewModel');
    } on HttpException catch (e) {
      _error = e;
      developer.log('HTTP error: $e', name: 'UserViewModel');
    } catch (e) {
      _error = ServiceException('Failed to fetch users: $e');
      developer.log('Unexpected error: $e', name: 'UserViewModel');
    } finally {
      _setLoading(false);
    }
  }

  /// Verifies a mobile number by sending an OTP.
  Future<bool> verifyMobileNumber(String mobileNumber,
      {required String errorMobileInUse}) async {
    try {
      _setLoading(true);
      _error = null;
      clearError('mobile');
      await _verificationService.sendOtp(mobileNumber);
      developer.log('OTP sent to: $mobileNumber', name: 'UserViewModel');
      return true;
    } on MobileNumberInUseException catch (e) {
      setError('mobile', errorMobileInUse);
      developer.log('Mobile number in use: $mobileNumber',
          name: 'UserViewModel', error: e);
      return false;
    } catch (e) {
      _error = ServiceException('Failed to send OTP: $e');
      setError('mobile', 'Failed to send OTP. Please try again.');
      developer.log('Unexpected error: $e', name: 'UserViewModel');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Verifies the OTP for a mobile number.
  Future<bool> verifyOtp(String mobileNumber, String otp) async {
    try {
      _setLoading(true);
      _error = null;
      clearError('otp');
      final result = await _verificationService.verifyOtp(
          mobileNumber: mobileNumber, otp: otp);
      if (!result.success) {
        setError('otp', 'Invalid OTP. Please try again.');
        return false;
      }
      developer.log('OTP verified for: $mobileNumber', name: 'UserViewModel');
      return true;
    } catch (e) {
      _error = ServiceException('Failed to verify OTP: $e');
      setError('otp', 'Failed to verify OTP. Please try again.');
      developer.log('Unexpected error: $e', name: 'UserViewModel');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Registers a new user.
  Future<bool> registerUser({
    required String username,
    required String email,
    required String mobileNumber,
    required String password,
    required String city,
    required String state,
    required String address,
    required String pincode,
    required bool isAppUserRegister,
    String? role,
    String? entity,
    List<String>? subEntity,
    String? entityId,
  }) async {
    try {
      _setLoading(true);
      _error = null;
      clearErrors();

      // Validate role
      final currentUserRole = await _secureStorageService.getUserRole();
      final allowedRoles = {
        'Plaza Owner': [
          'Plaza Owner',
          'Centralized Controller',
          'Plaza Admin',
          'Plaza Operator',
          'Cashier',
          'Backend Monitoring Operator',
          'Supervisor'
        ],
        'Plaza Admin': [
          'Plaza Operator',
          'Cashier',
          'Backend Monitoring Operator',
          'Supervisor'
        ],
      }[currentUserRole] ??
          [];
      if (role != null && !allowedRoles.contains(role)) {
        throw ServiceException('Unauthorized role assignment: $role');
      }

      // Validate entityId
      final currentEntityId = await _secureStorageService.getEntityId();
      if (entityId != null && entityId != currentEntityId) {
        throw ServiceException('Unauthorized entity assignment: $entityId');
      }

      // Validate subEntity
      if (role != 'Plaza Owner' &&
          role != 'Centralized Controller' &&
          (subEntity == null || subEntity.length != 1)) {
        throw ServiceException(
            'Exactly one sub-entity is required for role: $role');
      }
      if (role == 'Centralized Controller' &&
          (subEntity == null || subEntity.isEmpty)) {
        throw ServiceException(
            'At least one sub-entity is required for Centralized Controller');
      }

      final userData = await _userService.userRegister(
        username: username,
        email: email,
        mobileNumber: mobileNumber,
        password: password,
        city: city,
        state: state,
        address: address,
        pincode: pincode,
        isAppUserRegister: isAppUserRegister,
        role: role,
        entity: entity,
        subEntity: subEntity,
        entityId: entityId,
      );

      if (isAppUserRegister) {
        _currentUser = User.fromJson(userData);
      }

      developer.log('User registered: $username', name: 'UserViewModel');
      return true;
    } on EmailInUseException catch (e) {
      setError('email', 'Email is already in use');
      developer.log('Email in use: $email', name: 'UserViewModel', error: e);
      return false;
    } on NoInternetException catch (e) {
      _error = e;
      developer.log('No internet: $e', name: 'UserViewModel');
      return false;
    } on RequestTimeoutException catch (e) {
      _error = e;
      developer.log('Request timeout: $e', name: 'UserViewModel');
      return false;
    } on HttpException catch (e) {
      _error = e;
      setError('generic', e.serverMessage ?? 'Registration failed');
      developer.log('HTTP error: $e', name: 'UserViewModel');
      return false;
    } catch (e) {
      _error = ServiceException('Failed to register user: $e');
      setError('generic', 'Unexpected error during registration');
      developer.log('Unexpected error: $e', name: 'UserViewModel');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates an existing user's information.
  Future<bool> updateUser({
    required String userId,
    required String username,
    required String email,
    String? mobileNumber,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? role,
    List<String>? subEntity,
    required bool isCurrentAppUser,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      // Validate role
      final currentUserRole = await _secureStorageService.getUserRole();
      final allowedRoles = {
        'Plaza Owner': [
          'Plaza Owner',
          'Centralized Controller',
          'Plaza Admin',
          'Plaza Operator',
          'Cashier',
          'Backend Monitoring Operator',
          'Supervisor'
        ],
        'Plaza Admin': [
          'Plaza Operator',
          'Cashier',
          'Backend Monitoring Operator',
          'Supervisor'
        ],
      }[currentUserRole] ??
          [];
      if (role != null && !allowedRoles.contains(role)) {
        throw ServiceException('Unauthorized role assignment: $role');
      }

      // Validate subEntity
      if (role != null) {
        if (role == 'Plaza Owner' &&
            subEntity != null &&
            subEntity.isNotEmpty) {
          throw ServiceException('Sub-entity must be null for Plaza Owner');
        }
        if (role != 'Plaza Owner' &&
            role != 'Centralized Controller' &&
            (subEntity == null || subEntity.length != 1)) {
          throw ServiceException(
              'Exactly one sub-entity is required for role: $role');
        }
        if (role == 'Centralized Controller' &&
            (subEntity == null || subEntity.isEmpty)) {
          throw ServiceException(
              'At least one sub-entity is required for Centralized Controller');
        }
      }

      final success = await _userService.updateUserInfo(
        userId,
        username: username,
        email: email,
        mobileNumber: mobileNumber,
        address: address,
        city: city,
        state: state,
        pincode: pincode,
        role: role,
        subEntity: role == 'Plaza Owner' ? null : subEntity,
      );

      if (success) {
        if (isCurrentAppUser) {
          _currentUser = User(
            id: userId,
            name: username,
            email: email,
            role: role ?? _currentUser?.role ?? '',
            imageUrl: _currentUser?.imageUrl ?? '',
            mobileNumber: mobileNumber ?? _currentUser?.mobileNumber ?? '',
            address: address,
            city: city,
            state: state,
            pincode: pincode,
            entityName: _currentUser?.entityName,
            entityId: _currentUser?.entityId,
            subEntity: subEntity ?? _currentUser?.subEntity ?? [],
          );
        } else {
          _currentOperator = User(
            id: userId,
            name: username,
            email: email,
            role: role ?? _currentOperator?.role ?? '',
            imageUrl: _currentOperator?.imageUrl ?? '',
            mobileNumber: mobileNumber ?? _currentOperator?.mobileNumber ?? '',
            address: address,
            city: city,
            state: state,
            pincode: pincode,
            entityName: _currentOperator?.entityName,
            entityId: _currentOperator?.entityId,
            subEntity: subEntity ?? _currentOperator?.subEntity ?? [],
          );
        }
      }

      developer.log('User updated: $userId', name: 'UserViewModel');
      return success;
    } on EmailInUseException catch (e) {
      setError('email', 'Email is already in use');
      developer.log('Email in use: $email', name: 'UserViewModel', error: e);
      return false;
    } on NoInternetException catch (e) {
      _error = e;
      developer.log('No internet: $e', name: 'UserViewModel');
      return false;
    } on RequestTimeoutException catch (e) {
      _error = e;
      developer.log('Request timeout: $e', name: 'UserViewModel');
      return false;
    } on HttpException catch (e) {
      _error = e;
      setError('generic', e.serverMessage ?? 'Update failed');
      developer.log('HTTP error: $e', name: 'UserViewModel');
      return false;
    } catch (e) {
      _error = ServiceException('Failed to update user: $e');
      setError('generic', 'Unexpected error during update');
      developer.log('Unexpected error: $e', name: 'UserViewModel');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Resets a user's password.
  Future<bool> resetPassword(String userId, String newPassword) async {
    try {
      _setLoading(true);
      _error = null;
      clearErrors();

      // Validate role permissions
      final currentUserRole = await _secureStorageService.getUserRole();
      final user = await _userService.fetchUserInfo(userId, false);
      final allowedRoles = {
        'Plaza Owner': [
          'Plaza Owner',
          'Centralized Controller',
          'Plaza Admin',
          'Plaza Operator',
          'Cashier',
          'Backend Monitoring Operator',
          'Supervisor'
        ],
        'Plaza Admin': [
          'Plaza Operator',
          'Cashier',
          'Backend Monitoring Operator',
          'Supervisor'
        ],
      }[currentUserRole] ??
          [];
      if (!allowedRoles.contains(user.role)) {
        throw ServiceException(
            'Unauthorized to reset password for role: ${user.role}');
      }

      final success = await _userService.resetPassword(userId, newPassword);
      developer.log('Password reset for user: $userId', name: 'UserViewModel');
      return success;
    } on NoInternetException catch (e) {
      _error = e;
      developer.log('No internet: $e', name: 'UserViewModel');
      return false;
    } on RequestTimeoutException catch (e) {
      _error = e;
      developer.log('Request timeout: $e', name: 'UserViewModel');
      return false;
    } on HttpException catch (e) {
      _error = e;
      setError('generic', e.serverMessage ?? 'Password reset failed');
      developer.log('HTTP error: $e', name: 'UserViewModel');
      return false;
    } catch (e) {
      _error = ServiceException('Failed to reset password: $e');
      setError('generic', 'Unexpected error during password reset');
      developer.log('Unexpected error: $e', name: 'UserViewModel');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Validation Methods
  Map<String, String> validateRegistration({
    required String username,
    required String email,
    required String mobile,
    required String city,
    required String state,
    required String address,
    required String pincode,
    required String password,
    required String confirmPassword,
    required bool isMobileVerified,
    String? role,
    String? entity,
    String? subEntity,
  }) {
    final errors = <String, String>{};

    if (username.isEmpty) {
      errors['username'] = 'Username is required';
    } else if (!Validation.isValidUsername(username)) {
      errors['username'] = 'Username must be at least 3 characters';
    }

    if (email.isEmpty) {
      errors['email'] = 'Email is required';
    } else if (!Validation.isValidEmail(email)) {
      errors['email'] = 'Invalid email format';
    }

    if (mobile.isEmpty) {
      errors['mobile'] = 'Mobile number is required';
    } else if (!Validation.isValidMobile(mobile)) {
      errors['mobile'] = 'Invalid mobile number';
    } else if (!isMobileVerified) {
      errors['mobile'] = 'Mobile number must be verified';
    }

    if (city.isEmpty) {
      errors['city'] = 'City is required';
    }

    if (state.isEmpty) {
      errors['state'] = 'State is required';
    }

    if (address.isEmpty) {
      errors['address'] = 'Address is required';
    }

    if (pincode.isEmpty) {
      errors['pincode'] = 'Pincode is required';
    } else if (!Validation.isValidPincode(pincode)) {
      errors['pincode'] = 'Invalid pincode format';
    }

    if (password.isEmpty) {
      errors['password'] = 'Password is required';
    } else if (!Validation.isValidPassword(password)) {
      errors['password'] =
      'Password must be at least 8 characters with uppercase, lowercase, number, and special character';
    }

    if (confirmPassword.isEmpty) {
      errors['confirmPassword'] = 'Confirm password is required';
    } else if (password != confirmPassword) {
      errors['confirmPassword'] = 'Passwords do not match';
    }

    if (role == null || role.isEmpty) {
      errors['role'] = 'Role is required';
    }

    if (entity == null || entity.isEmpty) {
      errors['entity'] = 'Entity is required';
    }

    if (role != 'Plaza Owner' &&
        role != 'Centralized Controller' &&
        (subEntity == null || subEntity.isEmpty)) {
      errors['subEntity'] =
      'Exactly one sub-entity is required for role: $role';
    }
    if (role == 'Centralized Controller' &&
        (subEntity == null || subEntity.isEmpty)) {
      errors['subEntity'] =
      'At least one sub-entity is required for Centralized Controller';
    }

    return errors;
  }

  Map<String, String> validateUpdate({
    required String username,
    required String email,
    required String mobile,
    required String address,
    required String city,
    required String state,
    required String pincode,
    required bool isMobileVerified,
    String? originalMobile,
    String? role,
    String? subEntity,
    required bool isProfile,
  }) {
    final errors = <String, String>{};

    if (username.isEmpty) {
      errors['username'] = 'Username is required';
    } else if (!Validation.isValidUsername(username)) {
      errors['username'] = 'Username must be at least 3 characters';
    }

    if (email.isEmpty) {
      errors['email'] = 'Email is required';
    } else if (!Validation.isValidEmail(email)) {
      errors['email'] = 'Invalid email format';
    }

    if (mobile.isEmpty) {
      errors['mobile'] = 'Mobile number is required';
    } else if (!Validation.isValidMobile(mobile)) {
      errors['mobile'] = 'Invalid mobile number';
    } else if (mobile != originalMobile && !isMobileVerified) {
      errors['mobile'] = 'Mobile number must be verified';
    }

    if (city.isEmpty) {
      errors['city'] = 'City is required';
    }

    if (state.isEmpty) {
      errors['state'] = 'State is required';
    }

    if (address.isEmpty) {
      errors['address'] = 'Address is required';
    }

    if (pincode.isEmpty) {
      errors['pincode'] = 'Pincode is required';
    } else if (!Validation.isValidPincode(pincode)) {
      errors['pincode'] = 'Invalid pincode format';
    }

    if (!isProfile) {
      if (role == null || role.isEmpty) {
        errors['role'] = 'Role is required';
      }
      if (role != 'Plaza Owner' &&
          role != 'Centralized Controller' &&
          (subEntity == null || subEntity.isEmpty)) {
        errors['subEntity'] =
        'Exactly one sub-entity is required for role: $role';
      }
      if (role == 'Centralized Controller' &&
          (subEntity == null || subEntity.isEmpty)) {
        errors['subEntity'] =
        'At least one sub-entity is required for Centralized Controller';
      }
    }

    return errors;
  }

  Map<String, String> validateResetPassword({
    required String password,
    required String confirmPassword,
  }) {
    final errors = <String, String>{};

    if (password.isEmpty) {
      errors['password'] = 'Password is required';
    } else if (!Validation.isValidPassword(password)) {
      errors['password'] =
      'Password must be at least 8 characters with uppercase, lowercase, number, and special character';
    }

    if (confirmPassword.isEmpty) {
      errors['confirmPassword'] = 'Confirm password is required';
    } else if (password != confirmPassword) {
      errors['confirmPassword'] = 'Passwords do not match';
    }

    return errors;
  }

  Map<String, String> validateMobile(String mobile) {
    final errors = <String, String>{};

    if (mobile.isEmpty) {
      errors['mobile'] = 'Mobile number is required';
    } else if (!Validation.isValidMobile(mobile)) {
      errors['mobile'] = 'Invalid mobile number';
    }

    return errors;
  }
}