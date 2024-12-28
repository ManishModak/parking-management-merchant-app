class ApiConfig {
  // Base URL of your backend
  static const String baseUrl = 'http://192.168.1.100:3002/users';

  // Authentication endpoints
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/createUser';
  static const String getUserEndpoint = '/getUser/'; // Needs to be concatenated with user ID
  static const String updateProfileEndpoint = '/updateUser/'; // Needs to be concatenated with user ID
  static const String deleteUserEndpoint = '/deleteUser/'; // Needs to be concatenated with user ID
  static const String userListEndpoint = '/userList';

  // Password reset endpoints
  //static const String requestPasswordResetEndpoint = '/users/request-password-reset';
  static const String resetPasswordEndpoint = '/reset-password';
}