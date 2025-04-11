enum Status {
  open,
  rejected,
  complete,
  pending
}

class Ticket {
  final String? ticketId;
  final String? ticketRefId;
  final String? plazaId;       // Kept nullable
  final String? plazaName;     // <-- NEW FIELD: Added plaza name (optional)
  final int? fareId;
  final String entryLaneId;
  final String? entryLaneDirection;
  final String? floorId;
  final String? slotId;
  final String? vehicleNumber;
  final String? vehicleType;
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
  final String? channelId;
  final String? requestType;
  final String? cameraId;
  final String? cameraReadTime;

  Ticket({
    this.ticketId,
    this.ticketRefId,
    this.plazaId,
    this.plazaName, // <-- NEW FIELD: Added to constructor
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
    this.disputeRaised = 1,
    this.channelId,
    this.requestType,
    this.cameraId,
    this.cameraReadTime,
  })  : createdBy = createdBy ?? 'System',
        createdTime = createdTime ?? DateTime.now();

  factory Ticket.fromJson(Map<String, dynamic> json) {
    // --- Robust plazaId parsing for nullable field ---
    final dynamic plazaIdValue = json['plazaId'];
    final String? plazaIdString = plazaIdValue?.toString();

    // --- Parsing for other potentially non-string fields ---
    final dynamic floorIdValue = json['floor_id'];
    final String? floorIdString = floorIdValue?.toString();

    final dynamic slotIdValue = json['slot_id'];
    final String? slotIdString = slotIdValue?.toString();

    // --- Parsing helpers ---
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      return double.tryParse(value.toString());
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    DateTime? parseDateTime(dynamic value) {
      if (value == null || value is! String || value.isEmpty) return null;
      return DateTime.tryParse(value);
    }

    DateTime parseCreatedTime(dynamic value) {
      final parsed = parseDateTime(value);
      return parsed ?? DateTime.now();
    }

    List<String>? parseImages(dynamic imagesJson, dynamic imageJson) {
      if (imagesJson != null && imagesJson is List) {
        return imagesJson.map((item) => item?.toString()).where((item) => item != null).cast<String>().toList();
      } else if (imageJson != null) {
        return [imageJson.toString()];
      }
      return null;
    }

    return Ticket(
      ticketId: json['ticket_id'] as String?,
      ticketRefId: json['ticket_ref_id'] as String?,
      plazaId: plazaIdString,
      // <-- NEW FIELD: Attempt to read plaza name (might be null) -->
      // Check for both common casing conventions
      plazaName: json['plazaName'] as String? ?? json['plaza_name'] as String?,
      // <-- END NEW FIELD -->
      fareId: parseInt(json['fareId']),
      entryLaneId: json['entry_lane_id'] as String? ?? 'UNKNOWN_LANE',
      entryLaneDirection: json['entry_lane_direction'] as String?,
      floorId: floorIdString,
      slotId: slotIdString,
      vehicleNumber: json['vehicle_number'] as String?,
      vehicleType: json['vehicle_type'] as String?,
      createdBy: json['created_by'] as String? ?? 'System',
      createdTime: parseCreatedTime(json['created_time']),
      entryTime: json['entry_time'] as String?,
      exitTime: parseDateTime(json['exit_time']),
      status: _parseStatus(json['status'] as String?),
      capturedImages: parseImages(json['captured_images'], json['captured_image']),
      modifiedBy: json['modified_by'] as String?,
      modificationTime: parseDateTime(json['modification_time']),
      remarks: json['remarks'] as String?,
      fareType: json['fare_type'] as String?,
      fareAmount: parseDouble(json['fare_amount']),
      totalCharges: parseDouble(json['total_transaction']),
      parkingDuration: parseInt(json['duration']),
      disputeRaised: parseInt(json['dispute_raised']) ?? 1,
      channelId: json['channel_id'] as String?,
      requestType: json['request_type'] as String?,
      cameraId: json['camera_id'] as String?,
      cameraReadTime: json['cameraReadTime'] as String?,
    );
  }

  Ticket copyWith({
    String? ticketId,
    String? ticketRefId,
    String? plazaId,
    String? plazaName, // <-- NEW FIELD: Added to copyWith
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
    String? channelId,
    String? requestType,
    String? cameraId,
    String? cameraReadTime,
  }) {
    return Ticket(
      ticketId: ticketId ?? this.ticketId,
      ticketRefId: ticketRefId ?? this.ticketRefId,
      plazaId: plazaId ?? this.plazaId,
      plazaName: plazaName ?? this.plazaName, // <-- NEW FIELD: Handle copyWith
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
      channelId: channelId ?? this.channelId,
      requestType: requestType ?? this.requestType,
      cameraId: cameraId ?? this.cameraId,
      cameraReadTime: cameraReadTime ?? this.cameraReadTime,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'ticket_id': ticketId,
      'ticket_ref_id': ticketRefId,
      'plaza_id': plazaId,
      'plaza_name': plazaName, // <-- NEW FIELD: Add to JSON output (will be null if not set)
      'fareId': fareId,
      'entry_lane_id': entryLaneId,
      'entry_lane_direction': entryLaneDirection,
      'floor_id': floorId,
      'slot_id': slotId,
      'vehicle_number': vehicleNumber,
      'vehicle_type': vehicleType,
      'created_by': createdBy,
      'created_time': createdTime.toIso8601String(),
      'entry_time': entryTime,
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
      'dispute_raised': disputeRaised,
      'channel_id': channelId,
      'request_type': requestType,
      'camera_id': cameraId,
      'cameraReadTime': cameraReadTime,
    };
    // json.removeWhere((key, value) => value == null); // Optional: remove nulls
    return json;
  }

  Map<String, dynamic> toCreateRequest() {
    final Map<String, dynamic> json = {
      'plaza_id': plazaId,
      // Note: Typically plaza_name is not sent *in* a create request,
      // it's usually derived data based on plaza_id. Included here just in case.
      'plaza_name': plazaName, // <-- NEW FIELD: Included (might often be null)
      'entry_lane_id': entryLaneId,
      'entry_time': entryTime ?? DateTime.now().toIso8601String(),
      'channel_id': channelId ?? '3',
      'request_type': requestType ?? '0',
      'camera_id': cameraId,
      'cameraReadTime': cameraReadTime,
      if (vehicleNumber != null) 'vehicle_number': vehicleNumber,
      if (vehicleType != null) 'vehicle_type': vehicleType,
      if (floorId != null) 'floor_id': floorId,
      if (slotId != null) 'slot_id': slotId,
      'status': Status.pending.toString().split('.').last,
      if (capturedImages != null && capturedImages!.isNotEmpty) 'captured_images': capturedImages,
      'remarks': remarks ?? '',
    };
    // json.removeWhere((key, value) => value == null); // Optional: remove nulls
    return json;
  }

  Map<String, dynamic> toModifyRequest() {
    final Map<String, dynamic> json = {
      'plaza_id': plazaId,
      // Note: plaza_name is unlikely to be part of a modify request payload
      'plaza_name': plazaName, // <-- NEW FIELD: Included (might often be null/ignored by API)
      'entry_lane_id': entryLaneId,
      if (vehicleNumber != null) 'vehicle_number': vehicleNumber,
      if (vehicleType != null) 'vehicle_type': vehicleType,
      if (floorId != null) 'floor_id': floorId,
      if (slotId != null) 'slot_id': slotId,
      'modified_by': modifiedBy ?? 'System',
      'modification_time': DateTime.now().toIso8601String(),
      'status': status?.toString().split('.').last ?? Status.pending.toString().split('.').last,
      if (capturedImages != null && capturedImages!.isNotEmpty) 'captured_images': capturedImages,
      'remarks': remarks ?? '',
    };
    // json.removeWhere((key, value) => value == null); // Optional: remove nulls
    return json;
  }


  @override
  String toString() {
    // Updated toString to include plazaName
    return 'Ticket{ticketId: $ticketId, ticketRefId: $ticketRefId, plazaId: $plazaId, plazaName: $plazaName, fareId: $fareId, ' // <-- Added plazaName
        'entryLaneId: $entryLaneId, entryLaneDirection: $entryLaneDirection, '
        'floorId: $floorId, slotId: $slotId, vehicleNumber: $vehicleNumber, '
        'vehicleType: $vehicleType, createdBy: $createdBy, createdTime: $createdTime, entryTime: $entryTime, exitTime: $exitTime, '
        'status: $status, capturedImages: $capturedImages, modifiedBy: $modifiedBy, modificationTime: $modificationTime, '
        'remarks: $remarks, fareType: $fareType, fareAmount: $fareAmount, totalCharges: $totalCharges, '
        'parkingDuration: $parkingDuration, disputeRaised: $disputeRaised, '
        'channelId: $channelId, requestType: $requestType, cameraId: $cameraId, cameraReadTime: $cameraReadTime}';
  }

  // Helper function to parse Status enum safely from a String
  static Status _parseStatus(String? statusStr) {
    if (statusStr == null) return Status.pending;
    try {
      return Status.values.firstWhere(
              (e) => e.toString().split('.').last.toLowerCase() == statusStr.toLowerCase(),
          orElse: () {
            print("Warning: Unknown status string '$statusStr' received. Defaulting to 'pending'.");
            return Status.pending;
          }
      );
    } catch (e) {
      print("Error parsing status '$statusStr': $e. Defaulting to 'pending'.");
      return Status.pending;
    }
  }
}
