import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../../models/dashboard.dart';
import '../services/core/dashboard_service.dart';
import '../services/storage/secure_storage_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardService _dashboardService;
  final SecureStorageService _secureStorageService; // Add SecureStorageService

  // Data models to hold fetched data
  DashboardStats? _plazaSummary;
  TicketStats? _ticketStats;
  TicketOverview? _ticketOverview;
  DisputeSummary? _disputeSummary;
  PaymentMethodAnalysis? _paymentAnalysis;
  BookingStats? _bookingStats;

  // Getters for UI to access data
  DashboardStats? get plazaSummary => _plazaSummary;
  TicketStats? get ticketStats => _ticketStats;
  TicketOverview? get ticketOverview => _ticketOverview;
  DisputeSummary? get disputeSummary => _disputeSummary;
  PaymentMethodAnalysis? get paymentAnalysis => _paymentAnalysis;
  BookingStats? get bookingStats => _bookingStats;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  DashboardViewModel({
    DashboardService? dashboardService,
    SecureStorageService? secureStorageService, // Add parameter
  })  : _dashboardService = dashboardService ?? DashboardService(),
        _secureStorageService = secureStorageService ?? SecureStorageService();

  Future<void> fetchDashboardData({
    required String frequency,
    String? plazaId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch plazaOwnerId (entityId) from secure storage
      final plazaOwnerId = await _secureStorageService.getEntityId();
      developer.log('Fetched plazaOwnerId: $plazaOwnerId', name: 'DashboardViewModel');

      // Fetch all data concurrently, passing plazaOwnerId
      final futures = [
        _dashboardService
            .getPlazaDetails(frequency: frequency, ownerId: plazaOwnerId, plazaId: plazaId)
            .then((value) {
          _plazaSummary = value;
        }).catchError((e) {
          developer.log('Failed to fetch plaza details: $e', name: 'DashboardViewModel');
          _plazaSummary = null;
        }),
        _dashboardService
            .getTicketCollectionStats(
            frequency: frequency, plazaOwnerId: plazaOwnerId, plazaId: plazaId)
            .then((value) {
          _ticketStats = value;
        }).catchError((e) {
          developer.log('Failed to fetch ticket stats: $e', name: 'DashboardViewModel');
          _ticketStats = null;
        }),
        _dashboardService
            .getTicketOverview(
            frequency: frequency, plazaOwnerId: plazaOwnerId, plazaId: plazaId)
            .then((value) {
          _ticketOverview = value;
          developer.log('TicketOverview plazas: ${value.plazas}', name: 'DashboardViewModel');
        }).catchError((e) {
          developer.log('Failed to fetch ticket overview: $e', name: 'DashboardViewModel');
          _ticketOverview = null;
        }),
        _dashboardService
            .getDisputeSummary(
            frequency: frequency, plazaOwnerId: plazaOwnerId, plazaId: plazaId)
            .then((value) {
          _disputeSummary = value;
        }).catchError((e) {
          developer.log('Failed to fetch dispute summary: $e', name: 'DashboardViewModel');
          _disputeSummary = null;
        }),
        _dashboardService
            .getPaymentMethodAnalysis(
            frequency: frequency, plazaOwnerId: plazaOwnerId, plazaId: plazaId)
            .then((value) {
          _paymentAnalysis = value;
        }).catchError((e) {
          developer.log('Failed to fetch payment analysis: $e', name: 'DashboardViewModel');
          _paymentAnalysis = null;
        }),
        _dashboardService
            .getPlazaBookings(
            frequency: frequency, plazaOwnerId: plazaOwnerId, plazaId: plazaId)
            .then((value) {
          _bookingStats = value;
        }).catchError((e) {
          developer.log('Failed to fetch booking stats: $e', name: 'DashboardViewModel');
          _bookingStats = null;
        }),
      ];

      // Wait for all futures to complete, but don't fail on individual errors
      await Future.wait(futures, eagerError: false);

      // Check if any data was fetched successfully
      if (_plazaSummary == null &&
          _ticketStats == null &&
          _ticketOverview == null &&
          _disputeSummary == null &&
          _paymentAnalysis == null &&
          _bookingStats == null) {
        _errorMessage = 'Failed to fetch dashboard data';
      } else {
        _errorMessage = null; // Allow partial data to be displayed
        developer.log('[DASHBOARD] Successfully fetched partial dashboard data',
            name: 'DashboardViewModel');
      }
    } catch (e, stackTrace) {
      _errorMessage = e.toString();
      developer.log('[DASHBOARD] Error fetching dashboard data: $e',
          name: 'DashboardViewModel', error: e, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      developer.log('isLoading set to false', name: 'DashboardViewModel');
      notifyListeners();
    }
  }
}