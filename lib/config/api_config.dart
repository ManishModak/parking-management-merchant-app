class ApiConfig {
  // Base URL
  static const String apiGateway = 'http://192.168.1.15:5000/';

  // Authentication endpoints
  static const String loginEndpoint = 'users/login';
  static const String registerEndpoint = 'users/createUser';
  static const String getUserEndpoint = 'users/getUser/';
  static const String updateProfileEndpoint = 'users/updateUser/';
  static const String deleteUserEndpoint = 'users/deleteUser/';
  static const String userListEndpoint = 'users/userList';
  static const String getUsersByEntityEndpoint = 'users/getUsersByEntity/';

  // Password reset endpoints
  static const String resetPasswordEndpoint = 'users/reset-password';

  // Plaza endpoints
  static const String createPlazaEndpoint = 'plaza/register';
  static const String getAllPlazaOwnersEndpoint = 'plaza/owners/list';
  static const String getPlazaByOwnerIdEndpoint = 'plaza/export/';
  static const String getPlazaEndpoint = 'plaza/';
  static const String updatePlazaEndpoint = 'plaza/update/';
  static const String deletePlazaEndpoint = 'plaza/delete/';

  // Lane endpoints
  static const String createLaneEndpoint = 'plaza/lane/addLane';
  static const String getLaneByIdEndpoint = 'plaza/lane/getLane';
  static const String getLanesByPlazaIdEndpoint = 'plaza/lane/getLaneByPlazaId';
  static const String updateLaneEndpoint = 'plaza/lane/laneupdate/';

  // Bank details endpoints
  static const String addBankDetailsEndpoint = 'plaza/bank/addbankdetails';
  static const String getBankDetailsByPlazaIdEndpoint = 'plaza/bank/pid';
  static const String getBankDetailsByIdEndpoint = 'plaza/bank/id';
  static const String updateBankDetailsEndpoint = 'plaza/bank/update';
  static const String deleteBankDetailsEndpoint = 'plaza/bank/delete';

  // Image endpoints
  static const String uploadSingleImageEndpoint = 'plaza/images/uploadImage';
  static const String uploadMultipleImagesEndpoint = 'plaza/images/upload';
  static const String getImagesByPlazaIdEndpoint = 'plaza/images/getImages';
  static const String deleteImageEndpoint = 'plaza/images/deleteImage/';

  // Fare endpoints
  static const String addFareEndpoint = 'plaza/fare/';
  static const String getFaresByPlazaIdEndpoint = 'plaza/fare/id/';
  static const String getFareByIdEndpoint = 'plaza/fare/getFare';
  static const String updateFareEndpoint = 'plaza/fare/update/';
  static const String deleteFareEndpoint = 'plaza/fare/delete';

  // Ticket endpoints
  static const String getOpenTicketsEndpoint = 'plaza/api/tickets/open-tickets';
  static const String createTicketEndpoint = 'plaza/api/tickets/create';
  static const String ticketDetailsEndpoint = 'plaza/api/tickets/ticketDetails/';
  static const String rejectTicketEndpoint = 'plaza/api/tickets/reject-ticket/';
  static const String modifyTicketEndpoint = 'plaza/api/tickets/modify-ticket/';

  // Generic helper method to build complete URLs
  static String getFullUrl(String endpoint) {
    return apiGateway + endpoint;
  }
}