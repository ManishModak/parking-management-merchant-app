// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(operation) => "Failed to ${operation} bank details.";

  static String m1(operation) => "Bank details ${operation} successfully!";

  static String m2(operation) => "Failed to ${operation} bank details.";

  static String m3(error) => "Error loading plaza details: ";

  static String m4(code) => "Error ${code}";

  static String m5(error) => "Failed To Pick Images: ";

  static String m6(error) => "Failed to refresh images: ";

  static String m7(code) => "Request failed. Status: ${code}";

  static String m8(details) => "Error processing image: ${details}";

  static String m9(details) => "Failed to initialize the screen: ${details}";

  static String m10(id) => "ID: ${id}";

  static String m11(error) => "Failed to fetch lanes: ";

  static String m12(laneName) => "Lane \"${laneName}\" removed.";

  static String m13(maxImages) => "You can upload up to ${maxImages} images.";

  static String m14(mobile) => "OTP sent to ${mobile}";

  static String m15(error) => "Failed to fetch plazas: ";

  static String m16(seconds) => "Resend OTP in ${seconds} s";

  static String m17(operation) => "Bank details ${operation} successfully!";

  static String m18(operation) => "Basic details ${operation} successfully!";

  static String m19(plazaName) => "Fares";

  static String m20(details) => "An unexpected error occurred: ${details}";

  static String m21(field) => "${field} must be a boolean value";

  static String m22(field) => "${field} must contain only digits";

  static String m23(fieldName) => "${fieldName} is already in use.";

  static String m24(fieldName, digits) =>
      "${fieldName} must be exactly ${digits} digits long.";

  static String m25(fieldName, length) =>
      "The ${fieldName} must be exactly ${length} characters long.";

  static String m26(fieldName) => "${fieldName} is required.";

  static String m27(fieldName, value) =>
      "${fieldName} must be greater than or equal to ${value}";

  static String m28(field) => "${field} must be greater than 0";

  static String m29(field) => "${field} must be a valid number";

  static String m30(field, options) =>
      "Invalid ${field}. Must be one of: ${options}";

  static String m31(fieldName, value) =>
      "${fieldName} must be less than or equal to ${value}";

  static String m32(field, max) => "${field} must not exceed ${max} digits";

  static String m33(field, max) => "${field} must not exceed ${max} characters";

  static String m34(field, min) => "${field} must be at least ${min} digits";

  static String m35(fieldName, length) =>
      "${fieldName} must be at least ${length} characters";

  static String m36(fieldName) => "${fieldName} must not be negative";

  static String m37(fieldName) => "${fieldName} must not be zero";

  static String m38(fieldName) => "${fieldName} must be a valid number.";

  static String m39(fieldName) => "${fieldName} must be a positive number.";

  static String m40(total, sum) =>
      "Total parking slots (${total}) must equal the sum of capacities (${sum})";

  static String m41(total, sum) =>
      "Total slots (${total}) must be at least the sum of individual capacities (${sum})";

  static String m42(field, min, max) =>
      "${field} must be between ${min}° and ${max}°";

  static String m43(field) => "${field} is required";

  static String m44(field) => "Please select ${field}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "acceptedDisputesLabel":
            MessageLookupByLibrary.simpleMessage("Accepted"),
        "accessDenied": MessageLookupByLibrary.simpleMessage(
            "You do not have permission to access this feature."),
        "accountHolderName":
            MessageLookupByLibrary.simpleMessage("Account Holder Name"),
        "accountNumber": MessageLookupByLibrary.simpleMessage("Account Number"),
        "actionBack": MessageLookupByLibrary.simpleMessage("Back"),
        "actionCreateAccount":
            MessageLookupByLibrary.simpleMessage("Create Account"),
        "actionDownload": MessageLookupByLibrary.simpleMessage("Download"),
        "actionForgotPassword":
            MessageLookupByLibrary.simpleMessage("Forgot Password?"),
        "actionLoginAccount": MessageLookupByLibrary.simpleMessage(
            "Already have an account? Login"),
        "active": MessageLookupByLibrary.simpleMessage("Active"),
        "addBankDetailsAction":
            MessageLookupByLibrary.simpleMessage("Add Bank Details"),
        "addMore": MessageLookupByLibrary.simpleMessage("add more"),
        "addMoreLabel": MessageLookupByLibrary.simpleMessage("Add More"),
        "addOperation": MessageLookupByLibrary.simpleMessage("added"),
        "added": MessageLookupByLibrary.simpleMessage("added"),
        "address": MessageLookupByLibrary.simpleMessage("Address"),
        "adjustFiltersMessage": MessageLookupByLibrary.simpleMessage(
            "Try adjusting your filters or swipe down to refresh."),
        "advancedFiltersLabel":
            MessageLookupByLibrary.simpleMessage("Advanced Filters"),
        "anprFailedMessage": MessageLookupByLibrary.simpleMessage(
            "Automatic Number Plate Recognition failed to identify vehicle details. Please try again or use manual entry."),
        "anprFailedTitle":
            MessageLookupByLibrary.simpleMessage("ANPR Processing Failed"),
        "apiErrorGeneric": MessageLookupByLibrary.simpleMessage(
            "An error occurred while communicating with the server."),
        "appName": MessageLookupByLibrary.simpleMessage("CityPark"),
        "applyLabel": MessageLookupByLibrary.simpleMessage("Apply"),
        "badRequestError": MessageLookupByLibrary.simpleMessage(
            "Bad request. Please check your input and try again."),
        "bankDetails": MessageLookupByLibrary.simpleMessage("Bank Details"),
        "bankDetailsFailed": m0,
        "bankDetailsFailed_action":
            MessageLookupByLibrary.simpleMessage("updated"),
        "bankDetailsSuccess": m1,
        "bankName": MessageLookupByLibrary.simpleMessage("Bank Name"),
        "barrier": MessageLookupByLibrary.simpleMessage("Boomer Barrier"),
        "basicDetails": MessageLookupByLibrary.simpleMessage("Basic Details"),
        "basicDetailsUpdateSuccess": MessageLookupByLibrary.simpleMessage(
            "Basic details Updated successfully"),
        "basicDetailsUpdated": MessageLookupByLibrary.simpleMessage(
            "Basic details updated successfully!"),
        "bikeCapacity": MessageLookupByLibrary.simpleMessage("Bike Capacity"),
        "bikeLabel": MessageLookupByLibrary.simpleMessage("Bike"),
        "boomerBarrierId":
            MessageLookupByLibrary.simpleMessage("Boomer Barrier ID"),
        "busCapacity": MessageLookupByLibrary.simpleMessage("Bus Capacity"),
        "busLabel": MessageLookupByLibrary.simpleMessage("Bus"),
        "buttonAdd": MessageLookupByLibrary.simpleMessage("Add"),
        "buttonAddFare": MessageLookupByLibrary.simpleMessage("Add New Fare"),
        "buttonAddLane": MessageLookupByLibrary.simpleMessage("Add Lane"),
        "buttonAddMore": MessageLookupByLibrary.simpleMessage("Add More"),
        "buttonApply": MessageLookupByLibrary.simpleMessage("Apply"),
        "buttonCancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "buttonClearSearch":
            MessageLookupByLibrary.simpleMessage("Clear Search"),
        "buttonClose": MessageLookupByLibrary.simpleMessage("Close"),
        "buttonConfigureFare":
            MessageLookupByLibrary.simpleMessage("Configure Fare"),
        "buttonConfirm": MessageLookupByLibrary.simpleMessage("CONFIRM"),
        "buttonContinue": MessageLookupByLibrary.simpleMessage("CONTINUE"),
        "buttonDelete": MessageLookupByLibrary.simpleMessage("Delete"),
        "buttonDismiss": MessageLookupByLibrary.simpleMessage("Dismiss"),
        "buttonDone": MessageLookupByLibrary.simpleMessage("Done"),
        "buttonEdit": MessageLookupByLibrary.simpleMessage("Edit"),
        "buttonFinish": MessageLookupByLibrary.simpleMessage("Finish"),
        "buttonGetLocation":
            MessageLookupByLibrary.simpleMessage("Get Location"),
        "buttonLogin": MessageLookupByLibrary.simpleMessage("LOGIN"),
        "buttonLogout": MessageLookupByLibrary.simpleMessage("Log out"),
        "buttonMarkExit": MessageLookupByLibrary.simpleMessage("Mark Exit"),
        "buttonNo": MessageLookupByLibrary.simpleMessage("No"),
        "buttonOK": MessageLookupByLibrary.simpleMessage("OK"),
        "buttonOk": MessageLookupByLibrary.simpleMessage("OK"),
        "buttonPayCash": MessageLookupByLibrary.simpleMessage("Pay with Cash"),
        "buttonPayNfc":
            MessageLookupByLibrary.simpleMessage("Pay via Card (NFC)"),
        "buttonPayUpi": MessageLookupByLibrary.simpleMessage("Pay via UPI"),
        "buttonPickGallery":
            MessageLookupByLibrary.simpleMessage("Pick from Gallery"),
        "buttonPickImages": MessageLookupByLibrary.simpleMessage("Pick Images"),
        "buttonProcessDispute":
            MessageLookupByLibrary.simpleMessage("Process Dispute"),
        "buttonRaiseDispute":
            MessageLookupByLibrary.simpleMessage("Raise Dispute"),
        "buttonRegister": MessageLookupByLibrary.simpleMessage("REGISTER"),
        "buttonRejectTicket":
            MessageLookupByLibrary.simpleMessage("Reject Ticket"),
        "buttonRemoveImage":
            MessageLookupByLibrary.simpleMessage("Remove Image"),
        "buttonResendOtp": MessageLookupByLibrary.simpleMessage("Resend OTP"),
        "buttonRetry": MessageLookupByLibrary.simpleMessage("Retry"),
        "buttonSave": MessageLookupByLibrary.simpleMessage("Save"),
        "buttonSaveAndNext":
            MessageLookupByLibrary.simpleMessage("Save & Next"),
        "buttonSetResetPassword":
            MessageLookupByLibrary.simpleMessage("RESET\nPASSWORD"),
        "buttonSettings": MessageLookupByLibrary.simpleMessage("Settings"),
        "buttonSubmit": MessageLookupByLibrary.simpleMessage("Submit"),
        "buttonSubmitAllFares":
            MessageLookupByLibrary.simpleMessage("Submit All Fares"),
        "buttonSubmitting": MessageLookupByLibrary.simpleMessage("Submitting"),
        "buttonTakePhoto": MessageLookupByLibrary.simpleMessage("Take Photo"),
        "buttonTryAnotherNumber":
            MessageLookupByLibrary.simpleMessage("Try Another Number"),
        "buttonUpdate": MessageLookupByLibrary.simpleMessage("Update"),
        "buttonVerify": MessageLookupByLibrary.simpleMessage("Verify"),
        "buttonViewDispute":
            MessageLookupByLibrary.simpleMessage("View Dispute"),
        "buttonYes": MessageLookupByLibrary.simpleMessage("Yes"),
        "camera": MessageLookupByLibrary.simpleMessage("Camera"),
        "cameraId": MessageLookupByLibrary.simpleMessage("Camera ID"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "cancelledBookings":
            MessageLookupByLibrary.simpleMessage("Cancelled Bookings"),
        "captureImageLabel":
            MessageLookupByLibrary.simpleMessage("Capture Vehicle Image"),
        "captureVehicleImage":
            MessageLookupByLibrary.simpleMessage("Capture Vehicle Image"),
        "capturedImagesLabel":
            MessageLookupByLibrary.simpleMessage("Captured Vehicle Images"),
        "capturedVehicleImages":
            MessageLookupByLibrary.simpleMessage("Captured Vehicle Images"),
        "cardDisputeSummary":
            MessageLookupByLibrary.simpleMessage("Dispute Summary"),
        "cardPaymentMethodAnalysis":
            MessageLookupByLibrary.simpleMessage("Payment Method Analysis"),
        "cardPlazaBookingSummary":
            MessageLookupByLibrary.simpleMessage("Booking Analysis"),
        "cardPlazaRevenueSummary":
            MessageLookupByLibrary.simpleMessage("Plaza-wise Revenue Summary"),
        "cardRevenueDistribution":
            MessageLookupByLibrary.simpleMessage("Revenue Distribution"),
        "cardTicketCollections":
            MessageLookupByLibrary.simpleMessage("Ticket Collections"),
        "city": MessageLookupByLibrary.simpleMessage("City"),
        "clearAllLabel": MessageLookupByLibrary.simpleMessage("Clear All"),
        "clearFilterLabel":
            MessageLookupByLibrary.simpleMessage("Clear Filter"),
        "clearLabel": MessageLookupByLibrary.simpleMessage("Clear"),
        "clearSearch": MessageLookupByLibrary.simpleMessage("Clear Search"),
        "clearSearchLabel":
            MessageLookupByLibrary.simpleMessage("Clear Search"),
        "closingTime": MessageLookupByLibrary.simpleMessage("Closing Time"),
        "companyTypeIndividual":
            MessageLookupByLibrary.simpleMessage("Individual"),
        "companyTypeLLP": MessageLookupByLibrary.simpleMessage("LLP"),
        "companyTypePrivateLimited":
            MessageLookupByLibrary.simpleMessage("Private Limited"),
        "companyTypePublicLimited":
            MessageLookupByLibrary.simpleMessage("Public Limited"),
        "completedTicketsLabel":
            MessageLookupByLibrary.simpleMessage("Completed Tickets"),
        "confirmDeleteMessage": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete this notification?"),
        "confirmDeleteTitle":
            MessageLookupByLibrary.simpleMessage("Confirm Delete"),
        "correctBankDetailsErrors": MessageLookupByLibrary.simpleMessage(
            "Please correct the errors in bank details."),
        "correctBasicDetailsErrors": MessageLookupByLibrary.simpleMessage(
            "Please correct the errors in basic details."),
        "createTicket": MessageLookupByLibrary.simpleMessage("Create Ticket"),
        "createTicketLabel":
            MessageLookupByLibrary.simpleMessage("Create Ticket"),
        "creatingLabel": MessageLookupByLibrary.simpleMessage("Creating..."),
        "customLabel": MessageLookupByLibrary.simpleMessage("Custom"),
        "dataRefreshFailed":
            MessageLookupByLibrary.simpleMessage("Failed to refresh data"),
        "dataRefreshSuccess":
            MessageLookupByLibrary.simpleMessage("Data refreshed successfully"),
        "dateRangeLabel": MessageLookupByLibrary.simpleMessage("Date Range"),
        "dateRangeTooLongWarning": MessageLookupByLibrary.simpleMessage(
            "Selected date range cannot exceed 1 year"),
        "dialogContentBankDetailsModified":
            MessageLookupByLibrary.simpleMessage(
                "Bank Details Modified Successfully"),
        "dialogContentBankDetailsRegistered":
            MessageLookupByLibrary.simpleMessage(
                "Bank Details Registered Successfully"),
        "dialogContentBasicDetailsModified":
            MessageLookupByLibrary.simpleMessage(
                "Basic details modified Successfully"),
        "dialogContentBasicDetailsRegistered":
            MessageLookupByLibrary.simpleMessage(
                "Basic details registered successfully"),
        "dialogContentLanesModified": MessageLookupByLibrary.simpleMessage(
            "Lanes Details Modified Successfully"),
        "dialogContentLanesRegistered": MessageLookupByLibrary.simpleMessage(
            "Lane details registered successfully."),
        "dialogContentLogout": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to log out of your account? You\'ll need to sign in again to access your data."),
        "dialogContentPlazaRegistrationComplete":
            MessageLookupByLibrary.simpleMessage(
                "Plaza registration completed successfully!"),
        "dialogContentSuccess": MessageLookupByLibrary.simpleMessage(
            "User has been registered successfully."),
        "dialogMessageDiscardChanges": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to discard your changes?"),
        "dialogTitleAddNewFare":
            MessageLookupByLibrary.simpleMessage("Add New Fare"),
        "dialogTitleChooseTheme":
            MessageLookupByLibrary.simpleMessage("Choose Theme"),
        "dialogTitleDiscardChanges":
            MessageLookupByLibrary.simpleMessage("Discard Changes?"),
        "dialogTitleLogout": MessageLookupByLibrary.simpleMessage("Log out"),
        "dialogTitleSelectLanguage":
            MessageLookupByLibrary.simpleMessage("Select Language"),
        "dialogTitleSuccess":
            MessageLookupByLibrary.simpleMessage("Registration Successful"),
        "disabled": MessageLookupByLibrary.simpleMessage("Disabled"),
        "disputeAmountLabel":
            MessageLookupByLibrary.simpleMessage("Dispute Amount"),
        "disputeIdLabel": MessageLookupByLibrary.simpleMessage("Dispute ID"),
        "disputeListTitle":
            MessageLookupByLibrary.simpleMessage("Dispute List"),
        "disputeStatusLabel":
            MessageLookupByLibrary.simpleMessage("Dispute Status"),
        "district": MessageLookupByLibrary.simpleMessage("District"),
        "downloadStarted":
            MessageLookupByLibrary.simpleMessage("Download started"),
        "downloadTransactionsFailed": MessageLookupByLibrary.simpleMessage(
            "Failed to download transactions"),
        "downloadTransactionsStarted": MessageLookupByLibrary.simpleMessage(
            "Transaction download started"),
        "dropdownNoItems":
            MessageLookupByLibrary.simpleMessage("No items available"),
        "edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "editLaneDetails":
            MessageLookupByLibrary.simpleMessage("Edit Lane Details"),
        "email": MessageLookupByLibrary.simpleMessage("Email"),
        "enabled": MessageLookupByLibrary.simpleMessage("Enabled"),
        "entryTimeLabel": MessageLookupByLibrary.simpleMessage("Entry Time"),
        "error": MessageLookupByLibrary.simpleMessage("Error"),
        "errorAadhaarInvalid": MessageLookupByLibrary.simpleMessage(
            "Aadhaar number must be 12 digits"),
        "errorAccessDenied": MessageLookupByLibrary.simpleMessage(
            "Access denied. You do not have permission to perform this action."),
        "errorAccessDeniedMessage":
            MessageLookupByLibrary.simpleMessage("You don\'t have permission."),
        "errorAccountNumberInvalid": MessageLookupByLibrary.simpleMessage(
            "Account number must be numeric"),
        "errorAddingFare":
            MessageLookupByLibrary.simpleMessage("Error adding fare"),
        "errorAddingLane": MessageLookupByLibrary.simpleMessage(
            "Failed to add lane. Please try again."),
        "errorAddressLength": MessageLookupByLibrary.simpleMessage(
            "Address must be 256 characters or less"),
        "errorAddressRequired":
            MessageLookupByLibrary.simpleMessage("Address is required"),
        "errorAdminOperatorNoPlazasAssigned": MessageLookupByLibrary.simpleMessage(
            "You are not assigned to any plazas. Please contact your administrator."),
        "errorAdminOperatorNoPlazasConfigured":
            MessageLookupByLibrary.simpleMessage(
                "No plazas are configured for your account. Please contact support."),
        "errorAmountGreaterThanZero": MessageLookupByLibrary.simpleMessage(
            "Amount must be greater than 0."),
        "errorApiFailedRegisterPlaza":
            MessageLookupByLibrary.simpleMessage("Failed to register plaza."),
        "errorApiFailedSaveBasicDetails": MessageLookupByLibrary.simpleMessage(
            "Failed to save basic details"),
        "errorApiFailedUpdatePlaza":
            MessageLookupByLibrary.simpleMessage("Failed to update plaza."),
        "errorBankNameLength": MessageLookupByLibrary.simpleMessage(
            "Bank name must be 100 characters or less"),
        "errorBaseHourlyFareRequired": MessageLookupByLibrary.simpleMessage(
            "Please enter the base hourly fare."),
        "errorBaseHoursPositive": MessageLookupByLibrary.simpleMessage(
            "Base hours must be a positive whole number"),
        "errorBaseHoursRequired": MessageLookupByLibrary.simpleMessage(
            "Base hours is required for Hour-wise Custom fare"),
        "errorCashPaymentFailed": MessageLookupByLibrary.simpleMessage(
            "Error In Marking Payment by Cash"),
        "errorCityLength": MessageLookupByLibrary.simpleMessage(
            "City must be 50 characters or less"),
        "errorCityRequired":
            MessageLookupByLibrary.simpleMessage("City is required"),
        "errorCompanyNameLength": MessageLookupByLibrary.simpleMessage(
            "Company name must be between 3 and 50 characters"),
        "errorCompanyNameRequired":
            MessageLookupByLibrary.simpleMessage("Company name is required"),
        "errorCompanyTypeInvalid": MessageLookupByLibrary.simpleMessage(
            "Please select a valid company type"),
        "errorCompanyTypeRequired":
            MessageLookupByLibrary.simpleMessage("Company type is required"),
        "errorConfirmPasswordRequired": MessageLookupByLibrary.simpleMessage(
            "Confirm password is required"),
        "errorCorrectBankDetails": MessageLookupByLibrary.simpleMessage(
            "Please correct the bank details."),
        "errorCorrectBasicDetails": MessageLookupByLibrary.simpleMessage(
            "Please correct the basic details."),
        "errorCorrectErrors":
            MessageLookupByLibrary.simpleMessage("Please correct the errors"),
        "errorDailyFareRequired": MessageLookupByLibrary.simpleMessage(
            "Please enter the daily fare."),
        "errorDataNotFound":
            MessageLookupByLibrary.simpleMessage("Data not found"),
        "errorDataNotFoundBookingAnalysis":
            MessageLookupByLibrary.simpleMessage(
                "Could not load booking analysis. Please try refreshing."),
        "errorDataNotFoundDisputeSummary": MessageLookupByLibrary.simpleMessage(
            "Could not load dispute summary. Please try refreshing."),
        "errorDataNotFoundGeneric": MessageLookupByLibrary.simpleMessage(
            "Data not found. Please pull to refresh or try again later."),
        "errorDataNotFoundPaymentAnalysis":
            MessageLookupByLibrary.simpleMessage(
                "Could not load payment analysis. Please try refreshing."),
        "errorDataNotFoundPlazaSummary": MessageLookupByLibrary.simpleMessage(
            "Could not load plaza summary. Please try refreshing."),
        "errorDataNotFoundTicketOverview": MessageLookupByLibrary.simpleMessage(
            "Could not load ticket overview. Please try refreshing."),
        "errorDateOverlap":
            MessageLookupByLibrary.simpleMessage("Date Overlap"),
        "errorDetailsNoDetails": MessageLookupByLibrary.simpleMessage(
            "No additional details available."),
        "errorDetailsService": MessageLookupByLibrary.simpleMessage(
            "Please check your connection or try again later."),
        "errorDetailsUnexpected": MessageLookupByLibrary.simpleMessage(
            "An unexpected error occurred."),
        "errorDiscountNonNegative": MessageLookupByLibrary.simpleMessage(
            "Discount must be a non-negative number"),
        "errorDiscountNumeric":
            MessageLookupByLibrary.simpleMessage("Discount Numeric"),
        "errorDiscountRange": MessageLookupByLibrary.simpleMessage(
            "Discount must be a number between 0 and 100"),
        "errorDiscountRangeStrictPositive": MessageLookupByLibrary.simpleMessage(
            "Discount must be greater than 0 and less than or equal to 100."),
        "errorDiscountRequired": MessageLookupByLibrary.simpleMessage(
            "Please enter the discount amount for extended hours."),
        "errorDisplayNameEmpty": MessageLookupByLibrary.simpleMessage(
            "Display name cannot be empty."),
        "errorDuplicateFare": MessageLookupByLibrary.simpleMessage(
            "A fare with overlapping dates for this plaza, vehicle, and fare type already exists"),
        "errorEditingDisabled": MessageLookupByLibrary.simpleMessage(
            "Editing is currently disabled."),
        "errorEmailEmpty": MessageLookupByLibrary.simpleMessage(
            "Email address cannot be empty."),
        "errorEmailInUse":
            MessageLookupByLibrary.simpleMessage("Email ID already exists."),
        "errorEmailInvalid":
            MessageLookupByLibrary.simpleMessage("Invalid email format"),
        "errorEmailLength": MessageLookupByLibrary.simpleMessage(
            "Email ID must not exceed 50 characters."),
        "errorEmailMinLength": MessageLookupByLibrary.simpleMessage(
            "Email ID must be at least 10 characters."),
        "errorEmailOrMobileRequired": MessageLookupByLibrary.simpleMessage(
            "Please enter an email address or mobile number."),
        "errorEmailRequired":
            MessageLookupByLibrary.simpleMessage("Email is required"),
        "errorEndDateAfterStart": MessageLookupByLibrary.simpleMessage(
            "End date must be after the start date."),
        "errorEndDateRequired": MessageLookupByLibrary.simpleMessage(
            "Please enter the end effective date."),
        "errorEndDateStrictlyAfterStart": MessageLookupByLibrary.simpleMessage(
            "End Date must be strictly later than Start Date."),
        "errorEntityRequired": MessageLookupByLibrary.simpleMessage(
            "Assigning an entity is required."),
        "errorExistingSystemFare": MessageLookupByLibrary.simpleMessage(
            "A system fare already exists for this plaza."),
        "errorExistingTemporaryFare": MessageLookupByLibrary.simpleMessage(
            "A temporary fare already exists for this plaza."),
        "errorExistingVehicleClass": MessageLookupByLibrary.simpleMessage(
            "Vehicle class already exists for this plaza."),
        "errorFailedBankDetails": m2,
        "errorFailedSaveBankDetails":
            MessageLookupByLibrary.simpleMessage("Failed to save bank details"),
        "errorFailedToLoadPlazas": MessageLookupByLibrary.simpleMessage(
            "Failed to load plaza options. Please check your connection and try again."),
        "errorFailedToLoadSection": MessageLookupByLibrary.simpleMessage(
            "Couldn\'t load this section."),
        "errorFailedToMarkExit": MessageLookupByLibrary.simpleMessage(
            "Failed to mark ticket as Exited"),
        "errorFailedToRejectTicket":
            MessageLookupByLibrary.simpleMessage("Failed to reject ticket"),
        "errorFailedUploadImages":
            MessageLookupByLibrary.simpleMessage("Failed to upload images"),
        "errorFareNotConfigured": MessageLookupByLibrary.simpleMessage(
            "Fare not configured for this plaza."),
        "errorFareNotFound":
            MessageLookupByLibrary.simpleMessage("Fare Not Found"),
        "errorFareSubmission":
            MessageLookupByLibrary.simpleMessage("Error adding fare: "),
        "errorFareTypeRequired": MessageLookupByLibrary.simpleMessage(
            "Fare type selection is required"),
        "errorFareTypeSelectionRequired":
            MessageLookupByLibrary.simpleMessage("Please select a fare type"),
        "errorFetchEntities":
            MessageLookupByLibrary.simpleMessage("Error in fetching Entities"),
        "errorFetchPlazas":
            MessageLookupByLibrary.simpleMessage("Failed to fetch plazas"),
        "errorFetchingAddress": MessageLookupByLibrary.simpleMessage(
            "Failed to fetch address from coordinates. Please enter manually."),
        "errorFetchingImages":
            MessageLookupByLibrary.simpleMessage("Error fetching images"),
        "errorFetchingLane":
            MessageLookupByLibrary.simpleMessage("Error fetching lane details"),
        "errorFetchingLanes":
            MessageLookupByLibrary.simpleMessage("Error fetching lanes"),
        "errorFetchingLocation": MessageLookupByLibrary.simpleMessage(
            "Failed to fetch your current location. Please try again."),
        "errorFromMinutesNonNegative": MessageLookupByLibrary.simpleMessage(
            "From (minutes) must be 0 or greater."),
        "errorFromMinutesRequired":
            MessageLookupByLibrary.simpleMessage("From (minutes) is required."),
        "errorFullNameLength": MessageLookupByLibrary.simpleMessage(
            "Full name must be between 3 and 50 characters"),
        "errorFullNameRequired":
            MessageLookupByLibrary.simpleMessage("Full name is required"),
        "errorGeneralValidation": MessageLookupByLibrary.simpleMessage(
            "Error during validation checks"),
        "errorGeneric": MessageLookupByLibrary.simpleMessage(
            "Something went wrong. Please try again."),
        "errorHourlyFareRequired": MessageLookupByLibrary.simpleMessage(
            "Please enter the hourly fare."),
        "errorIfscInvalid": MessageLookupByLibrary.simpleMessage(
            "IFSC code must be 4 letters, 0, then 6 alphanumeric characters"),
        "errorImageLoadFailed":
            MessageLookupByLibrary.simpleMessage("Failed to load"),
        "errorImageNotFound":
            MessageLookupByLibrary.simpleMessage("Image not found"),
        "errorInvalidAmount":
            MessageLookupByLibrary.simpleMessage("Invalid amount for payment"),
        "errorInvalidCredentials": MessageLookupByLibrary.simpleMessage(
            "Invalid email/mobile or password."),
        "errorInvalidDateFormat": MessageLookupByLibrary.simpleMessage(
            "Invalid date format (YYYY-MM-DD)"),
        "errorInvalidDiscount": MessageLookupByLibrary.simpleMessage(
            "Discount must be greater than 0."),
        "errorInvalidEmail": MessageLookupByLibrary.simpleMessage(
            "Invalid email address format."),
        "errorInvalidFareType":
            MessageLookupByLibrary.simpleMessage("Invalid fare type selected"),
        "errorInvalidLaneData": MessageLookupByLibrary.simpleMessage(
            "Cannot update lane: Missing or invalid lane data."),
        "errorInvalidLaneId": MessageLookupByLibrary.simpleMessage(
            "Error: Cannot edit lane without a valid ID."),
        "errorInvalidLaneIdNavigate": MessageLookupByLibrary.simpleMessage(
            "Cannot navigate: Lane ID is missing."),
        "errorInvalidLaneIndex": MessageLookupByLibrary.simpleMessage(
            "Invalid lane index provided."),
        "errorInvalidMobile": MessageLookupByLibrary.simpleMessage(
            "Valid 10-digit mobile number is required"),
        "errorInvalidPhone": MessageLookupByLibrary.simpleMessage(
            "Invalid phone number format."),
        "errorInvalidPlazaId": MessageLookupByLibrary.simpleMessage(
            "Invalid Plaza ID provided. Please contact support."),
        "errorInvalidPlazaIdFormat": MessageLookupByLibrary.simpleMessage(
            "Error: Invalid Plaza ID format."),
        "errorInvalidRecordStatus": MessageLookupByLibrary.simpleMessage(
            "Cannot update lane: Invalid record status."),
        "errorInvalidRegistrationData":
            MessageLookupByLibrary.simpleMessage("Invalid registration data"),
        "errorInvalidRequest": MessageLookupByLibrary.simpleMessage(
            "Invalid request data. Please check your input and try again."),
        "errorInvalidRequestMessage":
            MessageLookupByLibrary.simpleMessage("The request was incorrect."),
        "errorInvalidStartDate":
            MessageLookupByLibrary.simpleMessage("Invalid start date format"),
        "errorInvalidTimeFormat": MessageLookupByLibrary.simpleMessage(
            "Invalid ticket creation time format"),
        "errorIsRequired": MessageLookupByLibrary.simpleMessage("is required"),
        "errorLoadCurrentUserInfo": MessageLookupByLibrary.simpleMessage(
            "Error loading current user info"),
        "errorLoadData":
            MessageLookupByLibrary.simpleMessage("Error In loading Data"),
        "errorLoadDisputeDetails": MessageLookupByLibrary.simpleMessage(
            "Failed to load dispute details"),
        "errorLoadOperator": MessageLookupByLibrary.simpleMessage(
            "Failed to load operator data."),
        "errorLoadOperatorData": MessageLookupByLibrary.simpleMessage(
            "Failed to load operator data"),
        "errorLoadOperatorDataFirst": MessageLookupByLibrary.simpleMessage(
            "Please wait for operator data to load first."),
        "errorLoadPlazas":
            MessageLookupByLibrary.simpleMessage("Failed to fetch plazas"),
        "errorLoadProfileFailed":
            MessageLookupByLibrary.simpleMessage("Failed to load profile data"),
        "errorLoadSettings":
            MessageLookupByLibrary.simpleMessage("Failed to load settings"),
        "errorLoadTicketDetails": MessageLookupByLibrary.simpleMessage(
            "Failed to load ticket details"),
        "errorLoadingDashboardConfig": MessageLookupByLibrary.simpleMessage(
            "Error loading dashboard configuration"),
        "errorLoadingData":
            MessageLookupByLibrary.simpleMessage("Error Loading Data"),
        "errorLoadingFare":
            MessageLookupByLibrary.simpleMessage("Loading Fare"),
        "errorLoadingLaneDetails":
            MessageLookupByLibrary.simpleMessage("Loading Lane Details"),
        "errorLoadingLanesFailed":
            MessageLookupByLibrary.simpleMessage("Loading Lanes Failed"),
        "errorLoadingNotifications":
            MessageLookupByLibrary.simpleMessage("Error Loading Notifications"),
        "errorLoadingPlazaDetails": m3,
        "errorLoadingPlazaDetailsFailed": MessageLookupByLibrary.simpleMessage(
            "Failed to Load Plaza Details"),
        "errorLoadingPlazaDetailsGeneric": MessageLookupByLibrary.simpleMessage(
            "Could not load plaza details at this time."),
        "errorLoadingRole":
            MessageLookupByLibrary.simpleMessage("Error Loading Role"),
        "errorLoadingUserProfile":
            MessageLookupByLibrary.simpleMessage("Error loading user profile"),
        "errorLoginFailed":
            MessageLookupByLibrary.simpleMessage("Login failed"),
        "errorMarkExitFailed":
            MessageLookupByLibrary.simpleMessage("Failed to mark exit"),
        "errorMessageDefault": MessageLookupByLibrary.simpleMessage(
            "Something went wrong. Please try again."),
        "errorMessageNoInternet": MessageLookupByLibrary.simpleMessage(
            "Please check your internet connection and try again."),
        "errorMessagePleaseTryAgain":
            MessageLookupByLibrary.simpleMessage("Please try again later."),
        "errorMessageServer": MessageLookupByLibrary.simpleMessage(
            "Failed to connect to the server. Please try again later."),
        "errorMessageTimeout": MessageLookupByLibrary.simpleMessage(
            "The server is taking too long to respond."),
        "errorMessageUnknown":
            MessageLookupByLibrary.simpleMessage("An unknown error occurred."),
        "errorMissingFareId":
            MessageLookupByLibrary.simpleMessage("Error: Fare ID is missing."),
        "errorMissingOwnerIdForPlaza": MessageLookupByLibrary.simpleMessage(
            "Cannot load plazas: Operator owner information is missing."),
        "errorMissingPlazaData": MessageLookupByLibrary.simpleMessage(
            "Cannot save lane: Plaza data is missing."),
        "errorMissingPlazaId": MessageLookupByLibrary.simpleMessage(
            "Cannot proceed: Plaza ID is missing."),
        "errorMobileChanged": MessageLookupByLibrary.simpleMessage(
            "Mobile number changed. Please verify again."),
        "errorMobileInUse": MessageLookupByLibrary.simpleMessage(
            "Mobile number already exists."),
        "errorMobileInvalidFormat": MessageLookupByLibrary.simpleMessage(
            "Mobile number must be 10 digits"),
        "errorMobileLength": MessageLookupByLibrary.simpleMessage(
            "Mobile number must be exactly 10 digits."),
        "errorMobileNoEmpty": MessageLookupByLibrary.simpleMessage(
            "Please enter your mobile number."),
        "errorMobileNumberInvalid": MessageLookupByLibrary.simpleMessage(
            "Please enter a valid 10-digit mobile number."),
        "errorMobileRequired":
            MessageLookupByLibrary.simpleMessage("Mobile number is required"),
        "errorMobileUnique": MessageLookupByLibrary.simpleMessage(
            "Mobile number is already registered."),
        "errorMobileVerificationFailed": MessageLookupByLibrary.simpleMessage(
            "Mobile number verification failed."),
        "errorMobileVerificationRequired": MessageLookupByLibrary.simpleMessage(
            "Mobile verification required"),
        "errorMonthlyFareRequired": MessageLookupByLibrary.simpleMessage(
            "Please enter the monthly fare."),
        "errorMustBeNonNegativeNumber": MessageLookupByLibrary.simpleMessage(
            "must be a non-negative number."),
        "errorMustBePositiveNumber": MessageLookupByLibrary.simpleMessage(
            "must be a valid number greater than 0"),
        "errorNavigatingToTicketDetails": MessageLookupByLibrary.simpleMessage(
            "Could not open ticket details. ID missing."),
        "errorNavigation":
            MessageLookupByLibrary.simpleMessage("Navigation error"),
        "errorNfc": MessageLookupByLibrary.simpleMessage("NFC Error"),
        "errorNfcDisabled": MessageLookupByLibrary.simpleMessage(
            "Please enable NFC in Settings"),
        "errorNfcNotSupported": MessageLookupByLibrary.simpleMessage(
            "This device does not support NFC"),
        "errorNfcTimeout": MessageLookupByLibrary.simpleMessage("NFC Timeout"),
        "errorNoAccess": MessageLookupByLibrary.simpleMessage("No Access"),
        "errorNoAccessToDashboard": MessageLookupByLibrary.simpleMessage(
            "You do not have permission to view the dashboard."),
        "errorNoAccessToPlazaData": MessageLookupByLibrary.simpleMessage(
            "You do not have access to view plaza-specific data."),
        "errorNoAddressFound": MessageLookupByLibrary.simpleMessage(
            "No address found for the given coordinates."),
        "errorNoEntityId":
            MessageLookupByLibrary.simpleMessage("No Entity Id Provided"),
        "errorNoFilesSelected":
            MessageLookupByLibrary.simpleMessage("No files selected"),
        "errorNoInternet":
            MessageLookupByLibrary.simpleMessage("No internet connection"),
        "errorNoInternetMessage": MessageLookupByLibrary.simpleMessage(
            "Please check your internet connection and try again."),
        "errorNoLaneToUpdate": MessageLookupByLibrary.simpleMessage(
            "No lane selected for update. Please try again."),
        "errorNoPlazasAssigned": MessageLookupByLibrary.simpleMessage(
            "No plazas are currently assigned to your account. Please contact support if you believe this is an error."),
        "errorNoPlazasFound": MessageLookupByLibrary.simpleMessage(
            "No plazas found for this entity."),
        "errorNoTicketData":
            MessageLookupByLibrary.simpleMessage("No Ticket Data"),
        "errorNoUserId":
            MessageLookupByLibrary.simpleMessage("No User Id Provided"),
        "errorNotFound": MessageLookupByLibrary.simpleMessage("Not Found"),
        "errorNotFoundMessage":
            MessageLookupByLibrary.simpleMessage("No open tickets were found."),
        "errorNotFoundMessageReject": MessageLookupByLibrary.simpleMessage(
            "No rejectable tickets were found."),
        "errorOtpSendFailed":
            MessageLookupByLibrary.simpleMessage("Failed to send OTP."),
        "errorOtpVerificationFailed": MessageLookupByLibrary.simpleMessage(
            "OTP verification failed. Please try again."),
        "errorPanInvalid": MessageLookupByLibrary.simpleMessage(
            "PAN number must be 5 letters, 4 digits, 1 letter"),
        "errorPasswordEmpty":
            MessageLookupByLibrary.simpleMessage("Password cannot be empty."),
        "errorPasswordFieldsEmpty": MessageLookupByLibrary.simpleMessage(
            "Please fill in all password fields"),
        "errorPasswordFormat": MessageLookupByLibrary.simpleMessage(
            "Password must be 8-20 characters with at least one lowercase, uppercase, digit, and special character"),
        "errorPasswordLength": MessageLookupByLibrary.simpleMessage(
            "Password must be 8 to 20 characters long."),
        "errorPasswordMinLength": MessageLookupByLibrary.simpleMessage(
            "Password must be at least 8 characters"),
        "errorPasswordMismatch":
            MessageLookupByLibrary.simpleMessage("Passwords do not match"),
        "errorPasswordRequired":
            MessageLookupByLibrary.simpleMessage("Password is required"),
        "errorPasswordResetFailed":
            MessageLookupByLibrary.simpleMessage("Failed to reset password"),
        "errorPasswordTooShort": MessageLookupByLibrary.simpleMessage(
            "Password must be at least 6 characters"),
        "errorPasswordsDoNotMatch":
            MessageLookupByLibrary.simpleMessage("Passwords do not match"),
        "errorPastDateNotAllowed":
            MessageLookupByLibrary.simpleMessage("Past dates are not allowed."),
        "errorPickingFiles":
            MessageLookupByLibrary.simpleMessage("Error picking files"),
        "errorPincodeInvalid":
            MessageLookupByLibrary.simpleMessage("Pincode must be 6 digits"),
        "errorPincodeLength":
            MessageLookupByLibrary.simpleMessage("Pincode must be 6 digits"),
        "errorPincodeRequired":
            MessageLookupByLibrary.simpleMessage("Pincode is required"),
        "errorPlazaOwnerEntityIdMissing": MessageLookupByLibrary.simpleMessage(
            "Plaza Owner configuration is incomplete. Please contact support."),
        "errorPlazaOwnerNameLength": MessageLookupByLibrary.simpleMessage(
            "Plaza owner name length is invalid."),
        "errorPlazaOwnerNameRequired": MessageLookupByLibrary.simpleMessage(
            "Plaza owner name is required."),
        "errorPlazaRequired":
            MessageLookupByLibrary.simpleMessage("Plaza selection is required"),
        "errorPlazaSelectionRequired":
            MessageLookupByLibrary.simpleMessage("Please select a plaza"),
        "errorProcessDispute":
            MessageLookupByLibrary.simpleMessage("Failed to process dispute"),
        "errorProgressiveFareNonNegative":
            MessageLookupByLibrary.simpleMessage("Fare must be 0 or greater."),
        "errorProgressiveFareRequired": MessageLookupByLibrary.simpleMessage(
            "Fare is required for Progressive type."),
        "errorQrCodeFailed": MessageLookupByLibrary.simpleMessage(
            "Failed to retrieve QR code URL"),
        "errorRegistrationFailed":
            MessageLookupByLibrary.simpleMessage("Failed to register user"),
        "errorRemovingImage":
            MessageLookupByLibrary.simpleMessage("Error removing image"),
        "errorRenderingMenu":
            MessageLookupByLibrary.simpleMessage("Error In Menu render"),
        "errorRepeatPasswordEmpty": MessageLookupByLibrary.simpleMessage(
            "Repeat password cannot be empty."),
        "errorRequestTimeout":
            MessageLookupByLibrary.simpleMessage("Request Timed Out"),
        "errorRequestTimeoutMessage": MessageLookupByLibrary.simpleMessage(
            "The server is taking too long to respond. Please try again later."),
        "errorRoleRequired":
            MessageLookupByLibrary.simpleMessage("Please select a role."),
        "errorSavingBankDetails":
            MessageLookupByLibrary.simpleMessage("Error saving bank details"),
        "errorSavingLane":
            MessageLookupByLibrary.simpleMessage("Error saving lane"),
        "errorSavingPlaza":
            MessageLookupByLibrary.simpleMessage("Error saving plaza details"),
        "errorSelectEntity":
            MessageLookupByLibrary.simpleMessage("Entity is Required"),
        "errorSelectRole":
            MessageLookupByLibrary.simpleMessage("Please select a role"),
        "errorSendingOtp":
            MessageLookupByLibrary.simpleMessage("Failed to send OTP"),
        "errorServer": MessageLookupByLibrary.simpleMessage("Server error"),
        "errorServerConnection": MessageLookupByLibrary.simpleMessage(
            "Failed to connect to the server. Please try again later."),
        "errorServerConnectionRefused": MessageLookupByLibrary.simpleMessage(
            "Failed to connect to the server. Please try again later."),
        "errorServerError":
            MessageLookupByLibrary.simpleMessage("Server Error"),
        "errorServerErrorMessage": MessageLookupByLibrary.simpleMessage(
            "We couldn\'t reach the server. Please try again."),
        "errorServerIssue":
            MessageLookupByLibrary.simpleMessage("Server Issue"),
        "errorServerIssueMessage":
            MessageLookupByLibrary.simpleMessage("Problem on our end."),
        "errorServerUnavailable":
            MessageLookupByLibrary.simpleMessage("Server unavailable"),
        "errorServiceException":
            MessageLookupByLibrary.simpleMessage("Service Error"),
        "errorServiceOverloaded":
            MessageLookupByLibrary.simpleMessage("Service Overloaded"),
        "errorServiceOverloadedMessage":
            MessageLookupByLibrary.simpleMessage("Server is busy."),
        "errorServiceUnavailable":
            MessageLookupByLibrary.simpleMessage("Service unavailable"),
        "errorServiceUnavailableMessage": MessageLookupByLibrary.simpleMessage(
            "Service is temporarily down."),
        "errorStartDateRequired": MessageLookupByLibrary.simpleMessage(
            "Please enter the start effective date."),
        "errorStateLength": MessageLookupByLibrary.simpleMessage(
            "State must be 50 characters or less"),
        "errorStateRequired":
            MessageLookupByLibrary.simpleMessage("State is required"),
        "errorSubEntityRequired": MessageLookupByLibrary.simpleMessage(
            "Sub-entity selection is required."),
        "errorSubmissionFailed":
            MessageLookupByLibrary.simpleMessage("Submission failed: "),
        "errorTicketNotFound":
            MessageLookupByLibrary.simpleMessage("Ticket not found"),
        "errorTimeout":
            MessageLookupByLibrary.simpleMessage("Request timed out"),
        "errorTitleDefault":
            MessageLookupByLibrary.simpleMessage("Unable to Load Users"),
        "errorTitleNoInternet":
            MessageLookupByLibrary.simpleMessage("No Internet Connection"),
        "errorTitlePlaza": MessageLookupByLibrary.simpleMessage("Plaza Error"),
        "errorTitleServer":
            MessageLookupByLibrary.simpleMessage("Server Error"),
        "errorTitleService":
            MessageLookupByLibrary.simpleMessage("Service Error"),
        "errorTitleTimeout":
            MessageLookupByLibrary.simpleMessage("Request Timed Out"),
        "errorTitleUnableToLoadPlazas":
            MessageLookupByLibrary.simpleMessage("Unable to Load Plazas"),
        "errorTitleUnexpected":
            MessageLookupByLibrary.simpleMessage("Unexpected Error"),
        "errorTitleWithCode": m4,
        "errorTitleWithCode_code":
            MessageLookupByLibrary.simpleMessage("HTTP status code"),
        "errorToMinutesGreaterThanFrom": MessageLookupByLibrary.simpleMessage(
            "To (minutes) must be greater than From (minutes)."),
        "errorToMinutesPositive": MessageLookupByLibrary.simpleMessage(
            "To (minutes) must be a positive number."),
        "errorToMinutesRequired":
            MessageLookupByLibrary.simpleMessage("To (minutes) is required."),
        "errorUnableToLoadDisputes":
            MessageLookupByLibrary.simpleMessage("Unable to Load Disputes"),
        "errorUnableToLoadLaneDetails":
            MessageLookupByLibrary.simpleMessage("Unable to Load Lane Details"),
        "errorUnableToLoadTicketDetails": MessageLookupByLibrary.simpleMessage(
            "Error Unable to Load Ticket Details"),
        "errorUnableToLoadTickets":
            MessageLookupByLibrary.simpleMessage("Unable to Load Tickets"),
        "errorUnableToLoadTicketsHistory": MessageLookupByLibrary.simpleMessage(
            "Unable to Load Ticket History"),
        "errorUnauthorized":
            MessageLookupByLibrary.simpleMessage("Unauthorized"),
        "errorUnauthorizedMessage":
            MessageLookupByLibrary.simpleMessage("Please log in again."),
        "errorUnexpected": MessageLookupByLibrary.simpleMessage(
            "An unexpected error occurred"),
        "errorUnexpectedMessage": MessageLookupByLibrary.simpleMessage(
            "An unexpected issue occurred."),
        "errorUnknown":
            MessageLookupByLibrary.simpleMessage("An unknown error occurred."),
        "errorUnsupportedCard":
            MessageLookupByLibrary.simpleMessage("Unsupported card type"),
        "errorUpdateFailed": MessageLookupByLibrary.simpleMessage(
            "Failed to update user information"),
        "errorUpdatingLane": MessageLookupByLibrary.simpleMessage(
            "Error updating lane. Please try again."),
        "errorUserExists": MessageLookupByLibrary.simpleMessage(
            "User with this information already exists"),
        "errorUserIdEmpty":
            MessageLookupByLibrary.simpleMessage("User ID cannot be empty."),
        "errorUserIdNotFound": MessageLookupByLibrary.simpleMessage(
            "User ID not found. Please log in again."),
        "errorUserNotFound": MessageLookupByLibrary.simpleMessage(
            "User not found. Please register."),
        "errorUsernameEmpty":
            MessageLookupByLibrary.simpleMessage("Username is required."),
        "errorUsernameLength": MessageLookupByLibrary.simpleMessage(
            "Username must be between 3 and 50 characters"),
        "errorUsernameRequired":
            MessageLookupByLibrary.simpleMessage("Username is required"),
        "errorUsernameTaken":
            MessageLookupByLibrary.simpleMessage("Username already taken"),
        "errorValidEmailRequired": MessageLookupByLibrary.simpleMessage(
            "Please enter a valid email address."),
        "errorValidMobileRequired": MessageLookupByLibrary.simpleMessage(
            "Please enter a valid mobile number."),
        "errorValidationFailed": MessageLookupByLibrary.simpleMessage(
            "Please check your fields and try again."),
        "errorVehicleTypeRequired": MessageLookupByLibrary.simpleMessage(
            "Vehicle type selection is required"),
        "errorVehicleTypeSelectionRequired":
            MessageLookupByLibrary.simpleMessage(
                "Please select a vehicle type"),
        "errorVerificationFailed":
            MessageLookupByLibrary.simpleMessage("Verification failed"),
        "errorVerifyMobile": MessageLookupByLibrary.simpleMessage(
            "Please verify your mobile number"),
        "exportReport": MessageLookupByLibrary.simpleMessage("Export Report"),
        "failedToCreateTicket":
            MessageLookupByLibrary.simpleMessage("Failed to create ticket"),
        "failedToParseTicketIds": MessageLookupByLibrary.simpleMessage(
            "Ticket created, but failed to retrieve all ticket identifiers"),
        "failedToPickImages": m5,
        "failedToRefreshImages": m6,
        "fareTypeFreePass": MessageLookupByLibrary.simpleMessage("Free Pass"),
        "featureComingSoon": MessageLookupByLibrary.simpleMessage(
            "This feature is coming soon!"),
        "fieldBaseHourlyFare":
            MessageLookupByLibrary.simpleMessage("Base hourly fare"),
        "fieldDailyFare": MessageLookupByLibrary.simpleMessage("Daily fare"),
        "fieldHourlyFare": MessageLookupByLibrary.simpleMessage("Hourly fare"),
        "fieldMonthlyFare":
            MessageLookupByLibrary.simpleMessage("Monthly fare"),
        "filterByDate": MessageLookupByLibrary.simpleMessage("Filter by Date"),
        "filterDaily": MessageLookupByLibrary.simpleMessage("Daily"),
        "filterMonthly": MessageLookupByLibrary.simpleMessage("Monthly"),
        "filterQuarterly": MessageLookupByLibrary.simpleMessage("Quarterly"),
        "filterWeekly": MessageLookupByLibrary.simpleMessage("Weekly"),
        "filtersLabel": MessageLookupByLibrary.simpleMessage("Filters"),
        "forbiddenError": MessageLookupByLibrary.simpleMessage(
            "Access denied. You do not have permission to perform this action."),
        "fourWheelerCapacity":
            MessageLookupByLibrary.simpleMessage("4-Wheeler Capacity"),
        "fourWheelerLabel": MessageLookupByLibrary.simpleMessage("4-Wheeler"),
        "freeParking": MessageLookupByLibrary.simpleMessage("Free Parking"),
        "geoLatitude": MessageLookupByLibrary.simpleMessage("Geo Latitude"),
        "geoLongitude": MessageLookupByLibrary.simpleMessage("Geo Longitude"),
        "heavyMachineryCapacity":
            MessageLookupByLibrary.simpleMessage("Heavy Machinery Capacity"),
        "heavyMachineryLabel":
            MessageLookupByLibrary.simpleMessage("Heavy Machinery"),
        "hintSearchPlazas": MessageLookupByLibrary.simpleMessage(
            "Search by plaza name or location..."),
        "hintSearchUsers": MessageLookupByLibrary.simpleMessage(
            "Search by name, mob no. or email"),
        "hmvCapacity": MessageLookupByLibrary.simpleMessage("HMV Capacity"),
        "httpRequestFailedWithCode": m7,
        "id": MessageLookupByLibrary.simpleMessage("ID"),
        "ifscCode": MessageLookupByLibrary.simpleMessage("IFSC Code"),
        "imageCaptureError":
            MessageLookupByLibrary.simpleMessage("Error capturing image: "),
        "imageProcessingError": m8,
        "imageRemoveFailed":
            MessageLookupByLibrary.simpleMessage("Image Remove Failed"),
        "imageRemovedSuccess":
            MessageLookupByLibrary.simpleMessage("Image Removed Successfully"),
        "imageRequired": MessageLookupByLibrary.simpleMessage(
            "Please capture at least one vehicle image"),
        "imagesUploadFailed":
            MessageLookupByLibrary.simpleMessage("Failed to upload images"),
        "imagesUploadedSuccess": MessageLookupByLibrary.simpleMessage(
            "Images uploaded successfully!"),
        "inProgressDisputesLabel":
            MessageLookupByLibrary.simpleMessage("In Progress"),
        "inactive": MessageLookupByLibrary.simpleMessage("Inactive"),
        "initializationError": m9,
        "internalServerError": MessageLookupByLibrary.simpleMessage(
            "Internal Server Error. Please try again later."),
        "invalidPlazaData":
            MessageLookupByLibrary.simpleMessage("Invalid Plaza Data"),
        "invalidPlazaId": MessageLookupByLibrary.simpleMessage(
            "Please select a valid plaza to view bank details."),
        "label3WheelerCapacity":
            MessageLookupByLibrary.simpleMessage("3-Wheeler Capacity"),
        "label4WheelerCapacity":
            MessageLookupByLibrary.simpleMessage("4-Wheeler Capacity"),
        "labelAadhaarNumber":
            MessageLookupByLibrary.simpleMessage("Aadhaar Number"),
        "labelAccountHolder":
            MessageLookupByLibrary.simpleMessage("Account Holder"),
        "labelAccountHolderName":
            MessageLookupByLibrary.simpleMessage("Account Holder Name"),
        "labelAccountNumber":
            MessageLookupByLibrary.simpleMessage("Account Number"),
        "labelActive": MessageLookupByLibrary.simpleMessage("Active"),
        "labelAddImagesOrPdfs":
            MessageLookupByLibrary.simpleMessage("Tap to Add Images or PDFs"),
        "labelAddress": MessageLookupByLibrary.simpleMessage("Address"),
        "labelAddressInfo":
            MessageLookupByLibrary.simpleMessage("Address Information"),
        "labelAllPlazas": MessageLookupByLibrary.simpleMessage("All Plazas"),
        "labelAmount": MessageLookupByLibrary.simpleMessage("Amount"),
        "labelAssignRole": MessageLookupByLibrary.simpleMessage("Assign Role"),
        "labelAuditDetails":
            MessageLookupByLibrary.simpleMessage("Audit Details"),
        "labelAvailableSlots":
            MessageLookupByLibrary.simpleMessage("Available Slots"),
        "labelAverageSlots":
            MessageLookupByLibrary.simpleMessage("Average Slots"),
        "labelBankDetails":
            MessageLookupByLibrary.simpleMessage("Bank\nDetails"),
        "labelBankName": MessageLookupByLibrary.simpleMessage("Bank Name"),
        "labelBaseHourlyFare":
            MessageLookupByLibrary.simpleMessage("Base Hourly Fare"),
        "labelBaseHours": MessageLookupByLibrary.simpleMessage("Base Hours"),
        "labelBaseRate": MessageLookupByLibrary.simpleMessage("Base Rate"),
        "labelBasicDetails":
            MessageLookupByLibrary.simpleMessage("Basic\nDetails"),
        "labelBasicInfo":
            MessageLookupByLibrary.simpleMessage("Basic Information"),
        "labelBikeCapacity":
            MessageLookupByLibrary.simpleMessage("Bike Capacity"),
        "labelBoomerBarrierId":
            MessageLookupByLibrary.simpleMessage("Boomer Barrier ID"),
        "labelBusCapacity":
            MessageLookupByLibrary.simpleMessage("Bus Capacity"),
        "labelCalculating":
            MessageLookupByLibrary.simpleMessage("Calculating..."),
        "labelCameraId": MessageLookupByLibrary.simpleMessage("Camera ID"),
        "labelCancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "labelCancelled": MessageLookupByLibrary.simpleMessage("Cancelled"),
        "labelCancelledBookings":
            MessageLookupByLibrary.simpleMessage("Cancelled Bookings"),
        "labelCapacity3Wheeler":
            MessageLookupByLibrary.simpleMessage("3-Wheeler Capacity"),
        "labelCapacity4Wheeler":
            MessageLookupByLibrary.simpleMessage("4-Wheeler Capacity"),
        "labelCapacityBike":
            MessageLookupByLibrary.simpleMessage("Bike Capacity"),
        "labelCapacityBus":
            MessageLookupByLibrary.simpleMessage("Bus Capacity"),
        "labelCapacityHeavyMachinery":
            MessageLookupByLibrary.simpleMessage("Heavy Machinery Capacity"),
        "labelCapacityTruck":
            MessageLookupByLibrary.simpleMessage("Truck Capacity"),
        "labelCapturedImages":
            MessageLookupByLibrary.simpleMessage("Captured Images"),
        "labelCard": MessageLookupByLibrary.simpleMessage("Card"),
        "labelCash": MessageLookupByLibrary.simpleMessage("Cash"),
        "labelCategory": MessageLookupByLibrary.simpleMessage("Category"),
        "labelCity": MessageLookupByLibrary.simpleMessage("City"),
        "labelClosingTime":
            MessageLookupByLibrary.simpleMessage("Closing Time"),
        "labelCompanyName":
            MessageLookupByLibrary.simpleMessage("Company Name"),
        "labelCompanyType":
            MessageLookupByLibrary.simpleMessage("Company Type"),
        "labelCompletedTickets":
            MessageLookupByLibrary.simpleMessage("Completed Tickets"),
        "labelConfirmPassword":
            MessageLookupByLibrary.simpleMessage("Confirm Password"),
        "labelContactInfo":
            MessageLookupByLibrary.simpleMessage("Contact Information"),
        "labelCount": MessageLookupByLibrary.simpleMessage("Count"),
        "labelCreated": MessageLookupByLibrary.simpleMessage("Created"),
        "labelDailyFare": MessageLookupByLibrary.simpleMessage("Daily Fare"),
        "labelDay": MessageLookupByLibrary.simpleMessage("Day"),
        "labelDaysAgo": MessageLookupByLibrary.simpleMessage("d ago"),
        "labelDelete": MessageLookupByLibrary.simpleMessage("Delete"),
        "labelDetails": MessageLookupByLibrary.simpleMessage("Details"),
        "labelDirection": MessageLookupByLibrary.simpleMessage("Direction"),
        "labelDiscount": MessageLookupByLibrary.simpleMessage("Discount"),
        "labelDiscountExtendedHours":
            MessageLookupByLibrary.simpleMessage("Discount for Extended Hours"),
        "labelDisputeAction":
            MessageLookupByLibrary.simpleMessage("Dispute Action"),
        "labelDisputeAmount":
            MessageLookupByLibrary.simpleMessage("Dispute Amount"),
        "labelDisputeExpiryDate":
            MessageLookupByLibrary.simpleMessage("Expiry Date"),
        "labelDisputeInformation":
            MessageLookupByLibrary.simpleMessage("Dispute Information"),
        "labelDisputeProcessedBy":
            MessageLookupByLibrary.simpleMessage("Dispute Processed By"),
        "labelDisputeProcessedDate":
            MessageLookupByLibrary.simpleMessage("Dispute Processed Date"),
        "labelDisputeRaisedBy":
            MessageLookupByLibrary.simpleMessage("Dispute Raised By"),
        "labelDisputeRaisedDate":
            MessageLookupByLibrary.simpleMessage("Dispute Raised Date"),
        "labelDisputeReason":
            MessageLookupByLibrary.simpleMessage("Dispute Reason"),
        "labelDisputeRemark":
            MessageLookupByLibrary.simpleMessage("Dispute Remark"),
        "labelDisputesLowerCase":
            MessageLookupByLibrary.simpleMessage("disputes"),
        "labelDistrict": MessageLookupByLibrary.simpleMessage("District"),
        "labelDuration": MessageLookupByLibrary.simpleMessage("Duration"),
        "labelEffectiveEndDate":
            MessageLookupByLibrary.simpleMessage("Effective End Date"),
        "labelEffectivePeriod":
            MessageLookupByLibrary.simpleMessage("Effective Period"),
        "labelEffectiveStartDate":
            MessageLookupByLibrary.simpleMessage("Effective Start Date"),
        "labelEmail": MessageLookupByLibrary.simpleMessage("Email"),
        "labelEmailAndMobileNo":
            MessageLookupByLibrary.simpleMessage("Email ID / Mobile No."),
        "labelEnterRemark":
            MessageLookupByLibrary.simpleMessage("Enter Remark"),
        "labelEntity": MessageLookupByLibrary.simpleMessage("Entity"),
        "labelEntryLane": MessageLookupByLibrary.simpleMessage("Entry Lane"),
        "labelEntryLaneDirection":
            MessageLookupByLibrary.simpleMessage("Entry Lane Direction"),
        "labelEntryLaneId":
            MessageLookupByLibrary.simpleMessage("Entry Lane ID"),
        "labelEntryTime": MessageLookupByLibrary.simpleMessage("Entry Time"),
        "labelExistingLanes":
            MessageLookupByLibrary.simpleMessage("Existing Lanes"),
        "labelExitLane": MessageLookupByLibrary.simpleMessage("Exit Lane"),
        "labelExitTime": MessageLookupByLibrary.simpleMessage("Exit Time"),
        "labelFailedTickets":
            MessageLookupByLibrary.simpleMessage("Failed Tickets"),
        "labelFareAmount": MessageLookupByLibrary.simpleMessage("Fare"),
        "labelFareDetails":
            MessageLookupByLibrary.simpleMessage("Fare Details"),
        "labelFareRate": MessageLookupByLibrary.simpleMessage("Fare Rate"),
        "labelFareType": MessageLookupByLibrary.simpleMessage("Fare Type"),
        "labelFaresToBeAdded":
            MessageLookupByLibrary.simpleMessage("Fares to be Added:"),
        "labelFloorId": MessageLookupByLibrary.simpleMessage("Floor ID"),
        "labelFreeParking":
            MessageLookupByLibrary.simpleMessage("Free Parking"),
        "labelFromMinutes":
            MessageLookupByLibrary.simpleMessage("From (minutes)"),
        "labelFullName": MessageLookupByLibrary.simpleMessage("Full Name"),
        "labelGeoLocation": MessageLookupByLibrary.simpleMessage("Geolocation"),
        "labelHMVCapacity":
            MessageLookupByLibrary.simpleMessage("HMV Capacity"),
        "labelHeavyMachineryCapacity":
            MessageLookupByLibrary.simpleMessage("Heavy Machinery Capacity"),
        "labelHour": MessageLookupByLibrary.simpleMessage("Hour"),
        "labelHourlyFare": MessageLookupByLibrary.simpleMessage("Hourly Fare"),
        "labelHoursAgo": MessageLookupByLibrary.simpleMessage("h ago"),
        "labelIFSC": MessageLookupByLibrary.simpleMessage("IFSC Code"),
        "labelIdValue": m10,
        "labelIfscCode": MessageLookupByLibrary.simpleMessage("IFSC Code"),
        "labelInactive": MessageLookupByLibrary.simpleMessage("Inactive"),
        "labelJustNow": MessageLookupByLibrary.simpleMessage("Just now"),
        "labelLCVCapacity":
            MessageLookupByLibrary.simpleMessage("LCV Capacity"),
        "labelLMVCapacity":
            MessageLookupByLibrary.simpleMessage("LMV Capacity"),
        "labelLaneDetails":
            MessageLookupByLibrary.simpleMessage("Lane\nDetails"),
        "labelLaneName": MessageLookupByLibrary.simpleMessage("Lane Name"),
        "labelLastUpdated":
            MessageLookupByLibrary.simpleMessage("Last updated"),
        "labelLatitude": MessageLookupByLibrary.simpleMessage("Latitude"),
        "labelLedScreenId":
            MessageLookupByLibrary.simpleMessage("LED Screen ID"),
        "labelLoading": MessageLookupByLibrary.simpleMessage("Loading..."),
        "labelLongitude": MessageLookupByLibrary.simpleMessage("Longitude"),
        "labelMagneticLoopId":
            MessageLookupByLibrary.simpleMessage("Magnetic Loop ID"),
        "labelMinutesAbbr": MessageLookupByLibrary.simpleMessage("min"),
        "labelMinutesAgo": MessageLookupByLibrary.simpleMessage("m ago"),
        "labelMobileNumber":
            MessageLookupByLibrary.simpleMessage("Mobile Number"),
        "labelModificationTime":
            MessageLookupByLibrary.simpleMessage("Modification Time"),
        "labelMonth": MessageLookupByLibrary.simpleMessage("Month"),
        "labelMonthlyFare":
            MessageLookupByLibrary.simpleMessage("Monthly Fare"),
        "labelNA": MessageLookupByLibrary.simpleMessage("N/A"),
        "labelNewLanes": MessageLookupByLibrary.simpleMessage("New Lanes"),
        "labelNewPassword":
            MessageLookupByLibrary.simpleMessage("New Password"),
        "labelNoData": MessageLookupByLibrary.simpleMessage("No Data Found"),
        "labelNoDataAvailable": MessageLookupByLibrary.simpleMessage(
            "No data available to display."),
        "labelNoDisputesData":
            MessageLookupByLibrary.simpleMessage("No dispute data to display"),
        "labelNoPaymentData":
            MessageLookupByLibrary.simpleMessage("No payment data to display"),
        "labelNoShow": MessageLookupByLibrary.simpleMessage("No-Show"),
        "labelNoShowBookings":
            MessageLookupByLibrary.simpleMessage("No-Show Bookings"),
        "labelNotFilled": MessageLookupByLibrary.simpleMessage("Not filled"),
        "labelNumberOfPlazas":
            MessageLookupByLibrary.simpleMessage("No. of Plazas"),
        "labelNumberOfTickets":
            MessageLookupByLibrary.simpleMessage("No. of Tickets"),
        "labelOccupiedSlots":
            MessageLookupByLibrary.simpleMessage("Occupied Slots"),
        "labelOf": MessageLookupByLibrary.simpleMessage("of"),
        "labelOngoing": MessageLookupByLibrary.simpleMessage("Ongoing"),
        "labelOpenAmount": MessageLookupByLibrary.simpleMessage("Open Amount"),
        "labelOpenDisputes":
            MessageLookupByLibrary.simpleMessage("Open Disputes"),
        "labelOpenTickets":
            MessageLookupByLibrary.simpleMessage("Open Tickets"),
        "labelOpeningTime":
            MessageLookupByLibrary.simpleMessage("Opening Time"),
        "labelOperator": MessageLookupByLibrary.simpleMessage("Operator"),
        "labelOperatorName":
            MessageLookupByLibrary.simpleMessage("Operator Name"),
        "labelOr": MessageLookupByLibrary.simpleMessage("OR"),
        "labelOtp": MessageLookupByLibrary.simpleMessage("OTP"),
        "labelOwner": MessageLookupByLibrary.simpleMessage("Owner"),
        "labelPage": MessageLookupByLibrary.simpleMessage("Page"),
        "labelPanNumber": MessageLookupByLibrary.simpleMessage("PAN Number"),
        "labelParkingDetails":
            MessageLookupByLibrary.simpleMessage("Parking Details"),
        "labelPassword": MessageLookupByLibrary.simpleMessage("Password"),
        "labelPaymentAmount":
            MessageLookupByLibrary.simpleMessage("Payment Amount"),
        "labelPaymentDate":
            MessageLookupByLibrary.simpleMessage("Payment Date"),
        "labelPaymentDetails":
            MessageLookupByLibrary.simpleMessage("Payment Details"),
        "labelPaymentStatus":
            MessageLookupByLibrary.simpleMessage("Payment Status"),
        "labelPending": MessageLookupByLibrary.simpleMessage("Pending"),
        "labelPendingTickets":
            MessageLookupByLibrary.simpleMessage("Pending Tickets"),
        "labelPercentageChange":
            MessageLookupByLibrary.simpleMessage("Percentage Change"),
        "labelPincode": MessageLookupByLibrary.simpleMessage("Pincode"),
        "labelPlaza": MessageLookupByLibrary.simpleMessage("Plaza"),
        "labelPlazaCategory":
            MessageLookupByLibrary.simpleMessage("Plaza Category"),
        "labelPlazaId": MessageLookupByLibrary.simpleMessage("Plaza ID: "),
        "labelPlazaImages":
            MessageLookupByLibrary.simpleMessage("Plaza\nImages"),
        "labelPlazaLaneId":
            MessageLookupByLibrary.simpleMessage("Plaza Lane ID"),
        "labelPlazaName": MessageLookupByLibrary.simpleMessage("Plaza Name"),
        "labelPlazaOrgId": MessageLookupByLibrary.simpleMessage("Plaza Org ID"),
        "labelPlazaOwner": MessageLookupByLibrary.simpleMessage("Plaza Owner"),
        "labelPlazaOwnerName":
            MessageLookupByLibrary.simpleMessage("Plaza Owner Name"),
        "labelPlazaStatus":
            MessageLookupByLibrary.simpleMessage("Plaza Status"),
        "labelPlazaSubCategory":
            MessageLookupByLibrary.simpleMessage("Plaza Sub-Category"),
        "labelPriceCategory":
            MessageLookupByLibrary.simpleMessage("Price Category"),
        "labelRate": MessageLookupByLibrary.simpleMessage("Rate"),
        "labelRejectedAmount":
            MessageLookupByLibrary.simpleMessage("Rejected Amount"),
        "labelRejectedDisputes":
            MessageLookupByLibrary.simpleMessage("Rejected Disputes"),
        "labelRejectedTickets":
            MessageLookupByLibrary.simpleMessage("Rejected Tickets"),
        "labelRemarks": MessageLookupByLibrary.simpleMessage(
            "Remarks (Minimum 10 Characters Required)"),
        "labelReserved": MessageLookupByLibrary.simpleMessage("Reserved"),
        "labelReservedBookings":
            MessageLookupByLibrary.simpleMessage("Reserved Bookings"),
        "labelRetry": MessageLookupByLibrary.simpleMessage("Retry"),
        "labelRfidReaderId":
            MessageLookupByLibrary.simpleMessage("RFID Reader ID"),
        "labelRole": MessageLookupByLibrary.simpleMessage("Role"),
        "labelSearch": MessageLookupByLibrary.simpleMessage("Search"),
        "labelSelectFareType":
            MessageLookupByLibrary.simpleMessage("Select Fare Type"),
        "labelSelectPlaza":
            MessageLookupByLibrary.simpleMessage("Select Plaza"),
        "labelSelectVehicleType":
            MessageLookupByLibrary.simpleMessage("Select Vehicle Type"),
        "labelSettledAmount":
            MessageLookupByLibrary.simpleMessage("Settled Amount"),
        "labelSettledDisputes":
            MessageLookupByLibrary.simpleMessage("Settled Disputes"),
        "labelSlotId": MessageLookupByLibrary.simpleMessage("Slot ID"),
        "labelStandard": MessageLookupByLibrary.simpleMessage("Standard"),
        "labelState": MessageLookupByLibrary.simpleMessage("State"),
        "labelStatus": MessageLookupByLibrary.simpleMessage("Status"),
        "labelStructureType":
            MessageLookupByLibrary.simpleMessage("Structure Type"),
        "labelSubCategory":
            MessageLookupByLibrary.simpleMessage("Sub Category"),
        "labelSubEntity": MessageLookupByLibrary.simpleMessage("Sub-Entity"),
        "labelSuccessfulTickets":
            MessageLookupByLibrary.simpleMessage("Successful Tickets"),
        "labelSwipeToRefresh":
            MessageLookupByLibrary.simpleMessage("Swipe down to refresh"),
        "labelTicket": MessageLookupByLibrary.simpleMessage("Ticket"),
        "labelTicketCollections":
            MessageLookupByLibrary.simpleMessage("Ticket Collection"),
        "labelTicketCreationTime":
            MessageLookupByLibrary.simpleMessage("Ticket Creation Time"),
        "labelTicketDetails":
            MessageLookupByLibrary.simpleMessage("Ticket Details"),
        "labelTicketId": MessageLookupByLibrary.simpleMessage("Ticket ID:"),
        "labelTicketInformation":
            MessageLookupByLibrary.simpleMessage("Ticket Information"),
        "labelTicketReferenceId":
            MessageLookupByLibrary.simpleMessage("Ticket Reference ID"),
        "labelTicketStatus":
            MessageLookupByLibrary.simpleMessage("Ticket Status"),
        "labelTimeRange": MessageLookupByLibrary.simpleMessage("Range"),
        "labelTimings": MessageLookupByLibrary.simpleMessage("Timings"),
        "labelToMinutes": MessageLookupByLibrary.simpleMessage("To (minutes)"),
        "labelTotal": MessageLookupByLibrary.simpleMessage("Total"),
        "labelTotalAmount":
            MessageLookupByLibrary.simpleMessage("Total Amount"),
        "labelTotalBookings":
            MessageLookupByLibrary.simpleMessage("Total Bookings"),
        "labelTotalCharges":
            MessageLookupByLibrary.simpleMessage("Total Charges"),
        "labelTotalDisputes":
            MessageLookupByLibrary.simpleMessage("Total Disputes"),
        "labelTotalParkingSlots":
            MessageLookupByLibrary.simpleMessage("Total Parking Slots"),
        "labelTotalSlots": MessageLookupByLibrary.simpleMessage("Total Slots"),
        "labelTotalTickets":
            MessageLookupByLibrary.simpleMessage("Total Tickets"),
        "labelTotalTransactions":
            MessageLookupByLibrary.simpleMessage("Total Transactions"),
        "labelTransactionsLowerCase":
            MessageLookupByLibrary.simpleMessage("transactions"),
        "labelTruckCapacity":
            MessageLookupByLibrary.simpleMessage("Truck Capacity"),
        "labelTwoWheelerCapacity":
            MessageLookupByLibrary.simpleMessage("Two-Wheeler Capacity"),
        "labelType": MessageLookupByLibrary.simpleMessage("Type"),
        "labelUPI": MessageLookupByLibrary.simpleMessage("UPI"),
        "labelUnknown": MessageLookupByLibrary.simpleMessage("Unknown"),
        "labelUnknownId": MessageLookupByLibrary.simpleMessage("Unknown ID"),
        "labelUpi": MessageLookupByLibrary.simpleMessage("UPI"),
        "labelUploadedDocuments":
            MessageLookupByLibrary.simpleMessage("Uploaded Documents"),
        "labelUploadedFiles":
            MessageLookupByLibrary.simpleMessage("Uploaded Files"),
        "labelUserDataNotAvailable":
            MessageLookupByLibrary.simpleMessage("User data not available"),
        "labelUserId": MessageLookupByLibrary.simpleMessage("User ID"),
        "labelUsername": MessageLookupByLibrary.simpleMessage("Username"),
        "labelVehicleCapacity":
            MessageLookupByLibrary.simpleMessage("Vehicle Capacity"),
        "labelVehicleEntryTimestamp":
            MessageLookupByLibrary.simpleMessage("Vehicle Entry Timestamp"),
        "labelVehicleNumber":
            MessageLookupByLibrary.simpleMessage("Vehicle Number"),
        "labelVehicleType":
            MessageLookupByLibrary.simpleMessage("Vehicle Type"),
        "labelVsPreviousPeriod":
            MessageLookupByLibrary.simpleMessage("vs previous period"),
        "labelWimId": MessageLookupByLibrary.simpleMessage("WIM ID"),
        "laneAddFailed":
            MessageLookupByLibrary.simpleMessage("Failed to add lane"),
        "laneAddedSuccess":
            MessageLookupByLibrary.simpleMessage("Lane added successfully!"),
        "laneDetails": MessageLookupByLibrary.simpleMessage("Lane Details"),
        "laneDirection": MessageLookupByLibrary.simpleMessage("Lane Direction"),
        "laneFetchError": m11,
        "laneId": MessageLookupByLibrary.simpleMessage("Lane ID"),
        "laneIdLabel": MessageLookupByLibrary.simpleMessage("Lane ID"),
        "laneIdRequired":
            MessageLookupByLibrary.simpleMessage("Entry Lane ID is required"),
        "laneName": MessageLookupByLibrary.simpleMessage("Lane Name"),
        "laneStatus": MessageLookupByLibrary.simpleMessage("Lane Status"),
        "laneType": MessageLookupByLibrary.simpleMessage("Lane Type"),
        "laneUpdateFailed":
            MessageLookupByLibrary.simpleMessage("Failed to update lane"),
        "laneUpdatedSuccess":
            MessageLookupByLibrary.simpleMessage("Lane updated successfully!"),
        "languageEnglish": MessageLookupByLibrary.simpleMessage("English"),
        "languageHindi": MessageLookupByLibrary.simpleMessage("Hindi"),
        "languageMarathi": MessageLookupByLibrary.simpleMessage("Marathi"),
        "last30DaysLabel": MessageLookupByLibrary.simpleMessage("Last 30 Days"),
        "last7DaysLabel": MessageLookupByLibrary.simpleMessage("Last 7 Days"),
        "lastUpdated": MessageLookupByLibrary.simpleMessage("Last Updated"),
        "latestRemarkLabel":
            MessageLookupByLibrary.simpleMessage("Latest Remark"),
        "lcvCapacity": MessageLookupByLibrary.simpleMessage("LCV Capacity"),
        "led": MessageLookupByLibrary.simpleMessage("LED Screen"),
        "ledScreenId": MessageLookupByLibrary.simpleMessage("LED Screen ID"),
        "legendCancelledBookings":
            MessageLookupByLibrary.simpleMessage("Cancelled Bookings"),
        "legendCash": MessageLookupByLibrary.simpleMessage("Cash"),
        "legendQr": MessageLookupByLibrary.simpleMessage("QR"),
        "legendTotalBookings":
            MessageLookupByLibrary.simpleMessage("Total Bookings"),
        "legendUpiCard":
            MessageLookupByLibrary.simpleMessage("UPI/Debit\nCredit Card"),
        "lmvCapacity": MessageLookupByLibrary.simpleMessage("LMV Capacity"),
        "loadingEllipsis": MessageLookupByLibrary.simpleMessage("Loading..."),
        "loadingId": MessageLookupByLibrary.simpleMessage("Loading ID..."),
        "loadingMessage": MessageLookupByLibrary.simpleMessage(
            "Please wait while we verify your credentials..."),
        "locationFetchError":
            MessageLookupByLibrary.simpleMessage("Failed to fetch location: "),
        "locationFetchTimeoutError": MessageLookupByLibrary.simpleMessage(
            "Could not get location in time. Please try again."),
        "locationNotAvailableError": MessageLookupByLibrary.simpleMessage(
            "Location data is not available. Please ensure location services are enabled and permissions are granted."),
        "locationPermissionDenied": MessageLookupByLibrary.simpleMessage(
            "Location permission denied. Please enable it to fetch your location."),
        "locationPermissionDeniedForever": MessageLookupByLibrary.simpleMessage(
            "Location permission permanently denied. Please enable it in settings."),
        "locationPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
            "Location permission is required to fetch your current location. Please enable it in app settings."),
        "locationPermissionDeniedTitle":
            MessageLookupByLibrary.simpleMessage("Location Permission Denied"),
        "locationRequired":
            MessageLookupByLibrary.simpleMessage("Location Required"),
        "locationServiceDisabled": MessageLookupByLibrary.simpleMessage(
            "Location services are disabled. Please enable them."),
        "locationServicesDisabledMessage": MessageLookupByLibrary.simpleMessage(
            "Please enable location services to fetch your current location."),
        "locationServicesDisabledTitle":
            MessageLookupByLibrary.simpleMessage("Location Services Disabled"),
        "loggingIn": MessageLookupByLibrary.simpleMessage("Logging in..."),
        "loginMessage": MessageLookupByLibrary.simpleMessage(
            "Welcome Back\nYou\'ve Been Missed!"),
        "logoutSuccess":
            MessageLookupByLibrary.simpleMessage("Logged out successfully"),
        "loop": MessageLookupByLibrary.simpleMessage("Magnetic Loop"),
        "magneticLoopId":
            MessageLookupByLibrary.simpleMessage("Magnetic Loop ID"),
        "manualTicket": MessageLookupByLibrary.simpleMessage("Manual Ticket"),
        "manualTicketLabel":
            MessageLookupByLibrary.simpleMessage("Manual Ticket"),
        "markAllAsRead":
            MessageLookupByLibrary.simpleMessage("Mark all as read"),
        "markExitLabel": MessageLookupByLibrary.simpleMessage("Mark Exit"),
        "markPending": MessageLookupByLibrary.simpleMessage("Mark Pending"),
        "markedAllAsRead": MessageLookupByLibrary.simpleMessage(
            "All notifications marked as read."),
        "menuAddPlazaFare":
            MessageLookupByLibrary.simpleMessage("Add Plaza Fare"),
        "menuBankDetails": MessageLookupByLibrary.simpleMessage("Bank Details"),
        "menuBasicDetails":
            MessageLookupByLibrary.simpleMessage("Basic Details"),
        "menuDisputes": MessageLookupByLibrary.simpleMessage("Disputes"),
        "menuLaneDetails": MessageLookupByLibrary.simpleMessage("Lane Details"),
        "menuMarkExit": MessageLookupByLibrary.simpleMessage("Mark Exit"),
        "menuModifyViewPlaza":
            MessageLookupByLibrary.simpleMessage("View/Edit Plaza Details"),
        "menuModifyViewPlazaFare": MessageLookupByLibrary.simpleMessage(
            "View/Edit Plaza\nFare Details"),
        "menuModifyViewUser":
            MessageLookupByLibrary.simpleMessage("View/Edit User Details"),
        "menuNewTicket": MessageLookupByLibrary.simpleMessage("New Ticket"),
        "menuOpenTickets": MessageLookupByLibrary.simpleMessage("Open Tickets"),
        "menuPlazaFare": MessageLookupByLibrary.simpleMessage("Plaza Fares"),
        "menuPlazaImages": MessageLookupByLibrary.simpleMessage("Plaza Images"),
        "menuPlazas": MessageLookupByLibrary.simpleMessage("Plazas"),
        "menuProcessDispute":
            MessageLookupByLibrary.simpleMessage("Process Dispute"),
        "menuRaiseDispute":
            MessageLookupByLibrary.simpleMessage("Raise Dispute"),
        "menuRegisterPlaza":
            MessageLookupByLibrary.simpleMessage("Register New Plaza"),
        "menuRegisterUser":
            MessageLookupByLibrary.simpleMessage("Register New User"),
        "menuRejectTicket":
            MessageLookupByLibrary.simpleMessage("Reject Ticket"),
        "menuResetPassword":
            MessageLookupByLibrary.simpleMessage("Reset Password"),
        "menuSettings": MessageLookupByLibrary.simpleMessage("Settings"),
        "menuTicketHistory":
            MessageLookupByLibrary.simpleMessage("Ticket History"),
        "menuTickets": MessageLookupByLibrary.simpleMessage("Tickets"),
        "menuTitle": MessageLookupByLibrary.simpleMessage("Menu"),
        "menuUsers": MessageLookupByLibrary.simpleMessage("Users"),
        "menuViewDispute":
            MessageLookupByLibrary.simpleMessage("View Disputes"),
        "messageCashPaymentSuccess":
            MessageLookupByLibrary.simpleMessage("Marked Payment by Cash"),
        "messageCollectCashConfirmation":
            MessageLookupByLibrary.simpleMessage("Collect Cash Amount"),
        "messageDisputeProcessed": MessageLookupByLibrary.simpleMessage(
            "Dispute processed successfully!"),
        "messageDisputeRaised": MessageLookupByLibrary.simpleMessage(
            "Dispute raised successfully!"),
        "messageEditModeActive": MessageLookupByLibrary.simpleMessage(
            "Edit mode active - Tap on any lane to modify its details"),
        "messageEmvCardDetected": MessageLookupByLibrary.simpleMessage(
            "EMV card detected - processing..."),
        "messageErrorLoadingLanes":
            MessageLookupByLibrary.simpleMessage("Error Loading Lanes"),
        "messageErrorMaxImagesReached": MessageLookupByLibrary.simpleMessage(
            "Maximum number of images reached"),
        "messageErrorPickingImages":
            MessageLookupByLibrary.simpleMessage("Error Picking Images"),
        "messageErrorPickingImagesPlatform":
            MessageLookupByLibrary.simpleMessage(
                "Image picking failed ({0}). Please try again."),
        "messageErrorPlazaIdNotSet":
            MessageLookupByLibrary.simpleMessage("Error Plaza Id Not Set"),
        "messageErrorPlazaIdNotSetForLane": MessageLookupByLibrary.simpleMessage(
            "Plaza ID is not set. Please complete the basic details first."),
        "messageErrorSavingBankDetails":
            MessageLookupByLibrary.simpleMessage("Error Saving Bank Details"),
        "messageErrorSavingImages":
            MessageLookupByLibrary.simpleMessage("Error Saving Images"),
        "messageErrorSavingLane": MessageLookupByLibrary.simpleMessage(
            "Error saving lane. Please check all fields."),
        "messageErrorSavingPlaza":
            MessageLookupByLibrary.simpleMessage("Error Saving Plaza"),
        "messageErrorUpdatingLane": MessageLookupByLibrary.simpleMessage(
            "Error updating lane. Please check all fields."),
        "messageErrorUpdatingLaneServer": MessageLookupByLibrary.simpleMessage(
            "Server failed to update the lane."),
        "messageErrorUserDataNotFound":
            MessageLookupByLibrary.simpleMessage("User data not found"),
        "messageFailedToPickImages":
            MessageLookupByLibrary.simpleMessage("Failed to pick images: "),
        "messageFailedToPickImages_error":
            MessageLookupByLibrary.simpleMessage("error details"),
        "messageFailedToRefreshImages":
            MessageLookupByLibrary.simpleMessage("Failed to refresh images: "),
        "messageFailedToRefreshImages_error":
            MessageLookupByLibrary.simpleMessage("error details"),
        "messageFailedToSaveImages":
            MessageLookupByLibrary.simpleMessage("Failed to save images: "),
        "messageFailedToSaveImages_error":
            MessageLookupByLibrary.simpleMessage("error details"),
        "messageFeatureNotImplemented": MessageLookupByLibrary.simpleMessage(
            "This feature is not yet implemented."),
        "messageImageRemovedFailed":
            MessageLookupByLibrary.simpleMessage("Failed to remove image."),
        "messageImageRemovedSuccess":
            MessageLookupByLibrary.simpleMessage("Image removed successfully!"),
        "messageLaneRemoved": m12,
        "messageMaxImagesHint": m13,
        "messageNfcScanPrompt": MessageLookupByLibrary.simpleMessage(
            "Hold your card near the device to scan."),
        "messageNoBankDetails":
            MessageLookupByLibrary.simpleMessage("No bank details available"),
        "messageNoDisputeData":
            MessageLookupByLibrary.simpleMessage("No dispute data available"),
        "messageNoExistingLanesSaved":
            MessageLookupByLibrary.simpleMessage("No Existing Lanes Saved"),
        "messageNoFaresAddedYet": MessageLookupByLibrary.simpleMessage(
            "No fares added yet. Tap \'+\' to add."),
        "messageNoFiltersAvailable": MessageLookupByLibrary.simpleMessage(
            "No filter options are available for the current list."),
        "messageNoImages":
            MessageLookupByLibrary.simpleMessage("No images added yet"),
        "messageNoImagesAvailable":
            MessageLookupByLibrary.simpleMessage("No Images Available"),
        "messageNoImagesSelected": MessageLookupByLibrary.simpleMessage(
            "No images selected. Please select images of your plaza to continue."),
        "messageNoImagesUploaded":
            MessageLookupByLibrary.simpleMessage("No images uploaded yet."),
        "messageNoLanes":
            MessageLookupByLibrary.simpleMessage("No lanes added yet"),
        "messageNoLanesAddedYet":
            MessageLookupByLibrary.simpleMessage("No lanes added yet"),
        "messageNoLanesAvailable": MessageLookupByLibrary.simpleMessage(
            "No filters available at this time."),
        "messageNoMorePlazas":
            MessageLookupByLibrary.simpleMessage("No more plazas found."),
        "messageNoNewLanesAddOne":
            MessageLookupByLibrary.simpleMessage("No New Lanes To Add"),
        "messageNoNewLanesToAdd":
            MessageLookupByLibrary.simpleMessage("No new lanes to add."),
        "messageNoNotifications":
            MessageLookupByLibrary.simpleMessage("No notifications"),
        "messageNoPlazasFound":
            MessageLookupByLibrary.simpleMessage("No plazas found"),
        "messageNoPlazasMatchFilter": MessageLookupByLibrary.simpleMessage(
            "No plazas match your search or filter criteria."),
        "messageNoUsersAvailable": MessageLookupByLibrary.simpleMessage(
            "There are no users available"),
        "messageNoUsersFound":
            MessageLookupByLibrary.simpleMessage("No users found"),
        "messageNoUsersMatchSearch": MessageLookupByLibrary.simpleMessage(
            "No users match your search criteria"),
        "messageNotImplemented": MessageLookupByLibrary.simpleMessage(
            "This feature is not implemented yet"),
        "messagePayCash": MessageLookupByLibrary.simpleMessage(
            "Please pay cash at the exit gate"),
        "messagePdfFailed":
            MessageLookupByLibrary.simpleMessage("Failed to export PDF"),
        "messagePdfSuccess":
            MessageLookupByLibrary.simpleMessage("PDF exported successfully"),
        "messagePlazaModificationComplete":
            MessageLookupByLibrary.simpleMessage(
                "Plaza modifications saved successfully!"),
        "messagePlazaRegistrationComplete":
            MessageLookupByLibrary.simpleMessage(
                "Plaza registration completed successfully!"),
        "messageProcessingPayment":
            MessageLookupByLibrary.simpleMessage("Accept Cash Payment"),
        "messageTicketRejectedSuccess": MessageLookupByLibrary.simpleMessage(
            "Ticket Rejected Successfully"),
        "messageUploadingImages":
            MessageLookupByLibrary.simpleMessage("Uploading images..."),
        "messageUseFabToAddLanes":
            MessageLookupByLibrary.simpleMessage("Use the FAB to add lanes"),
        "messageWarningImagesLimited": MessageLookupByLibrary.simpleMessage(
            "Only {0} images can be added. Extra selections ignored."),
        "mobileNumber": MessageLookupByLibrary.simpleMessage("Mobile Number"),
        "modifyDetails": MessageLookupByLibrary.simpleMessage("Modify Details"),
        "naLabel": MessageLookupByLibrary.simpleMessage("N/A"),
        "navAccount": MessageLookupByLibrary.simpleMessage("Account"),
        "navDashboard": MessageLookupByLibrary.simpleMessage("Dashboard"),
        "navMenu": MessageLookupByLibrary.simpleMessage("Menu"),
        "navNotifications":
            MessageLookupByLibrary.simpleMessage("Notifications"),
        "navTransactions": MessageLookupByLibrary.simpleMessage("Transactions"),
        "networkError": MessageLookupByLibrary.simpleMessage(
            "A network error occurred. Please check your connection and try again."),
        "newLane": MessageLookupByLibrary.simpleMessage("New Lane"),
        "newTicket": MessageLookupByLibrary.simpleMessage("New Ticket"),
        "newTicketTitle": MessageLookupByLibrary.simpleMessage("New Ticket"),
        "no": MessageLookupByLibrary.simpleMessage("No"),
        "noDetailsAvailable":
            MessageLookupByLibrary.simpleMessage("No Details Available"),
        "noDisputesFound":
            MessageLookupByLibrary.simpleMessage("No disputes found"),
        "noFaresForPlazaMessage": MessageLookupByLibrary.simpleMessage(
            "There are no fares for this plaza"),
        "noFaresFoundLabel":
            MessageLookupByLibrary.simpleMessage("No Fares Found"),
        "noFaresMatchSearchMessage": MessageLookupByLibrary.simpleMessage(
            "No fares match your search criteria"),
        "noInternetConnection": MessageLookupByLibrary.simpleMessage(
            "No internet connection. Please check your network settings."),
        "noInternetError": MessageLookupByLibrary.simpleMessage(
            "No Internet Connection: Please check your connection and try again."),
        "noLaneData":
            MessageLookupByLibrary.simpleMessage("No lane data available."),
        "noLaneSelected":
            MessageLookupByLibrary.simpleMessage("No lane selected."),
        "noLanesForPlaza": MessageLookupByLibrary.simpleMessage(
            "No lanes available for this plaza."),
        "noLanesForPlazaAddOne": MessageLookupByLibrary.simpleMessage(
            "This plaza has no lanes yet. Add one to get started!"),
        "noLanesFound": MessageLookupByLibrary.simpleMessage("No Lanes Found"),
        "noLanesFoundForPlaza": MessageLookupByLibrary.simpleMessage(
            "No lanes found for the selected plaza."),
        "noLanesMatchSearch": MessageLookupByLibrary.simpleMessage(
            "No lanes match your search criteria."),
        "noNewImagesToUpload":
            MessageLookupByLibrary.simpleMessage("No New Image To Upload"),
        "noNotificationsSubtitle": MessageLookupByLibrary.simpleMessage(
            "You don\'t have any notifications yet."),
        "noNotificationsTitle":
            MessageLookupByLibrary.simpleMessage("No Notifications"),
        "noOpenTickets":
            MessageLookupByLibrary.simpleMessage("No open tickets"),
        "noOpenTicketsLabel":
            MessageLookupByLibrary.simpleMessage("No Open Tickets"),
        "noPlazaAssigned": MessageLookupByLibrary.simpleMessage(
            "No plaza assigned to this user"),
        "noPlazaAssignedWidgetError": MessageLookupByLibrary.simpleMessage(
            "No plaza assigned. Cannot proceed."),
        "noPlazasFound": MessageLookupByLibrary.simpleMessage(
            "No plazas found for your account."),
        "noRejectableTicketsLabel":
            MessageLookupByLibrary.simpleMessage("No rejectable tickets"),
        "noResultsFound":
            MessageLookupByLibrary.simpleMessage("No results found"),
        "noTicketsAvailable": MessageLookupByLibrary.simpleMessage(
            "There are no open tickets available"),
        "noTicketsFoundLabel":
            MessageLookupByLibrary.simpleMessage("No tickets found."),
        "noTicketsMatchSearch": MessageLookupByLibrary.simpleMessage(
            "No tickets match your search criteria"),
        "noTicketsMatchSearchMessage": MessageLookupByLibrary.simpleMessage(
            "No tickets match your search criteria"),
        "noTicketsToRejectMessage": MessageLookupByLibrary.simpleMessage(
            "There are no tickets to reject at the moment"),
        "noTransactionsSubtitle": MessageLookupByLibrary.simpleMessage(
            "You haven\'t made any transactions yet."),
        "noTransactionsTitle":
            MessageLookupByLibrary.simpleMessage("No Transactions"),
        "noUserIdError": MessageLookupByLibrary.simpleMessage(
            "No user ID found. Please log in again."),
        "notApplicable": MessageLookupByLibrary.simpleMessage("N/A"),
        "notRaisedLabel": MessageLookupByLibrary.simpleMessage("Not Raised"),
        "notificationTypeAccountUpdate":
            MessageLookupByLibrary.simpleMessage("Account Update"),
        "notificationTypeBookingCancellation":
            MessageLookupByLibrary.simpleMessage("Booking Cancelled"),
        "notificationTypeDisputeRaised":
            MessageLookupByLibrary.simpleMessage("Dispute Raised"),
        "notificationTypeDisputeResolved":
            MessageLookupByLibrary.simpleMessage("Dispute Resolved"),
        "notificationTypeGeneric":
            MessageLookupByLibrary.simpleMessage("Notification"),
        "notificationTypeNewBooking":
            MessageLookupByLibrary.simpleMessage("New Booking"),
        "notificationTypePaymentReceived":
            MessageLookupByLibrary.simpleMessage("Payment Received"),
        "notificationTypePlazaAlert":
            MessageLookupByLibrary.simpleMessage("Plaza Alert"),
        "notificationTypePlazaRegistration":
            MessageLookupByLibrary.simpleMessage("Plaza Registration"),
        "notificationTypeTicketCreation":
            MessageLookupByLibrary.simpleMessage("New Ticket"),
        "notificationTypeUnknown":
            MessageLookupByLibrary.simpleMessage("Unknown Notification"),
        "notificationTypeVehicleRegistration":
            MessageLookupByLibrary.simpleMessage("Vehicle Registration"),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "okLabel": MessageLookupByLibrary.simpleMessage("OK"),
        "openDisputesLabel": MessageLookupByLibrary.simpleMessage("Open"),
        "openTicketsLabel":
            MessageLookupByLibrary.simpleMessage("Open Tickets"),
        "openingTime": MessageLookupByLibrary.simpleMessage("Opening Time"),
        "optionAboutApp": MessageLookupByLibrary.simpleMessage("About App"),
        "optionHelpSupport":
            MessageLookupByLibrary.simpleMessage("Help & Support"),
        "optionLanguage": MessageLookupByLibrary.simpleMessage("Language"),
        "optionLogout": MessageLookupByLibrary.simpleMessage("Log out"),
        "optionMyAccount": MessageLookupByLibrary.simpleMessage("My Account"),
        "optionNotifications":
            MessageLookupByLibrary.simpleMessage("Notifications"),
        "optionPrivacyPolicy":
            MessageLookupByLibrary.simpleMessage("Privacy Policy"),
        "optionTermsOfService":
            MessageLookupByLibrary.simpleMessage("Terms of Service"),
        "optionTheme": MessageLookupByLibrary.simpleMessage("Theme"),
        "optionTouchId": MessageLookupByLibrary.simpleMessage("Touch ID"),
        "otpDidNotReceive":
            MessageLookupByLibrary.simpleMessage("Didn\'t receive the OTP?"),
        "otpInvalid": MessageLookupByLibrary.simpleMessage(
            "Please enter a valid 6-digit OTP."),
        "otpResendFailed":
            MessageLookupByLibrary.simpleMessage("Failed to resend OTP"),
        "otpResendSuccess": MessageLookupByLibrary.simpleMessage(
            "OTP has been resent successfully!"),
        "otpSendFailed":
            MessageLookupByLibrary.simpleMessage("OTP send failed."),
        "otpSentSuccess": MessageLookupByLibrary.simpleMessage(
            "OTP has been sent successfully!"),
        "otpSentTo": m14,
        "otpVerifiedSuccess":
            MessageLookupByLibrary.simpleMessage("OTP verified successfully!"),
        "pendingTicketsLabel":
            MessageLookupByLibrary.simpleMessage("Pending Tickets"),
        "pincode": MessageLookupByLibrary.simpleMessage("Pincode"),
        "plazaCategory": MessageLookupByLibrary.simpleMessage("Plaza Category"),
        "plazaFetchError": m15,
        "plazaId": MessageLookupByLibrary.simpleMessage("Plaza ID"),
        "plazaIdLabel": MessageLookupByLibrary.simpleMessage("Plaza ID"),
        "plazaIdRequired":
            MessageLookupByLibrary.simpleMessage("Plaza ID is required"),
        "plazaImagesTitle":
            MessageLookupByLibrary.simpleMessage("Plaza Images"),
        "plazaInfoTitle":
            MessageLookupByLibrary.simpleMessage("Plaza Information"),
        "plazaLabel": MessageLookupByLibrary.simpleMessage("Plaza"),
        "plazaName": MessageLookupByLibrary.simpleMessage("Plaza Name"),
        "plazaNameLabel": MessageLookupByLibrary.simpleMessage("Plaza Name"),
        "plazaOperatorName":
            MessageLookupByLibrary.simpleMessage("Plaza Operator Name"),
        "plazaOwner": MessageLookupByLibrary.simpleMessage("Plaza Owner"),
        "plazaOwnerId": MessageLookupByLibrary.simpleMessage("Plaza Owner ID"),
        "plazaRegisteredSuccessfully": MessageLookupByLibrary.simpleMessage(
            "Plaza Registered Successfully"),
        "plazaStatus": MessageLookupByLibrary.simpleMessage("Plaza Status"),
        "plazaSubCategory":
            MessageLookupByLibrary.simpleMessage("Plaza Sub-Category"),
        "priceCategory": MessageLookupByLibrary.simpleMessage("Price Category"),
        "profileRefreshFailed":
            MessageLookupByLibrary.simpleMessage("Failed to refresh profile"),
        "profileRefreshSuccess": MessageLookupByLibrary.simpleMessage(
            "Profile refreshed successfully"),
        "raisedLabel": MessageLookupByLibrary.simpleMessage("Raised"),
        "reasonLabel": MessageLookupByLibrary.simpleMessage("Reason"),
        "refreshLabel": MessageLookupByLibrary.simpleMessage("Refresh"),
        "refreshNotifications":
            MessageLookupByLibrary.simpleMessage("Refreshing notifications..."),
        "refreshTransactions":
            MessageLookupByLibrary.simpleMessage("Refreshing transactions..."),
        "registerMessage": MessageLookupByLibrary.simpleMessage(
            "Create An Account\nTo Explore Our Platform."),
        "rejectedDisputesLabel":
            MessageLookupByLibrary.simpleMessage("Rejected"),
        "rejectedTicketsLabel":
            MessageLookupByLibrary.simpleMessage("Rejected Tickets"),
        "requestTimeoutError": MessageLookupByLibrary.simpleMessage(
            "The request timed out. Please try again."),
        "resendOtpInSeconds": m16,
        "resetAllLabel": MessageLookupByLibrary.simpleMessage("Reset All"),
        "retry": MessageLookupByLibrary.simpleMessage("Retry"),
        "rfid": MessageLookupByLibrary.simpleMessage("RFID Reader"),
        "rfidReaderId": MessageLookupByLibrary.simpleMessage("RFID Reader ID"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "search": MessageLookupByLibrary.simpleMessage("Search"),
        "searchClear": MessageLookupByLibrary.simpleMessage("Clear search"),
        "searchDisputeHint": MessageLookupByLibrary.simpleMessage(
            "Search by Dispute ID, Vehicle Number, Plaza, etc."),
        "searchHint": MessageLookupByLibrary.simpleMessage(
            "Search by Ticket ID, Plaza, Vehicle Number..."),
        "searchLanesHint": MessageLookupByLibrary.simpleMessage(
            "Search by lane name, ID, or direction"),
        "searchPlazaFareHint": MessageLookupByLibrary.simpleMessage(
            "Search by Vehicle or Fare Type..."),
        "searchPlazaHint":
            MessageLookupByLibrary.simpleMessage("Search Plaza Name"),
        "searchRejectTicketHint": MessageLookupByLibrary.simpleMessage(
            "Search by Ticket ID, Plaza, Vehicle Number..."),
        "searchTicketHistoryHint": MessageLookupByLibrary.simpleMessage(
            "Search by Ticket ID, Status, Plaza, Vehicle Number..."),
        "sectionAccount": MessageLookupByLibrary.simpleMessage("Account"),
        "sectionLegal": MessageLookupByLibrary.simpleMessage("Legal"),
        "sectionPreferences":
            MessageLookupByLibrary.simpleMessage("Preferences"),
        "sectionSupport": MessageLookupByLibrary.simpleMessage("Support"),
        "selectCompanyType":
            MessageLookupByLibrary.simpleMessage("Select Company Type"),
        "selectDateRangeLabel":
            MessageLookupByLibrary.simpleMessage("Select Date Range"),
        "selectDirectionHint":
            MessageLookupByLibrary.simpleMessage("Select a direction"),
        "selectTypeHint": MessageLookupByLibrary.simpleMessage("Select a type"),
        "selectedRangeLabel":
            MessageLookupByLibrary.simpleMessage("Selected Range"),
        "serverConnectionError": MessageLookupByLibrary.simpleMessage(
            "Could not connect to the server. Please try again later."),
        "serviceUnavailableError": MessageLookupByLibrary.simpleMessage(
            "Service Unavailable: Unable to reach plaza service. Please try again later."),
        "state": MessageLookupByLibrary.simpleMessage("State"),
        "statusLabel": MessageLookupByLibrary.simpleMessage("Status"),
        "statusPending": MessageLookupByLibrary.simpleMessage("Pending"),
        "statusSuccess": MessageLookupByLibrary.simpleMessage("Success"),
        "structureType": MessageLookupByLibrary.simpleMessage("Structure Type"),
        "subtitleAboutApp":
            MessageLookupByLibrary.simpleMessage("Version 1.0.0"),
        "subtitleHelpSupport": MessageLookupByLibrary.simpleMessage(
            "Get assistance with using the app"),
        "subtitleLogout": MessageLookupByLibrary.simpleMessage(
            "Further secure your account for safety"),
        "subtitleMyAccount": MessageLookupByLibrary.simpleMessage(
            "Make changes to your account"),
        "subtitleTouchId":
            MessageLookupByLibrary.simpleMessage("Manage your device security"),
        "success": MessageLookupByLibrary.simpleMessage("Success"),
        "successBankDetails": m17,
        "successBasicDetails": m18,
        "successFareAddedToList":
            MessageLookupByLibrary.simpleMessage("Fares Added Successfully"),
        "successFareSubmission":
            MessageLookupByLibrary.simpleMessage("Fares added successfully"),
        "successFareUpdate":
            MessageLookupByLibrary.simpleMessage("Fare updated successfully"),
        "successFareUpdated":
            MessageLookupByLibrary.simpleMessage("Fare updated successfully!"),
        "successIconLabel":
            MessageLookupByLibrary.simpleMessage("Success checkmark"),
        "successImagesUploaded": MessageLookupByLibrary.simpleMessage(
            "Images uploaded successfully!"),
        "successMessage": MessageLookupByLibrary.simpleMessage(
            "Congratulations! You Have Been Successfully Registered."),
        "successMobileRestored": MessageLookupByLibrary.simpleMessage(
            "Original mobile number restored and verified."),
        "successMobileVerification": MessageLookupByLibrary.simpleMessage(
            "Mobile number verified successfully!"),
        "successPasswordReset":
            MessageLookupByLibrary.simpleMessage("Password reset successful"),
        "successProfileUpdate": MessageLookupByLibrary.simpleMessage(
            "Profile updated successfully"),
        "successRegistrationMessage": MessageLookupByLibrary.simpleMessage(
            "Registration successful! Please log in to continue."),
        "successTitle": MessageLookupByLibrary.simpleMessage("Success"),
        "successUserRegistered": MessageLookupByLibrary.simpleMessage(
            "User Registration Successful"),
        "successUserUpdate":
            MessageLookupByLibrary.simpleMessage("User Update Successful"),
        "suggestionTryAnotherEmail": MessageLookupByLibrary.simpleMessage(
            "Please try a different email"),
        "suggestionTryAnotherNumber": MessageLookupByLibrary.simpleMessage(
            "Please try a different mobile number."),
        "summaryPendingTxns":
            MessageLookupByLibrary.simpleMessage("Pending Txns"),
        "summarySettledTxns":
            MessageLookupByLibrary.simpleMessage("Settled Txns"),
        "summaryTotalPlaza":
            MessageLookupByLibrary.simpleMessage("Total Plaza"),
        "summaryTotalTxns": MessageLookupByLibrary.simpleMessage("Total Txns"),
        "swipeToRefresh":
            MessageLookupByLibrary.simpleMessage("Swipe down to refresh"),
        "themeDark": MessageLookupByLibrary.simpleMessage("Dark Theme"),
        "themeLight": MessageLookupByLibrary.simpleMessage("Light Theme"),
        "themeSystem": MessageLookupByLibrary.simpleMessage("System Default"),
        "threeWheelerCapacity":
            MessageLookupByLibrary.simpleMessage("3-Wheeler Capacity"),
        "threeWheelerLabel": MessageLookupByLibrary.simpleMessage("3-Wheeler"),
        "ticketCreatedSuccess": MessageLookupByLibrary.simpleMessage(
            "Ticket created successfully!"),
        "ticketCreationError":
            MessageLookupByLibrary.simpleMessage("Failed to create ticket: "),
        "ticketIdLabel": MessageLookupByLibrary.simpleMessage("Ticket ID:"),
        "ticketMarkedExitSuccess":
            MessageLookupByLibrary.simpleMessage("Marked Exit"),
        "ticketStatusLabel":
            MessageLookupByLibrary.simpleMessage("Ticket Status"),
        "ticketStatusOpen": MessageLookupByLibrary.simpleMessage("Open"),
        "ticketSuccessMessage": MessageLookupByLibrary.simpleMessage(
            "Ticket created successfully!"),
        "timeoutError": MessageLookupByLibrary.simpleMessage(
            "Request Timed Out: Server took too long to respond. Please try again."),
        "titleAccountSettings":
            MessageLookupByLibrary.simpleMessage("Account Settings"),
        "titleAddFare": MessageLookupByLibrary.simpleMessage("Add Fare"),
        "titleAddLane": MessageLookupByLibrary.simpleMessage("Add New Lane"),
        "titleBankDetails":
            MessageLookupByLibrary.simpleMessage("Bank Details"),
        "titleDashboard": MessageLookupByLibrary.simpleMessage("Dashboard"),
        "titleDisputeList": MessageLookupByLibrary.simpleMessage("Disputes"),
        "titleEditFare": MessageLookupByLibrary.simpleMessage("Edit Fare"),
        "titleEditLane": MessageLookupByLibrary.simpleMessage("Edit Lane"),
        "titleEditNewLane":
            MessageLookupByLibrary.simpleMessage("Edit New Lane"),
        "titleEditSavedLane":
            MessageLookupByLibrary.simpleMessage("Edit Saved Lane"),
        "titleFaresForPlaza": m19,
        "titleForgotPassword":
            MessageLookupByLibrary.simpleMessage("Forgot Password"),
        "titleLoading": MessageLookupByLibrary.simpleMessage("Loading"),
        "titleLogin": MessageLookupByLibrary.simpleMessage("Login"),
        "titleMarkExit": MessageLookupByLibrary.simpleMessage("Mark Exit"),
        "titleModifyViewFareDetails":
            MessageLookupByLibrary.simpleMessage("Fare Details"),
        "titleModifyViewTicketDetails":
            MessageLookupByLibrary.simpleMessage("Ticket Details"),
        "titleNewTicket": MessageLookupByLibrary.simpleMessage("New Ticket"),
        "titleNotifications":
            MessageLookupByLibrary.simpleMessage("Notifications"),
        "titleOpenTickets":
            MessageLookupByLibrary.simpleMessage("Open Tickets"),
        "titleOtpVerification":
            MessageLookupByLibrary.simpleMessage("Verification Code"),
        "titlePlazaImages":
            MessageLookupByLibrary.simpleMessage("Plaza Images"),
        "titlePlazaRegistration":
            MessageLookupByLibrary.simpleMessage("Plaza Registration"),
        "titlePlazas": MessageLookupByLibrary.simpleMessage("Plazas"),
        "titleProcessDispute":
            MessageLookupByLibrary.simpleMessage("Process Dispute"),
        "titleProcessingDispute":
            MessageLookupByLibrary.simpleMessage("Processing Dispute"),
        "titleProfile": MessageLookupByLibrary.simpleMessage("Profile"),
        "titleRaiseDispute":
            MessageLookupByLibrary.simpleMessage("Raise Dispute"),
        "titleRegister": MessageLookupByLibrary.simpleMessage("Register"),
        "titleRejectTicket":
            MessageLookupByLibrary.simpleMessage("Reject Ticket"),
        "titleSetResetPassword":
            MessageLookupByLibrary.simpleMessage("Set/Reset\nPassword"),
        "titleSetUsername":
            MessageLookupByLibrary.simpleMessage("Set Username"),
        "titleSuccess": MessageLookupByLibrary.simpleMessage("Success"),
        "titleTicket": MessageLookupByLibrary.simpleMessage("Ticket"),
        "titleTicketDetails":
            MessageLookupByLibrary.simpleMessage("Ticket Details"),
        "titleTicketHistory":
            MessageLookupByLibrary.simpleMessage("Ticket History"),
        "titleUploadImages":
            MessageLookupByLibrary.simpleMessage("Upload Images"),
        "titleUserInfo": MessageLookupByLibrary.simpleMessage("User Info"),
        "titleUserRegistration":
            MessageLookupByLibrary.simpleMessage("User\nRegistration"),
        "titleUsers": MessageLookupByLibrary.simpleMessage("Users"),
        "titleViewFare": MessageLookupByLibrary.simpleMessage("View Fare"),
        "titleViewTicketDetails":
            MessageLookupByLibrary.simpleMessage("Ticket Details"),
        "todayLabel": MessageLookupByLibrary.simpleMessage("Today"),
        "toggleBiometricSuccess": MessageLookupByLibrary.simpleMessage(
            "Biometric authentication updated"),
        "toggleNotificationsSuccess": MessageLookupByLibrary.simpleMessage(
            "Notification settings updated"),
        "tooltipAbout": MessageLookupByLibrary.simpleMessage("About"),
        "tooltipAccount": MessageLookupByLibrary.simpleMessage("Account"),
        "tooltipAddFare": MessageLookupByLibrary.simpleMessage("Add New Fare"),
        "tooltipAddImage": MessageLookupByLibrary.simpleMessage("Add Image"),
        "tooltipAddLane":
            MessageLookupByLibrary.simpleMessage("Add a new lane"),
        "tooltipBack": MessageLookupByLibrary.simpleMessage("Back"),
        "tooltipCancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "tooltipCancelChanges":
            MessageLookupByLibrary.simpleMessage("Cancel Changes"),
        "tooltipCancelled": MessageLookupByLibrary.simpleMessage("Cancelled"),
        "tooltipDashboard": MessageLookupByLibrary.simpleMessage("Dashboard"),
        "tooltipDone": MessageLookupByLibrary.simpleMessage("Done"),
        "tooltipDownload": MessageLookupByLibrary.simpleMessage("Download"),
        "tooltipDownloadPlazaList":
            MessageLookupByLibrary.simpleMessage("Download plaza list"),
        "tooltipEdit": MessageLookupByLibrary.simpleMessage("Edit"),
        "tooltipEditBankDetails":
            MessageLookupByLibrary.simpleMessage("Edit Bank Details"),
        "tooltipEditBasicDetails":
            MessageLookupByLibrary.simpleMessage("Edit Basic Details"),
        "tooltipEditImages":
            MessageLookupByLibrary.simpleMessage("Edit Images"),
        "tooltipEditNewLane":
            MessageLookupByLibrary.simpleMessage("Edit new lane"),
        "tooltipEditSavedLane":
            MessageLookupByLibrary.simpleMessage("Edit saved lane"),
        "tooltipFirstPage": MessageLookupByLibrary.simpleMessage("First page"),
        "tooltipHelp": MessageLookupByLibrary.simpleMessage("Help"),
        "tooltipLanguage": MessageLookupByLibrary.simpleMessage("Language"),
        "tooltipLastPage": MessageLookupByLibrary.simpleMessage("Last page"),
        "tooltipLock": MessageLookupByLibrary.simpleMessage("Lock"),
        "tooltipLogout": MessageLookupByLibrary.simpleMessage("Logout"),
        "tooltipMenu": MessageLookupByLibrary.simpleMessage("Menu"),
        "tooltipNextPage": MessageLookupByLibrary.simpleMessage("Next page"),
        "tooltipNotifications":
            MessageLookupByLibrary.simpleMessage("Notifications"),
        "tooltipPerson": MessageLookupByLibrary.simpleMessage("Person"),
        "tooltipPreviousPage":
            MessageLookupByLibrary.simpleMessage("Previous page"),
        "tooltipPrivacy": MessageLookupByLibrary.simpleMessage("Privacy"),
        "tooltipRemoveImage":
            MessageLookupByLibrary.simpleMessage("Remove Image"),
        "tooltipRevenue": MessageLookupByLibrary.simpleMessage("Revenue"),
        "tooltipSave": MessageLookupByLibrary.simpleMessage("Save"),
        "tooltipSaveChanges":
            MessageLookupByLibrary.simpleMessage("Save Changes"),
        "tooltipSearch": MessageLookupByLibrary.simpleMessage("Search"),
        "tooltipTerms": MessageLookupByLibrary.simpleMessage("Terms"),
        "tooltipTheme": MessageLookupByLibrary.simpleMessage("Theme"),
        "tooltipTotal": MessageLookupByLibrary.simpleMessage("Total"),
        "tooltipTransactions":
            MessageLookupByLibrary.simpleMessage("Transactions"),
        "totalBookings": MessageLookupByLibrary.simpleMessage("Total Bookings"),
        "totalParkingSlots":
            MessageLookupByLibrary.simpleMessage("Total Parking Slots"),
        "truckCapacity": MessageLookupByLibrary.simpleMessage("Truck Capacity"),
        "truckLabel": MessageLookupByLibrary.simpleMessage("Truck"),
        "tryDifferentSearch": MessageLookupByLibrary.simpleMessage(
            "Try a different search term."),
        "tryRefreshing": MessageLookupByLibrary.simpleMessage(
            "Please pull down to refresh."),
        "twoWheelerCapacity":
            MessageLookupByLibrary.simpleMessage("Two-Wheeler Capacity"),
        "unauthorizedError": MessageLookupByLibrary.simpleMessage(
            "Unauthorized. Please login again."),
        "unexpectedErrorOccurred": m20,
        "unknownCode": MessageLookupByLibrary.simpleMessage("Unknown"),
        "unknownPlaza": MessageLookupByLibrary.simpleMessage("Unknown Plaza"),
        "unnamedPlaza": MessageLookupByLibrary.simpleMessage("Unnamed Plaza"),
        "updateOperation": MessageLookupByLibrary.simpleMessage("updated"),
        "updatePlazaFailed": MessageLookupByLibrary.simpleMessage(
            "Failed to update plaza details."),
        "updated": MessageLookupByLibrary.simpleMessage("updated"),
        "userModified":
            MessageLookupByLibrary.simpleMessage("User Modified Successfully"),
        "validationAccountNumberRange": MessageLookupByLibrary.simpleMessage(
            "Account number must be between 10 to 20 digits"),
        "validationAccountNumberRange_description":
            MessageLookupByLibrary.simpleMessage(
                "Error when account number length is invalid"),
        "validationAtLeastOneCapacity": MessageLookupByLibrary.simpleMessage(
            "At least one vehicle capacity must be greater than zero"),
        "validationAtLeastOneImage": MessageLookupByLibrary.simpleMessage(
            "At-least One Image is required"),
        "validationAtLeastOneLane": MessageLookupByLibrary.simpleMessage(
            "At least one lane must be added"),
        "validationBooleanRequired": m21,
        "validationBooleanRequired_description":
            MessageLookupByLibrary.simpleMessage(
                "Error when a boolean field is invalid"),
        "validationClosingAfterOpening": MessageLookupByLibrary.simpleMessage(
            "Closing time must be after opening time"),
        "validationClosingAfterOpening_description":
            MessageLookupByLibrary.simpleMessage(
                "Error when closing time isn\'t after opening time"),
        "validationDigitsOnly": m22,
        "validationDigitsOnly_description":
            MessageLookupByLibrary.simpleMessage(
                "Error when a field has non-digit characters"),
        "validationDuplicate": m23,
        "validationDuplicateGeneral": MessageLookupByLibrary.simpleMessage(
            "One or more fields contain duplicate values."),
        "validationExactDigits": m24,
        "validationExactLength": m25,
        "validationFailed": MessageLookupByLibrary.simpleMessage(
            "Validation failed. Please check your input."),
        "validationFailedTitle":
            MessageLookupByLibrary.simpleMessage("Validation Failed"),
        "validationFieldRequired": m26,
        "validationGeneralBankError": MessageLookupByLibrary.simpleMessage(
            "Please correct the errors in Bank Details"),
        "validationGeneralBankError_description":
            MessageLookupByLibrary.simpleMessage(
                "General error for bank details validation"),
        "validationGeneralError": MessageLookupByLibrary.simpleMessage(
            "Please complete all required fields correctly"),
        "validationGeneralError_description":
            MessageLookupByLibrary.simpleMessage(
                "General error for basic details validation"),
        "validationGeneralLaneError": MessageLookupByLibrary.simpleMessage(
            "Please correct the errors in Lane Details"),
        "validationGeneralLaneError_description":
            MessageLookupByLibrary.simpleMessage(
                "General error for lane details validation"),
        "validationGreaterThanOrEqualTo": m27,
        "validationGreaterThanZero": m28,
        "validationGreaterThanZero_description":
            MessageLookupByLibrary.simpleMessage(
                "Error when a numeric field is not positive"),
        "validationIfscLength": MessageLookupByLibrary.simpleMessage(
            "IFSC code must be exactly 11 characters"),
        "validationIfscLength_description":
            MessageLookupByLibrary.simpleMessage(
                "Error when IFSC code length is incorrect"),
        "validationInvalidEmail": MessageLookupByLibrary.simpleMessage(
            "Please enter a valid email address"),
        "validationInvalidEmail_description":
            MessageLookupByLibrary.simpleMessage(
                "Error when email format is invalid"),
        "validationInvalidIfscFormat": MessageLookupByLibrary.simpleMessage(
            "Please enter a valid IFSC code format (e.g., SBIN0123456)"),
        "validationInvalidIfscFormat_description":
            MessageLookupByLibrary.simpleMessage(
                "Error when IFSC code format is invalid"),
        "validationInvalidNumber": m29,
        "validationInvalidNumber_description":
            MessageLookupByLibrary.simpleMessage(
                "Error when a field isn\'t a valid number"),
        "validationInvalidOption": m30,
        "validationInvalidOption_description":
            MessageLookupByLibrary.simpleMessage(
                "Error when a dropdown value is invalid"),
        "validationInvalidTimeFormat": MessageLookupByLibrary.simpleMessage(
            "Please enter a valid time in HH:MM format"),
        "validationInvalidTimeFormat_description":
            MessageLookupByLibrary.simpleMessage(
                "Error when time format is invalid"),
        "validationLessThanOrEqualTo": m31,
        "validationMaxDigits": m32,
        "validationMaxDigits_description": MessageLookupByLibrary.simpleMessage(
            "Error when a numeric field is too long"),
        "validationMaxLength": m33,
        "validationMaxLength_description": MessageLookupByLibrary.simpleMessage(
            "Error when a field exceeds max length"),
        "validationMinDigits": m34,
        "validationMinDigits_description": MessageLookupByLibrary.simpleMessage(
            "Error when a numeric field is too short"),
        "validationMinLength": m35,
        "validationNonNegative": m36,
        "validationNonZero": m37,
        "validationNumberInvalid": m38,
        "validationNumberPositive": m39,
        "validationParkingCapacitySumMismatch":
            MessageLookupByLibrary.simpleMessage(
                "Vehicle capacities must sum to match total parking slots"),
        "validationParkingSlotEqual": m40,
        "validationParkingSlotSum": m41,
        "validationParkingSlotSum_description":
            MessageLookupByLibrary.simpleMessage(
                "Error when total slots are less than sum of capacities"),
        "validationRange": m42,
        "validationRange_description": MessageLookupByLibrary.simpleMessage(
            "Error when a coordinate is out of range"),
        "validationRequired": m43,
        "validationRequired_description": MessageLookupByLibrary.simpleMessage(
            "Error when a field is empty or too short"),
        "validationRequired_field":
            MessageLookupByLibrary.simpleMessage("The name of the field"),
        "validationSelectRequired": m44,
        "validationSelectRequired_description":
            MessageLookupByLibrary.simpleMessage(
                "Error when a dropdown isn\'t selected"),
        "vehicleLabel": MessageLookupByLibrary.simpleMessage("Vehicle"),
        "vehicleNumber": MessageLookupByLibrary.simpleMessage("Vehicle Number"),
        "vehicleNumberError": MessageLookupByLibrary.simpleMessage(
            "Vehicle number must be between 1 and 20 characters"),
        "vehicleNumberLabel":
            MessageLookupByLibrary.simpleMessage("Vehicle Number"),
        "vehicleNumberRequiredError":
            MessageLookupByLibrary.simpleMessage("Vehicle number is required."),
        "vehicleNumberTooLongError": MessageLookupByLibrary.simpleMessage(
            "Vehicle number cannot exceed 20 characters."),
        "vehicleType": MessageLookupByLibrary.simpleMessage("Vehicle Type"),
        "vehicleTypeLabel":
            MessageLookupByLibrary.simpleMessage("Vehicle Type"),
        "vehicleTypeRequired":
            MessageLookupByLibrary.simpleMessage("Vehicle type is required"),
        "verificationFailed":
            MessageLookupByLibrary.simpleMessage("Verification failed"),
        "verificationMessage": MessageLookupByLibrary.simpleMessage(
            "A verification code has been sent to your mobile number."),
        "viewDetails": MessageLookupByLibrary.simpleMessage("View Details"),
        "warningMobileVerificationRequired":
            MessageLookupByLibrary.simpleMessage(
                "Mobile number verification is required."),
        "warningNoFaresAdded": MessageLookupByLibrary.simpleMessage(
            "Please add at least one fare before submitting."),
        "warningSelectPlazaToAddFare": MessageLookupByLibrary.simpleMessage(
            "Please select a Plaza to add fares."),
        "warningSelectStartDateFirst": MessageLookupByLibrary.simpleMessage(
            "Please select a start date first"),
        "welcomeMessage": MessageLookupByLibrary.simpleMessage(
            "Welcome to the Merchant App!"),
        "wim": MessageLookupByLibrary.simpleMessage("WIM"),
        "wimId": MessageLookupByLibrary.simpleMessage("WIM ID"),
        "yes": MessageLookupByLibrary.simpleMessage("Yes"),
        "yesterdayLabel": MessageLookupByLibrary.simpleMessage("Yesterday")
      };
}
