enum Status {
  open,
  rejected,
  complete,
  pending
}

class Ticket {
  final String? ticketId;
  final String? ticketRefId;
  final String plazaId;
  final int? fareId;
  final String entryLaneId;
  final String entryLaneDirection;
  final String floorId;
  final String slotId;
  final String vehicleNumber;
  final String vehicleType;
  final String createdBy;
  final DateTime createdTime;
  final String? entryTime;
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
  final int? disputeRaised;

  Ticket({
    this.ticketId,
    this.ticketRefId,
    required this.plazaId,
    this.fareId,
    required this.entryLaneId,
    required this.entryLaneDirection,
    required this.floorId,
    required this.slotId,
    required this.vehicleNumber,
    required this.vehicleType,
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
    this.disputeRaised = 1,
  })  : createdBy = createdBy ?? 'System',
        createdTime = createdTime ?? DateTime.now();

// Update fromJson
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      ticketId: json['ticket_id'] as String?,
      ticketRefId: json['ticket_ref_id'] as String?,
      plazaId: json['plaza_id'] as String,
      fareId: json['fareId'] as int?,
      entryLaneId: json['entry_lane_id'] as String,
      entryLaneDirection: json['entry_lane_direction'] as String,
      floorId: json['floor_id'] as String,
      slotId: json['slot_id'] as String,
      vehicleNumber: json['vehicle_number'] as String,
      vehicleType: json['vehicle_type'] as String,
      createdBy: json['created_by'] as String?,
      createdTime: DateTime.tryParse(json['created_time'] as String? ?? '') ?? DateTime.now(),
      entryTime: json['entry_time'] as String?,
      exitTime: json['exit_time'] != null ? DateTime.tryParse(json['exit_time'] as String) : null,
      status: _parseStatus(json['status'] as String? ?? 'pending'),
      capturedImages: json['captured_images'] != null
          ? List<String>.from(json['captured_images'])
          : json['captured_image'] != null
          ? [json['captured_image'] as String]
          : null,
      modifiedBy: json['modified_by'] as String?,
      modificationTime: json['modification_time'] != null
          ? DateTime.tryParse(json['modification_time'] as String)
          : null,
      remarks: json['remarks'] as String?,
      fareType: json['fare_type'] as String?,
      fareAmount: json['fare_amount'] != null
          ? double.tryParse(json['fare_amount'].toString())
          : null,
      totalCharges: json['total_transaction'] != null
          ? double.tryParse(json['total_transaction'].toString())
          : null,
      parkingDuration: json['duration'] as int?,
      disputeRaised: json['dispute_raised'] as int? ?? 1,
    );
  }

// Update copyWith
  Ticket copyWith({
    String? ticketId,
    String? ticketRefId,
    String? plazaId,
    int? fareId,
    String? entryLaneId,
    String? entryLaneDirection,
    String? floorId,
    String? slotId,
    String? vehicleNumber,
    String? vehicleType,
    String? createdBy,
    DateTime? createdTime,
    String? entryTime,
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
    int? disputeRaised,
  }) {
    return Ticket(
      ticketId: ticketId ?? this.ticketId,
      ticketRefId: ticketRefId ?? this.ticketRefId,
      plazaId: plazaId ?? this.plazaId,
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
      disputeRaised: disputeRaised ?? this.disputeRaised,
    );
  }

// Update toJson
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'ticket_id': ticketId,
      'ticket_ref_id': ticketRefId,
      'plaza_id': plazaId,
      'entry_lane_id': entryLaneId,
      'entry_lane_direction': entryLaneDirection,
      'floor_id': floorId,
      'slot_id': slotId,
      'vehicle_number': vehicleNumber,
      'vehicle_type': vehicleType,
      'created_by': createdBy,
      'created_time': createdTime.toIso8601String(),
      'entry_time': entryTime,
      'status': status.toString().split('.').last,
      'remarks': remarks,
      'fare_type': fareType,
      'fare_amount': fareAmount,
      'total_transaction': totalCharges,
      'duration': parkingDuration,
    };

    if (fareId != null) {
      json['fareId'] = fareId;
    }
    if (exitTime != null) {
      json['exit_time'] = exitTime!.toIso8601String();
    }
    if (capturedImages != null && capturedImages!.isNotEmpty) {
      json['captured_images'] = capturedImages;
    }
    if (modifiedBy != null) {
      json['modified_by'] = modifiedBy;
    }
    if (modificationTime != null) {
      json['modification_time'] = modificationTime!.toIso8601String();
    }

    return json;
  }

// Update toCreateRequest
  Map<String, dynamic> toCreateRequest() {
    return {
      'plaza_id': plazaId,
      'entry_lane_id': entryLaneId,
      'entry_lane_direction': entryLaneDirection,
      'floor_id': floorId,
      'slot_id': slotId,
      'vehicle_number': vehicleNumber,
      'vehicle_type': vehicleType,
      'entry_time': entryTime,
      'status': Status.open.toString().split('.').last,
      'captured_images': capturedImages,
      'remarks': remarks ?? '',
    };
  }

// Update toModifyRequest
  Map<String, dynamic> toModifyRequest() {
    return {
      'plaza_id': plazaId,
      'vehicle_number': vehicleNumber,
      'vehicle_type': vehicleType,
      'modified_by': modifiedBy ?? 'System',
      'modification_time': DateTime.now().toIso8601String(),
      'status': Status.pending.toString().split('.').last,
      'captured_images': capturedImages,
      'remarks': remarks ?? '',
    };
  }

// Update toString
  @override
  String toString() {
    return 'Ticket{ticketId: $ticketId, ticketRefId: $ticketRefId, plazaId: $plazaId, fareId: $fareId, '
        'entryLaneId: $entryLaneId, entryLaneDirection: $entryLaneDirection, '
        'floorId: $floorId, slotId: $slotId, vehicleNumber: $vehicleNumber, '
        'vehicleType: $vehicleType, status: $status, capturedImages: $capturedImages, '
        'fareType: $fareType, fareAmount: $fareAmount, totalCharges: $totalCharges, '
        'parkingDuration: $parkingDuration, disputeRaised: $disputeRaised, remarks: $remarks}';
  }

  static Status _parseStatus(String? statusStr) {
    if (statusStr == null) return Status.pending;
    try {
      return Status.values.firstWhere(
            (e) => e.toString().split('.').last.toLowerCase() == statusStr.toLowerCase(),
        orElse: () => Status.pending,
      );
    } catch (e) {
      return Status.pending;
    }
  }
}