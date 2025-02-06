class RestorationHelper {
  static Map<String, dynamic> originalBasicDetails = {};
  static Map<String, dynamic> originalBankDetails = {};

  // Save the original state for Basic Details
  static void saveOriginalBasicDetails(Map<String, dynamic> currentDetails) {
    originalBasicDetails = Map<String, dynamic>.from(currentDetails);
  }

  // Restore the original state for Basic Details
  static void restoreBasicDetails(Map<String, dynamic> basicDetails) {
    basicDetails.clear();
    basicDetails.addAll(originalBasicDetails);
  }

  // Save the original state for Bank Details
  static void saveOriginalBankDetails(Map<String, dynamic> currentDetails) {
    originalBankDetails = Map<String, dynamic>.from(currentDetails);
  }

  // Restore the original state for Bank Details
  static void restoreBankDetails(Map<String, dynamic> bankDetails) {
    bankDetails.clear();
    bankDetails.addAll(originalBankDetails);
  }
}
