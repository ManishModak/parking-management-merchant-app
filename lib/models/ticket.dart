enum Status {
  Open,
  Rejected,
  Completed,
}

class TicketPayment {
  final int? id;
  final String? ticketId;
  final int? plazaId;
  final String? orderId;
  final String? ticketRefId;
  final String? transactionId;
  final String? transactionStatus;
  final double? transactionAmount;
  final double? charges;
  final double? gstAmount;
  final double? totalTransaction;
  final double? fareAmount;
  final String? paymentId;
  final DateTime? paymentTime;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? paymentRemark;
  final String? instrumentNo;
  final String? instrumentType;
  final String? instrumentSubtype;
  final String? vehicleNumber;
  final DateTime? entryTime;
  final DateTime? exitTime;
  final int? duration;
  final String? fareType;
  final String? createdBy;

  TicketPayment({
    this.id,
    this.ticketId,
    this.plazaId,
    this.orderId,
    this.ticketRefId,
    this.transactionId,
    this.transactionStatus,
    this.transactionAmount,
    this.charges,
    this.gstAmount,
    this.totalTransaction,
    this.fareAmount,
    this.paymentId,
    this.paymentTime,
    this.paymentMethod,
    this.paymentStatus,
    this.paymentRemark,
    this.instrumentNo,
    this.instrumentType,
    this.instrumentSubtype,
    this.vehicleNumber,
    this.entryTime,
    this.exitTime,
    this.duration,
    this.fareType,
    this.createdBy,
  });

  factory TicketPayment.fromJson(Map<String, dynamic> json) {
    double? _parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) {
        if (value.trim().isEmpty) return null;
        return double.tryParse(value);
      }
      return null;
    }

    return TicketPayment(
      id: json['id'] as int?,
      ticketId: json['ticket_id'] as String?,
      plazaId: json['plazaId'] as int?,
      orderId: json['order_id'] as String?,
      ticketRefId: json['ticket_ref_id'] as String?,
      transactionId: json['transaction_id'] as String?,
      transactionStatus: json['transaction_status'] as String?,
      transactionAmount: _parseDouble(json['transaction_amount']),
      charges: _parseDouble(json['charges']),
      gstAmount: _parseDouble(json['gst_amount']),
      totalTransaction: _parseDouble(json['total_transaction']),
      fareAmount: _parseDouble(json['fare_amount']),
      paymentId: json['payment_id'] as String?,
      paymentTime: json['payment_time'] != null ? DateTime.parse(json['payment_time'] as String) : null,
      paymentMethod: json['payment_method'] as String?,
      paymentStatus: json['payment_status'] as String?,
      paymentRemark: json['payment_remark'] as String?,
      instrumentNo: json['instrument_no'] as String?,
      instrumentType: json['instrument_type'] as String?,
      instrumentSubtype: json['instrument_subtype'] as String?,
      vehicleNumber: json['vehicle_number'] as String?,
      entryTime: json['entry_time'] != null ? DateTime.parse(json['entry_time'] as String) : null,
      exitTime: json['exit_time'] != null ? DateTime.parse(json['exit_time'] as String) : null,
      duration: json['duration'] as int?,
      fareType: json['fare_type'] as String?,
      createdBy: json['created_by'] as String?,
    );
  }
}

class Ticket {
  final String? ticketId;
  final String? ticketRefId;
  final int? plazaId;
  final String? plazaName;
  final int? fareId;
  final String entryLaneId;
  final String? entryLaneDirection;
  final String? floorId;
  final String? slotId;
  final String? vehicleNumber;
  final String? vehicleType;
  final String createdBy;
  final DateTime createdTime;
  final DateTime? entryTime;
  final DateTime? exitTime;
  final Status? status;
  final List<String>? capturedImages;
  final String? modifiedBy;
  final DateTime? modificationTime;
  final String? remarks;
  final String? fareType;
  final double? fareAmount;
  final double? totalCharges;
  final int? parkingDuration;
  final String? disputeStatus;
  final int? disputeId; // Changed to int?
  final String? paymentMode;
  final List<TicketPayment>? payments;
  final String? geoLatitude;
  final String? geoLongitude;

  Ticket({
    this.ticketId,
    this.ticketRefId,
    this.plazaId,
    this.plazaName,
    this.fareId,
    required this.entryLaneId,
    this.entryLaneDirection,
    this.floorId,
    this.slotId,
    this.vehicleNumber,
    this.vehicleType,
    String? createdBy,
    DateTime? createdTime,
    this.entryTime,
    this.exitTime,
    this.status,
    this.capturedImages,
    this.modifiedBy,
    this.modificationTime,
    this.remarks,
    this.fareType,
    this.fareAmount,
    this.totalCharges,
    this.parkingDuration,
    this.disputeStatus = 'Not Raised',
    this.disputeId,
    this.paymentMode,
    this.payments,
    this.geoLatitude,
    this.geoLongitude,
  })  : createdBy = createdBy ?? 'System',
        createdTime = createdTime ?? DateTime.now();

  factory Ticket.fromJson(Map<String, dynamic> json) {
    final paymentsList = (json['payments'] as List<dynamic>?)
        ?.map((p) => TicketPayment.fromJson(p as Map<String, dynamic>))
        .toList();
    TicketPayment? successfulPayment;
    if (paymentsList != null && paymentsList.isNotEmpty) {
      successfulPayment = paymentsList.firstWhere(
            (p) => p.paymentStatus == 'Paid',
        orElse: () => paymentsList.first,
      );
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    DateTime? parseDateTime(dynamic value) {
      if (value == null || value is! String || value.isEmpty) return null;
      return DateTime.tryParse(value);
    }

    DateTime parseCreatedTime(dynamic value) {
      final parsed = parseDateTime(value);
      return parsed ?? DateTime.now();
    }

    List<String>? parseImages(dynamic capturedImagesJson) {
      if (capturedImagesJson != null && capturedImagesJson is List) {
        return List<String>.from(capturedImagesJson);
      }
      return null;
    }

    return Ticket(
      ticketId: json['ticket_id'] as String?,
      ticketRefId: json['ticket_ref_id'] as String?,
      plazaId: parseInt(json['plazaId']),
      plazaName: json['plazaName'] as String? ?? json['plaza_name'] as String?,
      fareId: parseInt(json['fareId']),
      entryLaneId: json['entry_lane_id'] as String? ?? 'UNKNOWN_LANE',
      entryLaneDirection: json['entry_lane_direction'] as String?,
      floorId: json['floor_id'] as String?,
      slotId: json['slot_id'] as String?,
      vehicleNumber: json['vehicle_number'] as String?,
      vehicleType: json['vehicle_type'] as String?,
      createdBy: json['created_by'] as String? ?? 'System',
      createdTime: parseCreatedTime(json['created_time']),
      entryTime: parseDateTime(json['entry_time']),
      exitTime: successfulPayment?.exitTime ?? parseDateTime(json['exit_time']),
      status: _parseStatus(json['status'] as String?),
      capturedImages: parseImages(json['captured_images']),
      modifiedBy: json['modified_by'] as String?,
      modificationTime: parseDateTime(json['modification_time']),
      remarks: json['remarks'] as String?,
      fareType: successfulPayment?.fareType ?? json['fare_type'] as String?,
      fareAmount: successfulPayment?.fareAmount ?? parseDouble(json['fare_amount']),
      totalCharges: successfulPayment?.totalTransaction ?? parseDouble(json['total_transaction']),
      parkingDuration: successfulPayment?.duration ?? parseInt(json['duration']),
      disputeStatus: json['dispute_status'] as String? ?? 'Not Raised',
      disputeId: parseInt(json['disputeId']), // Updated to use parseInt
      paymentMode: successfulPayment?.paymentMethod ?? json['payment_method'] as String?,
      payments: paymentsList,
      geoLatitude: json['geo_latitude'] as String?,
      geoLongitude: json['geo_longitude'] as String?,
    );
  }

  Ticket copyWith({
    String? ticketId,
    String? ticketRefId,
    int? plazaId,
    String? plazaName,
    int? fareId,
    String? entryLaneId,
    String? entryLaneDirection,
    String? floorId,
    String? slotId,
    String? vehicleNumber,
    String? vehicleType,
    String? createdBy,
    DateTime? createdTime,
    DateTime? entryTime,
    DateTime? exitTime,
    Status? status,
    List<String>? capturedImages,
    String? modifiedBy,
    DateTime? modificationTime,
    String? remarks,
    String? fareType,
    double? fareAmount,
    double? totalCharges,
    int? parkingDuration,
    String? disputeStatus,
    int? disputeId, // Updated to int?
    String? paymentMode,
    List<TicketPayment>? payments,
    String? geoLatitude,
    String? geoLongitude,
  }) {
    return Ticket(
      ticketId: ticketId ?? this.ticketId,
      ticketRefId: ticketRefId ?? this.ticketRefId,
      plazaId: plazaId ?? this.plazaId,
      plazaName: plazaName ?? this.plazaName,
      fareId: fareId ?? this.fareId,
      entryLaneId: entryLaneId ?? this.entryLaneId,
      entryLaneDirection: entryLaneDirection ?? this.entryLaneDirection,
      floorId: floorId ?? this.floorId,
      slotId: slotId ?? this.slotId,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      createdBy: createdBy ?? this.createdBy,
      createdTime: createdTime ?? this.createdTime,
      entryTime: entryTime ?? this.entryTime,
      exitTime: exitTime ?? this.exitTime,
      status: status ?? this.status,
      capturedImages: capturedImages ?? this.capturedImages,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      modificationTime: modificationTime ?? this.modificationTime,
      remarks: remarks ?? this.remarks,
      fareType: fareType ?? this.fareType,
      fareAmount: fareAmount ?? this.fareAmount,
      totalCharges: totalCharges ?? this.totalCharges,
      parkingDuration: parkingDuration ?? this.parkingDuration,
      disputeStatus: disputeStatus ?? this.disputeStatus,
      disputeId: disputeId ?? this.disputeId,
      paymentMode: paymentMode ?? this.paymentMode,
      payments: payments ?? this.payments,
      geoLatitude: geoLatitude ?? this.geoLatitude,
      geoLongitude: geoLongitude ?? this.geoLongitude,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'ticket_id': ticketId,
      'ticket_ref_id': ticketRefId,
      'plazaId': plazaId,
      'plaza_name': plazaName,
      'fareId': fareId,
      'entry_lane_id': entryLaneId,
      'entry_lane_direction': entryLaneDirection,
      'floor_id': floorId,
      'slot_id': slotId,
      'vehicle_number': vehicleNumber,
      'vehicle_type': vehicleType,
      'created_by': createdBy,
      'created_time': createdTime.toIso8601String(),
      'entry_time': entryTime?.toIso8601String(),
      'exit_time': exitTime?.toIso8601String(),
      'status': status?.toString().split('.').last,
      'captured_images': capturedImages,
      'modified_by': modifiedBy,
      'modification_time': modificationTime?.toIso8601String(),
      'remarks': remarks,
      'fare_type': fareType,
      'fare_amount': fareAmount,
      'total_transaction': totalCharges,
      'duration': parkingDuration,
      'dispute_status': disputeStatus,
      'disputeId': disputeId, // Updated to int?
      'payment_method': paymentMode,
      'geo_latitude': geoLatitude,
      'geo_longitude': geoLongitude,
      'payments': payments?.map((p) => {
        'id': p.id,
        'ticket_id': p.ticketId,
        'plazaId': p.plazaId,
        'order_id': p.orderId,
        'ticket_ref_id': p.ticketRefId,
        'transaction_id': p.transactionId,
        'transaction_status': p.transactionStatus,
        'transaction_amount': p.transactionAmount,
        'charges': p.charges,
        'gst_amount': p.gstAmount,
        'total_transaction': p.totalTransaction,
        'fare_amount': p.fareAmount,
        'payment_id': p.paymentId,
        'payment_time': p.paymentTime?.toIso8601String(),
        'payment_method': p.paymentMethod,
        'payment_status': p.paymentStatus,
        'payment_remark': p.paymentRemark,
        'instrument_no': p.instrumentNo,
        'instrument_type': p.instrumentType,
        'instrument_subtype': p.instrumentSubtype,
        'vehicle_number': p.vehicleNumber,
        'entry_time': p.entryTime?.toIso8601String(),
        'exit_time': p.exitTime?.toIso8601String(),
        'duration': p.duration,
        'fare_type': p.fareType,
        'created_by': p.createdBy,
      }).toList(),
    };
    return json;
  }

  Map<String, dynamic> toCreateRequest() {
    final Map<String, dynamic> json = {
      'plazaId': plazaId,
      'plaza_name': plazaName,
      'entry_lane_id': entryLaneId,
      'entry_time': entryTime?.toIso8601String() ?? DateTime.now().toIso8601String(),
      if (vehicleNumber != null) 'vehicle_number': vehicleNumber,
      if (vehicleType != null) 'vehicle_type': vehicleType,
      if (floorId != null) 'floor_id': floorId,
      if (slotId != null) 'slot_id': slotId,
      'status': Status.Open.toString().split('.').last,
      'entry_lane_direction': entryLaneDirection ?? 'Unknown',
      if (capturedImages != null && capturedImages!.isNotEmpty) 'captured_images': capturedImages,
      'remarks': remarks ?? '',
      'geo_latitude': geoLatitude,
      'geo_longitude': geoLongitude,
      if (disputeId != null) 'disputeId': disputeId, // Updated to int?
    };
    return json;
  }

  Map<String, dynamic> toModifyRequest() {
    final Map<String, dynamic> json = {
      'plazaId': plazaId,
      'plaza_name': plazaName,
      'entry_lane_id': entryLaneId,
      if (vehicleNumber != null) 'vehicle_number': vehicleNumber,
      if (vehicleType != null) 'vehicle_type': vehicleType,
      if (floorId != null) 'floor_id': floorId,
      if (slotId != null) 'slot_id': slotId,
      'modified_by': modifiedBy ?? 'System',
      'modification_time': DateTime.now().toIso8601String(),
      'status': status?.toString().split('.').last ?? Status.Open.toString().split('.').last,
      'entry_lane_direction': entryLaneDirection ?? 'Unknown',
      if (capturedImages != null && capturedImages!.isNotEmpty) 'captured_images': capturedImages,
      'remarks': remarks ?? '',
      if (disputeId != null) 'disputeId': disputeId, // Updated to int?
    };
    return json;
  }

  @override
  String toString() {
    return 'Ticket{ticketId: $ticketId, ticketRefId: $ticketRefId, plazaId: $plazaId, plazaName: $plazaName, fareId: $fareId, '
        'entryLaneId: $entryLaneId, entryLaneDirection: $entryLaneDirection, '
        'floorId: $floorId, slotId: $slotId, vehicleNumber: $vehicleNumber, '
        'vehicleType: $vehicleType, createdBy: $createdBy, createdTime: $createdTime, entryTime: $entryTime, exitTime: $exitTime, '
        'status: $status, capturedImages: $capturedImages, modifiedBy: $modifiedBy, modificationTime: $modificationTime, '
        'remarks: $remarks, fareType: $fareType, fareAmount: $fareAmount, totalCharges: $totalCharges, '
        'parkingDuration: $parkingDuration, disputeStatus: $disputeStatus, disputeId: $disputeId, '
        'paymentMode: $paymentMode, payments: $payments}';
  }

  static Status _parseStatus(String? statusStr) {
    if (statusStr == null) return Status.Open;
    try {
      return Status.values.firstWhere(
            (e) => e.toString().split('.').last.toLowerCase() == statusStr.toLowerCase(),
        orElse: () {
          print("Warning: Unknown status string '$statusStr' received. Defaulting to 'Open'.");
          return Status.Open;
        },
      );
    } catch (e) {
      print("Error parsing status '$statusStr': $e. Defaulting to 'Open'.");
      return Status.Open;
    }
  }
}