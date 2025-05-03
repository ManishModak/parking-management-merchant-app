// API Configuration
class ApiConfig {
  //static const String baseUrl = 'http://13.201.218.178:3001/';
  static const String baseUrl = 'http://192.168.0.107:3001/';
  static Duration defaultTimeout = const Duration(seconds: 15);
  static Duration longTimeout = const Duration(seconds: 30);

  // Helper method to construct full URL from an endpoint
  static String getFullUrl(String endpoint) {
    return baseUrl + endpoint;
  }
}

// Authentication and User Management
class AuthApi {
  static const String basePath = 'users/';

  // General user endpoints
  static const String login = '${basePath}login'; // POST: User login
  static const String register = '${basePath}createUser'; // POST: Register a new user
  static const String getUser = '${basePath}getUser/'; // GET: Retrieve user details by ID
  static const String updateProfile = '${basePath}updateUser/'; // PUT: Update user profile
  static const String deleteUser = '${basePath}deleteUser/'; // DELETE: Delete a user by ID
  static const String userList = '${basePath}userList'; // GET: List all users
  static const String getUsersByEntity = '${basePath}entity/'; // GET: List users by entity
  static const String resetPassword = '${basePath}reset-password'; // POST: Request password reset

  // Plaza owner specific endpoints
  static const String ownerBasePath = '${basePath}owner/';
  static const String createOwner = '${ownerBasePath}createOwner'; // POST: Create a new plaza owner
  static const String mobileVerification = '${ownerBasePath}mobileVerification'; // POST: Verify mobile number
  static const String verifyOtp = '${ownerBasePath}verification'; // POST: Verify OTP
  static const String getOwner = '${ownerBasePath}getOwner'; // GET: Retrieve owner details
  static const String getOwnerByEmail = '${ownerBasePath}getOwnerByEmail'; // GET: Retrieve owner by email
  static const String updateOwner = '${ownerBasePath}updateOwner'; // PUT: Update owner details
  static const String deleteOwner = '${ownerBasePath}deleteUser'; // DELETE: Delete an owner
  static const String ownerList = '${ownerBasePath}ownersList'; // GET: List all owners
}

// Plaza Management
class PlazaApi {
  static const String basePath = 'plaza/';

  // Core plaza endpoints
  static const String create = '${basePath}register'; // POST: Register a new plaza
  static const String getAllOwners = '${basePath}owners/list'; // GET: List all plaza owners
  static const String getByOwnerId = '${basePath}export/'; // GET: Retrieve plaza by owner ID
  static const String get = basePath; // GET: Retrieve plaza details
  static const String update = '${basePath}update/'; // PUT: Update plaza details
  static const String delete = '${basePath}delete/'; // DELETE: Delete a plaza

  // Lane management
  static const String laneBasePath = '${basePath}lane/';
  static const String createLane = '${laneBasePath}addLane'; // POST: Add a new lane
  static const String getLane = '${laneBasePath}getLane'; // GET: Retrieve lane details
  static const String getLanesByPlaza = '${laneBasePath}getLaneByPlazaId'; // GET: List lanes by plaza ID
  static const String updateLane = '${laneBasePath}laneupdate/'; // PUT: Update lane details

  // Bank details
  static const String bankBasePath = '${basePath}bank/';
  static const String addBankDetails = '${bankBasePath}addbankdetails'; // POST: Add bank details
  static const String getBankByPlaza = '${bankBasePath}pid'; // GET: Retrieve bank details by plaza ID
  static const String getBankById = '${bankBasePath}id'; // GET: Retrieve bank details by ID
  static const String updateBank = '${bankBasePath}update'; // PUT: Update bank details
  static const String deleteBank = '${bankBasePath}delete'; // DELETE: Delete bank details

  // Image management
  static const String imagesBasePath = '${basePath}images/';
  static const String uploadSingleImage = '${imagesBasePath}uploadImage'; // POST: Upload a single image
  static const String uploadMultipleImages = '${imagesBasePath}upload'; // POST: Upload multiple images
  static const String getImagesByPlaza = '${imagesBasePath}getImages'; // GET: Retrieve images by plaza ID
  static const String deleteImage = '${imagesBasePath}deleteImage/'; // DELETE: Delete an image by ID

  // Fare management
  static const String fareBasePath = '${basePath}fare/';
  static const String addFare = fareBasePath; // POST: Add fare details
  static const String getFaresByPlaza = '${fareBasePath}id/'; // GET: Retrieve fares by plaza ID
  static const String getFareById = '${fareBasePath}getFare'; // GET: Retrieve fare details by ID
  static const String updateFare = '${fareBasePath}update/'; // PUT: Update fare details
  static const String deleteFare = '${fareBasePath}delete'; // DELETE: Delete fare details
}

// Ticket Management
class TicketApi {
  static const String basePath = 'plaza/api/tickets/';
  static const String vehicleBasePath = 'ticket/api/vehicle/';
  static const String newTicketBasePath = 'ticket/api/tickets/'; // New base path for newTicket

  // Ticket operations
  static const String getOpenTickets = '${basePath}open-tickets'; // GET: List all open tickets
  static const String getAllTickets = '${basePath}all-tickets'; // GET: List all tickets
  static const String createTicket = '${basePath}create'; // POST: Create a new ticket (existing)
  static const String newTicket = '${newTicketBasePath}newTicket'; // POST: New ticket endpoint
  static const String getTicketDetails = '${basePath}ticketDetails/'; // GET: Retrieve ticket details by ID
  static const String rejectTicket = '${basePath}reject-ticket/'; // POST: Reject a ticket
  static const String modifyTicket = '${basePath}modify-ticket/'; // PUT: Modify ticket details

  // Vehicle operations
  static const String markVehicleExit = '${vehicleBasePath}exit/'; // POST: Mark vehicle exit
}


// Disputes Management
class DisputesApi {
  static const String basePath = 'transactions/disputes/';

  // Create a dispute
  static const String createDispute = '${basePath}create'; // POST: Create a new dispute

  // Get all open disputes
  static const String getAllOpenDisputes = '${basePath}all'; // GET: List all open disputes

  // Get open dispute by dispute ID
  static const String getDisputeById = '${basePath}getById'; // GET: Retrieve dispute by dispute ID

  // Get open disputes by plaza ID
  static const String getDisputesByPlaza = '${basePath}getByPlaza'; // GET: List disputes by plaza ID

  // Get open disputes by ticket ID
  static const String getDisputesByTicket = '${basePath}getByTicket'; // GET: List disputes by ticket ID

  // Get open disputes by vehicle number
  static const String getDisputesByVehicleNumber = '${basePath}getByVehicleNumber'; // GET: List disputes by vehicle number

  // Get open disputes by date range
  static const String getDisputesByDate = '${basePath}getByDate'; // POST: List disputes by date range

  // Process a dispute
  static const String processDispute = '${basePath}processDispute'; // POST: Process an existing dispute
}


// Dashboard Management
class DashboardApi {
  static const String basePath = '';

  // Plaza-wise Booking Summary
  static const String getPlazaBookings = 'plaza-bookings'; // GET: Fetch plaza booking statistics

  // Plaza Details
  static const String getPlazaDetails = 'plazaDetails'; // GET: Fetch plaza details and slot information
}

// Transactions Management
class TransactionsApi {
  static const String basePath = 'transactions/payment/';

  static const String createOrderQrCode = '${basePath}create-order-Qr-code'; // POST: Generate QR code for an order
}