class AppStrings {
  // App Info
  static const String appName = 'CityPark';

  // Menu Screen
  static const String menuTitle = 'Menu';

  // Menu Categories
  static const String menuPlazas = 'Plazas';
  static const String menuUsers = 'Users';
  static const String menuDisputes = 'Disputes';
  static const String menuSettings = 'Settings';
  static const String menuPlazaFare = 'Plaza Fares';

  // Menu Items
  static const String menuModifyViewPlaza = 'Modify/View Plaza Details';
  static const String menuRegisterPlaza = 'Register Plaza';
  static const String menuRegisterUser = 'Register User';
  static const String menuModifyViewUser = 'Modify/View User Details';
  static const String menuViewAllDisputes = 'View All Disputes';
  static const String menuManualEntry = 'Manual Entry';
  static const String menuResetPassword = 'Reset Password';
  static const String menuAddPlazaFare = 'Add Plaza Fare';
  static const String menuModifyViewPlazaFare =
      'Modify/View Plaza Fare Details';
  static const String menuTickets = 'Tickets';
  static const String menuNewTicket = 'New Ticket';
  static const String menuOpenTickets = 'Open Tickets';
  static const String menuRejectTicket = 'Reject Ticket';
  static const String menuTicketHistory = 'Ticket History';
  static const String menuMarkExit = 'Mark Exit';

  // Auth & Welcome Messages
  static const String welcomeMessage = 'Welcome To Merchant App';
  static const String loginMessage = 'Welcome Back\nYou\'ve Been Missed!';
  static const String registerMessage =
      'Create An Account \nSo You Can Explore The Platform';
  static const String verificationMessage =
      'We Have Sent The Verification Code To Your Mobile No.';
  static const String loadingMessage =
      'Please wait while we verify your credentials';
  static const String successMessage =
      'Congratulations! You have been\nsuccessfully authenticated';

  // Button Labels
  static const String buttonLogin = 'LOGIN';
  static const String buttonRegister = 'REGISTER';
  static const String buttonContinue = 'CONTINUE';
  static const String buttonConfirm = 'CONFIRM';
  static const String buttonSetResetPassword = 'SET/RESET PASSWORD';

  // Screen Titles
  static const String titleLogin = 'Login';
  static const String titleRegister = 'Register';
  static const String titleForgotPassword = 'Forgot Password';
  static const String titleOtpVerification = 'Verification\nCode';
  static const String titleLoading = 'Loading';
  static const String titleSuccess = 'Success';
  static const String titlePlazas = 'Plazas';
  static const String titleDashboard = 'Dashboard';
  static const String titleSetUsername = 'Set Username';
  static const String titleUsers = 'Users';
  static const String titleUserInfo = 'User Info';
  static const String titleSetResetPassword = 'Set/Reset\nPassword';
  static const String titleAddFare = 'Add Fare';
  static const String titleModifyViewFareDetails = 'Fares';
  static const String titleNewTicket = 'New Ticket';
  static const String titleOpenTickets = 'Open Tickets';
  static const String titleRejectTicket = 'Reject Ticket';
  static const String titleTicketHistory = 'Ticket History';
  static const String titleMarkExit = 'Mark Exit';
  static const String titleModifyViewTicketDetails = 'Ticket';
  static const String titleViewTicketDetails = 'Ticket';



  // Form Labels
  static const String labelPassword = 'Password';
  static const String labelConfirmPassword = 'Confirm Password';
  static const String labelEmailAndMobileNo = 'EmailID/Mobile No.';
  static const String labelMobileNumber = 'Mobile No.';
  static const String labelEmail = 'Email ID';
  static const String labelFullName = 'Full Name';
  static const String labelPlazaOwnerName = 'Plaza Owner Name';
  static const String labelUsername = 'Username';
  static const String labelCity = 'City';
  static const String labelState = 'State';
  static const String labelDistrict = 'District';
  static const String labelAddress = 'Address';
  static const String labelPincode = 'Pincode';
  static const String labelRole = 'Role';
  static const String labelAssignRole = 'Assign Role';
  static const String labelEntity = 'Entity';
  static const String labelSubEntity = 'Sub-Entity';

  // Actions & Links
  static const String actionForgotPassword = 'Forgot Password?';
  static const String actionCreateAccount = 'Create Account';
  static const String actionLoginAccount = 'Already Have An Account';

  // Basic Validation Messages
  static const String errorUserIdEmpty = 'UserId Cannot Be Empty';
  static const String errorPasswordEmpty = 'Password Cannot Be Empty';
  static const String errorRepeatPasswordEmpty =
      'Repeat Password Cannot Be Empty';
  static const String errorEmailEmpty = 'Email Address Cannot Be Empty';
  static const String errorInvalidEmail = 'Invalid Email Address Format';
  static const String errorMobileNoEmpty = 'Please Enter Mobile No.';
  static const String errorInvalidPhone = 'Invalid Phone Number Format';
  static const String errorUsernameEmpty = 'Username field is required';
  static const String errorDisplayNameEmpty = 'Display Name Cannot Be Empty';
  static const String errorMobileNumberInvalid =
      'Please enter a valid 10-digit mobile number';
  static const String errorMobileVerificationFailed =
      'Mobile number verification failed';
  static const String errorUpdateFailed = 'Failed to update profile';
  static const String successProfileUpdate = 'Profile updated successfully';
  static const String warningMobileVerificationRequired =
      'Mobile number verification required';
  static const String errorLoadOperator = 'Failed to load Operator data';
  static const String errorUsernameRequired = 'Username field is required';
  static const String errorUsernameLength = 'Username length must be';
  static const String errorPlazaOwnerNameRequired =
      'Plaza Owner Name field is required';
  static const String errorPlazaOwnerNameLength =
      'Plaza Owner Name length must be';

  // Add these to your AppStrings class
  static const errorFullNameRequired = 'Full Name field is required';
  static const errorFullNameLength = 'Full Name must be 1-100 characters';
  static const errorRoleRequired = 'Please select a role';
  static const errorSubEntityRequired = 'Sub-entity selection is required';

  // Mobile Number validation messages
  static const String errorMobileRequired = 'Mobile Number field is required';
  static const String errorMobileLength =
      'Mobile Number should contain exactly 10 digits';
  static const String errorMobileUnique = 'Mobile Number is already registered';
  static const String errorMobileInvalidFormat = 'Please enter numbers only';
  static const String errorEmailOrMobileRequired =
      'Please enter email or mobile number';
  static const String errorValidEmailRequired =
      'Please enter a valid email address';
  static const String errorValidMobileRequired =
      'Please enter a valid mobile number';

  // Email validation messages
  static const String errorEmailRequired = 'Email ID field is required';
  static const String errorEmailLength =
      'Email ID exceeds the allowed limit of 50 characters';
  static const String errorEmailInvalid = 'Invalid Email ID';
  static const String errorEmailMinLength =
      'Email ID must be at least 10 characters';

  // Address validation messages
  static const String errorAddressRequired = 'Address field is required';
  static const String errorAddressLength =
      'Address length must be between 1 to 256 characters';

  // City validation messages
  static const String errorCityRequired = 'City field is required';
  static const String errorCityLength =
      'City length must be between 1 to 50 characters';

  // State validation messages
  static const String errorStateRequired = 'State field is required';
  static const String errorStateLength =
      'State length must be between 1 to 50 characters';

  // Password validation messages
  static const String errorPasswordRequired = 'Password field is required';
  static const String errorPasswordLength =
      'Password must be between 8 and 20 characters';
  static const String errorPasswordFormat =
      'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character';

  // Confirm Password validation messages
  static const String errorConfirmPasswordRequired =
      'Confirm Password field is required';
  static const String errorPasswordMismatch =
      'Confirm Password must match Password';

  // Role and Entity validation messages
  static const String errorEntityRequired = 'Assign Entity field is required';

  static const String errorPlazaSelectionRequired = 'Please select a plaza';
  static const String errorFareTypeSelectionRequired =
      'Please select a fare type';
  static const String errorVehicleTypeSelectionRequired =
      'Please select a vehicle type';

  static const String errorDailyFareRequired = 'Please enter Daily Fare';
  static const String errorHourlyFareRequired = 'Please enter Hourly Fare';
  static const String errorBaseHourlyFareRequired =
      'Please enter Base Hourly Fare';
  static const String errorMonthlyFareRequired = 'Please enter Monthly Fare';
  static const String errorAmountGreaterThanZero =
      'Amount must be greater than 0';

  static const String errorStartDateRequired =
      'Please enter Start Effective Date';
  static const String errorPastDateNotAllowed = 'Cannot be a past date';
  static const String errorEndDateRequired = 'Please enter End Effective Date';
  static const String errorEndDateAfterStart = 'Must be after start date';

  static const String errorDiscountRequired =
      'Please enter Discount Amount for Extended Hours';
  static const String errorInvalidDiscount = 'Discount must be greater than 0';

  static const String errorExistingSystemFare =
      'Fare already exists for this plaza in system';
  static const String errorExistingTemporaryFare =
      'Fare already exists for this plaza';
  static const String errorExistingVehicleClass =
      'Vehicle class already exists for this plaza';
  static const String errorFareSubmission = 'Error adding fare: ';

  static const String successFareSubmission =
      'All fares submitted successfully!';
  static const String warningNoFaresAdded =
      'Please add at least one fare before submitting.';
  static const String errorSubmissionFailed = 'Submission failed: ';
}
