import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'dart:developer' as developer;
import '../../generated/l10n.dart';
import '../../services/security/otp_verification_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String mobileNumber;

  const OtpVerificationScreen({
    super.key,
    required this.mobileNumber,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
        (index) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(
    6,
        (index) => FocusNode(),
  );

  bool _isLoading = false;
  final _verificationService = VerificationService();

  Timer? _resendTimer;
  int _resendSeconds = 30;
  bool _canResendOTP = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _focusNodes[0].requestFocus();
    developer.log('OtpVerificationScreen initialized for ${widget.mobileNumber}',
        name: 'OtpVerificationScreen');
  }

  void _startResendTimer() {
    setState(() {
      _canResendOTP = false;
      _resendSeconds = 30;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
          _canResendOTP = true;
          _resendTimer?.cancel();
        }
      });
    });
  }

  Future<void> _resendOTP() async {
    if (!_canResendOTP) return;

    setState(() => _isLoading = true);
    try {
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();

      await _verificationService.sendOtp(widget.mobileNumber);
      developer.log('OTP resent to ${widget.mobileNumber}', name: 'OtpVerificationScreen');
      HapticFeedback.lightImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).otpResendSuccess),
            backgroundColor: AppColors.success,
          ),
        );
      }
      _startResendTimer();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${S.of(context).errorSendingOtp}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  bool get _isOtpComplete => _controllers.every((controller) => controller.text.isNotEmpty);

  String get _completeOtp => _controllers.map((e) => e.text).join();

  Future<void> _verifyOTP() async {
    if (!_isOtpComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).otpInvalid),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _verificationService.verifyOtp(
        mobileNumber: widget.mobileNumber,
        otp: _completeOtp,
      );

      if (mounted) {
        if (result.success) {
          HapticFeedback.mediumImpact();
          developer.log('OTP verified successfully for ${widget.mobileNumber}',
              name: 'OtpVerificationScreen');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? S.of(context).otpVerifiedSuccess),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        } else {
          HapticFeedback.vibrate();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? S.of(context).otpInvalid),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${S.of(context).verificationFailed}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: strings.titleOtpVerification,
        onPressed: () => Navigator.pop(context, false),
        darkBackground: isDarkMode,
        context: context,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    strings.otpSentTo(_formatMobileNumber(widget.mobileNumber)),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    strings.verificationMessage,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildOtpInputFields(),
                  const SizedBox(height: 20),
                  _buildResendOtpSection(),
                  const SizedBox(height: 20),
                  Center(
                    child: CustomButtons.primaryButton(
                      height: 50,
                      text: strings.buttonConfirm,
                      onPressed: _isLoading ? () {} : _verifyOTP,
                      isEnabled: !_isLoading && _isOtpComplete,
                      context: context,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: context.shadowColor.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatMobileNumber(String mobile) {
    if (mobile.length <= 4) return mobile;
    String visible = mobile.substring(mobile.length - 4);
    String masked = mobile.substring(0, mobile.length - 4).replaceAll(RegExp(r'\d'), '*');
    return '$masked$visible';
  }

  Widget _buildOtpInputFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        6,
            (index) => SizedBox(
          width: 40,
          height: 65,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimaryColor,
            ),
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              filled: true,
              fillColor: context.formBackgroundColor,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.inputBorderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.inputBorderFocused,
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) {
              developer.log('OTP field $index changed to: $value', name: 'OtpVerificationScreen');
              if (value.isNotEmpty) {
                HapticFeedback.selectionClick();
              }
              if (value.length == 1 && index < 5) {
                _focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
              if (_isOtpComplete && index == 5) {
                FocusScope.of(context).unfocus();
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (mounted && _isOtpComplete) _verifyOTP();
                });
              }
              setState(() {});
            },
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
      ),
    );
  }

  Widget _buildResendOtpSection() {
    final strings = S.of(context);
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            strings.otpDidNotReceive,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          TextButton(
            onPressed: _canResendOTP ? _resendOTP : null,
            child: Text(
              _canResendOTP
                  ? strings.buttonResendOtp
                  : strings.resendOtpInSeconds(_resendSeconds),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _canResendOTP
                    ? Theme.of(context).primaryColor
                    : context.textSecondaryColor.withOpacity(0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}