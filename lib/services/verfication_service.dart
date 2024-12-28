import 'dart:math';

class VerificationService {
  // Store generated OTPs with mobile numbers
  static final Map<String, String> _otpStorage = {};

  // Generate a random 4-digit OTP
  String generateOTP(String mobileNumber) {
    final otp = (Random().nextInt(9000) + 1000).toString(); // Generates number between 1000-9999
    _otpStorage[mobileNumber] = otp;
    return otp;
  }

  Future<VerificationResult> verifyOTP({
    required String mobileNumber,
    required String otp,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final storedOTP = _otpStorage[mobileNumber];

    if (storedOTP == null) {
      return VerificationResult(
        success: false,
        message: 'No OTP found for this number. Please generate a new OTP.',
      );
    }

    if (storedOTP == otp) {
      // Clear the OTP after successful verification
      _otpStorage.remove(mobileNumber);
      return VerificationResult(
        success: true,
        message: 'OTP verified successfully!',
      );
    } else {
      return VerificationResult(
        success: false,
        message: 'Invalid OTP. Please try again.',
      );
    }
  }
}

class VerificationResult {
  final bool success;
  final String message;

  VerificationResult({
    required this.success,
    required this.message,
  });
}