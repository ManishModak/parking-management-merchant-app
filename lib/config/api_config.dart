class ApiConfig {
  // Base URL
  static const String apiGateway = 'http://192.168.1.101:3000/';

  // Authentication endpoints
  static const String loginEndpoint = 'users/login';
  static const String registerEndpoint = 'users/createUser';
  static const String getUserEndpoint = 'users/getUser/'; // Append user ID
  static const String updateProfileEndpoint = 'users/updateUser/'; // Append user ID
  static const String deleteUserEndpoint = 'users/deleteUser/'; // Append user ID
  static const String userListEndpoint = 'users/userList';
  static const String getUsersByEntityEndpoint = 'users/getUsersByEntity/';

  // Password reset endpoints
  static const String resetPasswordEndpoint = 'users/reset-password';

  // Plaza endpoints
  static const String createPlazaEndpoint = 'plaza/register';
  static const String getAllPlazaOwnersEndpoint = 'plaza/owners/list';
  static const String getPlazaByOwnerIdEndpoint = 'plaza/export/'; // Append owner ID
  static const String getPlazaEndpoint = 'plaza/'; // Append plaza ID
  static const String updatePlazaEndpoint = 'plaza/update/'; // Append plaza ID
  static const String deletePlazaEndpoint = 'plaza/delete/'; // Append plaza ID

  // Lane endpoints
  static const String createLaneEndpoint = 'plaza/lane/addLane';
  static const String getLaneByIdEndpoint = 'plaza/lane/getLane'; // Requires laneId query parameter
  static const String getLanesByPlazaIdEndpoint = 'plaza/lane/getLaneByPlazaId'; // Requires plazaId query parameter
  static const String updateLaneEndpoint = 'plaza/lane/laneupdate/'; // Append lane ID

  // Bank details endpoints
  static const String addBankDetailsEndpoint = 'plaza/bank/addbankdetails';
  static const String getBankDetailsByPlazaIdEndpoint = 'plaza/bank/pid'; // Requires plazaId query parameter
  static const String getBankDetailsByIdEndpoint = 'plaza/bank/id'; // Requires id query parameter
  static const String updateBankDetailsEndpoint = 'plaza/bank/update';
  static const String deleteBankDetailsEndpoint = 'plaza/bank/delete'; // Requires id query parameter

  // Image endpoints
  static const String uploadSingleImageEndpoint = 'plaza/images/uploadImage';
  static const String uploadMultipleImagesEndpoint = 'plaza/images/upload';
  static const String getImagesByPlazaIdEndpoint = 'plaza/images/getImages';
  static const String deleteImageEndpoint = 'plaza/images/deleteImage/'; // Append image ID

  // Fare endpoints
  static const String addFareEndpoint = 'plaza/fare/';
  static const String getFaresByPlazaIdEndpoint = 'plaza/fare/id/'; // Requires plazaId query parameter
  static const String getFareByIdEndpoint = 'plaza/fare/getFare'; // Requires fareId query parameter
  static const String updateFareEndpoint = 'plaza/fare/update/';
  static const String deleteFareEndpoint = 'plaza/fare/delete'; // Requires fareId query parameter

  // Helper method to build complete URLs
  static String getFullUrl(String endpoint) {
    return apiGateway + endpoint;
  }
}