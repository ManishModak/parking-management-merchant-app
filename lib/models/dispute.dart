import 'dart:developer' as developer;

class Dispute {
  int? disputeId; // Nullable: Auto-incremented by backend
  int userId;
  String? processedBy;
  String ticketId;
  int plazaId;
  String ticketCreationTime; // ISO date string
  String status;
  String? paymentTime; // ISO date string
  String? paymentMode;
  String vehicleNumber;
  String vehicleType;
  String parkingDuration; // Stored as String (ISO duration or backend format)
  double fareAmount;
  double paymentAmount;
  double disputeAmount;
  String disputeReason;
  String? remarks;
  String? latestRemark;

  Dispute({
    this.disputeId,
    required this.userId,
    this.processedBy,
    required this.ticketId,
    required this.plazaId,
    required this.ticketCreationTime,
    this.status = 'Open',
    this.paymentTime,
    this.paymentMode,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.parkingDuration,
    required this.fareAmount,
    required this.paymentAmount,
    required this.disputeAmount,
    required this.disputeReason,
    this.remarks,
    this.latestRemark,
  });

  factory Dispute.fromJson(Map<String, dynamic> json) {
    int? tryParseInt(dynamic value) {
      if (value == null) return null;
      return int.tryParse(value.toString());
    }

    double? tryParseDouble(dynamic value) {
      if (value == null) return null;
      return double.tryParse(value.toString());
    }

    return Dispute(
      disputeId: tryParseInt(json['disputeId']),
      userId: tryParseInt(json['userId']) ?? 0,
      processedBy: json['processedBy'] as String?,
      ticketId: json['ticketId'] as String? ?? '',
      plazaId: tryParseInt(json['plazaId']) ?? 0,
      ticketCreationTime: json['ticketCreationTime'] as String? ?? '',
      status: json['status'] as String? ?? 'Open',
      paymentTime: json['paymentTime'] as String?,
      paymentMode: json['paymentMode'] as String?,
      vehicleNumber: json['vehicleNumber'] as String? ?? '',
      vehicleType: json['vehicleType'] as String? ?? '',
      parkingDuration: json['parkingDuration']?.toString() ?? '',
      fareAmount: tryParseDouble(json['fareAmount']) ?? 0.0,
      paymentAmount: tryParseDouble(json['paymentAmount']) ?? 0.0,
      disputeAmount: tryParseDouble(json['disputeAmount']) ?? 0.0,
      disputeReason: json['disputeReason'] as String? ?? '',
      remarks: json['remarks'] as String?,
      latestRemark: json['latestRemark'] as String?,
    );
  }

  Map<String, dynamic> toJsonForCreate() {
    if (userId < 1 ||
        ticketId.isEmpty ||
        plazaId < 1 ||
        ticketCreationTime.isEmpty ||
        vehicleNumber.isEmpty ||
        vehicleType.isEmpty ||
        parkingDuration.isEmpty ||
        fareAmount < 0 ||
        paymentAmount < 0 ||
        disputeAmount < 0 ||
        disputeReason.isEmpty) {
      throw StateError('Required fields missing or invalid for dispute creation.');
    }

    return {
      'userId': userId,
      'ticketId': ticketId,
      'plazaId': plazaId,
      'ticketCreationTime': ticketCreationTime,
      'status': status,
      'paymentTime': paymentTime,
      'paymentMode': paymentMode ?? '',
      'vehicleNumber': vehicleNumber,
      'vehicleType': vehicleType,
      'parkingDuration': parkingDuration,
      'fareAmount': fareAmount,
      'paymentAmount': paymentAmount,
      'disputeAmount': disputeAmount,
      'disputeReason': disputeReason,
      'remarks': remarks ?? '',
    };
  }

  Map<String, dynamic> toJsonForUpdate() {
    if (disputeId == null || disputeId! < 1) {
      throw StateError('Dispute ID is required for update.');
    }

    return {
      'disputeId': disputeId,
      'userId': userId,
      'processedBy': processedBy,
      'ticketId': ticketId,
      'plazaId': plazaId,
      'ticketCreationTime': ticketCreationTime,
      'status': status,
      'paymentTime': paymentTime,
      'paymentMode': paymentMode,
      'vehicleNumber': vehicleNumber,
      'vehicleType': vehicleType,
      'parkingDuration': parkingDuration,
      'fareAmount': fareAmount,
      'paymentAmount': paymentAmount,
      'disputeAmount': disputeAmount,
      'disputeReason': disputeReason,
      'remarks': remarks,
      'latestRemark': latestRemark,
    };
  }

  static const List<String> validStatuses = ['Open', 'Accepted', 'Rejected', 'Inprogress'];
  static const vehicleNumberPattern = r'^[A-Z]{2}\d{2}[A-Z]{2}\d{4}$'; // From Joi schema

  String? validateForCreate() {
    developer.log('Validating Dispute: ticketCreationTime=$ticketCreationTime, vehicleNumber=$vehicleNumber',
        name: 'Dispute.ValidateForCreate');

    if (userId < 1) {
      final error = 'User ID must be a positive number.';
      developer.log('Validation failed: $error', name: 'Dispute.ValidateForCreate');
      return error;
    }
    if (ticketId.isEmpty) {
      final error = 'Ticket ID cannot be empty.';
      developer.log('Validation failed: $error', name: 'Dispute.ValidateForCreate');
      return error;
    }
    if (plazaId < 1) {
      final error = 'Plaza ID must be a positive number.';
      developer.log('Validation failed: $error', name: 'Dispute.ValidateForCreate');
      return error;
    }
    if (ticketCreationTime.isEmpty ||
        !RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{1,3})?Z$').hasMatch(ticketCreationTime)) {
      final error = 'Ticket creation time must be a valid ISO date.';
      developer.log('Validation failed: $error, ticketCreationTime=$ticketCreationTime',
          name: 'Dispute.ValidateForCreate');
      return error;
    }
    if (!validStatuses.contains(status)) {
      final error = 'Invalid status. Must be one of: ${validStatuses.join(", ")}';
      developer.log('Validation failed: $error', name: 'Dispute.ValidateForCreate');
      return error;
    }
    if (paymentTime != null &&
        !RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{1,3})?Z$').hasMatch(paymentTime!)) {
      final error = 'Payment time must be a valid ISO date if provided.';
      developer.log('Validation failed: $error, paymentTime=$paymentTime',
          name: 'Dispute.ValidateForCreate');
      return error;
    }
    if (vehicleNumber.isEmpty || !RegExp(vehicleNumberPattern).hasMatch(vehicleNumber)) {
      final error = 'Vehicle number must match pattern: XX12XX1234 (e.g., MH12AB1234).';
      developer.log('Validation failed: $error, vehicleNumber=$vehicleNumber',
          name: 'Dispute.ValidateForCreate');
      return error;
    }
    if (vehicleType.isEmpty) {
      final error = 'Vehicle type cannot be empty.';
      developer.log('Validation failed: $error', name: 'Dispute.ValidateForCreate');
      return error;
    }
    if (parkingDuration.isEmpty) {
      final error = 'Parking duration cannot be empty.';
      developer.log('Validation failed: $error', name: 'Dispute.ValidateForCreate');
      return error;
    }
    if (fareAmount < 0) {
      final error = 'Fare amount must be non-negative.';
      developer.log('Validation failed: $error', name: 'Dispute.ValidateForCreate');
      return error;
    }
    if (paymentAmount < 0) {
      final error = 'Payment amount must be non-negative.';
      developer.log('Validation failed: $error', name: 'Dispute.ValidateForCreate');
      return error;
    }
    if (disputeAmount < 0) {
      final error = 'Dispute amount must be non-negative.';
      developer.log('Validation failed: $error', name: 'Dispute.ValidateForCreate');
      return error;
    }
    if (disputeReason.isEmpty || disputeReason.length < 3 || disputeReason.length > 255) {
      final error = 'Dispute reason must be between 3 and 255 characters.';
      developer.log('Validation failed: $error', name: 'Dispute.ValidateForCreate');
      return error;
    }
    if (remarks != null && remarks!.length > 500) {
      final error = 'Remarks must not exceed 500 characters.';
      developer.log('Validation failed: $error', name: 'Dispute.ValidateForCreate');
      return error;
    }
    developer.log('Validation passed for Dispute', name: 'Dispute.ValidateForCreate');
    return null;
  }

  String? validateForUpdate() {
    if (disputeId == null || disputeId! < 1) {
      final error = 'Dispute ID must be a positive number.';
      developer.log('Validation failed: $error', name: 'Dispute.ValidateForUpdate');
      return error;
    }
    if (userId < 1) {
      final error = 'User ID must be a positive number.';
      developer.log('Validation failed: $error', name: 'Dispute.ValidateForUpdate');
      return error;
    }
    if (ticketId.isEmpty) {
      final error = 'Ticket ID cannot be empty.';
      developer.log('Validation failed: $error', name: 'Dispute.ValidateForUpdate');
      return error;
    }
    if (plazaId < 1) {
      final error = 'Plaza ID must be a positive number.';
      developer.log('Validation failed: $error', name: 'Dispute.ValidateForUpdate');
      return error;
    }
    if (ticketCreationTime.isEmpty ||
        !RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{1,3})?Z$').hasMatch(ticketCreationTime)) {
      final error = 'Ticket creation time must be a valid ISO date.';
      developer.log('Validation failed: $error, ticketCreationTime=$ticketCreationTime',
          name: 'Dispute.ValidateForUpdate');
      return error;
    }
    if (!validStatuses.contains(status)) {
      final error = 'Invalid status. Must be one of: ${validStatuses.join(", ")}';
      developer.log('Validation failed: $error', name: 'Dispute.ValidateForUpdate');
      return error;
    }
    if (paymentTime != null &&
        !RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{1,3})?Z$').hasMatch(paymentTime!)) {
      final error = 'Payment time must be a valid ISO date if provided.';
      developer.log('Validation failed: $error, paymentTime=$paymentTime',
          name: 'Dispute.ValidateForUpdate');
      return error;
    }
    if (vehicleNumber.isEmpty || !RegExp(vehicleNumberPattern).hasMatch(vehicleNumber)) {
      final error = 'Vehicle number must match pattern: XX12XX1234 (e.g., MH12AB1234).';
      developer.log('Validation failed: $error, vehicleNumber=$vehicleNumber',
          name: 'Dispute.ValidateForUpdate');
      return error;
    }
    if (vehicleType.isEmpty) {
      final error = 'Vehicle type cannot be empty.';
      developer.log('Validation failed: $error', name: 'Dispute.ValidateForUpdate');
      return error;
    }
    if (fareAmount < 0) {
      final error = 'Fare amount must be non-negative.';
      developer.log('Validation failed: $error', name: 'Dispute.ValidateForUpdate');
      return error;
    }
    if (paymentAmount < 0) {
      final error = 'Payment amount must be non-negative.';
      developer.log('Validation failed: $error', name: 'Dispute.ValidateForUpdate');
      return error;
    }
    if (disputeAmount < 0) {
      final error = 'Dispute amount must be non-negative.';
      developer.log('Validation failed: $error', name: 'Dispute.ValidateForUpdate');
      return error;
    }
    if (disputeReason.isEmpty || disputeReason.length < 3 || disputeReason.length > 255) {
      final error = 'Dispute reason must be between 3 and 255 characters.';
      developer.log('Validation failed: $error', name: 'Dispute.ValidateForUpdate');
      return error;
    }
    if (remarks != null && remarks!.length > 500) {
      final error = 'Remarks must not exceed 500 characters.';
      developer.log('Validation failed: $error', name: 'Dispute.ValidateForUpdate');
      return error;
    }
    developer.log('Validation passed for Dispute', name: 'Dispute.ValidateForUpdate');
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Dispute &&
        other.disputeId == disputeId &&
        other.userId == userId &&
        other.processedBy == processedBy &&
        other.ticketId == ticketId &&
        other.plazaId == plazaId &&
        other.ticketCreationTime == ticketCreationTime &&
        other.status == status &&
        other.paymentTime == paymentTime &&
        other.paymentMode == paymentMode &&
        other.vehicleNumber == vehicleNumber &&
        other.vehicleType == vehicleType &&
        other.parkingDuration == parkingDuration &&
        other.fareAmount == fareAmount &&
        other.paymentAmount == paymentAmount &&
        other.disputeAmount == disputeAmount &&
        other.disputeReason == disputeReason &&
        other.remarks == remarks &&
        other.latestRemark == latestRemark;
  }

  @override
  int get hashCode => Object.hash(
    disputeId,
    userId,
    processedBy,
    ticketId,
    plazaId,
    ticketCreationTime,
    status,
    paymentTime,
    paymentMode,
    vehicleNumber,
    vehicleType,
    parkingDuration,
    fareAmount,
    paymentAmount,
    disputeAmount,
    disputeReason,
    remarks,
    latestRemark,
  );

  @override
  String toString() {
    return 'Dispute(disputeId: $disputeId, userId: $userId, processedBy: $processedBy, ticketId: $ticketId, plazaId: $plazaId, ticketCreationTime: $ticketCreationTime, status: $status, paymentTime: $paymentTime, paymentMode: $paymentMode, vehicleNumber: $vehicleNumber, vehicleType: $vehicleType, parkingDuration: $parkingDuration, fareAmount: $fareAmount, paymentAmount: $paymentAmount, disputeAmount: $disputeAmount, disputeReason: $disputeReason, remarks: $remarks, latestRemark: $latestRemark)';
  }
}