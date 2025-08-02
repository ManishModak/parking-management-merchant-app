// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `CityPark`
  String get appName {
    return Intl.message(
      'CityPark',
      name: 'appName',
      desc: '',
      args: [],
    );
  }

  /// `Menu`
  String get menuTitle {
    return Intl.message(
      'Menu',
      name: 'menuTitle',
      desc: '',
      args: [],
    );
  }

  /// `Plazas`
  String get menuPlazas {
    return Intl.message(
      'Plazas',
      name: 'menuPlazas',
      desc: '',
      args: [],
    );
  }

  /// `Users`
  String get menuUsers {
    return Intl.message(
      'Users',
      name: 'menuUsers',
      desc: '',
      args: [],
    );
  }

  /// `Disputes`
  String get menuDisputes {
    return Intl.message(
      'Disputes',
      name: 'menuDisputes',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get menuSettings {
    return Intl.message(
      'Settings',
      name: 'menuSettings',
      desc: '',
      args: [],
    );
  }

  /// `Plaza Fares`
  String get menuPlazaFare {
    return Intl.message(
      'Plaza Fares',
      name: 'menuPlazaFare',
      desc: '',
      args: [],
    );
  }

  /// `View/Edit Plaza Details`
  String get menuModifyViewPlaza {
    return Intl.message(
      'View/Edit Plaza Details',
      name: 'menuModifyViewPlaza',
      desc: '',
      args: [],
    );
  }

  /// `Register New Plaza`
  String get menuRegisterPlaza {
    return Intl.message(
      'Register New Plaza',
      name: 'menuRegisterPlaza',
      desc: '',
      args: [],
    );
  }

  /// `Register New User`
  String get menuRegisterUser {
    return Intl.message(
      'Register New User',
      name: 'menuRegisterUser',
      desc: '',
      args: [],
    );
  }

  /// `View/Edit User Details`
  String get menuModifyViewUser {
    return Intl.message(
      'View/Edit User Details',
      name: 'menuModifyViewUser',
      desc: '',
      args: [],
    );
  }

  /// `Raise Dispute`
  String get menuRaiseDispute {
    return Intl.message(
      'Raise Dispute',
      name: 'menuRaiseDispute',
      desc: '',
      args: [],
    );
  }

  /// `View Disputes`
  String get menuViewDispute {
    return Intl.message(
      'View Disputes',
      name: 'menuViewDispute',
      desc: '',
      args: [],
    );
  }

  /// `Process Dispute`
  String get menuProcessDispute {
    return Intl.message(
      'Process Dispute',
      name: 'menuProcessDispute',
      desc: '',
      args: [],
    );
  }

  /// `Reset Password`
  String get menuResetPassword {
    return Intl.message(
      'Reset Password',
      name: 'menuResetPassword',
      desc: '',
      args: [],
    );
  }

  /// `Add Plaza Fare`
  String get menuAddPlazaFare {
    return Intl.message(
      'Add Plaza Fare',
      name: 'menuAddPlazaFare',
      desc: '',
      args: [],
    );
  }

  /// `View/Edit Plaza\nFare Details`
  String get menuModifyViewPlazaFare {
    return Intl.message(
      'View/Edit Plaza\nFare Details',
      name: 'menuModifyViewPlazaFare',
      desc: '',
      args: [],
    );
  }

  /// `Loading Lanes Failed`
  String get errorLoadingLanesFailed {
    return Intl.message(
      'Loading Lanes Failed',
      name: 'errorLoadingLanesFailed',
      desc: '',
      args: [],
    );
  }

  /// `Tickets`
  String get menuTickets {
    return Intl.message(
      'Tickets',
      name: 'menuTickets',
      desc: '',
      args: [],
    );
  }

  /// `New Ticket`
  String get menuNewTicket {
    return Intl.message(
      'New Ticket',
      name: 'menuNewTicket',
      desc: '',
      args: [],
    );
  }

  /// `Open Tickets`
  String get menuOpenTickets {
    return Intl.message(
      'Open Tickets',
      name: 'menuOpenTickets',
      desc: '',
      args: [],
    );
  }

  /// `Reject Ticket`
  String get menuRejectTicket {
    return Intl.message(
      'Reject Ticket',
      name: 'menuRejectTicket',
      desc: '',
      args: [],
    );
  }

  /// `Ticket History`
  String get menuTicketHistory {
    return Intl.message(
      'Ticket History',
      name: 'menuTicketHistory',
      desc: '',
      args: [],
    );
  }

  /// `Error Loading Data`
  String get errorLoadingData {
    return Intl.message(
      'Error Loading Data',
      name: 'errorLoadingData',
      desc: '',
      args: [],
    );
  }

  /// `Company Type`
  String get labelCompanyType {
    return Intl.message(
      'Company Type',
      name: 'labelCompanyType',
      desc: '',
      args: [],
    );
  }

  /// `Company Name`
  String get labelCompanyName {
    return Intl.message(
      'Company Name',
      name: 'labelCompanyName',
      desc: '',
      args: [],
    );
  }

  /// `Plaza Org ID`
  String get labelPlazaOrgId {
    return Intl.message(
      'Plaza Org ID',
      name: 'labelPlazaOrgId',
      desc: '',
      args: [],
    );
  }

  /// `Failed To Pick Images: `
  String failedToPickImages(String error) {
    return Intl.message(
      'Failed To Pick Images: ',
      name: 'failedToPickImages',
      desc: 'Error message shown when image picking fails',
      args: [error],
    );
  }

  /// `Image Removed Successfully`
  String get imageRemovedSuccess {
    return Intl.message(
      'Image Removed Successfully',
      name: 'imageRemovedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Image Remove Failed`
  String get imageRemoveFailed {
    return Intl.message(
      'Image Remove Failed',
      name: 'imageRemoveFailed',
      desc: '',
      args: [],
    );
  }

  /// `Plaza Images`
  String get titlePlazaImages {
    return Intl.message(
      'Plaza Images',
      name: 'titlePlazaImages',
      desc: '',
      args: [],
    );
  }

  /// `Failed to refresh images: `
  String failedToRefreshImages(String error) {
    return Intl.message(
      'Failed to refresh images: ',
      name: 'failedToRefreshImages',
      desc: 'Error message shown when image refresh fails',
      args: [error],
    );
  }

  /// `{fieldName} must be exactly {digits} digits long.`
  String validationExactDigits(String fieldName, int digits) {
    return Intl.message(
      '$fieldName must be exactly $digits digits long.',
      name: 'validationExactDigits',
      desc: 'Validation error for a field needing an exact number of digits.',
      args: [fieldName, digits],
    );
  }

  /// `Edit Basic Details`
  String get tooltipEditBasicDetails {
    return Intl.message(
      'Edit Basic Details',
      name: 'tooltipEditBasicDetails',
      desc: '',
      args: [],
    );
  }

  /// `Owner`
  String get labelOwner {
    return Intl.message(
      'Owner',
      name: 'labelOwner',
      desc: '',
      args: [],
    );
  }

  /// `Operator`
  String get labelOperator {
    return Intl.message(
      'Operator',
      name: 'labelOperator',
      desc: '',
      args: [],
    );
  }

  /// `Sub Category`
  String get labelSubCategory {
    return Intl.message(
      'Sub Category',
      name: 'labelSubCategory',
      desc: '',
      args: [],
    );
  }

  /// `Edit Bank Details`
  String get tooltipEditBankDetails {
    return Intl.message(
      'Edit Bank Details',
      name: 'tooltipEditBankDetails',
      desc: '',
      args: [],
    );
  }

  /// `Account Holder`
  String get labelAccountHolder {
    return Intl.message(
      'Account Holder',
      name: 'labelAccountHolder',
      desc: '',
      args: [],
    );
  }

  /// `IFSC Code`
  String get labelIFSC {
    return Intl.message(
      'IFSC Code',
      name: 'labelIFSC',
      desc: '',
      args: [],
    );
  }

  /// `No bank details available`
  String get messageNoBankDetails {
    return Intl.message(
      'No bank details available',
      name: 'messageNoBankDetails',
      desc: '',
      args: [],
    );
  }

  /// `Edit Images`
  String get tooltipEditImages {
    return Intl.message(
      'Edit Images',
      name: 'tooltipEditImages',
      desc: '',
      args: [],
    );
  }

  /// `Image not found`
  String get errorImageNotFound {
    return Intl.message(
      'Image not found',
      name: 'errorImageNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Mark Exit`
  String get menuMarkExit {
    return Intl.message(
      'Mark Exit',
      name: 'menuMarkExit',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to the Merchant App!`
  String get welcomeMessage {
    return Intl.message(
      'Welcome to the Merchant App!',
      name: 'welcomeMessage',
      desc: '',
      args: [],
    );
  }

  /// `Welcome Back\nYou've Been Missed!`
  String get loginMessage {
    return Intl.message(
      'Welcome Back\nYou\'ve Been Missed!',
      name: 'loginMessage',
      desc: '',
      args: [],
    );
  }

  /// `Create An Account\nTo Explore Our Platform.`
  String get registerMessage {
    return Intl.message(
      'Create An Account\nTo Explore Our Platform.',
      name: 'registerMessage',
      desc: '',
      args: [],
    );
  }

  /// `A verification code has been sent to your mobile number.`
  String get verificationMessage {
    return Intl.message(
      'A verification code has been sent to your mobile number.',
      name: 'verificationMessage',
      desc: '',
      args: [],
    );
  }

  /// `Please wait while we verify your credentials...`
  String get loadingMessage {
    return Intl.message(
      'Please wait while we verify your credentials...',
      name: 'loadingMessage',
      desc: '',
      args: [],
    );
  }

  /// `Congratulations! You Have Been Successfully Registered.`
  String get successMessage {
    return Intl.message(
      'Congratulations! You Have Been Successfully Registered.',
      name: 'successMessage',
      desc: '',
      args: [],
    );
  }

  /// `LOGIN`
  String get buttonLogin {
    return Intl.message(
      'LOGIN',
      name: 'buttonLogin',
      desc: '',
      args: [],
    );
  }

  /// `REGISTER`
  String get buttonRegister {
    return Intl.message(
      'REGISTER',
      name: 'buttonRegister',
      desc: '',
      args: [],
    );
  }

  /// `CONTINUE`
  String get buttonContinue {
    return Intl.message(
      'CONTINUE',
      name: 'buttonContinue',
      desc: '',
      args: [],
    );
  }

  /// `No New Image To Upload`
  String get noNewImagesToUpload {
    return Intl.message(
      'No New Image To Upload',
      name: 'noNewImagesToUpload',
      desc: '',
      args: [],
    );
  }

  /// `Add Bank Details`
  String get addBankDetailsAction {
    return Intl.message(
      'Add Bank Details',
      name: 'addBankDetailsAction',
      desc: '',
      args: [],
    );
  }

  /// `CONFIRM`
  String get buttonConfirm {
    return Intl.message(
      'CONFIRM',
      name: 'buttonConfirm',
      desc: '',
      args: [],
    );
  }

  /// `RESET\nPASSWORD`
  String get buttonSetResetPassword {
    return Intl.message(
      'RESET\nPASSWORD',
      name: 'buttonSetResetPassword',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get titleLogin {
    return Intl.message(
      'Login',
      name: 'titleLogin',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get titleRegister {
    return Intl.message(
      'Register',
      name: 'titleRegister',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Password`
  String get titleForgotPassword {
    return Intl.message(
      'Forgot Password',
      name: 'titleForgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Verification Code`
  String get titleOtpVerification {
    return Intl.message(
      'Verification Code',
      name: 'titleOtpVerification',
      desc: '',
      args: [],
    );
  }

  /// `Loading`
  String get titleLoading {
    return Intl.message(
      'Loading',
      name: 'titleLoading',
      desc: '',
      args: [],
    );
  }

  /// `Success`
  String get titleSuccess {
    return Intl.message(
      'Success',
      name: 'titleSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Plazas`
  String get titlePlazas {
    return Intl.message(
      'Plazas',
      name: 'titlePlazas',
      desc: '',
      args: [],
    );
  }

  /// `Dashboard`
  String get titleDashboard {
    return Intl.message(
      'Dashboard',
      name: 'titleDashboard',
      desc: '',
      args: [],
    );
  }

  /// `Set Username`
  String get titleSetUsername {
    return Intl.message(
      'Set Username',
      name: 'titleSetUsername',
      desc: '',
      args: [],
    );
  }

  /// `Users`
  String get titleUsers {
    return Intl.message(
      'Users',
      name: 'titleUsers',
      desc: '',
      args: [],
    );
  }

  /// `User Info`
  String get titleUserInfo {
    return Intl.message(
      'User Info',
      name: 'titleUserInfo',
      desc: '',
      args: [],
    );
  }

  /// `Set/Reset\nPassword`
  String get titleSetResetPassword {
    return Intl.message(
      'Set/Reset\nPassword',
      name: 'titleSetResetPassword',
      desc: '',
      args: [],
    );
  }

  /// `Add Fare`
  String get titleAddFare {
    return Intl.message(
      'Add Fare',
      name: 'titleAddFare',
      desc: '',
      args: [],
    );
  }

  /// `Fare Details`
  String get titleModifyViewFareDetails {
    return Intl.message(
      'Fare Details',
      name: 'titleModifyViewFareDetails',
      desc: '',
      args: [],
    );
  }

  /// `New Ticket`
  String get titleNewTicket {
    return Intl.message(
      'New Ticket',
      name: 'titleNewTicket',
      desc: '',
      args: [],
    );
  }

  /// `Open Tickets`
  String get titleOpenTickets {
    return Intl.message(
      'Open Tickets',
      name: 'titleOpenTickets',
      desc: '',
      args: [],
    );
  }

  /// `Reject Ticket`
  String get titleRejectTicket {
    return Intl.message(
      'Reject Ticket',
      name: 'titleRejectTicket',
      desc: '',
      args: [],
    );
  }

  /// `Ticket History`
  String get titleTicketHistory {
    return Intl.message(
      'Ticket History',
      name: 'titleTicketHistory',
      desc: '',
      args: [],
    );
  }

  /// `Mark Exit`
  String get titleMarkExit {
    return Intl.message(
      'Mark Exit',
      name: 'titleMarkExit',
      desc: '',
      args: [],
    );
  }

  /// `Ticket Details`
  String get titleModifyViewTicketDetails {
    return Intl.message(
      'Ticket Details',
      name: 'titleModifyViewTicketDetails',
      desc: '',
      args: [],
    );
  }

  /// `Ticket Details`
  String get titleViewTicketDetails {
    return Intl.message(
      'Ticket Details',
      name: 'titleViewTicketDetails',
      desc: '',
      args: [],
    );
  }

  /// `Total Transactions`
  String get labelTotalTransactions {
    return Intl.message(
      'Total Transactions',
      name: 'labelTotalTransactions',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't load this section.`
  String get errorFailedToLoadSection {
    return Intl.message(
      'Couldn\'t load this section.',
      name: 'errorFailedToLoadSection',
      desc: '',
      args: [],
    );
  }

  /// `Please pull down to refresh.`
  String get tryRefreshing {
    return Intl.message(
      'Please pull down to refresh.',
      name: 'tryRefreshing',
      desc: '',
      args: [],
    );
  }

  /// `disputes`
  String get labelDisputesLowerCase {
    return Intl.message(
      'disputes',
      name: 'labelDisputesLowerCase',
      desc: '',
      args: [],
    );
  }

  /// `transactions`
  String get labelTransactionsLowerCase {
    return Intl.message(
      'transactions',
      name: 'labelTransactionsLowerCase',
      desc: '',
      args: [],
    );
  }

  /// `No Access`
  String get errorNoAccess {
    return Intl.message(
      'No Access',
      name: 'errorNoAccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load plaza options. Please check your connection and try again.`
  String get errorFailedToLoadPlazas {
    return Intl.message(
      'Failed to load plaza options. Please check your connection and try again.',
      name: 'errorFailedToLoadPlazas',
      desc: '',
      args: [],
    );
  }

  /// `No plazas are currently assigned to your account. Please contact support if you believe this is an error.`
  String get errorNoPlazasAssigned {
    return Intl.message(
      'No plazas are currently assigned to your account. Please contact support if you believe this is an error.',
      name: 'errorNoPlazasAssigned',
      desc: '',
      args: [],
    );
  }

  /// `You do not have access to view plaza-specific data.`
  String get errorNoAccessToPlazaData {
    return Intl.message(
      'You do not have access to view plaza-specific data.',
      name: 'errorNoAccessToPlazaData',
      desc: '',
      args: [],
    );
  }

  /// `Data not found. Please pull to refresh or try again later.`
  String get errorDataNotFoundGeneric {
    return Intl.message(
      'Data not found. Please pull to refresh or try again later.',
      name: 'errorDataNotFoundGeneric',
      desc: '',
      args: [],
    );
  }

  /// `Could not load ticket overview. Please try refreshing.`
  String get errorDataNotFoundTicketOverview {
    return Intl.message(
      'Could not load ticket overview. Please try refreshing.',
      name: 'errorDataNotFoundTicketOverview',
      desc: '',
      args: [],
    );
  }

  /// `Could not load plaza summary. Please try refreshing.`
  String get errorDataNotFoundPlazaSummary {
    return Intl.message(
      'Could not load plaza summary. Please try refreshing.',
      name: 'errorDataNotFoundPlazaSummary',
      desc: '',
      args: [],
    );
  }

  /// `Could not load booking analysis. Please try refreshing.`
  String get errorDataNotFoundBookingAnalysis {
    return Intl.message(
      'Could not load booking analysis. Please try refreshing.',
      name: 'errorDataNotFoundBookingAnalysis',
      desc: '',
      args: [],
    );
  }

  /// `Could not load dispute summary. Please try refreshing.`
  String get errorDataNotFoundDisputeSummary {
    return Intl.message(
      'Could not load dispute summary. Please try refreshing.',
      name: 'errorDataNotFoundDisputeSummary',
      desc: '',
      args: [],
    );
  }

  /// `Could not load payment analysis. Please try refreshing.`
  String get errorDataNotFoundPaymentAnalysis {
    return Intl.message(
      'Could not load payment analysis. Please try refreshing.',
      name: 'errorDataNotFoundPaymentAnalysis',
      desc: '',
      args: [],
    );
  }

  /// `No data available to display.`
  String get labelNoDataAvailable {
    return Intl.message(
      'No data available to display.',
      name: 'labelNoDataAvailable',
      desc: '',
      args: [],
    );
  }

  /// `This feature is coming soon!`
  String get featureComingSoon {
    return Intl.message(
      'This feature is coming soon!',
      name: 'featureComingSoon',
      desc: '',
      args: [],
    );
  }

  /// `Export Report`
  String get exportReport {
    return Intl.message(
      'Export Report',
      name: 'exportReport',
      desc: '',
      args: [],
    );
  }

  /// `Available Slots`
  String get labelAvailableSlots {
    return Intl.message(
      'Available Slots',
      name: 'labelAvailableSlots',
      desc: '',
      args: [],
    );
  }

  /// `Disputes`
  String get titleDisputeList {
    return Intl.message(
      'Disputes',
      name: 'titleDisputeList',
      desc: '',
      args: [],
    );
  }

  /// `Status`
  String get statusLabel {
    return Intl.message(
      'Status',
      name: 'statusLabel',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get labelPassword {
    return Intl.message(
      'Password',
      name: 'labelPassword',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get labelConfirmPassword {
    return Intl.message(
      'Confirm Password',
      name: 'labelConfirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Email ID / Mobile No.`
  String get labelEmailAndMobileNo {
    return Intl.message(
      'Email ID / Mobile No.',
      name: 'labelEmailAndMobileNo',
      desc: '',
      args: [],
    );
  }

  /// `Full Name`
  String get labelFullName {
    return Intl.message(
      'Full Name',
      name: 'labelFullName',
      desc: '',
      args: [],
    );
  }

  /// `Plaza Owner Name`
  String get labelPlazaOwnerName {
    return Intl.message(
      'Plaza Owner Name',
      name: 'labelPlazaOwnerName',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get labelUsername {
    return Intl.message(
      'Username',
      name: 'labelUsername',
      desc: '',
      args: [],
    );
  }

  /// `Role`
  String get labelRole {
    return Intl.message(
      'Role',
      name: 'labelRole',
      desc: '',
      args: [],
    );
  }

  /// `Assign Role`
  String get labelAssignRole {
    return Intl.message(
      'Assign Role',
      name: 'labelAssignRole',
      desc: '',
      args: [],
    );
  }

  /// `Processing Dispute`
  String get titleProcessingDispute {
    return Intl.message(
      'Processing Dispute',
      name: 'titleProcessingDispute',
      desc: '',
      args: [],
    );
  }

  /// `Ticket`
  String get labelTicket {
    return Intl.message(
      'Ticket',
      name: 'labelTicket',
      desc: '',
      args: [],
    );
  }

  /// `Payment Amount`
  String get labelPaymentAmount {
    return Intl.message(
      'Payment Amount',
      name: 'labelPaymentAmount',
      desc: '',
      args: [],
    );
  }

  /// `Payment Date`
  String get labelPaymentDate {
    return Intl.message(
      'Payment Date',
      name: 'labelPaymentDate',
      desc: '',
      args: [],
    );
  }

  /// `Expiry Date`
  String get labelDisputeExpiryDate {
    return Intl.message(
      'Expiry Date',
      name: 'labelDisputeExpiryDate',
      desc: '',
      args: [],
    );
  }

  /// `Dispute Reason`
  String get labelDisputeReason {
    return Intl.message(
      'Dispute Reason',
      name: 'labelDisputeReason',
      desc: '',
      args: [],
    );
  }

  /// `Dispute Amount`
  String get labelDisputeAmount {
    return Intl.message(
      'Dispute Amount',
      name: 'labelDisputeAmount',
      desc: '',
      args: [],
    );
  }

  /// `Dispute Remark`
  String get labelDisputeRemark {
    return Intl.message(
      'Dispute Remark',
      name: 'labelDisputeRemark',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load dispute details`
  String get errorLoadDisputeDetails {
    return Intl.message(
      'Failed to load dispute details',
      name: 'errorLoadDisputeDetails',
      desc: '',
      args: [],
    );
  }

  /// `Process Dispute`
  String get buttonProcessDispute {
    return Intl.message(
      'Process Dispute',
      name: 'buttonProcessDispute',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get buttonClose {
    return Intl.message(
      'Close',
      name: 'buttonClose',
      desc: '',
      args: [],
    );
  }

  /// `Audit Details`
  String get labelAuditDetails {
    return Intl.message(
      'Audit Details',
      name: 'labelAuditDetails',
      desc: '',
      args: [],
    );
  }

  /// `Dispute Information`
  String get labelDisputeInformation {
    return Intl.message(
      'Dispute Information',
      name: 'labelDisputeInformation',
      desc: '',
      args: [],
    );
  }

  /// `Dispute Raised By`
  String get labelDisputeRaisedBy {
    return Intl.message(
      'Dispute Raised By',
      name: 'labelDisputeRaisedBy',
      desc: '',
      args: [],
    );
  }

  /// `Dispute Raised Date`
  String get labelDisputeRaisedDate {
    return Intl.message(
      'Dispute Raised Date',
      name: 'labelDisputeRaisedDate',
      desc: '',
      args: [],
    );
  }

  /// `Dispute Processed By`
  String get labelDisputeProcessedBy {
    return Intl.message(
      'Dispute Processed By',
      name: 'labelDisputeProcessedBy',
      desc: '',
      args: [],
    );
  }

  /// `Dispute Processed Date`
  String get labelDisputeProcessedDate {
    return Intl.message(
      'Dispute Processed Date',
      name: 'labelDisputeProcessedDate',
      desc: '',
      args: [],
    );
  }

  /// `Ticket Information`
  String get labelTicketInformation {
    return Intl.message(
      'Ticket Information',
      name: 'labelTicketInformation',
      desc: '',
      args: [],
    );
  }

  /// `Exit Lane`
  String get labelExitLane {
    return Intl.message(
      'Exit Lane',
      name: 'labelExitLane',
      desc: '',
      args: [],
    );
  }

  /// `Total Charges`
  String get labelTotalCharges {
    return Intl.message(
      'Total Charges',
      name: 'labelTotalCharges',
      desc: '',
      args: [],
    );
  }

  /// `Payment Status`
  String get labelPaymentStatus {
    return Intl.message(
      'Payment Status',
      name: 'labelPaymentStatus',
      desc: '',
      args: [],
    );
  }

  /// `Not filled`
  String get labelNotFilled {
    return Intl.message(
      'Not filled',
      name: 'labelNotFilled',
      desc: '',
      args: [],
    );
  }

  /// `Process Dispute`
  String get titleProcessDispute {
    return Intl.message(
      'Process Dispute',
      name: 'titleProcessDispute',
      desc: '',
      args: [],
    );
  }

  /// `Dispute Action`
  String get labelDisputeAction {
    return Intl.message(
      'Dispute Action',
      name: 'labelDisputeAction',
      desc: '',
      args: [],
    );
  }

  /// `Error processing image: {details}`
  String imageProcessingError(String details) {
    return Intl.message(
      'Error processing image: $details',
      name: 'imageProcessingError',
      desc: 'Message displayed when an error occurs during image processing.',
      args: [details],
    );
  }

  /// `You do not have permission to view the dashboard.`
  String get errorNoAccessToDashboard {
    return Intl.message(
      'You do not have permission to view the dashboard.',
      name: 'errorNoAccessToDashboard',
      desc: '',
      args: [],
    );
  }

  /// `Error loading dashboard configuration`
  String get errorLoadingDashboardConfig {
    return Intl.message(
      'Error loading dashboard configuration',
      name: 'errorLoadingDashboardConfig',
      desc: '',
      args: [],
    );
  }

  /// `Plaza Owner configuration is incomplete. Please contact support.`
  String get errorPlazaOwnerEntityIdMissing {
    return Intl.message(
      'Plaza Owner configuration is incomplete. Please contact support.',
      name: 'errorPlazaOwnerEntityIdMissing',
      desc: '',
      args: [],
    );
  }

  /// `No plazas are configured for your account. Please contact support.`
  String get errorAdminOperatorNoPlazasConfigured {
    return Intl.message(
      'No plazas are configured for your account. Please contact support.',
      name: 'errorAdminOperatorNoPlazasConfigured',
      desc: '',
      args: [],
    );
  }

  /// `You are not assigned to any plazas. Please contact your administrator.`
  String get errorAdminOperatorNoPlazasAssigned {
    return Intl.message(
      'You are not assigned to any plazas. Please contact your administrator.',
      name: 'errorAdminOperatorNoPlazasAssigned',
      desc: '',
      args: [],
    );
  }

  /// `No dispute data to display`
  String get labelNoDisputesData {
    return Intl.message(
      'No dispute data to display',
      name: 'labelNoDisputesData',
      desc: '',
      args: [],
    );
  }

  /// `No payment data to display`
  String get labelNoPaymentData {
    return Intl.message(
      'No payment data to display',
      name: 'labelNoPaymentData',
      desc: '',
      args: [],
    );
  }

  /// `vs previous period`
  String get labelVsPreviousPeriod {
    return Intl.message(
      'vs previous period',
      name: 'labelVsPreviousPeriod',
      desc: '',
      args: [],
    );
  }

  /// `Failed to initialize the screen: {details}`
  String initializationError(String details) {
    return Intl.message(
      'Failed to initialize the screen: $details',
      name: 'initializationError',
      desc: 'Error message when the screen/viewmodel fails to initialize.',
      args: [details],
    );
  }

  /// `Could not get location in time. Please try again.`
  String get locationFetchTimeoutError {
    return Intl.message(
      'Could not get location in time. Please try again.',
      name: 'locationFetchTimeoutError',
      desc: 'Error message when fetching GPS location times out.',
      args: [],
    );
  }

  /// `Location data is not available. Please ensure location services are enabled and permissions are granted.`
  String get locationNotAvailableError {
    return Intl.message(
      'Location data is not available. Please ensure location services are enabled and permissions are granted.',
      name: 'locationNotAvailableError',
      desc:
          'Error displayed during form validation if location data was not successfully fetched.',
      args: [],
    );
  }

  /// `No plazas found for your account.`
  String get noPlazasFound {
    return Intl.message(
      'No plazas found for your account.',
      name: 'noPlazasFound',
      desc:
          'Message displayed when a Plaza Owner has no plazas associated with their account.',
      args: [],
    );
  }

  /// `Unnamed Plaza`
  String get unnamedPlaza {
    return Intl.message(
      'Unnamed Plaza',
      name: 'unnamedPlaza',
      desc: 'Default name for a plaza if its name is missing.',
      args: [],
    );
  }

  /// `No lanes found for the selected plaza.`
  String get noLanesFoundForPlaza {
    return Intl.message(
      'No lanes found for the selected plaza.',
      name: 'noLanesFoundForPlaza',
      desc: 'Message displayed if a selected plaza has no lanes configured.',
      args: [],
    );
  }

  /// `Vehicle number is required.`
  String get vehicleNumberRequiredError {
    return Intl.message(
      'Vehicle number is required.',
      name: 'vehicleNumberRequiredError',
      desc:
          'Validation error if the vehicle number is empty for manual ticket.',
      args: [],
    );
  }

  /// `Vehicle number cannot exceed 20 characters.`
  String get vehicleNumberTooLongError {
    return Intl.message(
      'Vehicle number cannot exceed 20 characters.',
      name: 'vehicleNumberTooLongError',
      desc: 'Validation error if the vehicle number is too long.',
      args: [],
    );
  }

  /// `Internal Server Error. Please try again later.`
  String get internalServerError {
    return Intl.message(
      'Internal Server Error. Please try again later.',
      name: 'internalServerError',
      desc: 'Error message for HTTP 500 responses.',
      args: [],
    );
  }

  /// `Bad request. Please check your input and try again.`
  String get badRequestError {
    return Intl.message(
      'Bad request. Please check your input and try again.',
      name: 'badRequestError',
      desc:
          'Error message for HTTP 400 responses when no specific server message is available.',
      args: [],
    );
  }

  /// `Unauthorized. Please login again.`
  String get unauthorizedError {
    return Intl.message(
      'Unauthorized. Please login again.',
      name: 'unauthorizedError',
      desc: 'Error message for HTTP 401 responses.',
      args: [],
    );
  }

  /// `Access denied. You do not have permission to perform this action.`
  String get forbiddenError {
    return Intl.message(
      'Access denied. You do not have permission to perform this action.',
      name: 'forbiddenError',
      desc: 'Error message for HTTP 403 responses.',
      args: [],
    );
  }

  /// `Request failed. Status: {code}`
  String httpRequestFailedWithCode(String code) {
    return Intl.message(
      'Request failed. Status: $code',
      name: 'httpRequestFailedWithCode',
      desc:
          'Generic error message for HTTP requests that fail with a status code.',
      args: [code],
    );
  }

  /// `Unknown`
  String get unknownCode {
    return Intl.message(
      'Unknown',
      name: 'unknownCode',
      desc: 'Placeholder for an unknown HTTP status code.',
      args: [],
    );
  }

  /// `No internet connection. Please check your network settings.`
  String get noInternetConnection {
    return Intl.message(
      'No internet connection. Please check your network settings.',
      name: 'noInternetConnection',
      desc: 'Error message when there is no internet connectivity.',
      args: [],
    );
  }

  /// `Could not connect to the server. Please try again later.`
  String get serverConnectionError {
    return Intl.message(
      'Could not connect to the server. Please try again later.',
      name: 'serverConnectionError',
      desc: 'Error message when the app cannot connect to the backend server.',
      args: [],
    );
  }

  /// `The request timed out. Please try again.`
  String get requestTimeoutError {
    return Intl.message(
      'The request timed out. Please try again.',
      name: 'requestTimeoutError',
      desc: 'Error message when an HTTP request times out.',
      args: [],
    );
  }

  /// `A network error occurred. Please check your connection and try again.`
  String get networkError {
    return Intl.message(
      'A network error occurred. Please check your connection and try again.',
      name: 'networkError',
      desc:
          'Generic error message for network-related issues like SocketException.',
      args: [],
    );
  }

  /// `An unexpected error occurred: {details}`
  String unexpectedErrorOccurred(String details) {
    return Intl.message(
      'An unexpected error occurred: $details',
      name: 'unexpectedErrorOccurred',
      desc: 'Generic error message for any other unhandled exceptions.',
      args: [details],
    );
  }

  /// `No plaza assigned. Cannot proceed.`
  String get noPlazaAssignedWidgetError {
    return Intl.message(
      'No plaza assigned. Cannot proceed.',
      name: 'noPlazaAssignedWidgetError',
      desc:
          'Error message shown in the widget UI if no plaza is assigned (for Plaza Admin/Operator).',
      args: [],
    );
  }

  /// `Dispute processed successfully!`
  String get messageDisputeProcessed {
    return Intl.message(
      'Dispute processed successfully!',
      name: 'messageDisputeProcessed',
      desc: '',
      args: [],
    );
  }

  /// `Failed to process dispute`
  String get errorProcessDispute {
    return Intl.message(
      'Failed to process dispute',
      name: 'errorProcessDispute',
      desc: '',
      args: [],
    );
  }

  /// `No files selected`
  String get errorNoFilesSelected {
    return Intl.message(
      'No files selected',
      name: 'errorNoFilesSelected',
      desc: '',
      args: [],
    );
  }

  /// `Error picking files`
  String get errorPickingFiles {
    return Intl.message(
      'Error picking files',
      name: 'errorPickingFiles',
      desc: '',
      args: [],
    );
  }

  /// `Calculating...`
  String get labelCalculating {
    return Intl.message(
      'Calculating...',
      name: 'labelCalculating',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get labelPending {
    return Intl.message(
      'Pending',
      name: 'labelPending',
      desc: '',
      args: [],
    );
  }

  /// `Pay via UPI`
  String get buttonPayUpi {
    return Intl.message(
      'Pay via UPI',
      name: 'buttonPayUpi',
      desc: '',
      args: [],
    );
  }

  /// `Pay via Card (NFC)`
  String get buttonPayNfc {
    return Intl.message(
      'Pay via Card (NFC)',
      name: 'buttonPayNfc',
      desc: '',
      args: [],
    );
  }

  /// `Pay with Cash`
  String get buttonPayCash {
    return Intl.message(
      'Pay with Cash',
      name: 'buttonPayCash',
      desc: '',
      args: [],
    );
  }

  /// `Invalid amount for payment`
  String get errorInvalidAmount {
    return Intl.message(
      'Invalid amount for payment',
      name: 'errorInvalidAmount',
      desc: '',
      args: [],
    );
  }

  /// `Failed to retrieve QR code URL`
  String get errorQrCodeFailed {
    return Intl.message(
      'Failed to retrieve QR code URL',
      name: 'errorQrCodeFailed',
      desc: '',
      args: [],
    );
  }

  /// `This device does not support NFC`
  String get errorNfcNotSupported {
    return Intl.message(
      'This device does not support NFC',
      name: 'errorNfcNotSupported',
      desc: '',
      args: [],
    );
  }

  /// `Please enable NFC in Settings`
  String get errorNfcDisabled {
    return Intl.message(
      'Please enable NFC in Settings',
      name: 'errorNfcDisabled',
      desc: '',
      args: [],
    );
  }

  /// `EMV card detected - processing...`
  String get messageEmvCardDetected {
    return Intl.message(
      'EMV card detected - processing...',
      name: 'messageEmvCardDetected',
      desc: '',
      args: [],
    );
  }

  /// `Unsupported card type`
  String get errorUnsupportedCard {
    return Intl.message(
      'Unsupported card type',
      name: 'errorUnsupportedCard',
      desc: '',
      args: [],
    );
  }

  /// `NFC Error`
  String get errorNfc {
    return Intl.message(
      'NFC Error',
      name: 'errorNfc',
      desc: '',
      args: [],
    );
  }

  /// `Please pay cash at the exit gate`
  String get messagePayCash {
    return Intl.message(
      'Please pay cash at the exit gate',
      name: 'messagePayCash',
      desc: '',
      args: [],
    );
  }

  /// `No dispute data available`
  String get messageNoDisputeData {
    return Intl.message(
      'No dispute data available',
      name: 'messageNoDisputeData',
      desc: '',
      args: [],
    );
  }

  /// `Raise Dispute`
  String get titleRaiseDispute {
    return Intl.message(
      'Raise Dispute',
      name: 'titleRaiseDispute',
      desc: '',
      args: [],
    );
  }

  /// `Enter Remark`
  String get labelEnterRemark {
    return Intl.message(
      'Enter Remark',
      name: 'labelEnterRemark',
      desc: '',
      args: [],
    );
  }

  /// `Uploaded Files`
  String get labelUploadedFiles {
    return Intl.message(
      'Uploaded Files',
      name: 'labelUploadedFiles',
      desc: '',
      args: [],
    );
  }

  /// `Add More`
  String get buttonAddMore {
    return Intl.message(
      'Add More',
      name: 'buttonAddMore',
      desc: '',
      args: [],
    );
  }

  /// `Tap to Add Images or PDFs`
  String get labelAddImagesOrPdfs {
    return Intl.message(
      'Tap to Add Images or PDFs',
      name: 'labelAddImagesOrPdfs',
      desc: '',
      args: [],
    );
  }

  /// `Invalid ticket creation time format`
  String get errorInvalidTimeFormat {
    return Intl.message(
      'Invalid ticket creation time format',
      name: 'errorInvalidTimeFormat',
      desc: '',
      args: [],
    );
  }

  /// `Dispute raised successfully!`
  String get messageDisputeRaised {
    return Intl.message(
      'Dispute raised successfully!',
      name: 'messageDisputeRaised',
      desc: '',
      args: [],
    );
  }

  /// `Entity`
  String get labelEntity {
    return Intl.message(
      'Entity',
      name: 'labelEntity',
      desc: '',
      args: [],
    );
  }

  /// `Sub-Entity`
  String get labelSubEntity {
    return Intl.message(
      'Sub-Entity',
      name: 'labelSubEntity',
      desc: '',
      args: [],
    );
  }

  /// `Select Company Type`
  String get selectCompanyType {
    return Intl.message(
      'Select Company Type',
      name: 'selectCompanyType',
      desc: '',
      args: [],
    );
  }

  /// `Company name is required`
  String get errorCompanyNameRequired {
    return Intl.message(
      'Company name is required',
      name: 'errorCompanyNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Company name must be between 3 and 50 characters`
  String get errorCompanyNameLength {
    return Intl.message(
      'Company name must be between 3 and 50 characters',
      name: 'errorCompanyNameLength',
      desc: '',
      args: [],
    );
  }

  /// `Company type is required`
  String get errorCompanyTypeRequired {
    return Intl.message(
      'Company type is required',
      name: 'errorCompanyTypeRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please select a valid company type`
  String get errorCompanyTypeInvalid {
    return Intl.message(
      'Please select a valid company type',
      name: 'errorCompanyTypeInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Individual`
  String get companyTypeIndividual {
    return Intl.message(
      'Individual',
      name: 'companyTypeIndividual',
      desc: '',
      args: [],
    );
  }

  /// `LLP`
  String get companyTypeLLP {
    return Intl.message(
      'LLP',
      name: 'companyTypeLLP',
      desc: '',
      args: [],
    );
  }

  /// `Private Limited`
  String get companyTypePrivateLimited {
    return Intl.message(
      'Private Limited',
      name: 'companyTypePrivateLimited',
      desc: '',
      args: [],
    );
  }

  /// `Public Limited`
  String get companyTypePublicLimited {
    return Intl.message(
      'Public Limited',
      name: 'companyTypePublicLimited',
      desc: '',
      args: [],
    );
  }

  /// `Aadhaar Number`
  String get labelAadhaarNumber {
    return Intl.message(
      'Aadhaar Number',
      name: 'labelAadhaarNumber',
      desc: '',
      args: [],
    );
  }

  /// `Aadhaar number must be 12 digits`
  String get errorAadhaarInvalid {
    return Intl.message(
      'Aadhaar number must be 12 digits',
      name: 'errorAadhaarInvalid',
      desc: '',
      args: [],
    );
  }

  /// `PAN Number`
  String get labelPanNumber {
    return Intl.message(
      'PAN Number',
      name: 'labelPanNumber',
      desc: '',
      args: [],
    );
  }

  /// `PAN number must be 5 letters, 4 digits, 1 letter`
  String get errorPanInvalid {
    return Intl.message(
      'PAN number must be 5 letters, 4 digits, 1 letter',
      name: 'errorPanInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Bank Name`
  String get labelBankName {
    return Intl.message(
      'Bank Name',
      name: 'labelBankName',
      desc: '',
      args: [],
    );
  }

  /// `Bank name must be 100 characters or less`
  String get errorBankNameLength {
    return Intl.message(
      'Bank name must be 100 characters or less',
      name: 'errorBankNameLength',
      desc: '',
      args: [],
    );
  }

  /// `Account Number`
  String get labelAccountNumber {
    return Intl.message(
      'Account Number',
      name: 'labelAccountNumber',
      desc: '',
      args: [],
    );
  }

  /// `Account number must be numeric`
  String get errorAccountNumberInvalid {
    return Intl.message(
      'Account number must be numeric',
      name: 'errorAccountNumberInvalid',
      desc: '',
      args: [],
    );
  }

  /// `IFSC Code`
  String get labelIfscCode {
    return Intl.message(
      'IFSC Code',
      name: 'labelIfscCode',
      desc: '',
      args: [],
    );
  }

  /// `IFSC code must be 4 letters, 0, then 6 alphanumeric characters`
  String get errorIfscInvalid {
    return Intl.message(
      'IFSC code must be 4 letters, 0, then 6 alphanumeric characters',
      name: 'errorIfscInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Username is required`
  String get errorUsernameRequired {
    return Intl.message(
      'Username is required',
      name: 'errorUsernameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Username must be between 3 and 50 characters`
  String get errorUsernameLength {
    return Intl.message(
      'Username must be between 3 and 50 characters',
      name: 'errorUsernameLength',
      desc: '',
      args: [],
    );
  }

  /// `Full name is required`
  String get errorFullNameRequired {
    return Intl.message(
      'Full name is required',
      name: 'errorFullNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Full name must be between 3 and 50 characters`
  String get errorFullNameLength {
    return Intl.message(
      'Full name must be between 3 and 50 characters',
      name: 'errorFullNameLength',
      desc: '',
      args: [],
    );
  }

  /// `Mobile number is required`
  String get errorMobileRequired {
    return Intl.message(
      'Mobile number is required',
      name: 'errorMobileRequired',
      desc: '',
      args: [],
    );
  }

  /// `Mobile number must be 10 digits`
  String get errorMobileInvalidFormat {
    return Intl.message(
      'Mobile number must be 10 digits',
      name: 'errorMobileInvalidFormat',
      desc: '',
      args: [],
    );
  }

  /// `Email is required`
  String get errorEmailRequired {
    return Intl.message(
      'Email is required',
      name: 'errorEmailRequired',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email format`
  String get errorEmailInvalid {
    return Intl.message(
      'Invalid email format',
      name: 'errorEmailInvalid',
      desc: '',
      args: [],
    );
  }

  /// `City is required`
  String get errorCityRequired {
    return Intl.message(
      'City is required',
      name: 'errorCityRequired',
      desc: '',
      args: [],
    );
  }

  /// `City must be 50 characters or less`
  String get errorCityLength {
    return Intl.message(
      'City must be 50 characters or less',
      name: 'errorCityLength',
      desc: '',
      args: [],
    );
  }

  /// `State is required`
  String get errorStateRequired {
    return Intl.message(
      'State is required',
      name: 'errorStateRequired',
      desc: '',
      args: [],
    );
  }

  /// `State must be 50 characters or less`
  String get errorStateLength {
    return Intl.message(
      'State must be 50 characters or less',
      name: 'errorStateLength',
      desc: '',
      args: [],
    );
  }

  /// `Address is required`
  String get errorAddressRequired {
    return Intl.message(
      'Address is required',
      name: 'errorAddressRequired',
      desc: '',
      args: [],
    );
  }

  /// `Address must be 256 characters or less`
  String get errorAddressLength {
    return Intl.message(
      'Address must be 256 characters or less',
      name: 'errorAddressLength',
      desc: '',
      args: [],
    );
  }

  /// `Pincode is required`
  String get errorPincodeRequired {
    return Intl.message(
      'Pincode is required',
      name: 'errorPincodeRequired',
      desc: '',
      args: [],
    );
  }

  /// `Pincode must be 6 digits`
  String get errorPincodeInvalid {
    return Intl.message(
      'Pincode must be 6 digits',
      name: 'errorPincodeInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Password is required`
  String get errorPasswordRequired {
    return Intl.message(
      'Password is required',
      name: 'errorPasswordRequired',
      desc: '',
      args: [],
    );
  }

  /// `Password must be 8-20 characters with at least one lowercase, uppercase, digit, and special character`
  String get errorPasswordFormat {
    return Intl.message(
      'Password must be 8-20 characters with at least one lowercase, uppercase, digit, and special character',
      name: 'errorPasswordFormat',
      desc: '',
      args: [],
    );
  }

  /// `Confirm password is required`
  String get errorConfirmPasswordRequired {
    return Intl.message(
      'Confirm password is required',
      name: 'errorConfirmPasswordRequired',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get errorPasswordMismatch {
    return Intl.message(
      'Passwords do not match',
      name: 'errorPasswordMismatch',
      desc: '',
      args: [],
    );
  }

  /// `No internet connection`
  String get errorNoInternet {
    return Intl.message(
      'No internet connection',
      name: 'errorNoInternet',
      desc: '',
      args: [],
    );
  }

  /// `Request timed out`
  String get errorTimeout {
    return Intl.message(
      'Request timed out',
      name: 'errorTimeout',
      desc: '',
      args: [],
    );
  }

  /// `Server unavailable`
  String get errorServerUnavailable {
    return Intl.message(
      'Server unavailable',
      name: 'errorServerUnavailable',
      desc:
          'Message shown when the server refuses the connection or is unreachable.',
      args: [],
    );
  }

  /// `Server error`
  String get errorServer {
    return Intl.message(
      'Server error',
      name: 'errorServer',
      desc: '',
      args: [],
    );
  }

  /// `Service unavailable`
  String get errorServiceUnavailable {
    return Intl.message(
      'Service unavailable',
      name: 'errorServiceUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Username already taken`
  String get errorUsernameTaken {
    return Intl.message(
      'Username already taken',
      name: 'errorUsernameTaken',
      desc: '',
      args: [],
    );
  }

  /// `Mobile verification required`
  String get errorMobileVerificationRequired {
    return Intl.message(
      'Mobile verification required',
      name: 'errorMobileVerificationRequired',
      desc: '',
      args: [],
    );
  }

  /// `Invalid registration data`
  String get errorInvalidRegistrationData {
    return Intl.message(
      'Invalid registration data',
      name: 'errorInvalidRegistrationData',
      desc: '',
      args: [],
    );
  }

  /// `An unexpected error occurred`
  String get errorUnexpected {
    return Intl.message(
      'An unexpected error occurred',
      name: 'errorUnexpected',
      desc: 'Generic error message for unexpected errors',
      args: [],
    );
  }

  /// `Already have an account? Login`
  String get actionLoginAccount {
    return Intl.message(
      'Already have an account? Login',
      name: 'actionLoginAccount',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Password?`
  String get actionForgotPassword {
    return Intl.message(
      'Forgot Password?',
      name: 'actionForgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get actionCreateAccount {
    return Intl.message(
      'Create Account',
      name: 'actionCreateAccount',
      desc: '',
      args: [],
    );
  }

  /// `User ID cannot be empty.`
  String get errorUserIdEmpty {
    return Intl.message(
      'User ID cannot be empty.',
      name: 'errorUserIdEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Password cannot be empty.`
  String get errorPasswordEmpty {
    return Intl.message(
      'Password cannot be empty.',
      name: 'errorPasswordEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Repeat password cannot be empty.`
  String get errorRepeatPasswordEmpty {
    return Intl.message(
      'Repeat password cannot be empty.',
      name: 'errorRepeatPasswordEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Email address cannot be empty.`
  String get errorEmailEmpty {
    return Intl.message(
      'Email address cannot be empty.',
      name: 'errorEmailEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email address format.`
  String get errorInvalidEmail {
    return Intl.message(
      'Invalid email address format.',
      name: 'errorInvalidEmail',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your mobile number.`
  String get errorMobileNoEmpty {
    return Intl.message(
      'Please enter your mobile number.',
      name: 'errorMobileNoEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Invalid phone number format.`
  String get errorInvalidPhone {
    return Intl.message(
      'Invalid phone number format.',
      name: 'errorInvalidPhone',
      desc: '',
      args: [],
    );
  }

  /// `Username is required.`
  String get errorUsernameEmpty {
    return Intl.message(
      'Username is required.',
      name: 'errorUsernameEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Display name cannot be empty.`
  String get errorDisplayNameEmpty {
    return Intl.message(
      'Display name cannot be empty.',
      name: 'errorDisplayNameEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid 10-digit mobile number.`
  String get errorMobileNumberInvalid {
    return Intl.message(
      'Please enter a valid 10-digit mobile number.',
      name: 'errorMobileNumberInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Mobile number verification failed.`
  String get errorMobileVerificationFailed {
    return Intl.message(
      'Mobile number verification failed.',
      name: 'errorMobileVerificationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Mobile number verification is required.`
  String get warningMobileVerificationRequired {
    return Intl.message(
      'Mobile number verification is required.',
      name: 'warningMobileVerificationRequired',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load operator data.`
  String get errorLoadOperator {
    return Intl.message(
      'Failed to load operator data.',
      name: 'errorLoadOperator',
      desc: '',
      args: [],
    );
  }

  /// `Plaza owner name is required.`
  String get errorPlazaOwnerNameRequired {
    return Intl.message(
      'Plaza owner name is required.',
      name: 'errorPlazaOwnerNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Plaza owner name length is invalid.`
  String get errorPlazaOwnerNameLength {
    return Intl.message(
      'Plaza owner name length is invalid.',
      name: 'errorPlazaOwnerNameLength',
      desc: '',
      args: [],
    );
  }

  /// `Please select a role.`
  String get errorRoleRequired {
    return Intl.message(
      'Please select a role.',
      name: 'errorRoleRequired',
      desc: '',
      args: [],
    );
  }

  /// `Sub-entity selection is required.`
  String get errorSubEntityRequired {
    return Intl.message(
      'Sub-entity selection is required.',
      name: 'errorSubEntityRequired',
      desc: '',
      args: [],
    );
  }

  /// `Mobile number must be exactly 10 digits.`
  String get errorMobileLength {
    return Intl.message(
      'Mobile number must be exactly 10 digits.',
      name: 'errorMobileLength',
      desc: '',
      args: [],
    );
  }

  /// `Mobile number is already registered.`
  String get errorMobileUnique {
    return Intl.message(
      'Mobile number is already registered.',
      name: 'errorMobileUnique',
      desc: '',
      args: [],
    );
  }

  /// `Please enter an email address or mobile number.`
  String get errorEmailOrMobileRequired {
    return Intl.message(
      'Please enter an email address or mobile number.',
      name: 'errorEmailOrMobileRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email address.`
  String get errorValidEmailRequired {
    return Intl.message(
      'Please enter a valid email address.',
      name: 'errorValidEmailRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid mobile number.`
  String get errorValidMobileRequired {
    return Intl.message(
      'Please enter a valid mobile number.',
      name: 'errorValidMobileRequired',
      desc: '',
      args: [],
    );
  }

  /// `Email ID must not exceed 50 characters.`
  String get errorEmailLength {
    return Intl.message(
      'Email ID must not exceed 50 characters.',
      name: 'errorEmailLength',
      desc: '',
      args: [],
    );
  }

  /// `Email ID must be at least 10 characters.`
  String get errorEmailMinLength {
    return Intl.message(
      'Email ID must be at least 10 characters.',
      name: 'errorEmailMinLength',
      desc: '',
      args: [],
    );
  }

  /// `Error in fetching Entities`
  String get errorFetchEntities {
    return Intl.message(
      'Error in fetching Entities',
      name: 'errorFetchEntities',
      desc: '',
      args: [],
    );
  }

  /// `Entity is Required`
  String get errorSelectEntity {
    return Intl.message(
      'Entity is Required',
      name: 'errorSelectEntity',
      desc: '',
      args: [],
    );
  }

  /// `Password must be 8 to 20 characters long.`
  String get errorPasswordLength {
    return Intl.message(
      'Password must be 8 to 20 characters long.',
      name: 'errorPasswordLength',
      desc: '',
      args: [],
    );
  }

  /// `Assigning an entity is required.`
  String get errorEntityRequired {
    return Intl.message(
      'Assigning an entity is required.',
      name: 'errorEntityRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please select a plaza`
  String get errorPlazaSelectionRequired {
    return Intl.message(
      'Please select a plaza',
      name: 'errorPlazaSelectionRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please select a fare type`
  String get errorFareTypeSelectionRequired {
    return Intl.message(
      'Please select a fare type',
      name: 'errorFareTypeSelectionRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please select a vehicle type`
  String get errorVehicleTypeSelectionRequired {
    return Intl.message(
      'Please select a vehicle type',
      name: 'errorVehicleTypeSelectionRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the daily fare.`
  String get errorDailyFareRequired {
    return Intl.message(
      'Please enter the daily fare.',
      name: 'errorDailyFareRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the hourly fare.`
  String get errorHourlyFareRequired {
    return Intl.message(
      'Please enter the hourly fare.',
      name: 'errorHourlyFareRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the base hourly fare.`
  String get errorBaseHourlyFareRequired {
    return Intl.message(
      'Please enter the base hourly fare.',
      name: 'errorBaseHourlyFareRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the monthly fare.`
  String get errorMonthlyFareRequired {
    return Intl.message(
      'Please enter the monthly fare.',
      name: 'errorMonthlyFareRequired',
      desc: '',
      args: [],
    );
  }

  /// `Amount must be greater than 0.`
  String get errorAmountGreaterThanZero {
    return Intl.message(
      'Amount must be greater than 0.',
      name: 'errorAmountGreaterThanZero',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the start effective date.`
  String get errorStartDateRequired {
    return Intl.message(
      'Please enter the start effective date.',
      name: 'errorStartDateRequired',
      desc: '',
      args: [],
    );
  }

  /// `Past dates are not allowed.`
  String get errorPastDateNotAllowed {
    return Intl.message(
      'Past dates are not allowed.',
      name: 'errorPastDateNotAllowed',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the end effective date.`
  String get errorEndDateRequired {
    return Intl.message(
      'Please enter the end effective date.',
      name: 'errorEndDateRequired',
      desc: '',
      args: [],
    );
  }

  /// `End date must be after the start date.`
  String get errorEndDateAfterStart {
    return Intl.message(
      'End date must be after the start date.',
      name: 'errorEndDateAfterStart',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the discount amount for extended hours.`
  String get errorDiscountRequired {
    return Intl.message(
      'Please enter the discount amount for extended hours.',
      name: 'errorDiscountRequired',
      desc: '',
      args: [],
    );
  }

  /// `Discount must be greater than 0.`
  String get errorInvalidDiscount {
    return Intl.message(
      'Discount must be greater than 0.',
      name: 'errorInvalidDiscount',
      desc: '',
      args: [],
    );
  }

  /// `A system fare already exists for this plaza.`
  String get errorExistingSystemFare {
    return Intl.message(
      'A system fare already exists for this plaza.',
      name: 'errorExistingSystemFare',
      desc: '',
      args: [],
    );
  }

  /// `A temporary fare already exists for this plaza.`
  String get errorExistingTemporaryFare {
    return Intl.message(
      'A temporary fare already exists for this plaza.',
      name: 'errorExistingTemporaryFare',
      desc: '',
      args: [],
    );
  }

  /// `Vehicle class already exists for this plaza.`
  String get errorExistingVehicleClass {
    return Intl.message(
      'Vehicle class already exists for this plaza.',
      name: 'errorExistingVehicleClass',
      desc: '',
      args: [],
    );
  }

  /// `Error adding fare: `
  String get errorFareSubmission {
    return Intl.message(
      'Error adding fare: ',
      name: 'errorFareSubmission',
      desc: '',
      args: [],
    );
  }

  /// `Please add at least one fare before submitting.`
  String get warningNoFaresAdded {
    return Intl.message(
      'Please add at least one fare before submitting.',
      name: 'warningNoFaresAdded',
      desc: '',
      args: [],
    );
  }

  /// `Submission failed: `
  String get errorSubmissionFailed {
    return Intl.message(
      'Submission failed: ',
      name: 'errorSubmissionFailed',
      desc: '',
      args: [],
    );
  }

  /// `Transactions`
  String get navTransactions {
    return Intl.message(
      'Transactions',
      name: 'navTransactions',
      desc: '',
      args: [],
    );
  }

  /// `Menu`
  String get navMenu {
    return Intl.message(
      'Menu',
      name: 'navMenu',
      desc: '',
      args: [],
    );
  }

  /// `Dashboard`
  String get navDashboard {
    return Intl.message(
      'Dashboard',
      name: 'navDashboard',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get navNotifications {
    return Intl.message(
      'Notifications',
      name: 'navNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Account`
  String get navAccount {
    return Intl.message(
      'Account',
      name: 'navAccount',
      desc: '',
      args: [],
    );
  }

  /// `Search by Ticket ID, Plaza, Vehicle Number...`
  String get searchHint {
    return Intl.message(
      'Search by Ticket ID, Plaza, Vehicle Number...',
      name: 'searchHint',
      desc: '',
      args: [],
    );
  }

  /// `No open tickets`
  String get noOpenTickets {
    return Intl.message(
      'No open tickets',
      name: 'noOpenTickets',
      desc: '',
      args: [],
    );
  }

  /// `There are no open tickets available`
  String get noTicketsAvailable {
    return Intl.message(
      'There are no open tickets available',
      name: 'noTicketsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `No tickets match your search criteria`
  String get noTicketsMatchSearch {
    return Intl.message(
      'No tickets match your search criteria',
      name: 'noTicketsMatchSearch',
      desc: '',
      args: [],
    );
  }

  /// `Unable to Load Tickets`
  String get errorUnableToLoadTickets {
    return Intl.message(
      'Unable to Load Tickets',
      name: 'errorUnableToLoadTickets',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong. Please try again.`
  String get errorGeneric {
    return Intl.message(
      'Something went wrong. Please try again.',
      name: 'errorGeneric',
      desc: '',
      args: [],
    );
  }

  /// `Ticket ID:`
  String get labelTicketId {
    return Intl.message(
      'Ticket ID:',
      name: 'labelTicketId',
      desc: '',
      args: [],
    );
  }

  /// `Entry Time`
  String get labelEntryTime {
    return Intl.message(
      'Entry Time',
      name: 'labelEntryTime',
      desc: '',
      args: [],
    );
  }

  /// `Vehicle Number`
  String get labelVehicleNumber {
    return Intl.message(
      'Vehicle Number',
      name: 'labelVehicleNumber',
      desc: '',
      args: [],
    );
  }

  /// `Vehicle Type`
  String get labelVehicleType {
    return Intl.message(
      'Vehicle Type',
      name: 'labelVehicleType',
      desc: '',
      args: [],
    );
  }

  /// `Please check your internet connection and try again.`
  String get errorNoInternetMessage {
    return Intl.message(
      'Please check your internet connection and try again.',
      name: 'errorNoInternetMessage',
      desc: '',
      args: [],
    );
  }

  /// `Request Timed Out`
  String get errorRequestTimeout {
    return Intl.message(
      'Request Timed Out',
      name: 'errorRequestTimeout',
      desc: '',
      args: [],
    );
  }

  /// `The server is taking too long to respond. Please try again later.`
  String get errorRequestTimeoutMessage {
    return Intl.message(
      'The server is taking too long to respond. Please try again later.',
      name: 'errorRequestTimeoutMessage',
      desc: '',
      args: [],
    );
  }

  /// `Server Error`
  String get errorServerError {
    return Intl.message(
      'Server Error',
      name: 'errorServerError',
      desc: '',
      args: [],
    );
  }

  /// `We couldn't reach the server. Please try again.`
  String get errorServerErrorMessage {
    return Intl.message(
      'We couldn\'t reach the server. Please try again.',
      name: 'errorServerErrorMessage',
      desc: '',
      args: [],
    );
  }

  /// `The request was incorrect.`
  String get errorInvalidRequestMessage {
    return Intl.message(
      'The request was incorrect.',
      name: 'errorInvalidRequestMessage',
      desc: '',
      args: [],
    );
  }

  /// `Unauthorized`
  String get errorUnauthorized {
    return Intl.message(
      'Unauthorized',
      name: 'errorUnauthorized',
      desc: '',
      args: [],
    );
  }

  /// `Please log in again.`
  String get errorUnauthorizedMessage {
    return Intl.message(
      'Please log in again.',
      name: 'errorUnauthorizedMessage',
      desc: '',
      args: [],
    );
  }

  /// `You don't have permission.`
  String get errorAccessDeniedMessage {
    return Intl.message(
      'You don\'t have permission.',
      name: 'errorAccessDeniedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Not Found`
  String get errorNotFound {
    return Intl.message(
      'Not Found',
      name: 'errorNotFound',
      desc: '',
      args: [],
    );
  }

  /// `No open tickets were found.`
  String get errorNotFoundMessage {
    return Intl.message(
      'No open tickets were found.',
      name: 'errorNotFoundMessage',
      desc: '',
      args: [],
    );
  }

  /// `Server Issue`
  String get errorServerIssue {
    return Intl.message(
      'Server Issue',
      name: 'errorServerIssue',
      desc: '',
      args: [],
    );
  }

  /// `Problem on our end.`
  String get errorServerIssueMessage {
    return Intl.message(
      'Problem on our end.',
      name: 'errorServerIssueMessage',
      desc: '',
      args: [],
    );
  }

  /// `Service is temporarily down.`
  String get errorServiceUnavailableMessage {
    return Intl.message(
      'Service is temporarily down.',
      name: 'errorServiceUnavailableMessage',
      desc: '',
      args: [],
    );
  }

  /// `Service Overloaded`
  String get errorServiceOverloaded {
    return Intl.message(
      'Service Overloaded',
      name: 'errorServiceOverloaded',
      desc: '',
      args: [],
    );
  }

  /// `Server is busy.`
  String get errorServiceOverloadedMessage {
    return Intl.message(
      'Server is busy.',
      name: 'errorServiceOverloadedMessage',
      desc: '',
      args: [],
    );
  }

  /// `An unexpected issue occurred.`
  String get errorUnexpectedMessage {
    return Intl.message(
      'An unexpected issue occurred.',
      name: 'errorUnexpectedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Search by Ticket ID, Status, Plaza, Vehicle Number...`
  String get searchTicketHistoryHint {
    return Intl.message(
      'Search by Ticket ID, Status, Plaza, Vehicle Number...',
      name: 'searchTicketHistoryHint',
      desc: '',
      args: [],
    );
  }

  /// `Logging in...`
  String get loggingIn {
    return Intl.message(
      'Logging in...',
      name: 'loggingIn',
      desc: '',
      args: [],
    );
  }

  /// `Ticket Status`
  String get ticketStatusLabel {
    return Intl.message(
      'Ticket Status',
      name: 'ticketStatusLabel',
      desc: '',
      args: [],
    );
  }

  /// `Open Tickets`
  String get openTicketsLabel {
    return Intl.message(
      'Open Tickets',
      name: 'openTicketsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Pending Tickets`
  String get pendingTicketsLabel {
    return Intl.message(
      'Pending Tickets',
      name: 'pendingTicketsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Completed Tickets`
  String get completedTicketsLabel {
    return Intl.message(
      'Completed Tickets',
      name: 'completedTicketsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Rejected Tickets`
  String get rejectedTicketsLabel {
    return Intl.message(
      'Rejected Tickets',
      name: 'rejectedTicketsLabel',
      desc: '',
      args: [],
    );
  }

  /// `No tickets found.`
  String get noTicketsFoundLabel {
    return Intl.message(
      'No tickets found.',
      name: 'noTicketsFoundLabel',
      desc: '',
      args: [],
    );
  }

  /// `Try adjusting your filters or swipe down to refresh.`
  String get adjustFiltersMessage {
    return Intl.message(
      'Try adjusting your filters or swipe down to refresh.',
      name: 'adjustFiltersMessage',
      desc: '',
      args: [],
    );
  }

  /// `Unable to Load Ticket History`
  String get errorUnableToLoadTicketsHistory {
    return Intl.message(
      'Unable to Load Ticket History',
      name: 'errorUnableToLoadTicketsHistory',
      desc: '',
      args: [],
    );
  }

  /// `N/A`
  String get naLabel {
    return Intl.message(
      'N/A',
      name: 'naLabel',
      desc: '',
      args: [],
    );
  }

  /// `Error loading current user info`
  String get errorLoadCurrentUserInfo {
    return Intl.message(
      'Error loading current user info',
      name: 'errorLoadCurrentUserInfo',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load operator data`
  String get errorLoadOperatorData {
    return Intl.message(
      'Failed to load operator data',
      name: 'errorLoadOperatorData',
      desc: '',
      args: [],
    );
  }

  /// `Failed to fetch plazas`
  String get errorLoadPlazas {
    return Intl.message(
      'Failed to fetch plazas',
      name: 'errorLoadPlazas',
      desc: '',
      args: [],
    );
  }

  /// `No plazas found for this entity.`
  String get errorNoPlazasFound {
    return Intl.message(
      'No plazas found for this entity.',
      name: 'errorNoPlazasFound',
      desc: '',
      args: [],
    );
  }

  /// `User ID`
  String get labelUserId {
    return Intl.message(
      'User ID',
      name: 'labelUserId',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 8 characters`
  String get errorPasswordMinLength {
    return Intl.message(
      'Password must be at least 8 characters',
      name: 'errorPasswordMinLength',
      desc: '',
      args: [],
    );
  }

  /// `Pincode must be 6 digits`
  String get errorPincodeLength {
    return Intl.message(
      'Pincode must be 6 digits',
      name: 'errorPincodeLength',
      desc: '',
      args: [],
    );
  }

  /// `Account Settings`
  String get titleAccountSettings {
    return Intl.message(
      'Account Settings',
      name: 'titleAccountSettings',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load settings`
  String get errorLoadSettings {
    return Intl.message(
      'Failed to load settings',
      name: 'errorLoadSettings',
      desc: '',
      args: [],
    );
  }

  /// `Account`
  String get sectionAccount {
    return Intl.message(
      'Account',
      name: 'sectionAccount',
      desc: '',
      args: [],
    );
  }

  /// `My Account`
  String get optionMyAccount {
    return Intl.message(
      'My Account',
      name: 'optionMyAccount',
      desc: '',
      args: [],
    );
  }

  /// `Make changes to your account`
  String get subtitleMyAccount {
    return Intl.message(
      'Make changes to your account',
      name: 'subtitleMyAccount',
      desc: '',
      args: [],
    );
  }

  /// `Touch ID`
  String get optionTouchId {
    return Intl.message(
      'Touch ID',
      name: 'optionTouchId',
      desc: '',
      args: [],
    );
  }

  /// `Manage your device security`
  String get subtitleTouchId {
    return Intl.message(
      'Manage your device security',
      name: 'subtitleTouchId',
      desc: '',
      args: [],
    );
  }

  /// `Log out`
  String get optionLogout {
    return Intl.message(
      'Log out',
      name: 'optionLogout',
      desc: '',
      args: [],
    );
  }

  /// `Further secure your account for safety`
  String get subtitleLogout {
    return Intl.message(
      'Further secure your account for safety',
      name: 'subtitleLogout',
      desc: '',
      args: [],
    );
  }

  /// `Preferences`
  String get sectionPreferences {
    return Intl.message(
      'Preferences',
      name: 'sectionPreferences',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get optionLanguage {
    return Intl.message(
      'Language',
      name: 'optionLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get optionTheme {
    return Intl.message(
      'Theme',
      name: 'optionTheme',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get optionNotifications {
    return Intl.message(
      'Notifications',
      name: 'optionNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Enabled`
  String get enabled {
    return Intl.message(
      'Enabled',
      name: 'enabled',
      desc: '',
      args: [],
    );
  }

  /// `Disabled`
  String get disabled {
    return Intl.message(
      'Disabled',
      name: 'disabled',
      desc: '',
      args: [],
    );
  }

  /// `Support`
  String get sectionSupport {
    return Intl.message(
      'Support',
      name: 'sectionSupport',
      desc: '',
      args: [],
    );
  }

  /// `Help & Support`
  String get optionHelpSupport {
    return Intl.message(
      'Help & Support',
      name: 'optionHelpSupport',
      desc: '',
      args: [],
    );
  }

  /// `Get assistance with using the app`
  String get subtitleHelpSupport {
    return Intl.message(
      'Get assistance with using the app',
      name: 'subtitleHelpSupport',
      desc: '',
      args: [],
    );
  }

  /// `About App`
  String get optionAboutApp {
    return Intl.message(
      'About App',
      name: 'optionAboutApp',
      desc: '',
      args: [],
    );
  }

  /// `Version 1.0.0`
  String get subtitleAboutApp {
    return Intl.message(
      'Version 1.0.0',
      name: 'subtitleAboutApp',
      desc: '',
      args: [],
    );
  }

  /// `Legal`
  String get sectionLegal {
    return Intl.message(
      'Legal',
      name: 'sectionLegal',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get optionPrivacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'optionPrivacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Terms of Service`
  String get optionTermsOfService {
    return Intl.message(
      'Terms of Service',
      name: 'optionTermsOfService',
      desc: '',
      args: [],
    );
  }

  /// `Select Language`
  String get dialogTitleSelectLanguage {
    return Intl.message(
      'Select Language',
      name: 'dialogTitleSelectLanguage',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get languageEnglish {
    return Intl.message(
      'English',
      name: 'languageEnglish',
      desc: '',
      args: [],
    );
  }

  /// `Hindi`
  String get languageHindi {
    return Intl.message(
      'Hindi',
      name: 'languageHindi',
      desc: '',
      args: [],
    );
  }

  /// `Marathi`
  String get languageMarathi {
    return Intl.message(
      'Marathi',
      name: 'languageMarathi',
      desc: '',
      args: [],
    );
  }

  /// `Choose Theme`
  String get dialogTitleChooseTheme {
    return Intl.message(
      'Choose Theme',
      name: 'dialogTitleChooseTheme',
      desc: '',
      args: [],
    );
  }

  /// `Light Theme`
  String get themeLight {
    return Intl.message(
      'Light Theme',
      name: 'themeLight',
      desc: '',
      args: [],
    );
  }

  /// `Dark Theme`
  String get themeDark {
    return Intl.message(
      'Dark Theme',
      name: 'themeDark',
      desc: '',
      args: [],
    );
  }

  /// `System Default`
  String get themeSystem {
    return Intl.message(
      'System Default',
      name: 'themeSystem',
      desc: '',
      args: [],
    );
  }

  /// `Log out`
  String get dialogTitleLogout {
    return Intl.message(
      'Log out',
      name: 'dialogTitleLogout',
      desc: '',
      args: [],
    );
  }

  /// `No Ticket Data`
  String get errorNoTicketData {
    return Intl.message(
      'No Ticket Data',
      name: 'errorNoTicketData',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to log out of your account? You'll need to sign in again to access your data.`
  String get dialogContentLogout {
    return Intl.message(
      'Are you sure you want to log out of your account? You\'ll need to sign in again to access your data.',
      name: 'dialogContentLogout',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get buttonApply {
    return Intl.message(
      'Apply',
      name: 'buttonApply',
      desc: '',
      args: [],
    );
  }

  /// `Log out`
  String get buttonLogout {
    return Intl.message(
      'Log out',
      name: 'buttonLogout',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get titleNotifications {
    return Intl.message(
      'Notifications',
      name: 'titleNotifications',
      desc: '',
      args: [],
    );
  }

  /// `No notifications`
  String get messageNoNotifications {
    return Intl.message(
      'No notifications',
      name: 'messageNoNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Navigation error`
  String get errorNavigation {
    return Intl.message(
      'Navigation error',
      name: 'errorNavigation',
      desc: '',
      args: [],
    );
  }

  /// `This feature is not implemented yet`
  String get messageNotImplemented {
    return Intl.message(
      'This feature is not implemented yet',
      name: 'messageNotImplemented',
      desc: '',
      args: [],
    );
  }

  /// `User ID not found. Please log in again.`
  String get errorUserIdNotFound {
    return Intl.message(
      'User ID not found. Please log in again.',
      name: 'errorUserIdNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Daily`
  String get filterDaily {
    return Intl.message(
      'Daily',
      name: 'filterDaily',
      desc: '',
      args: [],
    );
  }

  /// `Weekly`
  String get filterWeekly {
    return Intl.message(
      'Weekly',
      name: 'filterWeekly',
      desc: '',
      args: [],
    );
  }

  /// `Monthly`
  String get filterMonthly {
    return Intl.message(
      'Monthly',
      name: 'filterMonthly',
      desc: '',
      args: [],
    );
  }

  /// `Quarterly`
  String get filterQuarterly {
    return Intl.message(
      'Quarterly',
      name: 'filterQuarterly',
      desc: '',
      args: [],
    );
  }

  /// `Total Plaza`
  String get summaryTotalPlaza {
    return Intl.message(
      'Total Plaza',
      name: 'summaryTotalPlaza',
      desc: '',
      args: [],
    );
  }

  /// `Total Txns`
  String get summaryTotalTxns {
    return Intl.message(
      'Total Txns',
      name: 'summaryTotalTxns',
      desc: '',
      args: [],
    );
  }

  /// `Settled Txns`
  String get summarySettledTxns {
    return Intl.message(
      'Settled Txns',
      name: 'summarySettledTxns',
      desc: '',
      args: [],
    );
  }

  /// `Pending Txns`
  String get summaryPendingTxns {
    return Intl.message(
      'Pending Txns',
      name: 'summaryPendingTxns',
      desc: '',
      args: [],
    );
  }

  /// `Plaza-wise Revenue Summary`
  String get cardPlazaRevenueSummary {
    return Intl.message(
      'Plaza-wise Revenue Summary',
      name: 'cardPlazaRevenueSummary',
      desc: '',
      args: [],
    );
  }

  /// `Revenue`
  String get tooltipRevenue {
    return Intl.message(
      'Revenue',
      name: 'tooltipRevenue',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get tooltipTotal {
    return Intl.message(
      'Total',
      name: 'tooltipTotal',
      desc: '',
      args: [],
    );
  }

  /// `Cancelled`
  String get tooltipCancelled {
    return Intl.message(
      'Cancelled',
      name: 'tooltipCancelled',
      desc: '',
      args: [],
    );
  }

  /// `Total Bookings`
  String get legendTotalBookings {
    return Intl.message(
      'Total Bookings',
      name: 'legendTotalBookings',
      desc: '',
      args: [],
    );
  }

  /// `Cancelled Bookings`
  String get legendCancelledBookings {
    return Intl.message(
      'Cancelled Bookings',
      name: 'legendCancelledBookings',
      desc: '',
      args: [],
    );
  }

  /// `Revenue Distribution`
  String get cardRevenueDistribution {
    return Intl.message(
      'Revenue Distribution',
      name: 'cardRevenueDistribution',
      desc: '',
      args: [],
    );
  }

  /// `UPI/Debit\nCredit Card`
  String get legendUpiCard {
    return Intl.message(
      'UPI/Debit\nCredit Card',
      name: 'legendUpiCard',
      desc: '',
      args: [],
    );
  }

  /// `Cash`
  String get legendCash {
    return Intl.message(
      'Cash',
      name: 'legendCash',
      desc: '',
      args: [],
    );
  }

  /// `QR`
  String get legendQr {
    return Intl.message(
      'QR',
      name: 'legendQr',
      desc: '',
      args: [],
    );
  }

  /// `User\nRegistration`
  String get titleUserRegistration {
    return Intl.message(
      'User\nRegistration',
      name: 'titleUserRegistration',
      desc: '',
      args: [],
    );
  }

  /// `Verify`
  String get buttonVerify {
    return Intl.message(
      'Verify',
      name: 'buttonVerify',
      desc: '',
      args: [],
    );
  }

  /// `Please verify your mobile number`
  String get errorVerifyMobile {
    return Intl.message(
      'Please verify your mobile number',
      name: 'errorVerifyMobile',
      desc: '',
      args: [],
    );
  }

  /// `Mobile number changed. Please verify again.`
  String get errorMobileChanged {
    return Intl.message(
      'Mobile number changed. Please verify again.',
      name: 'errorMobileChanged',
      desc: '',
      args: [],
    );
  }

  /// `Please select a role`
  String get errorSelectRole {
    return Intl.message(
      'Please select a role',
      name: 'errorSelectRole',
      desc: '',
      args: [],
    );
  }

  /// `Failed to fetch plazas`
  String get errorFetchPlazas {
    return Intl.message(
      'Failed to fetch plazas',
      name: 'errorFetchPlazas',
      desc: '',
      args: [],
    );
  }

  /// `Registration Successful`
  String get dialogTitleSuccess {
    return Intl.message(
      'Registration Successful',
      name: 'dialogTitleSuccess',
      desc: '',
      args: [],
    );
  }

  /// `User has been registered successfully.`
  String get dialogContentSuccess {
    return Intl.message(
      'User has been registered successfully.',
      name: 'dialogContentSuccess',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get buttonOk {
    return Intl.message(
      'OK',
      name: 'buttonOk',
      desc: '',
      args: [],
    );
  }

  /// `Search by name, mob no. or email`
  String get hintSearchUsers {
    return Intl.message(
      'Search by name, mob no. or email',
      name: 'hintSearchUsers',
      desc: '',
      args: [],
    );
  }

  /// `Original mobile number restored and verified.`
  String get successMobileRestored {
    return Intl.message(
      'Original mobile number restored and verified.',
      name: 'successMobileRestored',
      desc: '',
      args: [],
    );
  }

  /// `Mobile number verified successfully!`
  String get successMobileVerification {
    return Intl.message(
      'Mobile number verified successfully!',
      name: 'successMobileVerification',
      desc: '',
      args: [],
    );
  }

  /// `Please try a different mobile number.`
  String get suggestionTryAnotherNumber {
    return Intl.message(
      'Please try a different mobile number.',
      name: 'suggestionTryAnotherNumber',
      desc: '',
      args: [],
    );
  }

  /// `Failed to send OTP.`
  String get errorOtpSendFailed {
    return Intl.message(
      'Failed to send OTP.',
      name: 'errorOtpSendFailed',
      desc: '',
      args: [],
    );
  }

  /// `Last updated`
  String get labelLastUpdated {
    return Intl.message(
      'Last updated',
      name: 'labelLastUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Swipe down to refresh`
  String get labelSwipeToRefresh {
    return Intl.message(
      'Swipe down to refresh',
      name: 'labelSwipeToRefresh',
      desc: '',
      args: [],
    );
  }

  /// `Ticket created, but failed to retrieve all ticket identifiers`
  String get failedToParseTicketIds {
    return Intl.message(
      'Ticket created, but failed to retrieve all ticket identifiers',
      name: 'failedToParseTicketIds',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get labelRetry {
    return Intl.message(
      'Retry',
      name: 'labelRetry',
      desc: '',
      args: [],
    );
  }

  /// `Could not open ticket details. ID missing.`
  String get errorNavigatingToTicketDetails {
    return Intl.message(
      'Could not open ticket details. ID missing.',
      name: 'errorNavigatingToTicketDetails',
      desc: '',
      args: [],
    );
  }

  /// `Error Loading Notifications`
  String get errorLoadingNotifications {
    return Intl.message(
      'Error Loading Notifications',
      name: 'errorLoadingNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Mark all as read`
  String get markAllAsRead {
    return Intl.message(
      'Mark all as read',
      name: 'markAllAsRead',
      desc: '',
      args: [],
    );
  }

  /// `All notifications marked as read.`
  String get markedAllAsRead {
    return Intl.message(
      'All notifications marked as read.',
      name: 'markedAllAsRead',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Delete`
  String get confirmDeleteTitle {
    return Intl.message(
      'Confirm Delete',
      name: 'confirmDeleteTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this notification?`
  String get confirmDeleteMessage {
    return Intl.message(
      'Are you sure you want to delete this notification?',
      name: 'confirmDeleteMessage',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get labelCancel {
    return Intl.message(
      'Cancel',
      name: 'labelCancel',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get labelDelete {
    return Intl.message(
      'Delete',
      name: 'labelDelete',
      desc: '',
      args: [],
    );
  }

  /// `New Booking`
  String get notificationTypeNewBooking {
    return Intl.message(
      'New Booking',
      name: 'notificationTypeNewBooking',
      desc: '',
      args: [],
    );
  }

  /// `Payment Received`
  String get notificationTypePaymentReceived {
    return Intl.message(
      'Payment Received',
      name: 'notificationTypePaymentReceived',
      desc: '',
      args: [],
    );
  }

  /// `Dispute Raised`
  String get notificationTypeDisputeRaised {
    return Intl.message(
      'Dispute Raised',
      name: 'notificationTypeDisputeRaised',
      desc: '',
      args: [],
    );
  }

  /// `Plaza Alert`
  String get notificationTypePlazaAlert {
    return Intl.message(
      'Plaza Alert',
      name: 'notificationTypePlazaAlert',
      desc: '',
      args: [],
    );
  }

  /// `Account Update`
  String get notificationTypeAccountUpdate {
    return Intl.message(
      'Account Update',
      name: 'notificationTypeAccountUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Dispute Resolved`
  String get notificationTypeDisputeResolved {
    return Intl.message(
      'Dispute Resolved',
      name: 'notificationTypeDisputeResolved',
      desc: '',
      args: [],
    );
  }

  /// `Vehicle Registration`
  String get notificationTypeVehicleRegistration {
    return Intl.message(
      'Vehicle Registration',
      name: 'notificationTypeVehicleRegistration',
      desc: '',
      args: [],
    );
  }

  /// `Plaza Registration`
  String get notificationTypePlazaRegistration {
    return Intl.message(
      'Plaza Registration',
      name: 'notificationTypePlazaRegistration',
      desc: '',
      args: [],
    );
  }

  /// `Booking Cancelled`
  String get notificationTypeBookingCancellation {
    return Intl.message(
      'Booking Cancelled',
      name: 'notificationTypeBookingCancellation',
      desc: '',
      args: [],
    );
  }

  /// `New Ticket`
  String get notificationTypeTicketCreation {
    return Intl.message(
      'New Ticket',
      name: 'notificationTypeTicketCreation',
      desc: '',
      args: [],
    );
  }

  /// `Notification`
  String get notificationTypeGeneric {
    return Intl.message(
      'Notification',
      name: 'notificationTypeGeneric',
      desc: '',
      args: [],
    );
  }

  /// `Unknown Notification`
  String get notificationTypeUnknown {
    return Intl.message(
      'Unknown Notification',
      name: 'notificationTypeUnknown',
      desc: '',
      args: [],
    );
  }

  /// `No users found`
  String get messageNoUsersFound {
    return Intl.message(
      'No users found',
      name: 'messageNoUsersFound',
      desc: '',
      args: [],
    );
  }

  /// `There are no users available`
  String get messageNoUsersAvailable {
    return Intl.message(
      'There are no users available',
      name: 'messageNoUsersAvailable',
      desc: '',
      args: [],
    );
  }

  /// `No users match your search criteria`
  String get messageNoUsersMatchSearch {
    return Intl.message(
      'No users match your search criteria',
      name: 'messageNoUsersMatchSearch',
      desc: '',
      args: [],
    );
  }

  /// `Clear Search`
  String get buttonClearSearch {
    return Intl.message(
      'Clear Search',
      name: 'buttonClearSearch',
      desc: '',
      args: [],
    );
  }

  /// `Unable to Load Users`
  String get errorTitleDefault {
    return Intl.message(
      'Unable to Load Users',
      name: 'errorTitleDefault',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong. Please try again.`
  String get errorMessageDefault {
    return Intl.message(
      'Something went wrong. Please try again.',
      name: 'errorMessageDefault',
      desc: '',
      args: [],
    );
  }

  /// `No Internet Connection`
  String get errorTitleNoInternet {
    return Intl.message(
      'No Internet Connection',
      name: 'errorTitleNoInternet',
      desc: '',
      args: [],
    );
  }

  /// `Please check your internet connection and try again.`
  String get errorMessageNoInternet {
    return Intl.message(
      'Please check your internet connection and try again.',
      name: 'errorMessageNoInternet',
      desc: '',
      args: [],
    );
  }

  /// `Request Timed Out`
  String get errorTitleTimeout {
    return Intl.message(
      'Request Timed Out',
      name: 'errorTitleTimeout',
      desc: '',
      args: [],
    );
  }

  /// `The server is taking too long to respond.`
  String get errorMessageTimeout {
    return Intl.message(
      'The server is taking too long to respond.',
      name: 'errorMessageTimeout',
      desc: '',
      args: [],
    );
  }

  /// `Server Error`
  String get errorTitleServer {
    return Intl.message(
      'Server Error',
      name: 'errorTitleServer',
      desc: '',
      args: [],
    );
  }

  /// `An unexpected error occurred.`
  String get errorDetailsUnexpected {
    return Intl.message(
      'An unexpected error occurred.',
      name: 'errorDetailsUnexpected',
      desc: '',
      args: [],
    );
  }

  /// `PDF exported successfully`
  String get messagePdfSuccess {
    return Intl.message(
      'PDF exported successfully',
      name: 'messagePdfSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to export PDF`
  String get messagePdfFailed {
    return Intl.message(
      'Failed to export PDF',
      name: 'messagePdfFailed',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get buttonEdit {
    return Intl.message(
      'Edit',
      name: 'buttonEdit',
      desc: '',
      args: [],
    );
  }

  /// `Please fill in all password fields`
  String get errorPasswordFieldsEmpty {
    return Intl.message(
      'Please fill in all password fields',
      name: 'errorPasswordFieldsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get errorPasswordsDoNotMatch {
    return Intl.message(
      'Passwords do not match',
      name: 'errorPasswordsDoNotMatch',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 6 characters`
  String get errorPasswordTooShort {
    return Intl.message(
      'Password must be at least 6 characters',
      name: 'errorPasswordTooShort',
      desc: '',
      args: [],
    );
  }

  /// `Password reset successful`
  String get successPasswordReset {
    return Intl.message(
      'Password reset successful',
      name: 'successPasswordReset',
      desc: '',
      args: [],
    );
  }

  /// `Failed to reset password`
  String get errorPasswordResetFailed {
    return Intl.message(
      'Failed to reset password',
      name: 'errorPasswordResetFailed',
      desc: '',
      args: [],
    );
  }

  /// `New Password`
  String get labelNewPassword {
    return Intl.message(
      'New Password',
      name: 'labelNewPassword',
      desc: '',
      args: [],
    );
  }

  /// `Error loading user profile`
  String get errorLoadingUserProfile {
    return Intl.message(
      'Error loading user profile',
      name: 'errorLoadingUserProfile',
      desc: '',
      args: [],
    );
  }

  /// `Ticket Details`
  String get titleTicketDetails {
    return Intl.message(
      'Ticket Details',
      name: 'titleTicketDetails',
      desc: '',
      args: [],
    );
  }

  /// `Ticket`
  String get titleTicket {
    return Intl.message(
      'Ticket',
      name: 'titleTicket',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get labelLoading {
    return Intl.message(
      'Loading...',
      name: 'labelLoading',
      desc: '',
      args: [],
    );
  }

  /// `Created`
  String get labelCreated {
    return Intl.message(
      'Created',
      name: 'labelCreated',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load ticket details`
  String get errorLoadTicketDetails {
    return Intl.message(
      'Failed to load ticket details',
      name: 'errorLoadTicketDetails',
      desc: '',
      args: [],
    );
  }

  /// `Ticket Details`
  String get labelTicketDetails {
    return Intl.message(
      'Ticket Details',
      name: 'labelTicketDetails',
      desc: '',
      args: [],
    );
  }

  /// `Plaza`
  String get labelPlaza {
    return Intl.message(
      'Plaza',
      name: 'labelPlaza',
      desc: '',
      args: [],
    );
  }

  /// `Entry Lane`
  String get labelEntryLane {
    return Intl.message(
      'Entry Lane',
      name: 'labelEntryLane',
      desc: '',
      args: [],
    );
  }

  /// `Floor ID`
  String get labelFloorId {
    return Intl.message(
      'Floor ID',
      name: 'labelFloorId',
      desc: '',
      args: [],
    );
  }

  /// `Slot ID`
  String get labelSlotId {
    return Intl.message(
      'Slot ID',
      name: 'labelSlotId',
      desc: '',
      args: [],
    );
  }

  /// `Exit Time`
  String get labelExitTime {
    return Intl.message(
      'Exit Time',
      name: 'labelExitTime',
      desc: '',
      args: [],
    );
  }

  /// `Duration`
  String get labelDuration {
    return Intl.message(
      'Duration',
      name: 'labelDuration',
      desc: '',
      args: [],
    );
  }

  /// `Fare Rate`
  String get labelFareRate {
    return Intl.message(
      'Fare Rate',
      name: 'labelFareRate',
      desc: '',
      args: [],
    );
  }

  /// `Fare Type`
  String get labelFareType {
    return Intl.message(
      'Fare Type',
      name: 'labelFareType',
      desc: '',
      args: [],
    );
  }

  /// `Payment Details`
  String get labelPaymentDetails {
    return Intl.message(
      'Payment Details',
      name: 'labelPaymentDetails',
      desc: '',
      args: [],
    );
  }

  /// `UPI`
  String get labelUPI {
    return Intl.message(
      'UPI',
      name: 'labelUPI',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get statusPending {
    return Intl.message(
      'Pending',
      name: 'statusPending',
      desc: '',
      args: [],
    );
  }

  /// `Uploaded Documents`
  String get labelUploadedDocuments {
    return Intl.message(
      'Uploaded Documents',
      name: 'labelUploadedDocuments',
      desc: '',
      args: [],
    );
  }

  /// `No Images Available`
  String get messageNoImagesAvailable {
    return Intl.message(
      'No Images Available',
      name: 'messageNoImagesAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load`
  String get errorImageLoadFailed {
    return Intl.message(
      'Failed to load',
      name: 'errorImageLoadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Page`
  String get labelPage {
    return Intl.message(
      'Page',
      name: 'labelPage',
      desc: '',
      args: [],
    );
  }

  /// `of`
  String get labelOf {
    return Intl.message(
      'of',
      name: 'labelOf',
      desc: '',
      args: [],
    );
  }

  /// `View Dispute`
  String get buttonViewDispute {
    return Intl.message(
      'View Dispute',
      name: 'buttonViewDispute',
      desc: '',
      args: [],
    );
  }

  /// `Raise Dispute`
  String get buttonRaiseDispute {
    return Intl.message(
      'Raise Dispute',
      name: 'buttonRaiseDispute',
      desc: '',
      args: [],
    );
  }

  /// `N/A`
  String get labelNA {
    return Intl.message(
      'N/A',
      name: 'labelNA',
      desc: '',
      args: [],
    );
  }

  /// `OTP has been sent successfully!`
  String get otpSentSuccess {
    return Intl.message(
      'OTP has been sent successfully!',
      name: 'otpSentSuccess',
      desc: '',
      args: [],
    );
  }

  /// `OTP has been resent successfully!`
  String get otpResendSuccess {
    return Intl.message(
      'OTP has been resent successfully!',
      name: 'otpResendSuccess',
      desc: '',
      args: [],
    );
  }

  /// `OTP verified successfully!`
  String get otpVerifiedSuccess {
    return Intl.message(
      'OTP verified successfully!',
      name: 'otpVerifiedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid 6-digit OTP.`
  String get otpInvalid {
    return Intl.message(
      'Please enter a valid 6-digit OTP.',
      name: 'otpInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Verification failed`
  String get verificationFailed {
    return Intl.message(
      'Verification failed',
      name: 'verificationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Failed to send OTP`
  String get errorSendingOtp {
    return Intl.message(
      'Failed to send OTP',
      name: 'errorSendingOtp',
      desc: '',
      args: [],
    );
  }

  /// `Mobile number already exists.`
  String get errorMobileInUse {
    return Intl.message(
      'Mobile number already exists.',
      name: 'errorMobileInUse',
      desc: '',
      args: [],
    );
  }

  /// `User Update Successful`
  String get successUserUpdate {
    return Intl.message(
      'User Update Successful',
      name: 'successUserUpdate',
      desc: '',
      args: [],
    );
  }

  /// `User Registration Successful`
  String get successUserRegistered {
    return Intl.message(
      'User Registration Successful',
      name: 'successUserRegistered',
      desc: '',
      args: [],
    );
  }

  /// `OTP`
  String get labelOtp {
    return Intl.message(
      'OTP',
      name: 'labelOtp',
      desc: '',
      args: [],
    );
  }

  /// `No Entity Id Provided`
  String get errorNoEntityId {
    return Intl.message(
      'No Entity Id Provided',
      name: 'errorNoEntityId',
      desc: '',
      args: [],
    );
  }

  /// `No User Id Provided`
  String get errorNoUserId {
    return Intl.message(
      'No User Id Provided',
      name: 'errorNoUserId',
      desc: '',
      args: [],
    );
  }

  /// `Error In loading Data`
  String get errorLoadData {
    return Intl.message(
      'Error In loading Data',
      name: 'errorLoadData',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to access this feature.`
  String get accessDenied {
    return Intl.message(
      'You do not have permission to access this feature.',
      name: 'accessDenied',
      desc: '',
      args: [],
    );
  }

  /// `Not Raised`
  String get notRaisedLabel {
    return Intl.message(
      'Not Raised',
      name: 'notRaisedLabel',
      desc: '',
      args: [],
    );
  }

  /// `Raised`
  String get raisedLabel {
    return Intl.message(
      'Raised',
      name: 'raisedLabel',
      desc: '',
      args: [],
    );
  }

  /// `Error Loading Role`
  String get errorLoadingRole {
    return Intl.message(
      'Error Loading Role',
      name: 'errorLoadingRole',
      desc: '',
      args: [],
    );
  }

  /// `Error In Menu render`
  String get errorRenderingMenu {
    return Intl.message(
      'Error In Menu render',
      name: 'errorRenderingMenu',
      desc: '',
      args: [],
    );
  }

  /// `Try Another Number`
  String get buttonTryAnotherNumber {
    return Intl.message(
      'Try Another Number',
      name: 'buttonTryAnotherNumber',
      desc: '',
      args: [],
    );
  }

  /// `Verification failed`
  String get errorVerificationFailed {
    return Intl.message(
      'Verification failed',
      name: 'errorVerificationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Valid 10-digit mobile number is required`
  String get errorInvalidMobile {
    return Intl.message(
      'Valid 10-digit mobile number is required',
      name: 'errorInvalidMobile',
      desc: '',
      args: [],
    );
  }

  /// `Success`
  String get statusSuccess {
    return Intl.message(
      'Success',
      name: 'statusSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Standard`
  String get labelStandard {
    return Intl.message(
      'Standard',
      name: 'labelStandard',
      desc: '',
      args: [],
    );
  }

  /// `Search by Ticket ID, Plaza, Vehicle Number...`
  String get searchRejectTicketHint {
    return Intl.message(
      'Search by Ticket ID, Plaza, Vehicle Number...',
      name: 'searchRejectTicketHint',
      desc: '',
      args: [],
    );
  }

  /// `No rejectable tickets`
  String get noRejectableTicketsLabel {
    return Intl.message(
      'No rejectable tickets',
      name: 'noRejectableTicketsLabel',
      desc: '',
      args: [],
    );
  }

  /// `There are no tickets to reject at the moment`
  String get noTicketsToRejectMessage {
    return Intl.message(
      'There are no tickets to reject at the moment',
      name: 'noTicketsToRejectMessage',
      desc: '',
      args: [],
    );
  }

  /// `No tickets match your search criteria`
  String get noTicketsMatchSearchMessage {
    return Intl.message(
      'No tickets match your search criteria',
      name: 'noTicketsMatchSearchMessage',
      desc: '',
      args: [],
    );
  }

  /// `Clear Search`
  String get clearSearchLabel {
    return Intl.message(
      'Clear Search',
      name: 'clearSearchLabel',
      desc: '',
      args: [],
    );
  }

  /// `No rejectable tickets were found.`
  String get errorNotFoundMessageReject {
    return Intl.message(
      'No rejectable tickets were found.',
      name: 'errorNotFoundMessageReject',
      desc: '',
      args: [],
    );
  }

  /// `Ticket ID:`
  String get ticketIdLabel {
    return Intl.message(
      'Ticket ID:',
      name: 'ticketIdLabel',
      desc: '',
      args: [],
    );
  }

  /// `Vehicle Number`
  String get vehicleNumberLabel {
    return Intl.message(
      'Vehicle Number',
      name: 'vehicleNumberLabel',
      desc: '',
      args: [],
    );
  }

  /// `User with this information already exists`
  String get errorUserExists {
    return Intl.message(
      'User with this information already exists',
      name: 'errorUserExists',
      desc: '',
      args: [],
    );
  }

  /// `Transaction download started`
  String get downloadTransactionsStarted {
    return Intl.message(
      'Transaction download started',
      name: 'downloadTransactionsStarted',
      desc: '',
      args: [],
    );
  }

  /// `Failed to download transactions`
  String get downloadTransactionsFailed {
    return Intl.message(
      'Failed to download transactions',
      name: 'downloadTransactionsFailed',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get labelSearch {
    return Intl.message(
      'Search',
      name: 'labelSearch',
      desc: '',
      args: [],
    );
  }

  /// `Plaza ID: `
  String get labelPlazaId {
    return Intl.message(
      'Plaza ID: ',
      name: 'labelPlazaId',
      desc: '',
      args: [],
    );
  }

  /// `Inactive`
  String get labelInactive {
    return Intl.message(
      'Inactive',
      name: 'labelInactive',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get labelActive {
    return Intl.message(
      'Active',
      name: 'labelActive',
      desc: '',
      args: [],
    );
  }

  /// `Amount`
  String get labelAmount {
    return Intl.message(
      'Amount',
      name: 'labelAmount',
      desc: '',
      args: [],
    );
  }

  /// `Effective Period`
  String get labelEffectivePeriod {
    return Intl.message(
      'Effective Period',
      name: 'labelEffectivePeriod',
      desc: '',
      args: [],
    );
  }

  /// `Ongoing`
  String get labelOngoing {
    return Intl.message(
      'Ongoing',
      name: 'labelOngoing',
      desc: '',
      args: [],
    );
  }

  /// `First page`
  String get tooltipFirstPage {
    return Intl.message(
      'First page',
      name: 'tooltipFirstPage',
      desc: '',
      args: [],
    );
  }

  /// `Previous page`
  String get tooltipPreviousPage {
    return Intl.message(
      'Previous page',
      name: 'tooltipPreviousPage',
      desc: '',
      args: [],
    );
  }

  /// `Next page`
  String get tooltipNextPage {
    return Intl.message(
      'Next page',
      name: 'tooltipNextPage',
      desc: '',
      args: [],
    );
  }

  /// `Last page`
  String get tooltipLastPage {
    return Intl.message(
      'Last page',
      name: 'tooltipLastPage',
      desc: '',
      args: [],
    );
  }

  /// `Captured Images`
  String get labelCapturedImages {
    return Intl.message(
      'Captured Images',
      name: 'labelCapturedImages',
      desc: '',
      args: [],
    );
  }

  /// `Ticket Reference ID`
  String get labelTicketReferenceId {
    return Intl.message(
      'Ticket Reference ID',
      name: 'labelTicketReferenceId',
      desc: '',
      args: [],
    );
  }

  /// `Entry Lane ID`
  String get labelEntryLaneId {
    return Intl.message(
      'Entry Lane ID',
      name: 'labelEntryLaneId',
      desc: '',
      args: [],
    );
  }

  /// `Entry Lane Direction`
  String get labelEntryLaneDirection {
    return Intl.message(
      'Entry Lane Direction',
      name: 'labelEntryLaneDirection',
      desc: '',
      args: [],
    );
  }

  /// `Vehicle Entry Timestamp`
  String get labelVehicleEntryTimestamp {
    return Intl.message(
      'Vehicle Entry Timestamp',
      name: 'labelVehicleEntryTimestamp',
      desc: '',
      args: [],
    );
  }

  /// `Ticket Creation Time`
  String get labelTicketCreationTime {
    return Intl.message(
      'Ticket Creation Time',
      name: 'labelTicketCreationTime',
      desc: '',
      args: [],
    );
  }

  /// `Ticket Status`
  String get labelTicketStatus {
    return Intl.message(
      'Ticket Status',
      name: 'labelTicketStatus',
      desc: '',
      args: [],
    );
  }

  /// `Reject Ticket`
  String get buttonRejectTicket {
    return Intl.message(
      'Reject Ticket',
      name: 'buttonRejectTicket',
      desc: '',
      args: [],
    );
  }

  /// `Remarks (Minimum 10 Characters Required)`
  String get labelRemarks {
    return Intl.message(
      'Remarks (Minimum 10 Characters Required)',
      name: 'labelRemarks',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get buttonSubmit {
    return Intl.message(
      'Submit',
      name: 'buttonSubmit',
      desc: '',
      args: [],
    );
  }

  /// `Ticket Rejected Successfully`
  String get messageTicketRejectedSuccess {
    return Intl.message(
      'Ticket Rejected Successfully',
      name: 'messageTicketRejectedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to reject ticket`
  String get errorFailedToRejectTicket {
    return Intl.message(
      'Failed to reject ticket',
      name: 'errorFailedToRejectTicket',
      desc: '',
      args: [],
    );
  }

  /// `Ticket not found`
  String get errorTicketNotFound {
    return Intl.message(
      'Ticket not found',
      name: 'errorTicketNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Total Bookings`
  String get totalBookings {
    return Intl.message(
      'Total Bookings',
      name: 'totalBookings',
      desc: '',
      args: [],
    );
  }

  /// `Cancelled Bookings`
  String get cancelledBookings {
    return Intl.message(
      'Cancelled Bookings',
      name: 'cancelledBookings',
      desc: '',
      args: [],
    );
  }

  /// `Success`
  String get success {
    return Intl.message(
      'Success',
      name: 'success',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Please correct the basic details.`
  String get errorCorrectBasicDetails {
    return Intl.message(
      'Please correct the basic details.',
      name: 'errorCorrectBasicDetails',
      desc: '',
      args: [],
    );
  }

  /// `Failed to register plaza.`
  String get errorApiFailedRegisterPlaza {
    return Intl.message(
      'Failed to register plaza.',
      name: 'errorApiFailedRegisterPlaza',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update plaza.`
  String get errorApiFailedUpdatePlaza {
    return Intl.message(
      'Failed to update plaza.',
      name: 'errorApiFailedUpdatePlaza',
      desc: '',
      args: [],
    );
  }

  /// `Failed to save basic details`
  String get errorApiFailedSaveBasicDetails {
    return Intl.message(
      'Failed to save basic details',
      name: 'errorApiFailedSaveBasicDetails',
      desc: '',
      args: [],
    );
  }

  /// `Basic details {operation} successfully!`
  String successBasicDetails(Object operation) {
    return Intl.message(
      'Basic details $operation successfully!',
      name: 'successBasicDetails',
      desc: '',
      args: [operation],
    );
  }

  /// `Please correct the bank details.`
  String get errorCorrectBankDetails {
    return Intl.message(
      'Please correct the bank details.',
      name: 'errorCorrectBankDetails',
      desc: '',
      args: [],
    );
  }

  /// `Failed to {operation} bank details.`
  String errorFailedBankDetails(Object operation) {
    return Intl.message(
      'Failed to $operation bank details.',
      name: 'errorFailedBankDetails',
      desc: '',
      args: [operation],
    );
  }

  /// `Failed to save bank details`
  String get errorFailedSaveBankDetails {
    return Intl.message(
      'Failed to save bank details',
      name: 'errorFailedSaveBankDetails',
      desc: '',
      args: [],
    );
  }

  /// `Bank details {operation} successfully!`
  String successBankDetails(Object operation) {
    return Intl.message(
      'Bank details $operation successfully!',
      name: 'successBankDetails',
      desc: '',
      args: [operation],
    );
  }

  /// `Failed to connect to the server. Please try again later.`
  String get errorMessageServer {
    return Intl.message(
      'Failed to connect to the server. Please try again later.',
      name: 'errorMessageServer',
      desc: '',
      args: [],
    );
  }

  /// `Registration successful! Please log in to continue.`
  String get successRegistrationMessage {
    return Intl.message(
      'Registration successful! Please log in to continue.',
      name: 'successRegistrationMessage',
      desc: '',
      args: [],
    );
  }

  /// `OTP sent to {mobile}`
  String otpSentTo(Object mobile) {
    return Intl.message(
      'OTP sent to $mobile',
      name: 'otpSentTo',
      desc: '',
      args: [mobile],
    );
  }

  /// `OTP send failed.`
  String get otpSendFailed {
    return Intl.message(
      'OTP send failed.',
      name: 'otpSendFailed',
      desc: '',
      args: [],
    );
  }

  /// `Search by plaza name or location...`
  String get hintSearchPlazas {
    return Intl.message(
      'Search by plaza name or location...',
      name: 'hintSearchPlazas',
      desc: '',
      args: [],
    );
  }

  /// `No plazas found`
  String get messageNoPlazasFound {
    return Intl.message(
      'No plazas found',
      name: 'messageNoPlazasFound',
      desc: '',
      args: [],
    );
  }

  /// `Mark Exit`
  String get buttonMarkExit {
    return Intl.message(
      'Mark Exit',
      name: 'buttonMarkExit',
      desc: '',
      args: [],
    );
  }

  /// `Failed to mark exit`
  String get errorMarkExitFailed {
    return Intl.message(
      'Failed to mark exit',
      name: 'errorMarkExitFailed',
      desc: '',
      args: [],
    );
  }

  /// `Fare not configured for this plaza.`
  String get errorFareNotConfigured {
    return Intl.message(
      'Fare not configured for this plaza.',
      name: 'errorFareNotConfigured',
      desc: '',
      args: [],
    );
  }

  /// `Configure Fare`
  String get buttonConfigureFare {
    return Intl.message(
      'Configure Fare',
      name: 'buttonConfigureFare',
      desc: '',
      args: [],
    );
  }

  /// `OR`
  String get labelOr {
    return Intl.message(
      'OR',
      name: 'labelOr',
      desc: '',
      args: [],
    );
  }

  /// `Marked Exit`
  String get ticketMarkedExitSuccess {
    return Intl.message(
      'Marked Exit',
      name: 'ticketMarkedExitSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Resend OTP in {seconds} s`
  String resendOtpInSeconds(int seconds) {
    return Intl.message(
      'Resend OTP in $seconds s',
      name: 'resendOtpInSeconds',
      desc: '',
      args: [seconds],
    );
  }

  /// `Please check your fields and try again.`
  String get errorValidationFailed {
    return Intl.message(
      'Please check your fields and try again.',
      name: 'errorValidationFailed',
      desc: 'Message shown when login validation fails due to invalid input.',
      args: [],
    );
  }

  /// `Success checkmark`
  String get successIconLabel {
    return Intl.message(
      'Success checkmark',
      name: 'successIconLabel',
      desc: '',
      args: [],
    );
  }

  /// `Images uploaded successfully!`
  String get successImagesUploaded {
    return Intl.message(
      'Images uploaded successfully!',
      name: 'successImagesUploaded',
      desc: '',
      args: [],
    );
  }

  /// `Failed to upload images`
  String get errorFailedUploadImages {
    return Intl.message(
      'Failed to upload images',
      name: 'errorFailedUploadImages',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get actionBack {
    return Intl.message(
      'Back',
      name: 'actionBack',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get actionDownload {
    return Intl.message(
      'Download',
      name: 'actionDownload',
      desc: '',
      args: [],
    );
  }

  /// `d ago`
  String get labelDaysAgo {
    return Intl.message(
      'd ago',
      name: 'labelDaysAgo',
      desc: '',
      args: [],
    );
  }

  /// `h ago`
  String get labelHoursAgo {
    return Intl.message(
      'h ago',
      name: 'labelHoursAgo',
      desc: '',
      args: [],
    );
  }

  /// `m ago`
  String get labelMinutesAgo {
    return Intl.message(
      'm ago',
      name: 'labelMinutesAgo',
      desc: '',
      args: [],
    );
  }

  /// `Just now`
  String get labelJustNow {
    return Intl.message(
      'Just now',
      name: 'labelJustNow',
      desc: '',
      args: [],
    );
  }

  /// `No items available`
  String get dropdownNoItems {
    return Intl.message(
      'No items available',
      name: 'dropdownNoItems',
      desc: '',
      args: [],
    );
  }

  /// `Clear search`
  String get searchClear {
    return Intl.message(
      'Clear search',
      name: 'searchClear',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get tooltipBack {
    return Intl.message(
      'Back',
      name: 'tooltipBack',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get tooltipEdit {
    return Intl.message(
      'Edit',
      name: 'tooltipEdit',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get tooltipCancel {
    return Intl.message(
      'Cancel',
      name: 'tooltipCancel',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get tooltipSave {
    return Intl.message(
      'Save',
      name: 'tooltipSave',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get tooltipDownload {
    return Intl.message(
      'Download',
      name: 'tooltipDownload',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get tooltipSearch {
    return Intl.message(
      'Search',
      name: 'tooltipSearch',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get tooltipDone {
    return Intl.message(
      'Done',
      name: 'tooltipDone',
      desc: '',
      args: [],
    );
  }

  /// `Person`
  String get tooltipPerson {
    return Intl.message(
      'Person',
      name: 'tooltipPerson',
      desc: '',
      args: [],
    );
  }

  /// `Lock`
  String get tooltipLock {
    return Intl.message(
      'Lock',
      name: 'tooltipLock',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get tooltipLogout {
    return Intl.message(
      'Logout',
      name: 'tooltipLogout',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get tooltipLanguage {
    return Intl.message(
      'Language',
      name: 'tooltipLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get tooltipTheme {
    return Intl.message(
      'Theme',
      name: 'tooltipTheme',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get tooltipNotifications {
    return Intl.message(
      'Notifications',
      name: 'tooltipNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Help`
  String get tooltipHelp {
    return Intl.message(
      'Help',
      name: 'tooltipHelp',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get tooltipAbout {
    return Intl.message(
      'About',
      name: 'tooltipAbout',
      desc: '',
      args: [],
    );
  }

  /// `Privacy`
  String get tooltipPrivacy {
    return Intl.message(
      'Privacy',
      name: 'tooltipPrivacy',
      desc: '',
      args: [],
    );
  }

  /// `Terms`
  String get tooltipTerms {
    return Intl.message(
      'Terms',
      name: 'tooltipTerms',
      desc: '',
      args: [],
    );
  }

  /// `Transactions`
  String get tooltipTransactions {
    return Intl.message(
      'Transactions',
      name: 'tooltipTransactions',
      desc: '',
      args: [],
    );
  }

  /// `Menu`
  String get tooltipMenu {
    return Intl.message(
      'Menu',
      name: 'tooltipMenu',
      desc: '',
      args: [],
    );
  }

  /// `Dashboard`
  String get tooltipDashboard {
    return Intl.message(
      'Dashboard',
      name: 'tooltipDashboard',
      desc: '',
      args: [],
    );
  }

  /// `Account`
  String get tooltipAccount {
    return Intl.message(
      'Account',
      name: 'tooltipAccount',
      desc: '',
      args: [],
    );
  }

  /// `Failed to resend OTP`
  String get otpResendFailed {
    return Intl.message(
      'Failed to resend OTP',
      name: 'otpResendFailed',
      desc: '',
      args: [],
    );
  }

  /// `Didn't receive the OTP?`
  String get otpDidNotReceive {
    return Intl.message(
      'Didn\'t receive the OTP?',
      name: 'otpDidNotReceive',
      desc: '',
      args: [],
    );
  }

  /// `Email ID already exists.`
  String get errorEmailInUse {
    return Intl.message(
      'Email ID already exists.',
      name: 'errorEmailInUse',
      desc: '',
      args: [],
    );
  }

  /// `Please try a different email`
  String get suggestionTryAnotherEmail {
    return Intl.message(
      'Please try a different email',
      name: 'suggestionTryAnotherEmail',
      desc: '',
      args: [],
    );
  }

  /// `Failed to register user`
  String get errorRegistrationFailed {
    return Intl.message(
      'Failed to register user',
      name: 'errorRegistrationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update user information`
  String get errorUpdateFailed {
    return Intl.message(
      'Failed to update user information',
      name: 'errorUpdateFailed',
      desc: '',
      args: [],
    );
  }

  /// `Profile updated successfully`
  String get successProfileUpdate {
    return Intl.message(
      'Profile updated successfully',
      name: 'successProfileUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Lane Details`
  String get laneDetails {
    return Intl.message(
      'Lane Details',
      name: 'laneDetails',
      desc: '',
      args: [],
    );
  }

  /// `Search by lane name, ID, or direction`
  String get searchLanesHint {
    return Intl.message(
      'Search by lane name, ID, or direction',
      name: 'searchLanesHint',
      desc: '',
      args: [],
    );
  }

  /// `No Lanes Found`
  String get noLanesFound {
    return Intl.message(
      'No Lanes Found',
      name: 'noLanesFound',
      desc: '',
      args: [],
    );
  }

  /// `No lanes available for this plaza.`
  String get noLanesForPlaza {
    return Intl.message(
      'No lanes available for this plaza.',
      name: 'noLanesForPlaza',
      desc: '',
      args: [],
    );
  }

  /// `No lanes match your search criteria.`
  String get noLanesMatchSearch {
    return Intl.message(
      'No lanes match your search criteria.',
      name: 'noLanesMatchSearch',
      desc: '',
      args: [],
    );
  }

  /// `Clear Search`
  String get clearSearch {
    return Intl.message(
      'Clear Search',
      name: 'clearSearch',
      desc: '',
      args: [],
    );
  }

  /// `Lane Name`
  String get laneName {
    return Intl.message(
      'Lane Name',
      name: 'laneName',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get active {
    return Intl.message(
      'Active',
      name: 'active',
      desc: '',
      args: [],
    );
  }

  /// `Inactive`
  String get inactive {
    return Intl.message(
      'Inactive',
      name: 'inactive',
      desc: '',
      args: [],
    );
  }

  /// `Lane Direction`
  String get laneDirection {
    return Intl.message(
      'Lane Direction',
      name: 'laneDirection',
      desc: '',
      args: [],
    );
  }

  /// `Lane Type`
  String get laneType {
    return Intl.message(
      'Lane Type',
      name: 'laneType',
      desc: '',
      args: [],
    );
  }

  /// `Lane Status`
  String get laneStatus {
    return Intl.message(
      'Lane Status',
      name: 'laneStatus',
      desc: '',
      args: [],
    );
  }

  /// `RFID Reader`
  String get rfid {
    return Intl.message(
      'RFID Reader',
      name: 'rfid',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get camera {
    return Intl.message(
      'Camera',
      name: 'camera',
      desc: '',
      args: [],
    );
  }

  /// `WIM`
  String get wim {
    return Intl.message(
      'WIM',
      name: 'wim',
      desc: '',
      args: [],
    );
  }

  /// `Boomer Barrier`
  String get barrier {
    return Intl.message(
      'Boomer Barrier',
      name: 'barrier',
      desc: '',
      args: [],
    );
  }

  /// `LED Screen`
  String get led {
    return Intl.message(
      'LED Screen',
      name: 'led',
      desc: '',
      args: [],
    );
  }

  /// `Magnetic Loop`
  String get loop {
    return Intl.message(
      'Magnetic Loop',
      name: 'loop',
      desc: '',
      args: [],
    );
  }

  /// `N/A`
  String get notApplicable {
    return Intl.message(
      'N/A',
      name: 'notApplicable',
      desc: '',
      args: [],
    );
  }

  /// `updated`
  String get bankDetailsFailed_action {
    return Intl.message(
      'updated',
      name: 'bankDetailsFailed_action',
      desc: '',
      args: [],
    );
  }

  /// `HTTP status code`
  String get errorTitleWithCode_code {
    return Intl.message(
      'HTTP status code',
      name: 'errorTitleWithCode_code',
      desc: '',
      args: [],
    );
  }

  /// `Service Error`
  String get errorTitleService {
    return Intl.message(
      'Service Error',
      name: 'errorTitleService',
      desc: '',
      args: [],
    );
  }

  /// `Plaza Error`
  String get errorTitlePlaza {
    return Intl.message(
      'Plaza Error',
      name: 'errorTitlePlaza',
      desc: '',
      args: [],
    );
  }

  /// `No additional details available.`
  String get errorDetailsNoDetails {
    return Intl.message(
      'No additional details available.',
      name: 'errorDetailsNoDetails',
      desc: '',
      args: [],
    );
  }

  /// `Please check your connection or try again later.`
  String get errorDetailsService {
    return Intl.message(
      'Please check your connection or try again later.',
      name: 'errorDetailsService',
      desc: '',
      args: [],
    );
  }

  /// `An unknown error occurred.`
  String get errorMessageUnknown {
    return Intl.message(
      'An unknown error occurred.',
      name: 'errorMessageUnknown',
      desc: '',
      args: [],
    );
  }

  /// `No images uploaded yet.`
  String get messageNoImagesUploaded {
    return Intl.message(
      'No images uploaded yet.',
      name: 'messageNoImagesUploaded',
      desc: '',
      args: [],
    );
  }

  /// `Plaza Images`
  String get plazaImagesTitle {
    return Intl.message(
      'Plaza Images',
      name: 'plazaImagesTitle',
      desc: '',
      args: [],
    );
  }

  /// `Failed to pick images: `
  String get messageFailedToPickImages {
    return Intl.message(
      'Failed to pick images: ',
      name: 'messageFailedToPickImages',
      desc: '',
      args: [],
    );
  }

  /// `error details`
  String get messageFailedToPickImages_error {
    return Intl.message(
      'error details',
      name: 'messageFailedToPickImages_error',
      desc: '',
      args: [],
    );
  }

  /// `Image removed successfully!`
  String get messageImageRemovedSuccess {
    return Intl.message(
      'Image removed successfully!',
      name: 'messageImageRemovedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to remove image.`
  String get messageImageRemovedFailed {
    return Intl.message(
      'Failed to remove image.',
      name: 'messageImageRemovedFailed',
      desc: '',
      args: [],
    );
  }

  /// `Failed to refresh images: `
  String get messageFailedToRefreshImages {
    return Intl.message(
      'Failed to refresh images: ',
      name: 'messageFailedToRefreshImages',
      desc: '',
      args: [],
    );
  }

  /// `error details`
  String get messageFailedToRefreshImages_error {
    return Intl.message(
      'error details',
      name: 'messageFailedToRefreshImages_error',
      desc: '',
      args: [],
    );
  }

  /// `Failed to save images: `
  String get messageFailedToSaveImages {
    return Intl.message(
      'Failed to save images: ',
      name: 'messageFailedToSaveImages',
      desc: '',
      args: [],
    );
  }

  /// `error details`
  String get messageFailedToSaveImages_error {
    return Intl.message(
      'error details',
      name: 'messageFailedToSaveImages_error',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Changes`
  String get tooltipCancelChanges {
    return Intl.message(
      'Cancel Changes',
      name: 'tooltipCancelChanges',
      desc: '',
      args: [],
    );
  }

  /// `Save Changes`
  String get tooltipSaveChanges {
    return Intl.message(
      'Save Changes',
      name: 'tooltipSaveChanges',
      desc: '',
      args: [],
    );
  }

  /// `Add Image`
  String get tooltipAddImage {
    return Intl.message(
      'Add Image',
      name: 'tooltipAddImage',
      desc: '',
      args: [],
    );
  }

  /// `Remove Image`
  String get tooltipRemoveImage {
    return Intl.message(
      'Remove Image',
      name: 'tooltipRemoveImage',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message(
      'Retry',
      name: 'retry',
      desc: '',
      args: [],
    );
  }

  /// `ID`
  String get id {
    return Intl.message(
      'ID',
      name: 'id',
      desc: '',
      args: [],
    );
  }

  /// `Error {code}`
  String errorTitleWithCode(Object code) {
    return Intl.message(
      'Error $code',
      name: 'errorTitleWithCode',
      desc: 'Error title with HTTP status code',
      args: [code],
    );
  }

  /// `Unknown Plaza`
  String get unknownPlaza {
    return Intl.message(
      'Unknown Plaza',
      name: 'unknownPlaza',
      desc: '',
      args: [],
    );
  }

  /// `New Lane`
  String get newLane {
    return Intl.message(
      'New Lane',
      name: 'newLane',
      desc: '',
      args: [],
    );
  }

  /// `Lane added successfully!`
  String get laneAddedSuccess {
    return Intl.message(
      'Lane added successfully!',
      name: 'laneAddedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to add lane`
  String get laneAddFailed {
    return Intl.message(
      'Failed to add lane',
      name: 'laneAddFailed',
      desc: '',
      args: [],
    );
  }

  /// `Please correct the errors in basic details.`
  String get correctBasicDetailsErrors {
    return Intl.message(
      'Please correct the errors in basic details.',
      name: 'correctBasicDetailsErrors',
      desc: '',
      args: [],
    );
  }

  /// `Basic details updated successfully!`
  String get basicDetailsUpdated {
    return Intl.message(
      'Basic details updated successfully!',
      name: 'basicDetailsUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update plaza details.`
  String get updatePlazaFailed {
    return Intl.message(
      'Failed to update plaza details.',
      name: 'updatePlazaFailed',
      desc: '',
      args: [],
    );
  }

  /// `Please correct the errors in bank details.`
  String get correctBankDetailsErrors {
    return Intl.message(
      'Please correct the errors in bank details.',
      name: 'correctBankDetailsErrors',
      desc: '',
      args: [],
    );
  }

  /// `Bank details {operation} successfully!`
  String bankDetailsSuccess(Object operation) {
    return Intl.message(
      'Bank details $operation successfully!',
      name: 'bankDetailsSuccess',
      desc: '',
      args: [operation],
    );
  }

  /// `Failed to {operation} bank details.`
  String bankDetailsFailed(Object operation) {
    return Intl.message(
      'Failed to $operation bank details.',
      name: 'bankDetailsFailed',
      desc: '',
      args: [operation],
    );
  }

  /// `updated`
  String get updated {
    return Intl.message(
      'updated',
      name: 'updated',
      desc: '',
      args: [],
    );
  }

  /// `added`
  String get added {
    return Intl.message(
      'added',
      name: 'added',
      desc: '',
      args: [],
    );
  }

  /// `Images uploaded successfully!`
  String get imagesUploadedSuccess {
    return Intl.message(
      'Images uploaded successfully!',
      name: 'imagesUploadedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to upload images`
  String get imagesUploadFailed {
    return Intl.message(
      'Failed to upload images',
      name: 'imagesUploadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Edit Lane Details`
  String get editLaneDetails {
    return Intl.message(
      'Edit Lane Details',
      name: 'editLaneDetails',
      desc: '',
      args: [],
    );
  }

  /// `No lane data available.`
  String get noLaneData {
    return Intl.message(
      'No lane data available.',
      name: 'noLaneData',
      desc: '',
      args: [],
    );
  }

  /// `RFID Reader ID`
  String get rfidReaderId {
    return Intl.message(
      'RFID Reader ID',
      name: 'rfidReaderId',
      desc: '',
      args: [],
    );
  }

  /// `Camera ID`
  String get cameraId {
    return Intl.message(
      'Camera ID',
      name: 'cameraId',
      desc: '',
      args: [],
    );
  }

  /// `WIM ID`
  String get wimId {
    return Intl.message(
      'WIM ID',
      name: 'wimId',
      desc: '',
      args: [],
    );
  }

  /// `Boomer Barrier ID`
  String get boomerBarrierId {
    return Intl.message(
      'Boomer Barrier ID',
      name: 'boomerBarrierId',
      desc: '',
      args: [],
    );
  }

  /// `LED Screen ID`
  String get ledScreenId {
    return Intl.message(
      'LED Screen ID',
      name: 'ledScreenId',
      desc: '',
      args: [],
    );
  }

  /// `Magnetic Loop ID`
  String get magneticLoopId {
    return Intl.message(
      'Magnetic Loop ID',
      name: 'magneticLoopId',
      desc: '',
      args: [],
    );
  }

  /// `No lane selected.`
  String get noLaneSelected {
    return Intl.message(
      'No lane selected.',
      name: 'noLaneSelected',
      desc: '',
      args: [],
    );
  }

  /// `Lane updated successfully!`
  String get laneUpdatedSuccess {
    return Intl.message(
      'Lane updated successfully!',
      name: 'laneUpdatedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update lane`
  String get laneUpdateFailed {
    return Intl.message(
      'Failed to update lane',
      name: 'laneUpdateFailed',
      desc: '',
      args: [],
    );
  }

  /// `Resend OTP`
  String get buttonResendOtp {
    return Intl.message(
      'Resend OTP',
      name: 'buttonResendOtp',
      desc: '',
      args: [],
    );
  }

  /// `Biometric authentication updated`
  String get toggleBiometricSuccess {
    return Intl.message(
      'Biometric authentication updated',
      name: 'toggleBiometricSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Notification settings updated`
  String get toggleNotificationsSuccess {
    return Intl.message(
      'Notification settings updated',
      name: 'toggleNotificationsSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Logged out successfully`
  String get logoutSuccess {
    return Intl.message(
      'Logged out successfully',
      name: 'logoutSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Refreshing transactions...`
  String get refreshTransactions {
    return Intl.message(
      'Refreshing transactions...',
      name: 'refreshTransactions',
      desc: '',
      args: [],
    );
  }

  /// `Download started`
  String get downloadStarted {
    return Intl.message(
      'Download started',
      name: 'downloadStarted',
      desc: '',
      args: [],
    );
  }

  /// `No Transactions`
  String get noTransactionsTitle {
    return Intl.message(
      'No Transactions',
      name: 'noTransactionsTitle',
      desc: '',
      args: [],
    );
  }

  /// `You haven't made any transactions yet.`
  String get noTransactionsSubtitle {
    return Intl.message(
      'You haven\'t made any transactions yet.',
      name: 'noTransactionsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Refreshing notifications...`
  String get refreshNotifications {
    return Intl.message(
      'Refreshing notifications...',
      name: 'refreshNotifications',
      desc: '',
      args: [],
    );
  }

  /// `No Notifications`
  String get noNotificationsTitle {
    return Intl.message(
      'No Notifications',
      name: 'noNotificationsTitle',
      desc: '',
      args: [],
    );
  }

  /// `You don't have any notifications yet.`
  String get noNotificationsSubtitle {
    return Intl.message(
      'You don\'t have any notifications yet.',
      name: 'noNotificationsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Profile refreshed successfully`
  String get profileRefreshSuccess {
    return Intl.message(
      'Profile refreshed successfully',
      name: 'profileRefreshSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to refresh profile`
  String get profileRefreshFailed {
    return Intl.message(
      'Failed to refresh profile',
      name: 'profileRefreshFailed',
      desc: '',
      args: [],
    );
  }

  /// `Bank Details`
  String get bankDetails {
    return Intl.message(
      'Bank Details',
      name: 'bankDetails',
      desc: '',
      args: [],
    );
  }

  /// `Bank Name`
  String get bankName {
    return Intl.message(
      'Bank Name',
      name: 'bankName',
      desc: '',
      args: [],
    );
  }

  /// `Account Number`
  String get accountNumber {
    return Intl.message(
      'Account Number',
      name: 'accountNumber',
      desc: '',
      args: [],
    );
  }

  /// `Account Holder Name`
  String get accountHolderName {
    return Intl.message(
      'Account Holder Name',
      name: 'accountHolderName',
      desc: '',
      args: [],
    );
  }

  /// `IFSC Code`
  String get ifscCode {
    return Intl.message(
      'IFSC Code',
      name: 'ifscCode',
      desc: '',
      args: [],
    );
  }

  /// `Please select a valid plaza to view bank details.`
  String get invalidPlazaId {
    return Intl.message(
      'Please select a valid plaza to view bank details.',
      name: 'invalidPlazaId',
      desc: '',
      args: [],
    );
  }

  /// `Data refreshed successfully`
  String get dataRefreshSuccess {
    return Intl.message(
      'Data refreshed successfully',
      name: 'dataRefreshSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to refresh data`
  String get dataRefreshFailed {
    return Intl.message(
      'Failed to refresh data',
      name: 'dataRefreshFailed',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email/mobile or password.`
  String get errorInvalidCredentials {
    return Intl.message(
      'Invalid email/mobile or password.',
      name: 'errorInvalidCredentials',
      desc: '',
      args: [],
    );
  }

  /// `User not found. Please register.`
  String get errorUserNotFound {
    return Intl.message(
      'User not found. Please register.',
      name: 'errorUserNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Login failed`
  String get errorLoginFailed {
    return Intl.message(
      'Login failed',
      name: 'errorLoginFailed',
      desc: '',
      args: [],
    );
  }

  /// `OTP verification failed. Please try again.`
  String get errorOtpVerificationFailed {
    return Intl.message(
      'OTP verification failed. Please try again.',
      name: 'errorOtpVerificationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Please correct the errors`
  String get errorCorrectErrors {
    return Intl.message(
      'Please correct the errors',
      name: 'errorCorrectErrors',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get titleProfile {
    return Intl.message(
      'Profile',
      name: 'titleProfile',
      desc: '',
      args: [],
    );
  }

  /// `Basic Details`
  String get basicDetails {
    return Intl.message(
      'Basic Details',
      name: 'basicDetails',
      desc: '',
      args: [],
    );
  }

  /// `Plaza Name`
  String get plazaName {
    return Intl.message(
      'Plaza Name',
      name: 'plazaName',
      desc: '',
      args: [],
    );
  }

  /// `Plaza Operator Name`
  String get plazaOperatorName {
    return Intl.message(
      'Plaza Operator Name',
      name: 'plazaOperatorName',
      desc: '',
      args: [],
    );
  }

  /// `Mobile Number`
  String get mobileNumber {
    return Intl.message(
      'Mobile Number',
      name: 'mobileNumber',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get address {
    return Intl.message(
      'Address',
      name: 'address',
      desc: '',
      args: [],
    );
  }

  /// `City`
  String get city {
    return Intl.message(
      'City',
      name: 'city',
      desc: '',
      args: [],
    );
  }

  /// `District`
  String get district {
    return Intl.message(
      'District',
      name: 'district',
      desc: '',
      args: [],
    );
  }

  /// `State`
  String get state {
    return Intl.message(
      'State',
      name: 'state',
      desc: '',
      args: [],
    );
  }

  /// `Pincode`
  String get pincode {
    return Intl.message(
      'Pincode',
      name: 'pincode',
      desc: '',
      args: [],
    );
  }

  /// `Geo Latitude`
  String get geoLatitude {
    return Intl.message(
      'Geo Latitude',
      name: 'geoLatitude',
      desc: '',
      args: [],
    );
  }

  /// `Geo Longitude`
  String get geoLongitude {
    return Intl.message(
      'Geo Longitude',
      name: 'geoLongitude',
      desc: '',
      args: [],
    );
  }

  /// `Plaza Category`
  String get plazaCategory {
    return Intl.message(
      'Plaza Category',
      name: 'plazaCategory',
      desc: '',
      args: [],
    );
  }

  /// `Plaza Sub-Category`
  String get plazaSubCategory {
    return Intl.message(
      'Plaza Sub-Category',
      name: 'plazaSubCategory',
      desc: '',
      args: [],
    );
  }

  /// `Plaza Status`
  String get plazaStatus {
    return Intl.message(
      'Plaza Status',
      name: 'plazaStatus',
      desc: '',
      args: [],
    );
  }

  /// `Free Parking`
  String get freeParking {
    return Intl.message(
      'Free Parking',
      name: 'freeParking',
      desc: '',
      args: [],
    );
  }

  /// `Structure Type`
  String get structureType {
    return Intl.message(
      'Structure Type',
      name: 'structureType',
      desc: '',
      args: [],
    );
  }

  /// `Price Category`
  String get priceCategory {
    return Intl.message(
      'Price Category',
      name: 'priceCategory',
      desc: '',
      args: [],
    );
  }

  /// `Total Parking Slots`
  String get totalParkingSlots {
    return Intl.message(
      'Total Parking Slots',
      name: 'totalParkingSlots',
      desc: '',
      args: [],
    );
  }

  /// `Two-Wheeler Capacity`
  String get twoWheelerCapacity {
    return Intl.message(
      'Two-Wheeler Capacity',
      name: 'twoWheelerCapacity',
      desc: '',
      args: [],
    );
  }

  /// `LMV Capacity`
  String get lmvCapacity {
    return Intl.message(
      'LMV Capacity',
      name: 'lmvCapacity',
      desc: '',
      args: [],
    );
  }

  /// `LCV Capacity`
  String get lcvCapacity {
    return Intl.message(
      'LCV Capacity',
      name: 'lcvCapacity',
      desc: '',
      args: [],
    );
  }

  /// `HMV Capacity`
  String get hmvCapacity {
    return Intl.message(
      'HMV Capacity',
      name: 'hmvCapacity',
      desc: '',
      args: [],
    );
  }

  /// `Opening Time`
  String get openingTime {
    return Intl.message(
      'Opening Time',
      name: 'openingTime',
      desc: '',
      args: [],
    );
  }

  /// `Closing Time`
  String get closingTime {
    return Intl.message(
      'Closing Time',
      name: 'closingTime',
      desc: '',
      args: [],
    );
  }

  /// `Plaza Registration`
  String get titlePlazaRegistration {
    return Intl.message(
      'Plaza Registration',
      name: 'titlePlazaRegistration',
      desc: '',
      args: [],
    );
  }

  /// `Basic\nDetails`
  String get labelBasicDetails {
    return Intl.message(
      'Basic\nDetails',
      name: 'labelBasicDetails',
      desc: '',
      args: [],
    );
  }

  /// `Lane\nDetails`
  String get labelLaneDetails {
    return Intl.message(
      'Lane\nDetails',
      name: 'labelLaneDetails',
      desc: '',
      args: [],
    );
  }

  /// `Bank\nDetails`
  String get labelBankDetails {
    return Intl.message(
      'Bank\nDetails',
      name: 'labelBankDetails',
      desc: '',
      args: [],
    );
  }

  /// `Plaza\nImages`
  String get labelPlazaImages {
    return Intl.message(
      'Plaza\nImages',
      name: 'labelPlazaImages',
      desc: '',
      args: [],
    );
  }

  /// `New Lanes`
  String get labelNewLanes {
    return Intl.message(
      'New Lanes',
      name: 'labelNewLanes',
      desc: '',
      args: [],
    );
  }

  /// `Existing Lanes`
  String get labelExistingLanes {
    return Intl.message(
      'Existing Lanes',
      name: 'labelExistingLanes',
      desc: '',
      args: [],
    );
  }

  /// `Edit Lane`
  String get titleEditLane {
    return Intl.message(
      'Edit Lane',
      name: 'titleEditLane',
      desc: '',
      args: [],
    );
  }

  /// `Edit mode active - Tap on any lane to modify its details`
  String get messageEditModeActive {
    return Intl.message(
      'Edit mode active - Tap on any lane to modify its details',
      name: 'messageEditModeActive',
      desc: '',
      args: [],
    );
  }

  /// `Error saving lane. Please check all fields.`
  String get messageErrorSavingLane {
    return Intl.message(
      'Error saving lane. Please check all fields.',
      name: 'messageErrorSavingLane',
      desc: '',
      args: [],
    );
  }

  /// `Error updating lane. Please check all fields.`
  String get messageErrorUpdatingLane {
    return Intl.message(
      'Error updating lane. Please check all fields.',
      name: 'messageErrorUpdatingLane',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load profile data`
  String get errorLoadProfileFailed {
    return Intl.message(
      'Failed to load profile data',
      name: 'errorLoadProfileFailed',
      desc: '',
      args: [],
    );
  }

  /// `{field} is required`
  String validationRequired(Object field) {
    return Intl.message(
      '$field is required',
      name: 'validationRequired',
      desc: '',
      args: [field],
    );
  }

  /// `Error when a field is empty or too short`
  String get validationRequired_description {
    return Intl.message(
      'Error when a field is empty or too short',
      name: 'validationRequired_description',
      desc: '',
      args: [],
    );
  }

  /// `The name of the field`
  String get validationRequired_field {
    return Intl.message(
      'The name of the field',
      name: 'validationRequired_field',
      desc: '',
      args: [],
    );
  }

  /// `{field} must not exceed {max} characters`
  String validationMaxLength(Object field, Object max) {
    return Intl.message(
      '$field must not exceed $max characters',
      name: 'validationMaxLength',
      desc: '',
      args: [field, max],
    );
  }

  /// `Error when a field exceeds max length`
  String get validationMaxLength_description {
    return Intl.message(
      'Error when a field exceeds max length',
      name: 'validationMaxLength_description',
      desc: '',
      args: [],
    );
  }

  /// `{field} must be at least {min} digits`
  String validationMinDigits(Object field, Object min) {
    return Intl.message(
      '$field must be at least $min digits',
      name: 'validationMinDigits',
      desc: '',
      args: [field, min],
    );
  }

  /// `Error when a numeric field is too short`
  String get validationMinDigits_description {
    return Intl.message(
      'Error when a numeric field is too short',
      name: 'validationMinDigits_description',
      desc: '',
      args: [],
    );
  }

  /// `{field} must not exceed {max} digits`
  String validationMaxDigits(Object field, Object max) {
    return Intl.message(
      '$field must not exceed $max digits',
      name: 'validationMaxDigits',
      desc: '',
      args: [field, max],
    );
  }

  /// `Error when a numeric field is too long`
  String get validationMaxDigits_description {
    return Intl.message(
      'Error when a numeric field is too long',
      name: 'validationMaxDigits_description',
      desc: '',
      args: [],
    );
  }

  /// `{field} must contain only digits`
  String validationDigitsOnly(Object field) {
    return Intl.message(
      '$field must contain only digits',
      name: 'validationDigitsOnly',
      desc: '',
      args: [field],
    );
  }

  /// `Error when a field has non-digit characters`
  String get validationDigitsOnly_description {
    return Intl.message(
      'Error when a field has non-digit characters',
      name: 'validationDigitsOnly_description',
      desc: '',
      args: [],
    );
  }

  /// `{field} must be greater than 0`
  String validationGreaterThanZero(Object field) {
    return Intl.message(
      '$field must be greater than 0',
      name: 'validationGreaterThanZero',
      desc: '',
      args: [field],
    );
  }

  /// `Error when a numeric field is not positive`
  String get validationGreaterThanZero_description {
    return Intl.message(
      'Error when a numeric field is not positive',
      name: 'validationGreaterThanZero_description',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email address`
  String get validationInvalidEmail {
    return Intl.message(
      'Please enter a valid email address',
      name: 'validationInvalidEmail',
      desc: 'Error message for invalid email format',
      args: [],
    );
  }

  /// `Error when email format is invalid`
  String get validationInvalidEmail_description {
    return Intl.message(
      'Error when email format is invalid',
      name: 'validationInvalidEmail_description',
      desc: '',
      args: [],
    );
  }

  /// `{field} must be a valid number`
  String validationInvalidNumber(Object field) {
    return Intl.message(
      '$field must be a valid number',
      name: 'validationInvalidNumber',
      desc: '',
      args: [field],
    );
  }

  /// `Error when a field isn't a valid number`
  String get validationInvalidNumber_description {
    return Intl.message(
      'Error when a field isn\'t a valid number',
      name: 'validationInvalidNumber_description',
      desc: '',
      args: [],
    );
  }

  /// `{field} must be between {min}° and {max}°`
  String validationRange(Object field, Object min, Object max) {
    return Intl.message(
      '$field must be between $min° and $max°',
      name: 'validationRange',
      desc: '',
      args: [field, min, max],
    );
  }

  /// `Error when a coordinate is out of range`
  String get validationRange_description {
    return Intl.message(
      'Error when a coordinate is out of range',
      name: 'validationRange_description',
      desc: '',
      args: [],
    );
  }

  /// `Please select {field}`
  String validationSelectRequired(Object field) {
    return Intl.message(
      'Please select $field',
      name: 'validationSelectRequired',
      desc: '',
      args: [field],
    );
  }

  /// `Error when a dropdown isn't selected`
  String get validationSelectRequired_description {
    return Intl.message(
      'Error when a dropdown isn\'t selected',
      name: 'validationSelectRequired_description',
      desc: '',
      args: [],
    );
  }

  /// `Invalid {field}. Must be one of: {options}`
  String validationInvalidOption(Object field, Object options) {
    return Intl.message(
      'Invalid $field. Must be one of: $options',
      name: 'validationInvalidOption',
      desc: '',
      args: [field, options],
    );
  }

  /// `Error when a dropdown value is invalid`
  String get validationInvalidOption_description {
    return Intl.message(
      'Error when a dropdown value is invalid',
      name: 'validationInvalidOption_description',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid time in HH:MM format`
  String get validationInvalidTimeFormat {
    return Intl.message(
      'Please enter a valid time in HH:MM format',
      name: 'validationInvalidTimeFormat',
      desc: 'Error message for invalid time format',
      args: [],
    );
  }

  /// `Error when time format is invalid`
  String get validationInvalidTimeFormat_description {
    return Intl.message(
      'Error when time format is invalid',
      name: 'validationInvalidTimeFormat_description',
      desc: '',
      args: [],
    );
  }

  /// `{field} must be a boolean value`
  String validationBooleanRequired(Object field) {
    return Intl.message(
      '$field must be a boolean value',
      name: 'validationBooleanRequired',
      desc: '',
      args: [field],
    );
  }

  /// `Error when a boolean field is invalid`
  String get validationBooleanRequired_description {
    return Intl.message(
      'Error when a boolean field is invalid',
      name: 'validationBooleanRequired_description',
      desc: '',
      args: [],
    );
  }

  /// `This feature is not yet implemented.`
  String get messageFeatureNotImplemented {
    return Intl.message(
      'This feature is not yet implemented.',
      name: 'messageFeatureNotImplemented',
      desc: '',
      args: [],
    );
  }

  /// `No filters available at this time.`
  String get messageNoLanesAvailable {
    return Intl.message(
      'No filters available at this time.',
      name: 'messageNoLanesAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Plaza Information`
  String get plazaInfoTitle {
    return Intl.message(
      'Plaza Information',
      name: 'plazaInfoTitle',
      desc: '',
      args: [],
    );
  }

  /// `Error loading plaza details: `
  String errorLoadingPlazaDetails(Object error) {
    return Intl.message(
      'Error loading plaza details: ',
      name: 'errorLoadingPlazaDetails',
      desc: 'Error message with details for loading plaza details',
      args: [error],
    );
  }

  /// `ID: {id}`
  String labelIdValue(Object id) {
    return Intl.message(
      'ID: $id',
      name: 'labelIdValue',
      desc: 'Label for displaying an ID value',
      args: [id],
    );
  }

  /// `Failed to Load Plaza Details`
  String get errorLoadingPlazaDetailsFailed {
    return Intl.message(
      'Failed to Load Plaza Details',
      name: 'errorLoadingPlazaDetailsFailed',
      desc: '',
      args: [],
    );
  }

  /// `Please try again later.`
  String get errorMessagePleaseTryAgain {
    return Intl.message(
      'Please try again later.',
      name: 'errorMessagePleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get loadingEllipsis {
    return Intl.message(
      'Loading...',
      name: 'loadingEllipsis',
      desc:
          'Placeholder text shown while data is loading, e.g., for names or statuses.',
      args: [],
    );
  }

  /// `Category`
  String get labelCategory {
    return Intl.message(
      'Category',
      name: 'labelCategory',
      desc: '',
      args: [],
    );
  }

  /// `Basic Details`
  String get menuBasicDetails {
    return Intl.message(
      'Basic Details',
      name: 'menuBasicDetails',
      desc: '',
      args: [],
    );
  }

  /// `Lane Details`
  String get menuLaneDetails {
    return Intl.message(
      'Lane Details',
      name: 'menuLaneDetails',
      desc: '',
      args: [],
    );
  }

  /// `Bank Details`
  String get menuBankDetails {
    return Intl.message(
      'Bank Details',
      name: 'menuBankDetails',
      desc: '',
      args: [],
    );
  }

  /// `Error saving plaza details`
  String get errorSavingPlaza {
    return Intl.message(
      'Error saving plaza details',
      name: 'errorSavingPlaza',
      desc: '',
      args: [],
    );
  }

  /// `Error saving bank details`
  String get errorSavingBankDetails {
    return Intl.message(
      'Error saving bank details',
      name: 'errorSavingBankDetails',
      desc: '',
      args: [],
    );
  }

  /// `Error fetching lanes`
  String get errorFetchingLanes {
    return Intl.message(
      'Error fetching lanes',
      name: 'errorFetchingLanes',
      desc: '',
      args: [],
    );
  }

  /// `Error fetching lane details`
  String get errorFetchingLane {
    return Intl.message(
      'Error fetching lane details',
      name: 'errorFetchingLane',
      desc: '',
      args: [],
    );
  }

  /// `Error saving lane`
  String get errorSavingLane {
    return Intl.message(
      'Error saving lane',
      name: 'errorSavingLane',
      desc: '',
      args: [],
    );
  }

  /// `Error fetching images`
  String get errorFetchingImages {
    return Intl.message(
      'Error fetching images',
      name: 'errorFetchingImages',
      desc: '',
      args: [],
    );
  }

  /// `Error removing image`
  String get errorRemovingImage {
    return Intl.message(
      'Error removing image',
      name: 'errorRemovingImage',
      desc: '',
      args: [],
    );
  }

  /// `Basic details Updated successfully`
  String get basicDetailsUpdateSuccess {
    return Intl.message(
      'Basic details Updated successfully',
      name: 'basicDetailsUpdateSuccess',
      desc: '',
      args: [],
    );
  }

  /// `updated`
  String get updateOperation {
    return Intl.message(
      'updated',
      name: 'updateOperation',
      desc: '',
      args: [],
    );
  }

  /// `added`
  String get addOperation {
    return Intl.message(
      'added',
      name: 'addOperation',
      desc: '',
      args: [],
    );
  }

  /// `Plaza Images`
  String get menuPlazaImages {
    return Intl.message(
      'Plaza Images',
      name: 'menuPlazaImages',
      desc: '',
      args: [],
    );
  }

  /// `Loading ID...`
  String get loadingId {
    return Intl.message(
      'Loading ID...',
      name: 'loadingId',
      desc: 'Placeholder text shown for an ID field while data is loading.',
      args: [],
    );
  }

  /// `Could not load plaza details at this time.`
  String get errorLoadingPlazaDetailsGeneric {
    return Intl.message(
      'Could not load plaza details at this time.',
      name: 'errorLoadingPlazaDetailsGeneric',
      desc:
          'Generic error message shown when loading plaza details fails for an unspecified reason.',
      args: [],
    );
  }

  /// `Unable to Load Plazas`
  String get errorTitleUnableToLoadPlazas {
    return Intl.message(
      'Unable to Load Plazas',
      name: 'errorTitleUnableToLoadPlazas',
      desc: 'Error title shown when fetching the list of plazas fails.',
      args: [],
    );
  }

  /// `No plazas match your search or filter criteria.`
  String get messageNoPlazasMatchFilter {
    return Intl.message(
      'No plazas match your search or filter criteria.',
      name: 'messageNoPlazasMatchFilter',
      desc:
          'Message shown when the plaza list is empty after applying search or filters.',
      args: [],
    );
  }

  /// `No more plazas found.`
  String get messageNoMorePlazas {
    return Intl.message(
      'No more plazas found.',
      name: 'messageNoMorePlazas',
      desc:
          'Message shown on a paginated list when navigating to a page beyond the last item (e.g., page 2 is empty).',
      args: [],
    );
  }

  /// `Download plaza list`
  String get tooltipDownloadPlazaList {
    return Intl.message(
      'Download plaza list',
      name: 'tooltipDownloadPlazaList',
      desc:
          'Tooltip text for the download icon button in the plaza list app bar.',
      args: [],
    );
  }

  /// `Cannot proceed: Plaza ID is missing.`
  String get errorMissingPlazaId {
    return Intl.message(
      'Cannot proceed: Plaza ID is missing.',
      name: 'errorMissingPlazaId',
      desc:
          'Error message shown in a snackbar or log when trying to navigate but the plaza\'s ID is null.',
      args: [],
    );
  }

  /// `Unknown ID`
  String get labelUnknownId {
    return Intl.message(
      'Unknown ID',
      name: 'labelUnknownId',
      desc: 'Fallback text used when a Plaza ID is unexpectedly null or empty.',
      args: [],
    );
  }

  /// `Plaza Owner`
  String get plazaOwner {
    return Intl.message(
      'Plaza Owner',
      name: 'plazaOwner',
      desc: '',
      args: [],
    );
  }

  /// `Plaza Owner ID`
  String get plazaOwnerId {
    return Intl.message(
      'Plaza Owner ID',
      name: 'plazaOwnerId',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message(
      'Yes',
      name: 'yes',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message(
      'No',
      name: 'no',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Plaza selection is required`
  String get errorPlazaRequired {
    return Intl.message(
      'Plaza selection is required',
      name: 'errorPlazaRequired',
      desc: '',
      args: [],
    );
  }

  /// `Fare type selection is required`
  String get errorFareTypeRequired {
    return Intl.message(
      'Fare type selection is required',
      name: 'errorFareTypeRequired',
      desc: '',
      args: [],
    );
  }

  /// `Vehicle type selection is required`
  String get errorVehicleTypeRequired {
    return Intl.message(
      'Vehicle type selection is required',
      name: 'errorVehicleTypeRequired',
      desc: '',
      args: [],
    );
  }

  /// `Invalid fare type selected`
  String get errorInvalidFareType {
    return Intl.message(
      'Invalid fare type selected',
      name: 'errorInvalidFareType',
      desc: '',
      args: [],
    );
  }

  /// `is required`
  String get errorIsRequired {
    return Intl.message(
      'is required',
      name: 'errorIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `must be a valid number greater than 0`
  String get errorMustBePositiveNumber {
    return Intl.message(
      'must be a valid number greater than 0',
      name: 'errorMustBePositiveNumber',
      desc: '',
      args: [],
    );
  }

  /// `Daily fare`
  String get fieldDailyFare {
    return Intl.message(
      'Daily fare',
      name: 'fieldDailyFare',
      desc: '',
      args: [],
    );
  }

  /// `Hourly fare`
  String get fieldHourlyFare {
    return Intl.message(
      'Hourly fare',
      name: 'fieldHourlyFare',
      desc: '',
      args: [],
    );
  }

  /// `Base hourly fare`
  String get fieldBaseHourlyFare {
    return Intl.message(
      'Base hourly fare',
      name: 'fieldBaseHourlyFare',
      desc: '',
      args: [],
    );
  }

  /// `Monthly fare`
  String get fieldMonthlyFare {
    return Intl.message(
      'Monthly fare',
      name: 'fieldMonthlyFare',
      desc: '',
      args: [],
    );
  }

  /// `Base hours is required for Hour-wise Custom fare`
  String get errorBaseHoursRequired {
    return Intl.message(
      'Base hours is required for Hour-wise Custom fare',
      name: 'errorBaseHoursRequired',
      desc: '',
      args: [],
    );
  }

  /// `Base hours must be a positive whole number`
  String get errorBaseHoursPositive {
    return Intl.message(
      'Base hours must be a positive whole number',
      name: 'errorBaseHoursPositive',
      desc: '',
      args: [],
    );
  }

  /// `Invalid date format (YYYY-MM-DD)`
  String get errorInvalidDateFormat {
    return Intl.message(
      'Invalid date format (YYYY-MM-DD)',
      name: 'errorInvalidDateFormat',
      desc: '',
      args: [],
    );
  }

  /// `Discount must be a number between 0 and 100`
  String get errorDiscountRange {
    return Intl.message(
      'Discount must be a number between 0 and 100',
      name: 'errorDiscountRange',
      desc: '',
      args: [],
    );
  }

  /// `Discount must be a non-negative number`
  String get errorDiscountNonNegative {
    return Intl.message(
      'Discount must be a non-negative number',
      name: 'errorDiscountNonNegative',
      desc: '',
      args: [],
    );
  }

  /// `A fare with overlapping dates for this plaza, vehicle, and fare type already exists`
  String get errorDuplicateFare {
    return Intl.message(
      'A fare with overlapping dates for this plaza, vehicle, and fare type already exists',
      name: 'errorDuplicateFare',
      desc: '',
      args: [],
    );
  }

  /// `Error during validation checks`
  String get errorGeneralValidation {
    return Intl.message(
      'Error during validation checks',
      name: 'errorGeneralValidation',
      desc: '',
      args: [],
    );
  }

  /// `Please select a start date first`
  String get warningSelectStartDateFirst {
    return Intl.message(
      'Please select a start date first',
      name: 'warningSelectStartDateFirst',
      desc: '',
      args: [],
    );
  }

  /// `Invalid start date format`
  String get errorInvalidStartDate {
    return Intl.message(
      'Invalid start date format',
      name: 'errorInvalidStartDate',
      desc: '',
      args: [],
    );
  }

  /// `Error adding fare`
  String get errorAddingFare {
    return Intl.message(
      'Error adding fare',
      name: 'errorAddingFare',
      desc: '',
      args: [],
    );
  }

  /// `Success`
  String get successTitle {
    return Intl.message(
      'Success',
      name: 'successTitle',
      desc: '',
      args: [],
    );
  }

  /// `Fares added successfully`
  String get successFareSubmission {
    return Intl.message(
      'Fares added successfully',
      name: 'successFareSubmission',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get buttonOK {
    return Intl.message(
      'OK',
      name: 'buttonOK',
      desc: '',
      args: [],
    );
  }

  /// `Fare updated successfully`
  String get successFareUpdate {
    return Intl.message(
      'Fare updated successfully',
      name: 'successFareUpdate',
      desc: '',
      args: [],
    );
  }

  /// `No filter options are available for the current list.`
  String get messageNoFiltersAvailable {
    return Intl.message(
      'No filter options are available for the current list.',
      name: 'messageNoFiltersAvailable',
      desc:
          'Message shown when trying to open the filter dialog but there are no statuses (or other criteria) to filter by.',
      args: [],
    );
  }

  /// `Closing time must be after opening time`
  String get validationClosingAfterOpening {
    return Intl.message(
      'Closing time must be after opening time',
      name: 'validationClosingAfterOpening',
      desc: 'Error message when closing time is not after opening time',
      args: [],
    );
  }

  /// `Error when closing time isn't after opening time`
  String get validationClosingAfterOpening_description {
    return Intl.message(
      'Error when closing time isn\'t after opening time',
      name: 'validationClosingAfterOpening_description',
      desc: '',
      args: [],
    );
  }

  /// `Total slots ({total}) must be at least the sum of individual capacities ({sum})`
  String validationParkingSlotSum(Object total, Object sum) {
    return Intl.message(
      'Total slots ($total) must be at least the sum of individual capacities ($sum)',
      name: 'validationParkingSlotSum',
      desc: '',
      args: [total, sum],
    );
  }

  /// `Error when total slots are less than sum of capacities`
  String get validationParkingSlotSum_description {
    return Intl.message(
      'Error when total slots are less than sum of capacities',
      name: 'validationParkingSlotSum_description',
      desc: '',
      args: [],
    );
  }

  /// `Bank Details Registered Successfully`
  String get dialogContentBankDetailsRegistered {
    return Intl.message(
      'Bank Details Registered Successfully',
      name: 'dialogContentBankDetailsRegistered',
      desc: '',
      args: [],
    );
  }

  /// `Bank Details Modified Successfully`
  String get dialogContentBankDetailsModified {
    return Intl.message(
      'Bank Details Modified Successfully',
      name: 'dialogContentBankDetailsModified',
      desc: '',
      args: [],
    );
  }

  /// `Lane details registered successfully.`
  String get dialogContentLanesRegistered {
    return Intl.message(
      'Lane details registered successfully.',
      name: 'dialogContentLanesRegistered',
      desc: '',
      args: [],
    );
  }

  /// `One or more fields contain duplicate values.`
  String get validationDuplicateGeneral {
    return Intl.message(
      'One or more fields contain duplicate values.',
      name: 'validationDuplicateGeneral',
      desc: 'General error message when duplicates are detected',
      args: [],
    );
  }

  /// `New Ticket`
  String get newTicketTitle {
    return Intl.message(
      'New Ticket',
      name: 'newTicketTitle',
      desc: '',
      args: [],
    );
  }

  /// `Plaza ID`
  String get plazaIdLabel {
    return Intl.message(
      'Plaza ID',
      name: 'plazaIdLabel',
      desc: '',
      args: [],
    );
  }

  /// `Lane ID`
  String get laneIdLabel {
    return Intl.message(
      'Lane ID',
      name: 'laneIdLabel',
      desc: '',
      args: [],
    );
  }

  /// `Captured Vehicle Images`
  String get capturedImagesLabel {
    return Intl.message(
      'Captured Vehicle Images',
      name: 'capturedImagesLabel',
      desc: '',
      args: [],
    );
  }

  /// `Add More`
  String get addMoreLabel {
    return Intl.message(
      'Add More',
      name: 'addMoreLabel',
      desc: '',
      args: [],
    );
  }

  /// `Capture Vehicle Image`
  String get captureImageLabel {
    return Intl.message(
      'Capture Vehicle Image',
      name: 'captureImageLabel',
      desc: '',
      args: [],
    );
  }

  /// `Manual Ticket`
  String get manualTicketLabel {
    return Intl.message(
      'Manual Ticket',
      name: 'manualTicketLabel',
      desc: '',
      args: [],
    );
  }

  /// `Creating...`
  String get creatingLabel {
    return Intl.message(
      'Creating...',
      name: 'creatingLabel',
      desc: '',
      args: [],
    );
  }

  /// `Create Ticket`
  String get createTicketLabel {
    return Intl.message(
      'Create Ticket',
      name: 'createTicketLabel',
      desc: '',
      args: [],
    );
  }

  /// `Ticket created successfully!`
  String get ticketSuccessMessage {
    return Intl.message(
      'Ticket created successfully!',
      name: 'ticketSuccessMessage',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get okLabel {
    return Intl.message(
      'OK',
      name: 'okLabel',
      desc: '',
      args: [],
    );
  }

  /// `Failed to create ticket`
  String get failedToCreateTicket {
    return Intl.message(
      'Failed to create ticket',
      name: 'failedToCreateTicket',
      desc: '',
      args: [],
    );
  }

  /// `Error: Cannot edit lane without a valid ID.`
  String get errorInvalidLaneId {
    return Intl.message(
      'Error: Cannot edit lane without a valid ID.',
      name: 'errorInvalidLaneId',
      desc: '',
      args: [],
    );
  }

  /// `Lane "{laneName}" removed.`
  String messageLaneRemoved(Object laneName) {
    return Intl.message(
      'Lane "$laneName" removed.',
      name: 'messageLaneRemoved',
      desc: '',
      args: [laneName],
    );
  }

  /// `Delete`
  String get buttonDelete {
    return Intl.message(
      'Delete',
      name: 'buttonDelete',
      desc: '',
      args: [],
    );
  }

  /// `Edit new lane`
  String get tooltipEditNewLane {
    return Intl.message(
      'Edit new lane',
      name: 'tooltipEditNewLane',
      desc: '',
      args: [],
    );
  }

  /// `Edit saved lane`
  String get tooltipEditSavedLane {
    return Intl.message(
      'Edit saved lane',
      name: 'tooltipEditSavedLane',
      desc: '',
      args: [],
    );
  }

  /// `The {fieldName} must be exactly {length} characters long.`
  String validationExactLength(String fieldName, int length) {
    return Intl.message(
      'The $fieldName must be exactly $length characters long.',
      name: 'validationExactLength',
      desc: 'Error message for exact length validation',
      args: [fieldName, length],
    );
  }

  /// `Hold your card near the device to scan.`
  String get messageNfcScanPrompt {
    return Intl.message(
      'Hold your card near the device to scan.',
      name: 'messageNfcScanPrompt',
      desc: 'Prompt shown on iOS NFC scan dialog.',
      args: [],
    );
  }

  /// `Marked Payment by Cash`
  String get messageCashPaymentSuccess {
    return Intl.message(
      'Marked Payment by Cash',
      name: 'messageCashPaymentSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Accept Cash Payment`
  String get messageProcessingPayment {
    return Intl.message(
      'Accept Cash Payment',
      name: 'messageProcessingPayment',
      desc: '',
      args: [],
    );
  }

  /// `Error In Marking Payment by Cash`
  String get errorCashPaymentFailed {
    return Intl.message(
      'Error In Marking Payment by Cash',
      name: 'errorCashPaymentFailed',
      desc: '',
      args: [],
    );
  }

  /// `NFC Timeout`
  String get errorNfcTimeout {
    return Intl.message(
      'NFC Timeout',
      name: 'errorNfcTimeout',
      desc: '',
      args: [],
    );
  }

  /// `Failed to mark ticket as Exited`
  String get errorFailedToMarkExit {
    return Intl.message(
      'Failed to mark ticket as Exited',
      name: 'errorFailedToMarkExit',
      desc: '',
      args: [],
    );
  }

  /// `Service Error`
  String get errorServiceException {
    return Intl.message(
      'Service Error',
      name: 'errorServiceException',
      desc: '',
      args: [],
    );
  }

  /// `You can upload up to {maxImages} images.`
  String messageMaxImagesHint(Object maxImages) {
    return Intl.message(
      'You can upload up to $maxImages images.',
      name: 'messageMaxImagesHint',
      desc: '',
      args: [maxImages],
    );
  }

  /// `Remove Image`
  String get buttonRemoveImage {
    return Intl.message(
      'Remove Image',
      name: 'buttonRemoveImage',
      desc: '',
      args: [],
    );
  }

  /// `Plaza Registered Successfully`
  String get plazaRegisteredSuccessfully {
    return Intl.message(
      'Plaza Registered Successfully',
      name: 'plazaRegisteredSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Uploading images...`
  String get messageUploadingImages {
    return Intl.message(
      'Uploading images...',
      name: 'messageUploadingImages',
      desc: '',
      args: [],
    );
  }

  /// `An unknown error occurred.`
  String get errorUnknown {
    return Intl.message(
      'An unknown error occurred.',
      name: 'errorUnknown',
      desc: '',
      args: [],
    );
  }

  /// `Image picking failed ({0}). Please try again.`
  String get messageErrorPickingImagesPlatform {
    return Intl.message(
      'Image picking failed ({0}). Please try again.',
      name: 'messageErrorPickingImagesPlatform',
      desc: '',
      args: [],
    );
  }

  /// `Service Unavailable: Unable to reach plaza service. Please try again later.`
  String get serviceUnavailableError {
    return Intl.message(
      'Service Unavailable: Unable to reach plaza service. Please try again later.',
      name: 'serviceUnavailableError',
      desc: '',
      args: [],
    );
  }

  /// `No Internet Connection: Please check your connection and try again.`
  String get noInternetError {
    return Intl.message(
      'No Internet Connection: Please check your connection and try again.',
      name: 'noInternetError',
      desc: '',
      args: [],
    );
  }

  /// `Request Timed Out: Server took too long to respond. Please try again.`
  String get timeoutError {
    return Intl.message(
      'Request Timed Out: Server took too long to respond. Please try again.',
      name: 'timeoutError',
      desc: '',
      args: [],
    );
  }

  /// `Only {0} images can be added. Extra selections ignored.`
  String get messageWarningImagesLimited {
    return Intl.message(
      'Only {0} images can be added. Extra selections ignored.',
      name: 'messageWarningImagesLimited',
      desc: '',
      args: [],
    );
  }

  /// `Error capturing image: `
  String get imageCaptureError {
    return Intl.message(
      'Error capturing image: ',
      name: 'imageCaptureError',
      desc: '',
      args: [],
    );
  }

  /// `Plaza ID is required`
  String get plazaIdRequired {
    return Intl.message(
      'Plaza ID is required',
      name: 'plazaIdRequired',
      desc: '',
      args: [],
    );
  }

  /// `Entry Lane ID is required`
  String get laneIdRequired {
    return Intl.message(
      'Entry Lane ID is required',
      name: 'laneIdRequired',
      desc: '',
      args: [],
    );
  }

  /// `Error updating lane. Please try again.`
  String get errorUpdatingLane {
    return Intl.message(
      'Error updating lane. Please try again.',
      name: 'errorUpdatingLane',
      desc: '',
      args: [],
    );
  }

  /// `Please capture at least one vehicle image`
  String get imageRequired {
    return Intl.message(
      'Please capture at least one vehicle image',
      name: 'imageRequired',
      desc: '',
      args: [],
    );
  }

  /// `Vehicle number must be between 1 and 20 characters`
  String get vehicleNumberError {
    return Intl.message(
      'Vehicle number must be between 1 and 20 characters',
      name: 'vehicleNumberError',
      desc: '',
      args: [],
    );
  }

  /// `Vehicle type is required`
  String get vehicleTypeRequired {
    return Intl.message(
      'Vehicle type is required',
      name: 'vehicleTypeRequired',
      desc: '',
      args: [],
    );
  }

  /// `Failed to create ticket: `
  String get ticketCreationError {
    return Intl.message(
      'Failed to create ticket: ',
      name: 'ticketCreationError',
      desc: '',
      args: [],
    );
  }

  /// `Lanes Details Modified Successfully`
  String get dialogContentLanesModified {
    return Intl.message(
      'Lanes Details Modified Successfully',
      name: 'dialogContentLanesModified',
      desc: '',
      args: [],
    );
  }

  /// `Edit New Lane`
  String get titleEditNewLane {
    return Intl.message(
      'Edit New Lane',
      name: 'titleEditNewLane',
      desc: '',
      args: [],
    );
  }

  /// `Please complete all required fields correctly`
  String get validationGeneralError {
    return Intl.message(
      'Please complete all required fields correctly',
      name: 'validationGeneralError',
      desc: 'General error message when validation fails',
      args: [],
    );
  }

  /// `General error for basic details validation`
  String get validationGeneralError_description {
    return Intl.message(
      'General error for basic details validation',
      name: 'validationGeneralError_description',
      desc: '',
      args: [],
    );
  }

  /// `Account number must be between 10 to 20 digits`
  String get validationAccountNumberRange {
    return Intl.message(
      'Account number must be between 10 to 20 digits',
      name: 'validationAccountNumberRange',
      desc: '',
      args: [],
    );
  }

  /// `Error when account number length is invalid`
  String get validationAccountNumberRange_description {
    return Intl.message(
      'Error when account number length is invalid',
      name: 'validationAccountNumberRange_description',
      desc: '',
      args: [],
    );
  }

  /// `IFSC code must be exactly 11 characters`
  String get validationIfscLength {
    return Intl.message(
      'IFSC code must be exactly 11 characters',
      name: 'validationIfscLength',
      desc: '',
      args: [],
    );
  }

  /// `Error when IFSC code length is incorrect`
  String get validationIfscLength_description {
    return Intl.message(
      'Error when IFSC code length is incorrect',
      name: 'validationIfscLength_description',
      desc: '',
      args: [],
    );
  }

  /// `No Existing Lanes Saved`
  String get messageNoExistingLanesSaved {
    return Intl.message(
      'No Existing Lanes Saved',
      name: 'messageNoExistingLanesSaved',
      desc: '',
      args: [],
    );
  }

  /// `Dismiss`
  String get buttonDismiss {
    return Intl.message(
      'Dismiss',
      name: 'buttonDismiss',
      desc: '',
      args: [],
    );
  }

  /// `No New Lanes To Add`
  String get messageNoNewLanesAddOne {
    return Intl.message(
      'No New Lanes To Add',
      name: 'messageNoNewLanesAddOne',
      desc: '',
      args: [],
    );
  }

  /// `Error Loading Lanes`
  String get messageErrorLoadingLanes {
    return Intl.message(
      'Error Loading Lanes',
      name: 'messageErrorLoadingLanes',
      desc: '',
      args: [],
    );
  }

  /// `Plaza registration completed successfully!`
  String get messagePlazaRegistrationComplete {
    return Intl.message(
      'Plaza registration completed successfully!',
      name: 'messagePlazaRegistrationComplete',
      desc: '',
      args: [],
    );
  }

  /// `Plaza modifications saved successfully!`
  String get messagePlazaModificationComplete {
    return Intl.message(
      'Plaza modifications saved successfully!',
      name: 'messagePlazaModificationComplete',
      desc: '',
      args: [],
    );
  }

  /// `Failed to add lane. Please try again.`
  String get errorAddingLane {
    return Intl.message(
      'Failed to add lane. Please try again.',
      name: 'errorAddingLane',
      desc: '',
      args: [],
    );
  }

  /// `Error when IFSC code format is invalid`
  String get validationInvalidIfscFormat_description {
    return Intl.message(
      'Error when IFSC code format is invalid',
      name: 'validationInvalidIfscFormat_description',
      desc: '',
      args: [],
    );
  }

  /// `Upload Images`
  String get titleUploadImages {
    return Intl.message(
      'Upload Images',
      name: 'titleUploadImages',
      desc: '',
      args: [],
    );
  }

  /// `Pick from Gallery`
  String get buttonPickGallery {
    return Intl.message(
      'Pick from Gallery',
      name: 'buttonPickGallery',
      desc: '',
      args: [],
    );
  }

  /// `Take Photo`
  String get buttonTakePhoto {
    return Intl.message(
      'Take Photo',
      name: 'buttonTakePhoto',
      desc: '',
      args: [],
    );
  }

  /// `No images selected. Please select images of your plaza to continue.`
  String get messageNoImagesSelected {
    return Intl.message(
      'No images selected. Please select images of your plaza to continue.',
      name: 'messageNoImagesSelected',
      desc: '',
      args: [],
    );
  }

  /// `No new lanes to add.`
  String get messageNoNewLanesToAdd {
    return Intl.message(
      'No new lanes to add.',
      name: 'messageNoNewLanesToAdd',
      desc: '',
      args: [],
    );
  }

  /// `Edit Saved Lane`
  String get titleEditSavedLane {
    return Intl.message(
      'Edit Saved Lane',
      name: 'titleEditSavedLane',
      desc: '',
      args: [],
    );
  }

  /// `Please correct the errors in Bank Details`
  String get validationGeneralBankError {
    return Intl.message(
      'Please correct the errors in Bank Details',
      name: 'validationGeneralBankError',
      desc: '',
      args: [],
    );
  }

  /// `General error for bank details validation`
  String get validationGeneralBankError_description {
    return Intl.message(
      'General error for bank details validation',
      name: 'validationGeneralBankError_description',
      desc: '',
      args: [],
    );
  }

  /// `Please correct the errors in Lane Details`
  String get validationGeneralLaneError {
    return Intl.message(
      'Please correct the errors in Lane Details',
      name: 'validationGeneralLaneError',
      desc: '',
      args: [],
    );
  }

  /// `General error for lane details validation`
  String get validationGeneralLaneError_description {
    return Intl.message(
      'General error for lane details validation',
      name: 'validationGeneralLaneError_description',
      desc: '',
      args: [],
    );
  }

  /// `Two-Wheeler Capacity`
  String get labelTwoWheelerCapacity {
    return Intl.message(
      'Two-Wheeler Capacity',
      name: 'labelTwoWheelerCapacity',
      desc: '',
      args: [],
    );
  }

  /// `New Ticket`
  String get newTicket {
    return Intl.message(
      'New Ticket',
      name: 'newTicket',
      desc: '',
      args: [],
    );
  }

  /// `Plaza ID`
  String get plazaId {
    return Intl.message(
      'Plaza ID',
      name: 'plazaId',
      desc: '',
      args: [],
    );
  }

  /// `Lane ID`
  String get laneId {
    return Intl.message(
      'Lane ID',
      name: 'laneId',
      desc: '',
      args: [],
    );
  }

  /// `Vehicle Number`
  String get vehicleNumber {
    return Intl.message(
      'Vehicle Number',
      name: 'vehicleNumber',
      desc: '',
      args: [],
    );
  }

  /// `Vehicle Type`
  String get vehicleType {
    return Intl.message(
      'Vehicle Type',
      name: 'vehicleType',
      desc: '',
      args: [],
    );
  }

  /// `Create Ticket`
  String get createTicket {
    return Intl.message(
      'Create Ticket',
      name: 'createTicket',
      desc: '',
      args: [],
    );
  }

  /// `Ticket created successfully!`
  String get ticketCreatedSuccess {
    return Intl.message(
      'Ticket created successfully!',
      name: 'ticketCreatedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Capture Vehicle Image`
  String get captureVehicleImage {
    return Intl.message(
      'Capture Vehicle Image',
      name: 'captureVehicleImage',
      desc: '',
      args: [],
    );
  }

  /// `Captured Vehicle Images`
  String get capturedVehicleImages {
    return Intl.message(
      'Captured Vehicle Images',
      name: 'capturedVehicleImages',
      desc: '',
      args: [],
    );
  }

  /// `add more`
  String get addMore {
    return Intl.message(
      'add more',
      name: 'addMore',
      desc: '',
      args: [],
    );
  }

  /// `Manual Ticket`
  String get manualTicket {
    return Intl.message(
      'Manual Ticket',
      name: 'manualTicket',
      desc: '',
      args: [],
    );
  }

  /// `LMV Capacity`
  String get labelLMVCapacity {
    return Intl.message(
      'LMV Capacity',
      name: 'labelLMVCapacity',
      desc: '',
      args: [],
    );
  }

  /// `LCV Capacity`
  String get labelLCVCapacity {
    return Intl.message(
      'LCV Capacity',
      name: 'labelLCVCapacity',
      desc: '',
      args: [],
    );
  }

  /// `HMV Capacity`
  String get labelHMVCapacity {
    return Intl.message(
      'HMV Capacity',
      name: 'labelHMVCapacity',
      desc: '',
      args: [],
    );
  }

  /// `Add Lane`
  String get buttonAddLane {
    return Intl.message(
      'Add Lane',
      name: 'buttonAddLane',
      desc: '',
      args: [],
    );
  }

  /// `Basic details registered successfully`
  String get dialogContentBasicDetailsRegistered {
    return Intl.message(
      'Basic details registered successfully',
      name: 'dialogContentBasicDetailsRegistered',
      desc: '',
      args: [],
    );
  }

  /// `Basic details modified Successfully`
  String get dialogContentBasicDetailsModified {
    return Intl.message(
      'Basic details modified Successfully',
      name: 'dialogContentBasicDetailsModified',
      desc: '',
      args: [],
    );
  }

  /// `No Details Available`
  String get noDetailsAvailable {
    return Intl.message(
      'No Details Available',
      name: 'noDetailsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Date Overlap`
  String get errorDateOverlap {
    return Intl.message(
      'Date Overlap',
      name: 'errorDateOverlap',
      desc: '',
      args: [],
    );
  }

  /// `Discount Numeric`
  String get errorDiscountNumeric {
    return Intl.message(
      'Discount Numeric',
      name: 'errorDiscountNumeric',
      desc: '',
      args: [],
    );
  }

  /// `Fares Added Successfully`
  String get successFareAddedToList {
    return Intl.message(
      'Fares Added Successfully',
      name: 'successFareAddedToList',
      desc: '',
      args: [],
    );
  }

  /// `Add New Fare`
  String get buttonAddFare {
    return Intl.message(
      'Add New Fare',
      name: 'buttonAddFare',
      desc: '',
      args: [],
    );
  }

  /// `Fares`
  String titleFaresForPlaza(String plazaName) {
    return Intl.message(
      'Fares',
      name: 'titleFaresForPlaza',
      desc: 'App bar title for the list of fares for a specific plaza',
      args: [plazaName],
    );
  }

  /// `Loading Fare`
  String get errorLoadingFare {
    return Intl.message(
      'Loading Fare',
      name: 'errorLoadingFare',
      desc: '',
      args: [],
    );
  }

  /// `Fare Not Found`
  String get errorFareNotFound {
    return Intl.message(
      'Fare Not Found',
      name: 'errorFareNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Error: Invalid Plaza ID format.`
  String get errorInvalidPlazaIdFormat {
    return Intl.message(
      'Error: Invalid Plaza ID format.',
      name: 'errorInvalidPlazaIdFormat',
      desc: '',
      args: [],
    );
  }

  /// `Error: Fare ID is missing.`
  String get errorMissingFareId {
    return Intl.message(
      'Error: Fare ID is missing.',
      name: 'errorMissingFareId',
      desc: '',
      args: [],
    );
  }

  /// `Bike Capacity`
  String get bikeCapacity {
    return Intl.message(
      'Bike Capacity',
      name: 'bikeCapacity',
      desc: '',
      args: [],
    );
  }

  /// `3-Wheeler Capacity`
  String get threeWheelerCapacity {
    return Intl.message(
      '3-Wheeler Capacity',
      name: 'threeWheelerCapacity',
      desc: '',
      args: [],
    );
  }

  /// `4-Wheeler Capacity`
  String get fourWheelerCapacity {
    return Intl.message(
      '4-Wheeler Capacity',
      name: 'fourWheelerCapacity',
      desc: '',
      args: [],
    );
  }

  /// `Bus Capacity`
  String get busCapacity {
    return Intl.message(
      'Bus Capacity',
      name: 'busCapacity',
      desc: '',
      args: [],
    );
  }

  /// `Truck Capacity`
  String get truckCapacity {
    return Intl.message(
      'Truck Capacity',
      name: 'truckCapacity',
      desc: '',
      args: [],
    );
  }

  /// `Heavy Machinery Capacity`
  String get heavyMachineryCapacity {
    return Intl.message(
      'Heavy Machinery Capacity',
      name: 'heavyMachineryCapacity',
      desc: '',
      args: [],
    );
  }

  /// `Bike Capacity`
  String get labelBikeCapacity {
    return Intl.message(
      'Bike Capacity',
      name: 'labelBikeCapacity',
      desc: '',
      args: [],
    );
  }

  /// `3-Wheeler Capacity`
  String get label3WheelerCapacity {
    return Intl.message(
      '3-Wheeler Capacity',
      name: 'label3WheelerCapacity',
      desc: '',
      args: [],
    );
  }

  /// `4-Wheeler Capacity`
  String get label4WheelerCapacity {
    return Intl.message(
      '4-Wheeler Capacity',
      name: 'label4WheelerCapacity',
      desc: '',
      args: [],
    );
  }

  /// `Bus Capacity`
  String get labelBusCapacity {
    return Intl.message(
      'Bus Capacity',
      name: 'labelBusCapacity',
      desc: '',
      args: [],
    );
  }

  /// `Truck Capacity`
  String get labelTruckCapacity {
    return Intl.message(
      'Truck Capacity',
      name: 'labelTruckCapacity',
      desc: '',
      args: [],
    );
  }

  /// `Heavy Machinery Capacity`
  String get labelHeavyMachineryCapacity {
    return Intl.message(
      'Heavy Machinery Capacity',
      name: 'labelHeavyMachineryCapacity',
      desc: '',
      args: [],
    );
  }

  /// `Account Holder Name`
  String get labelAccountHolderName {
    return Intl.message(
      'Account Holder Name',
      name: 'labelAccountHolderName',
      desc: '',
      args: [],
    );
  }

  /// `Pick Images`
  String get buttonPickImages {
    return Intl.message(
      'Pick Images',
      name: 'buttonPickImages',
      desc: '',
      args: [],
    );
  }

  /// `No images added yet`
  String get messageNoImages {
    return Intl.message(
      'No images added yet',
      name: 'messageNoImages',
      desc: '',
      args: [],
    );
  }

  /// `No lanes added yet`
  String get messageNoLanes {
    return Intl.message(
      'No lanes added yet',
      name: 'messageNoLanes',
      desc: '',
      args: [],
    );
  }

  /// `Use the FAB to add lanes`
  String get messageUseFabToAddLanes {
    return Intl.message(
      'Use the FAB to add lanes',
      name: 'messageUseFabToAddLanes',
      desc: '',
      args: [],
    );
  }

  /// `No lanes added yet`
  String get messageNoLanesAddedYet {
    return Intl.message(
      'No lanes added yet',
      name: 'messageNoLanesAddedYet',
      desc: '',
      args: [],
    );
  }

  /// `Bank Details`
  String get titleBankDetails {
    return Intl.message(
      'Bank Details',
      name: 'titleBankDetails',
      desc: '',
      args: [],
    );
  }

  /// `At-least One Image is required`
  String get validationAtLeastOneImage {
    return Intl.message(
      'At-least One Image is required',
      name: 'validationAtLeastOneImage',
      desc: '',
      args: [],
    );
  }

  /// `Maximum number of images reached`
  String get messageErrorMaxImagesReached {
    return Intl.message(
      'Maximum number of images reached',
      name: 'messageErrorMaxImagesReached',
      desc: '',
      args: [],
    );
  }

  /// `{fieldName} must be at least {length} characters`
  String validationMinLength(Object fieldName, Object length) {
    return Intl.message(
      '$fieldName must be at least $length characters',
      name: 'validationMinLength',
      desc: '',
      args: [fieldName, length],
    );
  }

  /// `{fieldName} must be greater than or equal to {value}`
  String validationGreaterThanOrEqualTo(Object fieldName, Object value) {
    return Intl.message(
      '$fieldName must be greater than or equal to $value',
      name: 'validationGreaterThanOrEqualTo',
      desc: '',
      args: [fieldName, value],
    );
  }

  /// `{fieldName} must be less than or equal to {value}`
  String validationLessThanOrEqualTo(Object fieldName, Object value) {
    return Intl.message(
      '$fieldName must be less than or equal to $value',
      name: 'validationLessThanOrEqualTo',
      desc: '',
      args: [fieldName, value],
    );
  }

  /// `Vehicle capacities must sum to match total parking slots`
  String get validationParkingCapacitySumMismatch {
    return Intl.message(
      'Vehicle capacities must sum to match total parking slots',
      name: 'validationParkingCapacitySumMismatch',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid IFSC code format (e.g., SBIN0123456)`
  String get validationInvalidIfscFormat {
    return Intl.message(
      'Please enter a valid IFSC code format (e.g., SBIN0123456)',
      name: 'validationInvalidIfscFormat',
      desc: '',
      args: [],
    );
  }

  /// `No user ID found. Please log in again.`
  String get noUserIdError {
    return Intl.message(
      'No user ID found. Please log in again.',
      name: 'noUserIdError',
      desc: 'Error message when no user ID is found in secure storage.',
      args: [],
    );
  }

  /// `Failed to fetch plazas: `
  String plazaFetchError(Object error) {
    return Intl.message(
      'Failed to fetch plazas: ',
      name: 'plazaFetchError',
      desc: 'Error message when fetching plazas fails.',
      args: [error],
    );
  }

  /// `Failed to fetch lanes: `
  String laneFetchError(Object error) {
    return Intl.message(
      'Failed to fetch lanes: ',
      name: 'laneFetchError',
      desc: 'Error message when fetching lanes fails.',
      args: [error],
    );
  }

  /// `Total parking slots ({total}) must equal the sum of capacities ({sum})`
  String validationParkingSlotEqual(Object total, Object sum) {
    return Intl.message(
      'Total parking slots ($total) must equal the sum of capacities ($sum)',
      name: 'validationParkingSlotEqual',
      desc:
          'Error message when total parking slots do not equal the sum of vehicle capacities',
      args: [total, sum],
    );
  }

  /// `Failed to connect to the server. Please try again later.`
  String get errorServerConnection {
    return Intl.message(
      'Failed to connect to the server. Please try again later.',
      name: 'errorServerConnection',
      desc: '',
      args: [],
    );
  }

  /// `At least one lane must be added`
  String get validationAtLeastOneLane {
    return Intl.message(
      'At least one lane must be added',
      name: 'validationAtLeastOneLane',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get buttonUpdate {
    return Intl.message(
      'Update',
      name: 'buttonUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Plaza registration completed successfully!`
  String get dialogContentPlazaRegistrationComplete {
    return Intl.message(
      'Plaza registration completed successfully!',
      name: 'dialogContentPlazaRegistrationComplete',
      desc: '',
      args: [],
    );
  }

  /// `Location Services Disabled`
  String get locationServicesDisabledTitle {
    return Intl.message(
      'Location Services Disabled',
      name: 'locationServicesDisabledTitle',
      desc: '',
      args: [],
    );
  }

  /// `Please enable location services to fetch your current location.`
  String get locationServicesDisabledMessage {
    return Intl.message(
      'Please enable location services to fetch your current location.',
      name: 'locationServicesDisabledMessage',
      desc: '',
      args: [],
    );
  }

  /// `Location Permission Denied`
  String get locationPermissionDeniedTitle {
    return Intl.message(
      'Location Permission Denied',
      name: 'locationPermissionDeniedTitle',
      desc: '',
      args: [],
    );
  }

  /// `Location permission is required to fetch your current location. Please enable it in app settings.`
  String get locationPermissionDeniedMessage {
    return Intl.message(
      'Location permission is required to fetch your current location. Please enable it in app settings.',
      name: 'locationPermissionDeniedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get buttonSettings {
    return Intl.message(
      'Settings',
      name: 'buttonSettings',
      desc: '',
      args: [],
    );
  }

  /// `Location permission denied. Please enable it to fetch your location.`
  String get locationPermissionDenied {
    return Intl.message(
      'Location permission denied. Please enable it to fetch your location.',
      name: 'locationPermissionDenied',
      desc: '',
      args: [],
    );
  }

  /// `Failed to fetch your current location. Please try again.`
  String get errorFetchingLocation {
    return Intl.message(
      'Failed to fetch your current location. Please try again.',
      name: 'errorFetchingLocation',
      desc: '',
      args: [],
    );
  }

  /// `Failed to fetch address from coordinates. Please enter manually.`
  String get errorFetchingAddress {
    return Intl.message(
      'Failed to fetch address from coordinates. Please enter manually.',
      name: 'errorFetchingAddress',
      desc: '',
      args: [],
    );
  }

  /// `No address found for the given coordinates.`
  String get errorNoAddressFound {
    return Intl.message(
      'No address found for the given coordinates.',
      name: 'errorNoAddressFound',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred while communicating with the server.`
  String get apiErrorGeneric {
    return Intl.message(
      'An error occurred while communicating with the server.',
      name: 'apiErrorGeneric',
      desc: '',
      args: [],
    );
  }

  /// `Save & Next`
  String get buttonSaveAndNext {
    return Intl.message(
      'Save & Next',
      name: 'buttonSaveAndNext',
      desc: '',
      args: [],
    );
  }

  /// `Basic Information`
  String get labelBasicInfo {
    return Intl.message(
      'Basic Information',
      name: 'labelBasicInfo',
      desc: '',
      args: [],
    );
  }

  /// `Contact Information`
  String get labelContactInfo {
    return Intl.message(
      'Contact Information',
      name: 'labelContactInfo',
      desc: '',
      args: [],
    );
  }

  /// `Address Information`
  String get labelAddressInfo {
    return Intl.message(
      'Address Information',
      name: 'labelAddressInfo',
      desc: '',
      args: [],
    );
  }

  /// `Geolocation`
  String get labelGeoLocation {
    return Intl.message(
      'Geolocation',
      name: 'labelGeoLocation',
      desc: '',
      args: [],
    );
  }

  /// `Timings`
  String get labelTimings {
    return Intl.message(
      'Timings',
      name: 'labelTimings',
      desc: '',
      args: [],
    );
  }

  /// `Parking Details`
  String get labelParkingDetails {
    return Intl.message(
      'Parking Details',
      name: 'labelParkingDetails',
      desc: '',
      args: [],
    );
  }

  /// `Vehicle Capacity`
  String get labelVehicleCapacity {
    return Intl.message(
      'Vehicle Capacity',
      name: 'labelVehicleCapacity',
      desc: '',
      args: [],
    );
  }

  /// `Plaza Owner`
  String get labelPlazaOwner {
    return Intl.message(
      'Plaza Owner',
      name: 'labelPlazaOwner',
      desc: '',
      args: [],
    );
  }

  /// `Plaza Name`
  String get labelPlazaName {
    return Intl.message(
      'Plaza Name',
      name: 'labelPlazaName',
      desc: '',
      args: [],
    );
  }

  /// `Operator Name`
  String get labelOperatorName {
    return Intl.message(
      'Operator Name',
      name: 'labelOperatorName',
      desc: '',
      args: [],
    );
  }

  /// `Plaza Category`
  String get labelPlazaCategory {
    return Intl.message(
      'Plaza Category',
      name: 'labelPlazaCategory',
      desc: '',
      args: [],
    );
  }

  /// `Plaza Sub-Category`
  String get labelPlazaSubCategory {
    return Intl.message(
      'Plaza Sub-Category',
      name: 'labelPlazaSubCategory',
      desc: '',
      args: [],
    );
  }

  /// `Structure Type`
  String get labelStructureType {
    return Intl.message(
      'Structure Type',
      name: 'labelStructureType',
      desc: '',
      args: [],
    );
  }

  /// `Price Category`
  String get labelPriceCategory {
    return Intl.message(
      'Price Category',
      name: 'labelPriceCategory',
      desc: '',
      args: [],
    );
  }

  /// `Plaza Status`
  String get labelPlazaStatus {
    return Intl.message(
      'Plaza Status',
      name: 'labelPlazaStatus',
      desc: '',
      args: [],
    );
  }

  /// `Free Parking`
  String get labelFreeParking {
    return Intl.message(
      'Free Parking',
      name: 'labelFreeParking',
      desc: '',
      args: [],
    );
  }

  /// `Mobile Number`
  String get labelMobileNumber {
    return Intl.message(
      'Mobile Number',
      name: 'labelMobileNumber',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get labelEmail {
    return Intl.message(
      'Email',
      name: 'labelEmail',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get labelAddress {
    return Intl.message(
      'Address',
      name: 'labelAddress',
      desc: '',
      args: [],
    );
  }

  /// `City`
  String get labelCity {
    return Intl.message(
      'City',
      name: 'labelCity',
      desc: '',
      args: [],
    );
  }

  /// `District`
  String get labelDistrict {
    return Intl.message(
      'District',
      name: 'labelDistrict',
      desc: '',
      args: [],
    );
  }

  /// `State`
  String get labelState {
    return Intl.message(
      'State',
      name: 'labelState',
      desc: '',
      args: [],
    );
  }

  /// `Pincode`
  String get labelPincode {
    return Intl.message(
      'Pincode',
      name: 'labelPincode',
      desc: '',
      args: [],
    );
  }

  /// `Latitude`
  String get labelLatitude {
    return Intl.message(
      'Latitude',
      name: 'labelLatitude',
      desc: '',
      args: [],
    );
  }

  /// `Longitude`
  String get labelLongitude {
    return Intl.message(
      'Longitude',
      name: 'labelLongitude',
      desc: '',
      args: [],
    );
  }

  /// `Opening Time`
  String get labelOpeningTime {
    return Intl.message(
      'Opening Time',
      name: 'labelOpeningTime',
      desc: '',
      args: [],
    );
  }

  /// `Closing Time`
  String get labelClosingTime {
    return Intl.message(
      'Closing Time',
      name: 'labelClosingTime',
      desc: '',
      args: [],
    );
  }

  /// `Total Parking Slots`
  String get labelTotalParkingSlots {
    return Intl.message(
      'Total Parking Slots',
      name: 'labelTotalParkingSlots',
      desc: '',
      args: [],
    );
  }

  /// `Bike Capacity`
  String get labelCapacityBike {
    return Intl.message(
      'Bike Capacity',
      name: 'labelCapacityBike',
      desc: '',
      args: [],
    );
  }

  /// `3-Wheeler Capacity`
  String get labelCapacity3Wheeler {
    return Intl.message(
      '3-Wheeler Capacity',
      name: 'labelCapacity3Wheeler',
      desc: '',
      args: [],
    );
  }

  /// `4-Wheeler Capacity`
  String get labelCapacity4Wheeler {
    return Intl.message(
      '4-Wheeler Capacity',
      name: 'labelCapacity4Wheeler',
      desc: '',
      args: [],
    );
  }

  /// `Bus Capacity`
  String get labelCapacityBus {
    return Intl.message(
      'Bus Capacity',
      name: 'labelCapacityBus',
      desc: '',
      args: [],
    );
  }

  /// `Truck Capacity`
  String get labelCapacityTruck {
    return Intl.message(
      'Truck Capacity',
      name: 'labelCapacityTruck',
      desc: '',
      args: [],
    );
  }

  /// `Heavy Machinery Capacity`
  String get labelCapacityHeavyMachinery {
    return Intl.message(
      'Heavy Machinery Capacity',
      name: 'labelCapacityHeavyMachinery',
      desc: '',
      args: [],
    );
  }

  /// `Get Location`
  String get buttonGetLocation {
    return Intl.message(
      'Get Location',
      name: 'buttonGetLocation',
      desc: '',
      args: [],
    );
  }

  /// `User data not available`
  String get labelUserDataNotAvailable {
    return Intl.message(
      'User data not available',
      name: 'labelUserDataNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Finish`
  String get buttonFinish {
    return Intl.message(
      'Finish',
      name: 'buttonFinish',
      desc: '',
      args: [],
    );
  }

  /// `Plaza ID is not set. Please complete the basic details first.`
  String get messageErrorPlazaIdNotSetForLane {
    return Intl.message(
      'Plaza ID is not set. Please complete the basic details first.',
      name: 'messageErrorPlazaIdNotSetForLane',
      desc: '',
      args: [],
    );
  }

  /// `Search by Vehicle or Fare Type...`
  String get searchPlazaFareHint {
    return Intl.message(
      'Search by Vehicle or Fare Type...',
      name: 'searchPlazaFareHint',
      desc: 'Hint text for the search field in the plaza fares list screen',
      args: [],
    );
  }

  /// `No Fares Found`
  String get noFaresFoundLabel {
    return Intl.message(
      'No Fares Found',
      name: 'noFaresFoundLabel',
      desc: 'Label displayed when no fares are found for the plaza',
      args: [],
    );
  }

  /// `There are no fares for this plaza`
  String get noFaresForPlazaMessage {
    return Intl.message(
      'There are no fares for this plaza',
      name: 'noFaresForPlazaMessage',
      desc:
          'Message displayed when no fares are found for the plaza and no search query is active',
      args: [],
    );
  }

  /// `No fares match your search criteria`
  String get noFaresMatchSearchMessage {
    return Intl.message(
      'No fares match your search criteria',
      name: 'noFaresMatchSearchMessage',
      desc: 'Message displayed when no fares match the search query',
      args: [],
    );
  }

  /// `User data not found`
  String get messageErrorUserDataNotFound {
    return Intl.message(
      'User data not found',
      name: 'messageErrorUserDataNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Error Saving Plaza`
  String get messageErrorSavingPlaza {
    return Intl.message(
      'Error Saving Plaza',
      name: 'messageErrorSavingPlaza',
      desc: '',
      args: [],
    );
  }

  /// `Error Saving Bank Details`
  String get messageErrorSavingBankDetails {
    return Intl.message(
      'Error Saving Bank Details',
      name: 'messageErrorSavingBankDetails',
      desc: '',
      args: [],
    );
  }

  /// `Error Picking Images`
  String get messageErrorPickingImages {
    return Intl.message(
      'Error Picking Images',
      name: 'messageErrorPickingImages',
      desc: '',
      args: [],
    );
  }

  /// `Error Saving Images`
  String get messageErrorSavingImages {
    return Intl.message(
      'Error Saving Images',
      name: 'messageErrorSavingImages',
      desc: '',
      args: [],
    );
  }

  /// `Mark Pending`
  String get markPending {
    return Intl.message(
      'Mark Pending',
      name: 'markPending',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get refreshLabel {
    return Intl.message(
      'Refresh',
      name: 'refreshLabel',
      desc: '',
      args: [],
    );
  }

  /// `Modification Time`
  String get labelModificationTime {
    return Intl.message(
      'Modification Time',
      name: 'labelModificationTime',
      desc: '',
      args: [],
    );
  }

  /// `Mark Exit`
  String get markExitLabel {
    return Intl.message(
      'Mark Exit',
      name: 'markExitLabel',
      desc: '',
      args: [],
    );
  }

  /// `No Open Tickets`
  String get noOpenTicketsLabel {
    return Intl.message(
      'No Open Tickets',
      name: 'noOpenTicketsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Error Unable to Load Ticket Details`
  String get errorUnableToLoadTicketDetails {
    return Intl.message(
      'Error Unable to Load Ticket Details',
      name: 'errorUnableToLoadTicketDetails',
      desc: '',
      args: [],
    );
  }

  /// `Error Plaza Id Not Set`
  String get messageErrorPlazaIdNotSet {
    return Intl.message(
      'Error Plaza Id Not Set',
      name: 'messageErrorPlazaIdNotSet',
      desc: '',
      args: [],
    );
  }

  /// `Filter by Date`
  String get filterByDate {
    return Intl.message(
      'Filter by Date',
      name: 'filterByDate',
      desc: '',
      args: [],
    );
  }

  /// `Clear Filter`
  String get clearFilterLabel {
    return Intl.message(
      'Clear Filter',
      name: 'clearFilterLabel',
      desc: '',
      args: [],
    );
  }

  /// `{fieldName} must not be negative`
  String validationNonNegative(Object fieldName) {
    return Intl.message(
      '$fieldName must not be negative',
      name: 'validationNonNegative',
      desc: 'Error message when a numeric field is negative',
      args: [fieldName],
    );
  }

  /// `{fieldName} must not be zero`
  String validationNonZero(Object fieldName) {
    return Intl.message(
      '$fieldName must not be zero',
      name: 'validationNonZero',
      desc: 'Error message when a numeric field is zero but should not be',
      args: [fieldName],
    );
  }

  /// `At least one vehicle capacity must be greater than zero`
  String get validationAtLeastOneCapacity {
    return Intl.message(
      'At least one vehicle capacity must be greater than zero',
      name: 'validationAtLeastOneCapacity',
      desc:
          'Error message when all vehicle capacities are zero but total slots are not',
      args: [],
    );
  }

  /// `ANPR Processing Failed`
  String get anprFailedTitle {
    return Intl.message(
      'ANPR Processing Failed',
      name: 'anprFailedTitle',
      desc: '',
      args: [],
    );
  }

  /// `{fieldName} must be a valid number.`
  String validationNumberInvalid(Object fieldName) {
    return Intl.message(
      '$fieldName must be a valid number.',
      name: 'validationNumberInvalid',
      desc:
          'Error message template for invalid number input, with placeholder for field name',
      args: [fieldName],
    );
  }

  /// `{fieldName} must be a positive number.`
  String validationNumberPositive(Object fieldName) {
    return Intl.message(
      '$fieldName must be a positive number.',
      name: 'validationNumberPositive',
      desc:
          'Error message template for requiring a positive number, with placeholder for field name',
      args: [fieldName],
    );
  }

  /// `{fieldName} is already in use.`
  String validationDuplicate(Object fieldName) {
    return Intl.message(
      '$fieldName is already in use.',
      name: 'validationDuplicate',
      desc:
          'Error message template for duplicate values, with placeholder for field name',
      args: [fieldName],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: 'Hint text for search input fields',
      args: [],
    );
  }

  /// `No results found`
  String get noResultsFound {
    return Intl.message(
      'No results found',
      name: 'noResultsFound',
      desc: 'Text displayed when a search yields no results',
      args: [],
    );
  }

  /// `Please wait for operator data to load first.`
  String get errorLoadOperatorDataFirst {
    return Intl.message(
      'Please wait for operator data to load first.',
      name: 'errorLoadOperatorDataFirst',
      desc:
          'Error message shown when trying an action before necessary data is loaded',
      args: [],
    );
  }

  /// `Cannot load plazas: Operator owner information is missing.`
  String get errorMissingOwnerIdForPlaza {
    return Intl.message(
      'Cannot load plazas: Operator owner information is missing.',
      name: 'errorMissingOwnerIdForPlaza',
      desc:
          'Error shown when trying to fetch plazas but the required owner ID is not available',
      args: [],
    );
  }

  /// `Invalid lane index provided.`
  String get errorInvalidLaneIndex {
    return Intl.message(
      'Invalid lane index provided.',
      name: 'errorInvalidLaneIndex',
      desc:
          'Error message when an invalid index is used to update a saved lane.',
      args: [],
    );
  }

  /// `Cannot update lane: Missing or invalid lane data.`
  String get errorInvalidLaneData {
    return Intl.message(
      'Cannot update lane: Missing or invalid lane data.',
      name: 'errorInvalidLaneData',
      desc: 'Error message when the original lane data is missing a valid ID.',
      args: [],
    );
  }

  /// `Cannot update lane: Invalid record status.`
  String get errorInvalidRecordStatus {
    return Intl.message(
      'Cannot update lane: Invalid record status.',
      name: 'errorInvalidRecordStatus',
      desc:
          'Error message when the original lane\'s record status is missing or invalid.',
      args: [],
    );
  }

  /// `Editing is currently disabled.`
  String get errorEditingDisabled {
    return Intl.message(
      'Editing is currently disabled.',
      name: 'errorEditingDisabled',
      desc:
          'Error message when attempting to update a lane while editing is disabled.',
      args: [],
    );
  }

  /// `Validation failed. Please check your input.`
  String get validationFailed {
    return Intl.message(
      'Validation failed. Please check your input.',
      name: 'validationFailed',
      desc:
          'Generic error message when lane validation fails during an update.',
      args: [],
    );
  }

  /// `Server failed to update the lane.`
  String get messageErrorUpdatingLaneServer {
    return Intl.message(
      'Server failed to update the lane.',
      name: 'messageErrorUpdatingLaneServer',
      desc:
          'Error message when the server indicates a failure to update a lane.',
      args: [],
    );
  }

  /// `Loading Lane Details`
  String get errorLoadingLaneDetails {
    return Intl.message(
      'Loading Lane Details',
      name: 'errorLoadingLaneDetails',
      desc: '',
      args: [],
    );
  }

  /// `No lane selected for update. Please try again.`
  String get errorNoLaneToUpdate {
    return Intl.message(
      'No lane selected for update. Please try again.',
      name: 'errorNoLaneToUpdate',
      desc:
          'Error message shown when attempting to save without a valid lane selected.',
      args: [],
    );
  }

  /// `Unable to Load Lane Details`
  String get errorUnableToLoadLaneDetails {
    return Intl.message(
      'Unable to Load Lane Details',
      name: 'errorUnableToLoadLaneDetails',
      desc: 'Error title shown when lane details fail to load.',
      args: [],
    );
  }

  /// `Unexpected Error`
  String get errorTitleUnexpected {
    return Intl.message(
      'Unexpected Error',
      name: 'errorTitleUnexpected',
      desc: 'Generic error title for unexpected errors',
      args: [],
    );
  }

  /// `Add a new lane`
  String get tooltipAddLane {
    return Intl.message(
      'Add a new lane',
      name: 'tooltipAddLane',
      desc: 'Tooltip for the floating action button to add a new lane.',
      args: [],
    );
  }

  /// `Try a different search term.`
  String get tryDifferentSearch {
    return Intl.message(
      'Try a different search term.',
      name: 'tryDifferentSearch',
      desc: 'Suggestion to try a different search when no results are found.',
      args: [],
    );
  }

  /// `This plaza has no lanes yet. Add one to get started!`
  String get noLanesForPlazaAddOne {
    return Intl.message(
      'This plaza has no lanes yet. Add one to get started!',
      name: 'noLanesForPlazaAddOne',
      desc:
          'Message encouraging the user to add a lane when none exist for the plaza.',
      args: [],
    );
  }

  /// `Cannot navigate: Lane ID is missing.`
  String get errorInvalidLaneIdNavigate {
    return Intl.message(
      'Cannot navigate: Lane ID is missing.',
      name: 'errorInvalidLaneIdNavigate',
      desc:
          'Error message when attempting to navigate to edit a lane with a missing ID.',
      args: [],
    );
  }

  /// `Select a direction`
  String get selectDirectionHint {
    return Intl.message(
      'Select a direction',
      name: 'selectDirectionHint',
      desc: 'Hint text for the lane direction dropdown.',
      args: [],
    );
  }

  /// `Select a type`
  String get selectTypeHint {
    return Intl.message(
      'Select a type',
      name: 'selectTypeHint',
      desc: 'Hint text for the lane type dropdown.',
      args: [],
    );
  }

  /// `Modify Details`
  String get modifyDetails {
    return Intl.message(
      'Modify Details',
      name: 'modifyDetails',
      desc: '',
      args: [],
    );
  }

  /// `View Details`
  String get viewDetails {
    return Intl.message(
      'View Details',
      name: 'viewDetails',
      desc: '',
      args: [],
    );
  }

  /// `Add New Lane`
  String get titleAddLane {
    return Intl.message(
      'Add New Lane',
      name: 'titleAddLane',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get buttonSave {
    return Intl.message(
      'Save',
      name: 'buttonSave',
      desc: '',
      args: [],
    );
  }

  /// `Lane Name`
  String get labelLaneName {
    return Intl.message(
      'Lane Name',
      name: 'labelLaneName',
      desc: '',
      args: [],
    );
  }

  /// `Plaza Lane ID`
  String get labelPlazaLaneId {
    return Intl.message(
      'Plaza Lane ID',
      name: 'labelPlazaLaneId',
      desc: '',
      args: [],
    );
  }

  /// `Direction`
  String get labelDirection {
    return Intl.message(
      'Direction',
      name: 'labelDirection',
      desc: '',
      args: [],
    );
  }

  /// `Type`
  String get labelType {
    return Intl.message(
      'Type',
      name: 'labelType',
      desc: '',
      args: [],
    );
  }

  /// `Status`
  String get labelStatus {
    return Intl.message(
      'Status',
      name: 'labelStatus',
      desc: '',
      args: [],
    );
  }

  /// `RFID Reader ID`
  String get labelRfidReaderId {
    return Intl.message(
      'RFID Reader ID',
      name: 'labelRfidReaderId',
      desc: '',
      args: [],
    );
  }

  /// `Camera ID`
  String get labelCameraId {
    return Intl.message(
      'Camera ID',
      name: 'labelCameraId',
      desc: '',
      args: [],
    );
  }

  /// `WIM ID`
  String get labelWimId {
    return Intl.message(
      'WIM ID',
      name: 'labelWimId',
      desc: '',
      args: [],
    );
  }

  /// `Boomer Barrier ID`
  String get labelBoomerBarrierId {
    return Intl.message(
      'Boomer Barrier ID',
      name: 'labelBoomerBarrierId',
      desc: '',
      args: [],
    );
  }

  /// `LED Screen ID`
  String get labelLedScreenId {
    return Intl.message(
      'LED Screen ID',
      name: 'labelLedScreenId',
      desc: '',
      args: [],
    );
  }

  /// `Magnetic Loop ID`
  String get labelMagneticLoopId {
    return Intl.message(
      'Magnetic Loop ID',
      name: 'labelMagneticLoopId',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get buttonCancel {
    return Intl.message(
      'Cancel',
      name: 'buttonCancel',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get buttonAdd {
    return Intl.message(
      'Add',
      name: 'buttonAdd',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Plaza ID provided. Please contact support.`
  String get errorInvalidPlazaId {
    return Intl.message(
      'Invalid Plaza ID provided. Please contact support.',
      name: 'errorInvalidPlazaId',
      desc: '',
      args: [],
    );
  }

  /// `Cannot save lane: Plaza data is missing.`
  String get errorMissingPlazaData {
    return Intl.message(
      'Cannot save lane: Plaza data is missing.',
      name: 'errorMissingPlazaData',
      desc: '',
      args: [],
    );
  }

  /// `{fieldName} is required.`
  String validationFieldRequired(Object fieldName) {
    return Intl.message(
      '$fieldName is required.',
      name: 'validationFieldRequired',
      desc:
          'Error message template for required fields, with placeholder for field name',
      args: [fieldName],
    );
  }

  /// `Select Plaza`
  String get labelSelectPlaza {
    return Intl.message(
      'Select Plaza',
      name: 'labelSelectPlaza',
      desc: '',
      args: [],
    );
  }

  /// `Select Fare Type`
  String get labelSelectFareType {
    return Intl.message(
      'Select Fare Type',
      name: 'labelSelectFareType',
      desc: '',
      args: [],
    );
  }

  /// `Select Vehicle Type`
  String get labelSelectVehicleType {
    return Intl.message(
      'Select Vehicle Type',
      name: 'labelSelectVehicleType',
      desc: '',
      args: [],
    );
  }

  /// `Effective Start Date`
  String get labelEffectiveStartDate {
    return Intl.message(
      'Effective Start Date',
      name: 'labelEffectiveStartDate',
      desc: '',
      args: [],
    );
  }

  /// `Effective End Date`
  String get labelEffectiveEndDate {
    return Intl.message(
      'Effective End Date',
      name: 'labelEffectiveEndDate',
      desc: '',
      args: [],
    );
  }

  /// `Hour`
  String get labelHour {
    return Intl.message(
      'Hour',
      name: 'labelHour',
      desc: '',
      args: [],
    );
  }

  /// `Month`
  String get labelMonth {
    return Intl.message(
      'Month',
      name: 'labelMonth',
      desc: '',
      args: [],
    );
  }

  /// `Rate`
  String get labelRate {
    return Intl.message(
      'Rate',
      name: 'labelRate',
      desc: '',
      args: [],
    );
  }

  /// `Details`
  String get labelDetails {
    return Intl.message(
      'Details',
      name: 'labelDetails',
      desc: '',
      args: [],
    );
  }

  /// `Fare Details`
  String get labelFareDetails {
    return Intl.message(
      'Fare Details',
      name: 'labelFareDetails',
      desc: '',
      args: [],
    );
  }

  /// `Submit All Fares`
  String get buttonSubmitAllFares {
    return Intl.message(
      'Submit All Fares',
      name: 'buttonSubmitAllFares',
      desc: '',
      args: [],
    );
  }

  /// `Add New Fare`
  String get dialogTitleAddNewFare {
    return Intl.message(
      'Add New Fare',
      name: 'dialogTitleAddNewFare',
      desc: '',
      args: [],
    );
  }

  /// `Add New Fare`
  String get tooltipAddFare {
    return Intl.message(
      'Add New Fare',
      name: 'tooltipAddFare',
      desc: '',
      args: [],
    );
  }

  /// `From (minutes)`
  String get labelFromMinutes {
    return Intl.message(
      'From (minutes)',
      name: 'labelFromMinutes',
      desc: '',
      args: [],
    );
  }

  /// `To (minutes)`
  String get labelToMinutes {
    return Intl.message(
      'To (minutes)',
      name: 'labelToMinutes',
      desc: '',
      args: [],
    );
  }

  /// `Fare`
  String get labelFareAmount {
    return Intl.message(
      'Fare',
      name: 'labelFareAmount',
      desc: '',
      args: [],
    );
  }

  /// `Daily Fare`
  String get labelDailyFare {
    return Intl.message(
      'Daily Fare',
      name: 'labelDailyFare',
      desc: '',
      args: [],
    );
  }

  /// `Hourly Fare`
  String get labelHourlyFare {
    return Intl.message(
      'Hourly Fare',
      name: 'labelHourlyFare',
      desc: '',
      args: [],
    );
  }

  /// `Base Hours`
  String get labelBaseHours {
    return Intl.message(
      'Base Hours',
      name: 'labelBaseHours',
      desc: '',
      args: [],
    );
  }

  /// `Base Hourly Fare`
  String get labelBaseHourlyFare {
    return Intl.message(
      'Base Hourly Fare',
      name: 'labelBaseHourlyFare',
      desc: '',
      args: [],
    );
  }

  /// `Discount for Extended Hours`
  String get labelDiscountExtendedHours {
    return Intl.message(
      'Discount for Extended Hours',
      name: 'labelDiscountExtendedHours',
      desc: '',
      args: [],
    );
  }

  /// `Discount`
  String get labelDiscount {
    return Intl.message(
      'Discount',
      name: 'labelDiscount',
      desc: '',
      args: [],
    );
  }

  /// `Monthly Fare`
  String get labelMonthlyFare {
    return Intl.message(
      'Monthly Fare',
      name: 'labelMonthlyFare',
      desc: '',
      args: [],
    );
  }

  /// `Fares to be Added:`
  String get labelFaresToBeAdded {
    return Intl.message(
      'Fares to be Added:',
      name: 'labelFaresToBeAdded',
      desc: '',
      args: [],
    );
  }

  /// `Failed to connect to the server. Please try again later.`
  String get errorServerConnectionRefused {
    return Intl.message(
      'Failed to connect to the server. Please try again later.',
      name: 'errorServerConnectionRefused',
      desc: '',
      args: [],
    );
  }

  /// `Access denied. You do not have permission to perform this action.`
  String get errorAccessDenied {
    return Intl.message(
      'Access denied. You do not have permission to perform this action.',
      name: 'errorAccessDenied',
      desc: '',
      args: [],
    );
  }

  /// `Invalid request data. Please check your input and try again.`
  String get errorInvalidRequest {
    return Intl.message(
      'Invalid request data. Please check your input and try again.',
      name: 'errorInvalidRequest',
      desc: '',
      args: [],
    );
  }

  /// `No fares added yet. Tap '+' to add.`
  String get messageNoFaresAddedYet {
    return Intl.message(
      'No fares added yet. Tap \'+\' to add.',
      name: 'messageNoFaresAddedYet',
      desc: '',
      args: [],
    );
  }

  /// `Free Pass`
  String get fareTypeFreePass {
    return Intl.message(
      'Free Pass',
      name: 'fareTypeFreePass',
      desc: '',
      args: [],
    );
  }

  /// `Range`
  String get labelTimeRange {
    return Intl.message(
      'Range',
      name: 'labelTimeRange',
      desc: '',
      args: [],
    );
  }

  /// `min`
  String get labelMinutesAbbr {
    return Intl.message(
      'min',
      name: 'labelMinutesAbbr',
      desc: '',
      args: [],
    );
  }

  /// `Day`
  String get labelDay {
    return Intl.message(
      'Day',
      name: 'labelDay',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get buttonNo {
    return Intl.message(
      'No',
      name: 'buttonNo',
      desc: '',
      args: [],
    );
  }

  /// `Location services are disabled. Please enable them.`
  String get locationServiceDisabled {
    return Intl.message(
      'Location services are disabled. Please enable them.',
      name: 'locationServiceDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Location permission permanently denied. Please enable it in settings.`
  String get locationPermissionDeniedForever {
    return Intl.message(
      'Location permission permanently denied. Please enable it in settings.',
      name: 'locationPermissionDeniedForever',
      desc: '',
      args: [],
    );
  }

  /// `Failed to fetch location: `
  String get locationFetchError {
    return Intl.message(
      'Failed to fetch location: ',
      name: 'locationFetchError',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get buttonYes {
    return Intl.message(
      'Yes',
      name: 'buttonYes',
      desc: '',
      args: [],
    );
  }

  /// `User Modified Successfully`
  String get userModified {
    return Intl.message(
      'User Modified Successfully',
      name: 'userModified',
      desc: '',
      args: [],
    );
  }

  /// `Base Rate`
  String get labelBaseRate {
    return Intl.message(
      'Base Rate',
      name: 'labelBaseRate',
      desc: '',
      args: [],
    );
  }

  /// `Edit Fare`
  String get titleEditFare {
    return Intl.message(
      'Edit Fare',
      name: 'titleEditFare',
      desc: '',
      args: [],
    );
  }

  /// `View Fare`
  String get titleViewFare {
    return Intl.message(
      'View Fare',
      name: 'titleViewFare',
      desc: '',
      args: [],
    );
  }

  /// `Discard Changes?`
  String get dialogTitleDiscardChanges {
    return Intl.message(
      'Discard Changes?',
      name: 'dialogTitleDiscardChanges',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to discard your changes?`
  String get dialogMessageDiscardChanges {
    return Intl.message(
      'Are you sure you want to discard your changes?',
      name: 'dialogMessageDiscardChanges',
      desc: '',
      args: [],
    );
  }

  /// `Fare updated successfully!`
  String get successFareUpdated {
    return Intl.message(
      'Fare updated successfully!',
      name: 'successFareUpdated',
      desc: '',
      args: [],
    );
  }

  /// `must be a non-negative number.`
  String get errorMustBeNonNegativeNumber {
    return Intl.message(
      'must be a non-negative number.',
      name: 'errorMustBeNonNegativeNumber',
      desc: '',
      args: [],
    );
  }

  /// `End Date must be strictly later than Start Date.`
  String get errorEndDateStrictlyAfterStart {
    return Intl.message(
      'End Date must be strictly later than Start Date.',
      name: 'errorEndDateStrictlyAfterStart',
      desc: '',
      args: [],
    );
  }

  /// `Discount must be greater than 0 and less than or equal to 100.`
  String get errorDiscountRangeStrictPositive {
    return Intl.message(
      'Discount must be greater than 0 and less than or equal to 100.',
      name: 'errorDiscountRangeStrictPositive',
      desc: '',
      args: [],
    );
  }

  /// `From (minutes) is required.`
  String get errorFromMinutesRequired {
    return Intl.message(
      'From (minutes) is required.',
      name: 'errorFromMinutesRequired',
      desc: '',
      args: [],
    );
  }

  /// `From (minutes) must be 0 or greater.`
  String get errorFromMinutesNonNegative {
    return Intl.message(
      'From (minutes) must be 0 or greater.',
      name: 'errorFromMinutesNonNegative',
      desc: '',
      args: [],
    );
  }

  /// `To (minutes) is required.`
  String get errorToMinutesRequired {
    return Intl.message(
      'To (minutes) is required.',
      name: 'errorToMinutesRequired',
      desc: '',
      args: [],
    );
  }

  /// `To (minutes) must be a positive number.`
  String get errorToMinutesPositive {
    return Intl.message(
      'To (minutes) must be a positive number.',
      name: 'errorToMinutesPositive',
      desc: '',
      args: [],
    );
  }

  /// `To (minutes) must be greater than From (minutes).`
  String get errorToMinutesGreaterThanFrom {
    return Intl.message(
      'To (minutes) must be greater than From (minutes).',
      name: 'errorToMinutesGreaterThanFrom',
      desc: '',
      args: [],
    );
  }

  /// `Fare is required for Progressive type.`
  String get errorProgressiveFareRequired {
    return Intl.message(
      'Fare is required for Progressive type.',
      name: 'errorProgressiveFareRequired',
      desc: '',
      args: [],
    );
  }

  /// `Fare must be 0 or greater.`
  String get errorProgressiveFareNonNegative {
    return Intl.message(
      'Fare must be 0 or greater.',
      name: 'errorProgressiveFareNonNegative',
      desc: '',
      args: [],
    );
  }

  /// `Please select a Plaza to add fares.`
  String get warningSelectPlazaToAddFare {
    return Intl.message(
      'Please select a Plaza to add fares.',
      name: 'warningSelectPlazaToAddFare',
      desc: '',
      args: [],
    );
  }

  /// `Ticket Collections`
  String get cardTicketCollections {
    return Intl.message(
      'Ticket Collections',
      name: 'cardTicketCollections',
      desc: 'Title of the card displaying ticket collection statistics.',
      args: [],
    );
  }

  /// `No. of Tickets`
  String get labelNumberOfTickets {
    return Intl.message(
      'No. of Tickets',
      name: 'labelNumberOfTickets',
      desc: 'Label for the number of tickets in the ticket collections card.',
      args: [],
    );
  }

  /// `Ticket Collection`
  String get labelTicketCollections {
    return Intl.message(
      'Ticket Collection',
      name: 'labelTicketCollections',
      desc:
          'Label for the ticket collection amount in the ticket collections card.',
      args: [],
    );
  }

  /// `Total Tickets`
  String get labelTotalTickets {
    return Intl.message(
      'Total Tickets',
      name: 'labelTotalTickets',
      desc: 'Label for the total tickets in the ticket overview section.',
      args: [],
    );
  }

  /// `Open Tickets`
  String get labelOpenTickets {
    return Intl.message(
      'Open Tickets',
      name: 'labelOpenTickets',
      desc: 'Label for open tickets in the ticket overview section.',
      args: [],
    );
  }

  /// `Completed Tickets`
  String get labelCompletedTickets {
    return Intl.message(
      'Completed Tickets',
      name: 'labelCompletedTickets',
      desc: 'Label for completed tickets in the ticket overview section.',
      args: [],
    );
  }

  /// `No. of Plazas`
  String get labelNumberOfPlazas {
    return Intl.message(
      'No. of Plazas',
      name: 'labelNumberOfPlazas',
      desc: 'Label for the number of plazas in the plaza summary section.',
      args: [],
    );
  }

  /// `Total Slots`
  String get labelTotalSlots {
    return Intl.message(
      'Total Slots',
      name: 'labelTotalSlots',
      desc: 'Label for the total slots in the plaza summary section.',
      args: [],
    );
  }

  /// `Average Slots`
  String get labelAverageSlots {
    return Intl.message(
      'Average Slots',
      name: 'labelAverageSlots',
      desc: 'Label for the average slots in the plaza summary section.',
      args: [],
    );
  }

  /// `Occupied Slots`
  String get labelOccupiedSlots {
    return Intl.message(
      'Occupied Slots',
      name: 'labelOccupiedSlots',
      desc: 'Label for the occupied slots in the plaza summary section.',
      args: [],
    );
  }

  /// `Count`
  String get labelCount {
    return Intl.message(
      'Count',
      name: 'labelCount',
      desc: 'Generic label for counts in summary cards.',
      args: [],
    );
  }

  /// `Booking Analysis`
  String get cardPlazaBookingSummary {
    return Intl.message(
      'Booking Analysis',
      name: 'cardPlazaBookingSummary',
      desc: 'Title of the card displaying plaza booking statistics as a chart.',
      args: [],
    );
  }

  /// `Total Bookings`
  String get labelTotalBookings {
    return Intl.message(
      'Total Bookings',
      name: 'labelTotalBookings',
      desc: 'Label for total bookings in the booking analysis chart.',
      args: [],
    );
  }

  /// `Reserved Bookings`
  String get labelReservedBookings {
    return Intl.message(
      'Reserved Bookings',
      name: 'labelReservedBookings',
      desc: 'Label for reserved bookings in the booking analysis chart.',
      args: [],
    );
  }

  /// `Cancelled Bookings`
  String get labelCancelledBookings {
    return Intl.message(
      'Cancelled Bookings',
      name: 'labelCancelledBookings',
      desc: 'Label for cancelled bookings in the booking analysis chart.',
      args: [],
    );
  }

  /// `No-Show Bookings`
  String get labelNoShowBookings {
    return Intl.message(
      'No-Show Bookings',
      name: 'labelNoShowBookings',
      desc: 'Label for no-show bookings in the booking analysis chart.',
      args: [],
    );
  }

  /// `Total`
  String get labelTotal {
    return Intl.message(
      'Total',
      name: 'labelTotal',
      desc:
          'Short label for total bookings in the booking analysis chart axis.',
      args: [],
    );
  }

  /// `Reserved`
  String get labelReserved {
    return Intl.message(
      'Reserved',
      name: 'labelReserved',
      desc:
          'Short label for reserved bookings in the booking analysis chart axis.',
      args: [],
    );
  }

  /// `Cancelled`
  String get labelCancelled {
    return Intl.message(
      'Cancelled',
      name: 'labelCancelled',
      desc:
          'Short label for cancelled bookings in the booking analysis chart axis.',
      args: [],
    );
  }

  /// `No-Show`
  String get labelNoShow {
    return Intl.message(
      'No-Show',
      name: 'labelNoShow',
      desc:
          'Short label for no-show bookings in the booking analysis chart axis.',
      args: [],
    );
  }

  /// `Percentage Change`
  String get labelPercentageChange {
    return Intl.message(
      'Percentage Change',
      name: 'labelPercentageChange',
      desc: 'Label for the percentage change in the booking analysis card.',
      args: [],
    );
  }

  /// `Dispute Summary`
  String get cardDisputeSummary {
    return Intl.message(
      'Dispute Summary',
      name: 'cardDisputeSummary',
      desc: 'Title of the card displaying dispute summary statistics.',
      args: [],
    );
  }

  /// `Total Disputes`
  String get labelTotalDisputes {
    return Intl.message(
      'Total Disputes',
      name: 'labelTotalDisputes',
      desc:
          'Label for the total number of disputes in the dispute summary card.',
      args: [],
    );
  }

  /// `Total Amount`
  String get labelTotalAmount {
    return Intl.message(
      'Total Amount',
      name: 'labelTotalAmount',
      desc:
          'Label for the total amount of disputes in the dispute summary card.',
      args: [],
    );
  }

  /// `Open Disputes`
  String get labelOpenDisputes {
    return Intl.message(
      'Open Disputes',
      name: 'labelOpenDisputes',
      desc:
          'Label for the number of open disputes in the dispute summary card.',
      args: [],
    );
  }

  /// `Open Amount`
  String get labelOpenAmount {
    return Intl.message(
      'Open Amount',
      name: 'labelOpenAmount',
      desc:
          'Label for the amount of open disputes in the dispute summary card.',
      args: [],
    );
  }

  /// `Settled Disputes`
  String get labelSettledDisputes {
    return Intl.message(
      'Settled Disputes',
      name: 'labelSettledDisputes',
      desc:
          'Label for the number of settled disputes in the dispute summary card.',
      args: [],
    );
  }

  /// `Settled Amount`
  String get labelSettledAmount {
    return Intl.message(
      'Settled Amount',
      name: 'labelSettledAmount',
      desc:
          'Label for the amount of settled disputes in the dispute summary card.',
      args: [],
    );
  }

  /// `Rejected Disputes`
  String get labelRejectedDisputes {
    return Intl.message(
      'Rejected Disputes',
      name: 'labelRejectedDisputes',
      desc:
          'Label for the number of rejected disputes in the dispute summary card.',
      args: [],
    );
  }

  /// `Rejected Amount`
  String get labelRejectedAmount {
    return Intl.message(
      'Rejected Amount',
      name: 'labelRejectedAmount',
      desc:
          'Label for the amount of rejected disputes in the dispute summary card.',
      args: [],
    );
  }

  /// `Payment Method Analysis`
  String get cardPaymentMethodAnalysis {
    return Intl.message(
      'Payment Method Analysis',
      name: 'cardPaymentMethodAnalysis',
      desc:
          'Title of the card displaying payment method analysis as a pie chart.',
      args: [],
    );
  }

  /// `Card`
  String get labelCard {
    return Intl.message(
      'Card',
      name: 'labelCard',
      desc:
          'Label for card payment method in the payment method analysis card.',
      args: [],
    );
  }

  /// `UPI`
  String get labelUpi {
    return Intl.message(
      'UPI',
      name: 'labelUpi',
      desc: 'Label for UPI payment method in the payment method analysis card.',
      args: [],
    );
  }

  /// `Cash`
  String get labelCash {
    return Intl.message(
      'Cash',
      name: 'labelCash',
      desc:
          'Label for cash payment method in the payment method analysis card.',
      args: [],
    );
  }

  /// `Data not found`
  String get errorDataNotFound {
    return Intl.message(
      'Data not found',
      name: 'errorDataNotFound',
      desc: 'Message shown when no data is available for a card or chart.',
      args: [],
    );
  }

  /// `Unknown`
  String get labelUnknown {
    return Intl.message(
      'Unknown',
      name: 'labelUnknown',
      desc: '',
      args: [],
    );
  }

  /// `No Data Found`
  String get labelNoData {
    return Intl.message(
      'No Data Found',
      name: 'labelNoData',
      desc: '',
      args: [],
    );
  }

  /// `No plaza assigned to this user`
  String get noPlazaAssigned {
    return Intl.message(
      'No plaza assigned to this user',
      name: 'noPlazaAssigned',
      desc: '',
      args: [],
    );
  }

  /// `Pending Tickets`
  String get labelPendingTickets {
    return Intl.message(
      'Pending Tickets',
      name: 'labelPendingTickets',
      desc: '',
      args: [],
    );
  }

  /// `Successful Tickets`
  String get labelSuccessfulTickets {
    return Intl.message(
      'Successful Tickets',
      name: 'labelSuccessfulTickets',
      desc: '',
      args: [],
    );
  }

  /// `Failed Tickets`
  String get labelFailedTickets {
    return Intl.message(
      'Failed Tickets',
      name: 'labelFailedTickets',
      desc: '',
      args: [],
    );
  }

  /// `Rejected Tickets`
  String get labelRejectedTickets {
    return Intl.message(
      'Rejected Tickets',
      name: 'labelRejectedTickets',
      desc: '',
      args: [],
    );
  }

  /// `All Plazas`
  String get labelAllPlazas {
    return Intl.message(
      'All Plazas',
      name: 'labelAllPlazas',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Plaza Data`
  String get invalidPlazaData {
    return Intl.message(
      'Invalid Plaza Data',
      name: 'invalidPlazaData',
      desc: '',
      args: [],
    );
  }

  /// `Dispute List`
  String get disputeListTitle {
    return Intl.message(
      'Dispute List',
      name: 'disputeListTitle',
      desc: 'Title displayed in the app bar of the Dispute List screen',
      args: [],
    );
  }

  /// `Search by Dispute ID, Vehicle Number, Plaza, etc.`
  String get searchDisputeHint {
    return Intl.message(
      'Search by Dispute ID, Vehicle Number, Plaza, etc.',
      name: 'searchDisputeHint',
      desc: 'Hint text for the search input field',
      args: [],
    );
  }

  /// `No disputes found`
  String get noDisputesFound {
    return Intl.message(
      'No disputes found',
      name: 'noDisputesFound',
      desc: 'Message displayed when no disputes are available',
      args: [],
    );
  }

  /// `Last Updated`
  String get lastUpdated {
    return Intl.message(
      'Last Updated',
      name: 'lastUpdated',
      desc: 'Label for the last updated timestamp',
      args: [],
    );
  }

  /// `Swipe down to refresh`
  String get swipeToRefresh {
    return Intl.message(
      'Swipe down to refresh',
      name: 'swipeToRefresh',
      desc: 'Instruction to refresh the dispute list',
      args: [],
    );
  }

  /// `Filters`
  String get filtersLabel {
    return Intl.message(
      'Filters',
      name: 'filtersLabel',
      desc: 'Label for the filters chip',
      args: [],
    );
  }

  /// `Reset All`
  String get resetAllLabel {
    return Intl.message(
      'Reset All',
      name: 'resetAllLabel',
      desc: 'Label for the reset all filters button',
      args: [],
    );
  }

  /// `Date Range`
  String get dateRangeLabel {
    return Intl.message(
      'Date Range',
      name: 'dateRangeLabel',
      desc: 'Label for the date range filter chip when no range is selected',
      args: [],
    );
  }

  /// `Today`
  String get todayLabel {
    return Intl.message(
      'Today',
      name: 'todayLabel',
      desc: 'Label for the \'Today\' date filter option',
      args: [],
    );
  }

  /// `Yesterday`
  String get yesterdayLabel {
    return Intl.message(
      'Yesterday',
      name: 'yesterdayLabel',
      desc: 'Label for the \'Yesterday\' date filter option',
      args: [],
    );
  }

  /// `Last 7 Days`
  String get last7DaysLabel {
    return Intl.message(
      'Last 7 Days',
      name: 'last7DaysLabel',
      desc: 'Label for the \'Last 7 Days\' date filter option',
      args: [],
    );
  }

  /// `Last 30 Days`
  String get last30DaysLabel {
    return Intl.message(
      'Last 30 Days',
      name: 'last30DaysLabel',
      desc: 'Label for the \'Last 30 Days\' date filter option',
      args: [],
    );
  }

  /// `Custom`
  String get customLabel {
    return Intl.message(
      'Custom',
      name: 'customLabel',
      desc: 'Label for the \'Custom\' date range filter option',
      args: [],
    );
  }

  /// `Advanced Filters`
  String get advancedFiltersLabel {
    return Intl.message(
      'Advanced Filters',
      name: 'advancedFiltersLabel',
      desc: 'Title for the advanced filters dialog',
      args: [],
    );
  }

  /// `Dispute Status`
  String get disputeStatusLabel {
    return Intl.message(
      'Dispute Status',
      name: 'disputeStatusLabel',
      desc: 'Label for the dispute status filter section',
      args: [],
    );
  }

  /// `Open`
  String get openDisputesLabel {
    return Intl.message(
      'Open',
      name: 'openDisputesLabel',
      desc: 'Label for the \'Open\' dispute status filter',
      args: [],
    );
  }

  /// `Unable to Load Disputes`
  String get errorUnableToLoadDisputes {
    return Intl.message(
      'Unable to Load Disputes',
      name: 'errorUnableToLoadDisputes',
      desc: '',
      args: [],
    );
  }

  /// `In Progress`
  String get inProgressDisputesLabel {
    return Intl.message(
      'In Progress',
      name: 'inProgressDisputesLabel',
      desc: 'Label for the \'In Progress\' dispute status filter',
      args: [],
    );
  }

  /// `Accepted`
  String get acceptedDisputesLabel {
    return Intl.message(
      'Accepted',
      name: 'acceptedDisputesLabel',
      desc: 'Label for the \'Accepted\' dispute status filter',
      args: [],
    );
  }

  /// `Rejected`
  String get rejectedDisputesLabel {
    return Intl.message(
      'Rejected',
      name: 'rejectedDisputesLabel',
      desc: 'Label for the \'Rejected\' dispute status filter',
      args: [],
    );
  }

  /// `Vehicle Type`
  String get vehicleTypeLabel {
    return Intl.message(
      'Vehicle Type',
      name: 'vehicleTypeLabel',
      desc: 'Label for the vehicle type filter section',
      args: [],
    );
  }

  /// `Bike`
  String get bikeLabel {
    return Intl.message(
      'Bike',
      name: 'bikeLabel',
      desc: 'Label for the \'Bike\' vehicle type filter',
      args: [],
    );
  }

  /// `3-Wheeler`
  String get threeWheelerLabel {
    return Intl.message(
      '3-Wheeler',
      name: 'threeWheelerLabel',
      desc: 'Label for the \'3-Wheeler\' vehicle type filter',
      args: [],
    );
  }

  /// `4-Wheeler`
  String get fourWheelerLabel {
    return Intl.message(
      '4-Wheeler',
      name: 'fourWheelerLabel',
      desc: 'Label for the \'4-Wheeler\' vehicle type filter',
      args: [],
    );
  }

  /// `Bus`
  String get busLabel {
    return Intl.message(
      'Bus',
      name: 'busLabel',
      desc: 'Label for the \'Bus\' vehicle type filter',
      args: [],
    );
  }

  /// `Truck`
  String get truckLabel {
    return Intl.message(
      'Truck',
      name: 'truckLabel',
      desc: 'Label for the \'Truck\' vehicle type filter',
      args: [],
    );
  }

  /// `Heavy Machinery`
  String get heavyMachineryLabel {
    return Intl.message(
      'Heavy Machinery',
      name: 'heavyMachineryLabel',
      desc: 'Label for the \'Heavy Machinery\' vehicle type filter',
      args: [],
    );
  }

  /// `Plaza Name`
  String get plazaNameLabel {
    return Intl.message(
      'Plaza Name',
      name: 'plazaNameLabel',
      desc: 'Label for the plaza name filter section',
      args: [],
    );
  }

  /// `Search Plaza Name`
  String get searchPlazaHint {
    return Intl.message(
      'Search Plaza Name',
      name: 'searchPlazaHint',
      desc: 'Hint text for the plaza name search input in the filters dialog',
      args: [],
    );
  }

  /// `Clear All`
  String get clearAllLabel {
    return Intl.message(
      'Clear All',
      name: 'clearAllLabel',
      desc: 'Label for the clear all filters button in the filters dialog',
      args: [],
    );
  }

  /// `Apply`
  String get applyLabel {
    return Intl.message(
      'Apply',
      name: 'applyLabel',
      desc: 'Label for the apply filters button in the filters dialog',
      args: [],
    );
  }

  /// `Select Date Range`
  String get selectDateRangeLabel {
    return Intl.message(
      'Select Date Range',
      name: 'selectDateRangeLabel',
      desc: 'Title for the date range filter dialog',
      args: [],
    );
  }

  /// `Clear`
  String get clearLabel {
    return Intl.message(
      'Clear',
      name: 'clearLabel',
      desc: 'Label for the clear button in the date range dialog',
      args: [],
    );
  }

  /// `Selected Range`
  String get selectedRangeLabel {
    return Intl.message(
      'Selected Range',
      name: 'selectedRangeLabel',
      desc:
          'Label for the selected date range display in the date range dialog',
      args: [],
    );
  }

  /// `Selected date range cannot exceed 1 year`
  String get dateRangeTooLongWarning {
    return Intl.message(
      'Selected date range cannot exceed 1 year',
      name: 'dateRangeTooLongWarning',
      desc: 'Warning message when the selected date range is too long',
      args: [],
    );
  }

  /// `Dispute ID`
  String get disputeIdLabel {
    return Intl.message(
      'Dispute ID',
      name: 'disputeIdLabel',
      desc: 'Label for the dispute ID field in the dispute card',
      args: [],
    );
  }

  /// `Vehicle`
  String get vehicleLabel {
    return Intl.message(
      'Vehicle',
      name: 'vehicleLabel',
      desc: 'Label for the vehicle details field in the dispute card',
      args: [],
    );
  }

  /// `Plaza`
  String get plazaLabel {
    return Intl.message(
      'Plaza',
      name: 'plazaLabel',
      desc: 'Label for the plaza name field in the dispute card',
      args: [],
    );
  }

  /// `Entry Time`
  String get entryTimeLabel {
    return Intl.message(
      'Entry Time',
      name: 'entryTimeLabel',
      desc: 'Label for the entry time field in the dispute card',
      args: [],
    );
  }

  /// `Dispute Amount`
  String get disputeAmountLabel {
    return Intl.message(
      'Dispute Amount',
      name: 'disputeAmountLabel',
      desc: 'Label for the dispute amount field in the dispute card',
      args: [],
    );
  }

  /// `Reason`
  String get reasonLabel {
    return Intl.message(
      'Reason',
      name: 'reasonLabel',
      desc: 'Label for the dispute reason field in the dispute card',
      args: [],
    );
  }

  /// `Latest Remark`
  String get latestRemarkLabel {
    return Intl.message(
      'Latest Remark',
      name: 'latestRemarkLabel',
      desc: 'Label for the latest remark field in the dispute card',
      args: [],
    );
  }

  /// `Open`
  String get ticketStatusOpen {
    return Intl.message(
      'Open',
      name: 'ticketStatusOpen',
      desc: '',
      args: [],
    );
  }

  /// `Automatic Number Plate Recognition failed to identify vehicle details. Please try again or use manual entry.`
  String get anprFailedMessage {
    return Intl.message(
      'Automatic Number Plate Recognition failed to identify vehicle details. Please try again or use manual entry.',
      name: 'anprFailedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Location Required`
  String get locationRequired {
    return Intl.message(
      'Location Required',
      name: 'locationRequired',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get buttonRetry {
    return Intl.message(
      'Retry',
      name: 'buttonRetry',
      desc: '',
      args: [],
    );
  }

  /// `Submitting`
  String get buttonSubmitting {
    return Intl.message(
      'Submitting',
      name: 'buttonSubmitting',
      desc: '',
      args: [],
    );
  }

  /// `Collect Cash Amount`
  String get messageCollectCashConfirmation {
    return Intl.message(
      'Collect Cash Amount',
      name: 'messageCollectCashConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get buttonDone {
    return Intl.message(
      'Done',
      name: 'buttonDone',
      desc: '',
      args: [],
    );
  }

  /// `Validation Failed`
  String get validationFailedTitle {
    return Intl.message(
      'Validation Failed',
      name: 'validationFailedTitle',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'hi'),
      Locale.fromSubtags(languageCode: 'mr'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
