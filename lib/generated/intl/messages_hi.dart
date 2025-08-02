// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a hi locale. All the
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
  String get localeName => 'hi';

  static String m5(error) => "छवियां चुनने में विफल:  ";

  static String m6(error) => "छवियों को रीफ्रेश करने में विफल:  ";

  static String m7(code) => "अनुरोध विफल। स्थिति: ${code}";

  static String m8(details) => "छवि संसाधन त्रुटि:   ";

  static String m9(details) => "स्क्रीन प्रारंभ करने में विफल:   ";

  static String m11(error) => "लेन प्राप्त करने में त्रुटि:   ";

  static String m15(error) => "प्लाज़ा प्राप्त करने में त्रुटि:   ";

  static String m20(details) => "एक अप्रत्याशित त्रुटि हुई:   ";

  static String m24(fieldName, digits) =>
      "${fieldName} सटीक ${digits} अंक लंबा होना चाहिए।";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "actionCreateAccount":
            MessageLookupByLibrary.simpleMessage("खाता बनाएं"),
        "actionForgotPassword":
            MessageLookupByLibrary.simpleMessage("पासवर्ड भूल गए?"),
        "actionLoginAccount":
            MessageLookupByLibrary.simpleMessage("क्या पहले से खाता है?"),
        "addBankDetailsAction":
            MessageLookupByLibrary.simpleMessage("बैंक विवरण जोड़ें"),
        "appName": MessageLookupByLibrary.simpleMessage("सिटीपार्क"),
        "badRequestError": MessageLookupByLibrary.simpleMessage(
            "गलत अनुरोध। कृपया अपना इनपुट जांचें और पुनः प्रयास करें।"),
        "buttonClose": MessageLookupByLibrary.simpleMessage("बंद करें"),
        "buttonConfigureFare":
            MessageLookupByLibrary.simpleMessage("किराया कॉन्फ़िगर करें"),
        "buttonConfirm": MessageLookupByLibrary.simpleMessage("पुष्टि करें"),
        "buttonContinue": MessageLookupByLibrary.simpleMessage("जारी रखें"),
        "buttonLogin": MessageLookupByLibrary.simpleMessage("लॉगिन"),
        "buttonMarkExit":
            MessageLookupByLibrary.simpleMessage("निकास चिह्नित करें"),
        "buttonProcessDispute":
            MessageLookupByLibrary.simpleMessage("विवाद संसाधित करें"),
        "buttonRegister": MessageLookupByLibrary.simpleMessage("पंजीकरण"),
        "buttonRetry": MessageLookupByLibrary.simpleMessage("पुनः प्रयास"),
        "buttonSetResetPassword":
            MessageLookupByLibrary.simpleMessage("सेट/रीसेट पासवर्ड"),
        "buttonSettings": MessageLookupByLibrary.simpleMessage("सेटिंग्स"),
        "errorAddressLength": MessageLookupByLibrary.simpleMessage(
            "पत्ता 1 ते 256 अक्षरांमध्ये असावा."),
        "errorAddressRequired":
            MessageLookupByLibrary.simpleMessage("पत्ता आवश्यक आहे."),
        "errorAmountGreaterThanZero":
            MessageLookupByLibrary.simpleMessage("रक्कम 0 पेक्षा जास्त असावी."),
        "errorBaseHourlyFareRequired": MessageLookupByLibrary.simpleMessage(
            "कृपया बेस तासाचे भाडे प्रविष्ट करा."),
        "errorCityLength": MessageLookupByLibrary.simpleMessage(
            "शहर 1 ते 50 अक्षरांमध्ये असावा."),
        "errorCityRequired":
            MessageLookupByLibrary.simpleMessage("शहर आवश्यक आहे."),
        "errorConfirmPasswordRequired":
            MessageLookupByLibrary.simpleMessage("पुनः पासवर्ड आवश्यक आहे."),
        "errorDailyFareRequired": MessageLookupByLibrary.simpleMessage(
            "कृपया दैनिक भाडे प्रविष्ट करा."),
        "errorDataNotFoundGeneric": MessageLookupByLibrary.simpleMessage(
            "डेटा नहीं मिला। कृपया रीफ्रेश करने के लिए खींचें या बाद में पुनः प्रयास करें।"),
        "errorDiscountRequired": MessageLookupByLibrary.simpleMessage(
            "कृपया विस्तारित तासांसाठी सूट रक्कम प्रविष्ट करा."),
        "errorDisplayNameEmpty": MessageLookupByLibrary.simpleMessage(
            "डिस्प्ले नाम खाली नहीं हो सकता।"),
        "errorEmailEmpty":
            MessageLookupByLibrary.simpleMessage("ईमेल पता खाली नहीं हो सकता।"),
        "errorEmailInvalid":
            MessageLookupByLibrary.simpleMessage("अवैध ईमेल आयडी."),
        "errorEmailLength": MessageLookupByLibrary.simpleMessage(
            "ईमेल आयडी 50 अक्षरांपेक्षा जास्त नसावे."),
        "errorEmailMinLength": MessageLookupByLibrary.simpleMessage(
            "ईमेल आयडी किमान 10 अक्षरांचा असावा."),
        "errorEmailOrMobileRequired": MessageLookupByLibrary.simpleMessage(
            "कृपया ईमेल आईडी किंवा मोबाइल नंबर प्रविष्ट करा."),
        "errorEmailRequired":
            MessageLookupByLibrary.simpleMessage("ईमेल आयडी आवश्यक आहे."),
        "errorEndDateAfterStart": MessageLookupByLibrary.simpleMessage(
            "समाप्ती तारीख प्रारंभ तारीखीनंतर असावी."),
        "errorEndDateRequired": MessageLookupByLibrary.simpleMessage(
            "कृपया प्रभावी समाप्ती तारीख प्रविष्ट करा."),
        "errorEntityRequired": MessageLookupByLibrary.simpleMessage(
            "संस्था नियुक्त करणे आवश्यक आहे."),
        "errorExistingSystemFare": MessageLookupByLibrary.simpleMessage(
            "या प्लाझासाठी सिस्टीम भाडे आधीच आहे."),
        "errorExistingTemporaryFare": MessageLookupByLibrary.simpleMessage(
            "या प्लाझासाठी तात्पुरते भाडे आधीच आहे."),
        "errorExistingVehicleClass": MessageLookupByLibrary.simpleMessage(
            "या प्लाझासाठी वाहन वर्ग आधीच आहे."),
        "errorFailedToLoadPlazas": MessageLookupByLibrary.simpleMessage(
            "प्लाज़ा विकल्प लोड करने में विफल। कृपया अपना कनेक्शन जांचें और पुनः प्रयास करें।"),
        "errorFailedToLoadSection":
            MessageLookupByLibrary.simpleMessage("यह अनुभाग लोड नहीं हो सका।"),
        "errorFareNotConfigured": MessageLookupByLibrary.simpleMessage(
            "इस प्लाज़ा के लिए किराया कॉन्फ़िगर नहीं किया गया है। कृपया किराया कॉन्फ़िगर करें और पुनः प्रयास करें।"),
        "errorFareSubmission":
            MessageLookupByLibrary.simpleMessage("भाडे जोडण्यात त्रुटी: "),
        "errorFareTypeSelectionRequired":
            MessageLookupByLibrary.simpleMessage("कृपया एक भाडे प्रकार निवडा."),
        "errorFullNameLength": MessageLookupByLibrary.simpleMessage(
            "पूरा नाम 1 से 100 अक्षरों में होना चाहिए।"),
        "errorFullNameRequired":
            MessageLookupByLibrary.simpleMessage("पूरा नाम आवश्यक है।"),
        "errorHourlyFareRequired": MessageLookupByLibrary.simpleMessage(
            "कृपया तासाचे भाडे प्रविष्ट करा."),
        "errorImageNotFound":
            MessageLookupByLibrary.simpleMessage("छवि नहीं मिली"),
        "errorInvalidDiscount":
            MessageLookupByLibrary.simpleMessage("सूट 0 पेक्षा जास्त असावी."),
        "errorInvalidEmail":
            MessageLookupByLibrary.simpleMessage("अमान्य ईमेल प्रारूप।"),
        "errorInvalidPhone":
            MessageLookupByLibrary.simpleMessage("अमान्य फोन नंबर प्रारूप।"),
        "errorLoadDisputeDetails": MessageLookupByLibrary.simpleMessage(
            "विवाद विवरण लोड करने में विफल"),
        "errorLoadOperator": MessageLookupByLibrary.simpleMessage(
            "ऑपरेटर डेटा लोड करने में विफल।"),
        "errorLoadingDashboardConfig": MessageLookupByLibrary.simpleMessage(
            "डैशबोर्ड कॉन्फ़िगरेशन लोड करने में त्रुटि"),
        "errorLoadingData":
            MessageLookupByLibrary.simpleMessage("डेटा लोड करने में त्रुटि"),
        "errorLoadingLanesFailed":
            MessageLookupByLibrary.simpleMessage("लेन लोड करने में विफल"),
        "errorMarkExitFailed":
            MessageLookupByLibrary.simpleMessage("निकास चिह्नित करने में विफल"),
        "errorMobileInvalidFormat": MessageLookupByLibrary.simpleMessage(
            "कृपया फक्त अंक प्रविष्ट करा."),
        "errorMobileLength": MessageLookupByLibrary.simpleMessage(
            "मोबाइल नंबर अचूक 10 अंकांचा असावा."),
        "errorMobileNoEmpty": MessageLookupByLibrary.simpleMessage(
            "कृपया अपना मोबाइल नंबर दर्ज करें।"),
        "errorMobileNumberInvalid": MessageLookupByLibrary.simpleMessage(
            "कृपया 10 अंकों का वैध मोबाइल नंबर दर्ज करें।"),
        "errorMobileRequired":
            MessageLookupByLibrary.simpleMessage("मोबाइल नंबर आवश्यक है।"),
        "errorMobileUnique": MessageLookupByLibrary.simpleMessage(
            "मोबाइल नंबर आधीच नोंदणीकृत आहे."),
        "errorMobileVerificationFailed": MessageLookupByLibrary.simpleMessage(
            "मोबाइल नंबर की पुष्टि अयशस्वी रही।"),
        "errorMonthlyFareRequired": MessageLookupByLibrary.simpleMessage(
            "कृपया मासिक भाडे प्रविष्ट करा."),
        "errorNoAccess": MessageLookupByLibrary.simpleMessage("कोई पहुंच नहीं"),
        "errorNoAccessToDashboard": MessageLookupByLibrary.simpleMessage(
            "आपको डैशबोर्ड देखने की अनुमति नहीं है।"),
        "errorNoAccessToPlazaData": MessageLookupByLibrary.simpleMessage(
            "आपको प्लाज़ा-विशिष्ट डेटा देखने की अनुमति नहीं है।"),
        "errorNoPlazasAssigned": MessageLookupByLibrary.simpleMessage(
            "आपके खाते में वर्तमान में कोई प्लाज़ा असाइन नहीं है। कृपया सहायता से संपर्क करें यदि आपको लगता है कि यह एक त्रुटि है।"),
        "errorPasswordEmpty":
            MessageLookupByLibrary.simpleMessage("पासवर्ड खाली नहीं हो सकता।"),
        "errorPasswordFormat": MessageLookupByLibrary.simpleMessage(
            "पासवर्डमध्ये किमान एक अपरकेस, एक लोअरकेस, एक संख्या, आणि एक विशेष चिन्ह असावे."),
        "errorPasswordLength": MessageLookupByLibrary.simpleMessage(
            "पासवर्ड 8 ते 20 अक्षरांचा असावा."),
        "errorPasswordMismatch":
            MessageLookupByLibrary.simpleMessage("पासवर्ड जुळत नाहीत."),
        "errorPasswordRequired":
            MessageLookupByLibrary.simpleMessage("पासवर्ड आवश्यक आहे."),
        "errorPastDateNotAllowed":
            MessageLookupByLibrary.simpleMessage("मागील तारीख अनुमत नाहीत."),
        "errorPlazaOwnerNameLength": MessageLookupByLibrary.simpleMessage(
            "प्लाजा मालिक के नाम की लंबाई अमान्य है।"),
        "errorPlazaOwnerNameRequired": MessageLookupByLibrary.simpleMessage(
            "प्लाजा मालिक का नाम आवश्यक है।"),
        "errorPlazaSelectionRequired":
            MessageLookupByLibrary.simpleMessage("कृपया एक प्लाझा निवडा."),
        "errorRepeatPasswordEmpty": MessageLookupByLibrary.simpleMessage(
            "पुनः पासवर्ड खाली नहीं हो सकता।"),
        "errorRoleRequired":
            MessageLookupByLibrary.simpleMessage("कृपया एक भूमिका चुनें।"),
        "errorStartDateRequired": MessageLookupByLibrary.simpleMessage(
            "कृपया प्रभावी प्रारंभ तारीख प्रविष्ट करा."),
        "errorStateLength": MessageLookupByLibrary.simpleMessage(
            "राज्य 1 ते 50 अक्षरांमध्ये असावे."),
        "errorStateRequired":
            MessageLookupByLibrary.simpleMessage("राज्य आवश्यक आहे."),
        "errorSubEntityRequired":
            MessageLookupByLibrary.simpleMessage("उप-संस्था का चयन आवश्यक है।"),
        "errorSubmissionFailed":
            MessageLookupByLibrary.simpleMessage("सबमिशन अयशस्वी: "),
        "errorUpdateFailed": MessageLookupByLibrary.simpleMessage(
            "प्रोफ़ाइल अपडेट करने में विफल।"),
        "errorUserIdEmpty": MessageLookupByLibrary.simpleMessage(
            "यूजर आईडी खाली नहीं हो सकती।"),
        "errorUsernameEmpty":
            MessageLookupByLibrary.simpleMessage("उपयोगकर्ता नाम आवश्यक है।"),
        "errorUsernameLength": MessageLookupByLibrary.simpleMessage(
            "उपयोगकर्ता नाम की लंबाई अमान्य है।"),
        "errorUsernameRequired":
            MessageLookupByLibrary.simpleMessage("उपयोगकर्ता नाम आवश्यक है।"),
        "errorValidEmailRequired": MessageLookupByLibrary.simpleMessage(
            "कृपया वैध ईमेल आईडी प्रविष्ट करा."),
        "errorValidMobileRequired": MessageLookupByLibrary.simpleMessage(
            "कृपया वैध मोबाइल नंबर प्रविष्ट करा."),
        "errorVehicleTypeSelectionRequired":
            MessageLookupByLibrary.simpleMessage("कृपया एक वाहन प्रकार निवडा."),
        "exportReport":
            MessageLookupByLibrary.simpleMessage("रिपोर्ट निर्यात करें"),
        "failedToCreateTicket":
            MessageLookupByLibrary.simpleMessage("टिकट बनाने में विफल।"),
        "failedToParseTicketIds": MessageLookupByLibrary.simpleMessage(
            "टिकट ID पार्स करने में विफल।"),
        "failedToPickImages": m5,
        "failedToRefreshImages": m6,
        "featureComingSoon":
            MessageLookupByLibrary.simpleMessage("यह सुविधा जल्द आ रही है!"),
        "forbiddenError": MessageLookupByLibrary.simpleMessage(
            "पहुंच निषेध। आपको यह कार्रवाई करने की अनुमति नहीं है।"),
        "httpRequestFailedWithCode": m7,
        "imageCaptureError":
            MessageLookupByLibrary.simpleMessage("छवि कैप्चर त्रुटि:   "),
        "imageProcessingError": m8,
        "imageRemoveFailed":
            MessageLookupByLibrary.simpleMessage("छवि हटाने में विफल"),
        "imageRemovedSuccess":
            MessageLookupByLibrary.simpleMessage("छवि सफलतापूर्वक हटाई गई"),
        "imageRequired": MessageLookupByLibrary.simpleMessage("छवि आवश्यक है।"),
        "initializationError": m9,
        "internalServerError": MessageLookupByLibrary.simpleMessage(
            "आंतरिक सर्वर त्रुटि। कृपया बाद में पुनः प्रयास करें।"),
        "invalidPlazaData":
            MessageLookupByLibrary.simpleMessage("अमान्य प्लाज़ा डेटा।"),
        "labelAccountHolder": MessageLookupByLibrary.simpleMessage("खाता धारक"),
        "labelAddress": MessageLookupByLibrary.simpleMessage("पता"),
        "labelAssignRole":
            MessageLookupByLibrary.simpleMessage("भूमिका असाइन करें"),
        "labelAuditDetails": MessageLookupByLibrary.simpleMessage("ऑडिट विवरण"),
        "labelAvailableSlots":
            MessageLookupByLibrary.simpleMessage("उपलब्ध स्लॉट"),
        "labelCity": MessageLookupByLibrary.simpleMessage("शहर"),
        "labelCompanyName":
            MessageLookupByLibrary.simpleMessage("कंपनी का नाम"),
        "labelCompanyType":
            MessageLookupByLibrary.simpleMessage("कंपनी प्रकार"),
        "labelConfirmPassword":
            MessageLookupByLibrary.simpleMessage("पासवर्ड की पुष्टि करें"),
        "labelDisputeAction":
            MessageLookupByLibrary.simpleMessage("विवाद कार्रवाई"),
        "labelDisputeAmount":
            MessageLookupByLibrary.simpleMessage("विवाद राशि"),
        "labelDisputeExpiryDate":
            MessageLookupByLibrary.simpleMessage("समाप्ति तिथि"),
        "labelDisputeInformation":
            MessageLookupByLibrary.simpleMessage("विवाद जानकारी"),
        "labelDisputeProcessedBy":
            MessageLookupByLibrary.simpleMessage("विवाद संसाधित किया गया"),
        "labelDisputeProcessedDate":
            MessageLookupByLibrary.simpleMessage("विवाद संसाधन तारीख"),
        "labelDisputeRaisedBy":
            MessageLookupByLibrary.simpleMessage("विवाद उठाया गया"),
        "labelDisputeRaisedDate":
            MessageLookupByLibrary.simpleMessage("विवाद उठाने की तारीख"),
        "labelDisputeReason":
            MessageLookupByLibrary.simpleMessage("विवाद कारण"),
        "labelDisputeRemark":
            MessageLookupByLibrary.simpleMessage("विवाद टिप्पणी"),
        "labelDisputesLowerCase": MessageLookupByLibrary.simpleMessage("विवाद"),
        "labelDistrict": MessageLookupByLibrary.simpleMessage("जिला"),
        "labelEmail": MessageLookupByLibrary.simpleMessage("ईमेल आईडी"),
        "labelEmailAndMobileNo":
            MessageLookupByLibrary.simpleMessage("ईमेल आईडी / मोबाइल नंबर"),
        "labelEntity": MessageLookupByLibrary.simpleMessage("संस्था"),
        "labelExitLane": MessageLookupByLibrary.simpleMessage("निकास लेन"),
        "labelFullName": MessageLookupByLibrary.simpleMessage("पूरा नाम"),
        "labelIFSC": MessageLookupByLibrary.simpleMessage("IFSC कोड"),
        "labelMobileNumber":
            MessageLookupByLibrary.simpleMessage("मोबाइल नंबर"),
        "labelNotFilled": MessageLookupByLibrary.simpleMessage("भरा नहीं गया"),
        "labelOperator": MessageLookupByLibrary.simpleMessage("ऑपरेटर"),
        "labelOr": MessageLookupByLibrary.simpleMessage("या"),
        "labelOwner": MessageLookupByLibrary.simpleMessage("मालिक"),
        "labelPassword": MessageLookupByLibrary.simpleMessage("पासवर्ड"),
        "labelPaymentAmount":
            MessageLookupByLibrary.simpleMessage("भुगतान राशि"),
        "labelPaymentDate": MessageLookupByLibrary.simpleMessage("भुगतान तिथि"),
        "labelPaymentStatus":
            MessageLookupByLibrary.simpleMessage("भुगतान स्थिति"),
        "labelPincode": MessageLookupByLibrary.simpleMessage("पिनकोड"),
        "labelPlazaOrgId":
            MessageLookupByLibrary.simpleMessage("प्लाज़ा संगठन ID"),
        "labelPlazaOwnerName":
            MessageLookupByLibrary.simpleMessage("प्लाजा मालिक का नाम"),
        "labelRole": MessageLookupByLibrary.simpleMessage("भूमिका"),
        "labelState": MessageLookupByLibrary.simpleMessage("राज्य"),
        "labelSubCategory": MessageLookupByLibrary.simpleMessage("उप श्रेणी"),
        "labelSubEntity": MessageLookupByLibrary.simpleMessage("उप-संस्था"),
        "labelTicket": MessageLookupByLibrary.simpleMessage("टिकट"),
        "labelTicketInformation":
            MessageLookupByLibrary.simpleMessage("टिकट जानकारी"),
        "labelTotalCharges": MessageLookupByLibrary.simpleMessage("कुल शुल्क"),
        "labelTotalTransactions":
            MessageLookupByLibrary.simpleMessage("कुल लेनदेन"),
        "labelTransactionsLowerCase":
            MessageLookupByLibrary.simpleMessage("लेनदेन"),
        "labelUsername": MessageLookupByLibrary.simpleMessage("उपयोगकर्ता नाम"),
        "laneFetchError": m11,
        "loadingMessage": MessageLookupByLibrary.simpleMessage(
            "कृपया प्रतीक्षा करें, हम आपके क्रेडेंशियल्स की पुष्टि कर रहे हैं..."),
        "locationFetchError": MessageLookupByLibrary.simpleMessage(
            "स्थान प्राप्त करने में त्रुटि:   "),
        "locationFetchTimeoutError": MessageLookupByLibrary.simpleMessage(
            "समय पर स्थान नहीं मिल सका। कृपया पुनः प्रयास करें।"),
        "locationNotAvailableError": MessageLookupByLibrary.simpleMessage(
            "स्थान डेटा उपलब्ध नहीं है। कृपया सुनिश्चित करें कि स्थान सेवाएं सक्षम हैं और अनुमतियां दी गई हैं।"),
        "locationPermissionDenied": MessageLookupByLibrary.simpleMessage(
            "स्थान अनुमति अस्वीकार कर दी गई।"),
        "locationPermissionDeniedForever": MessageLookupByLibrary.simpleMessage(
            "स्थान अनुमति हमेशा के लिए अस्वीकार कर दी गई।"),
        "locationRequired":
            MessageLookupByLibrary.simpleMessage("स्थान आवश्यक"),
        "locationServiceDisabled":
            MessageLookupByLibrary.simpleMessage("स्थान सेवा अक्षम है।"),
        "loginMessage": MessageLookupByLibrary.simpleMessage(
            "वापसी पर स्वागत है\nआपकी कमी महसूस हुई!"),
        "menuAddPlazaFare":
            MessageLookupByLibrary.simpleMessage("प्लाजा किराया जोड़ें"),
        "menuDisputes": MessageLookupByLibrary.simpleMessage("विवाद"),
        "menuMarkExit":
            MessageLookupByLibrary.simpleMessage("निकास चिह्नित करें"),
        "menuModifyViewPlaza": MessageLookupByLibrary.simpleMessage(
            "प्लाजा विवरण देखें/संपादित करें"),
        "menuModifyViewPlazaFare": MessageLookupByLibrary.simpleMessage(
            "प्लाजा किराया विवरण देखें/संपादित करें"),
        "menuModifyViewUser": MessageLookupByLibrary.simpleMessage(
            "उपयोगकर्ता विवरण देखें/संपादित करें"),
        "menuNewTicket": MessageLookupByLibrary.simpleMessage("नया टिकट"),
        "menuOpenTickets": MessageLookupByLibrary.simpleMessage("खुले टिकट"),
        "menuPlazaFare": MessageLookupByLibrary.simpleMessage("प्लाजा किराया"),
        "menuPlazas": MessageLookupByLibrary.simpleMessage("प्लाजा"),
        "menuProcessDispute":
            MessageLookupByLibrary.simpleMessage("विवाद प्रक्रिया करें"),
        "menuRaiseDispute": MessageLookupByLibrary.simpleMessage("विवाद उठाएं"),
        "menuRegisterPlaza":
            MessageLookupByLibrary.simpleMessage("नया प्लाजा पंजीकृत करें"),
        "menuRegisterUser":
            MessageLookupByLibrary.simpleMessage("नया उपयोगकर्ता पंजीकृत करें"),
        "menuRejectTicket":
            MessageLookupByLibrary.simpleMessage("टिकट अस्वीकार करें"),
        "menuResetPassword":
            MessageLookupByLibrary.simpleMessage("पासवर्ड रीसेट करें"),
        "menuSettings": MessageLookupByLibrary.simpleMessage("सेटिंग्स"),
        "menuTicketHistory":
            MessageLookupByLibrary.simpleMessage("टिकट इतिहास"),
        "menuTickets": MessageLookupByLibrary.simpleMessage("टिकट"),
        "menuTitle": MessageLookupByLibrary.simpleMessage("मेनू"),
        "menuUsers": MessageLookupByLibrary.simpleMessage("उपयोगकर्ता"),
        "menuViewDispute": MessageLookupByLibrary.simpleMessage("विवाद देखें"),
        "messageNoBankDetails":
            MessageLookupByLibrary.simpleMessage("कोई बैंक विवरण उपलब्ध नहीं"),
        "navAccount": MessageLookupByLibrary.simpleMessage("खाते"),
        "navDashboard": MessageLookupByLibrary.simpleMessage("डॅशबोर्ड"),
        "navMenu": MessageLookupByLibrary.simpleMessage("मेनू"),
        "navNotifications": MessageLookupByLibrary.simpleMessage("सूचना"),
        "navTransactions": MessageLookupByLibrary.simpleMessage("व्यवहार"),
        "networkError": MessageLookupByLibrary.simpleMessage(
            "एक नेटवर्क त्रुटि हुई। कृपया अपना कनेक्शन जांचें और पुनः प्रयास करें।"),
        "noInternetConnection": MessageLookupByLibrary.simpleMessage(
            "कोई इंटरनेट कनेक्शन नहीं। कृपया अपनी नेटवर्क सेटिंग्स जांचें।"),
        "noLanesFoundForPlaza": MessageLookupByLibrary.simpleMessage(
            "चयनित प्लाज़ा के लिए कोई लेन नहीं मिली।"),
        "noNewImagesToUpload": MessageLookupByLibrary.simpleMessage(
            "अपलोड करने के लिए कोई नई छवि नहीं"),
        "noPlazaAssigned":
            MessageLookupByLibrary.simpleMessage("कोई प्लाज़ा असाइन नहीं।"),
        "noPlazasFound": MessageLookupByLibrary.simpleMessage(
            "आपके खाते के लिए कोई प्लाज़ा नहीं मिला।"),
        "noUserIdError":
            MessageLookupByLibrary.simpleMessage("कोई उपयोगकर्ता ID नहीं।"),
        "plazaFetchError": m15,
        "registerMessage": MessageLookupByLibrary.simpleMessage(
            "हमारे प्लेटफ़ॉर्म का उपयोग करने के लिए एक खाता बनाएं।"),
        "requestTimeoutError": MessageLookupByLibrary.simpleMessage(
            "अनुरोध समय समाप्त हो गया। कृपया पुनः प्रयास करें।"),
        "serverConnectionError": MessageLookupByLibrary.simpleMessage(
            "सर्वर से कनेक्ट नहीं हो सका। कृपया बाद में पुनः प्रयास करें।"),
        "statusLabel": MessageLookupByLibrary.simpleMessage("स्थिति"),
        "successFareSubmission": MessageLookupByLibrary.simpleMessage(
            "सर्व भाडे यशस्वीरित्या सबमिट झाले आहेत!"),
        "successMessage": MessageLookupByLibrary.simpleMessage(
            "बधाई हो! आप सफलतापूर्वक लॉगिन हो गए हैं।"),
        "successProfileUpdate": MessageLookupByLibrary.simpleMessage(
            "प्रोफ़ाइल सफलतापूर्वक अपडेट हुई।"),
        "ticketMarkedExitSuccess":
            MessageLookupByLibrary.simpleMessage("निकास चिह्नित किया गया"),
        "titleAddFare": MessageLookupByLibrary.simpleMessage("किराया जोड़ें"),
        "titleDashboard": MessageLookupByLibrary.simpleMessage("डैशबोर्ड"),
        "titleDisputeList": MessageLookupByLibrary.simpleMessage("विवाद"),
        "titleForgotPassword":
            MessageLookupByLibrary.simpleMessage("पासवर्ड भूल गए"),
        "titleLoading": MessageLookupByLibrary.simpleMessage("लोड हो रहा है"),
        "titleLogin": MessageLookupByLibrary.simpleMessage("लॉगिन"),
        "titleMarkExit":
            MessageLookupByLibrary.simpleMessage("निकास चिह्नित करें"),
        "titleModifyViewFareDetails":
            MessageLookupByLibrary.simpleMessage("किराया विवरण"),
        "titleModifyViewTicketDetails":
            MessageLookupByLibrary.simpleMessage("टिकट विवरण"),
        "titleNewTicket": MessageLookupByLibrary.simpleMessage("नया टिकट"),
        "titleOpenTickets": MessageLookupByLibrary.simpleMessage("खुले टिकट"),
        "titleOtpVerification":
            MessageLookupByLibrary.simpleMessage("सत्यापन कोड"),
        "titlePlazaImages":
            MessageLookupByLibrary.simpleMessage("प्लाज़ा छवियां"),
        "titlePlazas": MessageLookupByLibrary.simpleMessage("प्लाजा"),
        "titleProcessDispute":
            MessageLookupByLibrary.simpleMessage("विवाद संसाधन"),
        "titleProcessingDispute":
            MessageLookupByLibrary.simpleMessage("विवाद संसाधन"),
        "titleRegister": MessageLookupByLibrary.simpleMessage("पंजीकरण"),
        "titleRejectTicket":
            MessageLookupByLibrary.simpleMessage("टिकट अस्वीकार करें"),
        "titleSetResetPassword":
            MessageLookupByLibrary.simpleMessage("सेट/रीसेट\nपासवर्ड"),
        "titleSetUsername":
            MessageLookupByLibrary.simpleMessage("उपयोगकर्ता नाम सेट करें"),
        "titleSuccess": MessageLookupByLibrary.simpleMessage("सफलता"),
        "titleTicketHistory":
            MessageLookupByLibrary.simpleMessage("टिकट इतिहास"),
        "titleUserInfo":
            MessageLookupByLibrary.simpleMessage("उपयोगकर्ता जानकारी"),
        "titleUsers": MessageLookupByLibrary.simpleMessage("उपयोगकर्ता"),
        "titleViewTicketDetails":
            MessageLookupByLibrary.simpleMessage("टिकट विवरण"),
        "tooltipEditBankDetails":
            MessageLookupByLibrary.simpleMessage("बैंक विवरण संपादित करें"),
        "tooltipEditBasicDetails":
            MessageLookupByLibrary.simpleMessage("मूल विवरण संपादित करें"),
        "tooltipEditImages":
            MessageLookupByLibrary.simpleMessage("छवियां संपादित करें"),
        "tryRefreshing": MessageLookupByLibrary.simpleMessage(
            "कृपया रीफ्रेश करने के लिए नीचे खींचें।"),
        "unauthorizedError": MessageLookupByLibrary.simpleMessage(
            "अनधिकृत। कृपया फिर से लॉगिन करें।"),
        "unexpectedErrorOccurred": m20,
        "unknownCode": MessageLookupByLibrary.simpleMessage("अज्ञात"),
        "unnamedPlaza": MessageLookupByLibrary.simpleMessage("अनाम प्लाज़ा"),
        "validationExactDigits": m24,
        "vehicleNumberRequiredError":
            MessageLookupByLibrary.simpleMessage("वाहन नंबर आवश्यक है।"),
        "vehicleNumberTooLongError": MessageLookupByLibrary.simpleMessage(
            "वाहन नंबर 20 अक्षरों से अधिक नहीं हो सकता।"),
        "vehicleTypeRequired":
            MessageLookupByLibrary.simpleMessage("वाहन प्रकार आवश्यक है।"),
        "verificationMessage": MessageLookupByLibrary.simpleMessage(
            "आपके मोबाइल नंबर पर सत्यापन कोड भेजा गया है।"),
        "warningMobileVerificationRequired":
            MessageLookupByLibrary.simpleMessage(
                "मोबाइल नंबर की पुष्टि आवश्यक है।"),
        "warningNoFaresAdded": MessageLookupByLibrary.simpleMessage(
            "सबमिट करण्यापूर्वी किमान एक भाडे जोडा."),
        "welcomeMessage": MessageLookupByLibrary.simpleMessage(
            "मर्चेंट ऐप में आपका स्वागत है!")
      };
}
