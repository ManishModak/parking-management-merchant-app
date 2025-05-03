  class Lane {
    int? laneId; // Nullable: Doesn't exist before creation
    int plazaId;
    int? plazaLaneId; // Changed to nullable to handle null from API
    String laneName;
    String laneDirection;
    String laneType;
    String laneStatus;
    String? rfidReaderId;
    String? cameraId;
    String? wimId;
    String? boomerBarrierId;
    String? ledScreenId;
    String? magneticLoopId;
    String? recordStatus; // Nullable: Only required for update
  
    Lane({
      this.laneId,
      required this.plazaId,
      this.plazaLaneId, // No longer required
      required this.laneName,
      required this.laneDirection,
      required this.laneType,
      required this.laneStatus,
      this.rfidReaderId,
      this.cameraId,
      this.wimId,
      this.boomerBarrierId,
      this.ledScreenId,
      this.magneticLoopId,
      this.recordStatus,
    });
  
    factory Lane.fromJson(Map<String, dynamic> json) {
      int? tryParseInt(dynamic value) {
        if (value == null) return null;
        return int.tryParse(value.toString());
      }
  
      final parsedPlazaId = tryParseInt(json['plazaId']);
      final parsedPlazaLaneId = tryParseInt(json['plazaLaneId']);
  
      if (parsedPlazaId == null) {
        throw FormatException("Invalid or missing 'plazaId' in JSON: ${json['plazaId']}");
      }
  
      return Lane(
        laneId: tryParseInt(json['laneId']),
        plazaId: parsedPlazaId,
        plazaLaneId: parsedPlazaLaneId, // Accepts null
        laneName: json['LaneName'] as String? ?? 'Unknown', // Fallback for null
        laneDirection: json['LaneDirection'] as String? ?? 'Unknown',
        laneType: json['LaneType'] as String? ?? 'Unknown',
        laneStatus: json['LaneStatus'] as String? ?? 'Unknown',
        rfidReaderId: json['RFIDReaderID'] as String?,
        cameraId: json['CameraID'] as String?,
        wimId: json['WIMID'] as String?,
        boomerBarrierId: json['BoomerBarrierID'] as String?,
        ledScreenId: json['LEDScreenID'] as String?,
        magneticLoopId: json['MagneticLoopID'] as String?,
        recordStatus: json['RecordStatus'] as String?,
      );
    }
  
    // --- JSON Serialization Methods ---
  
    Map<String, dynamic> toJsonForCreate() {
      final Map<String, dynamic> json = {
        'plazaId': plazaId,
        'plazaLaneId': plazaLaneId,
        'LaneName': laneName,
        'LaneDirection': laneDirection,
        'LaneType': laneType,
        'LaneStatus': laneStatus,
      };
  
      if (rfidReaderId?.isNotEmpty == true) json['RFIDReaderID'] = rfidReaderId;
      if (cameraId?.isNotEmpty == true) json['CameraID'] = cameraId;
      if (wimId?.isNotEmpty == true) json['WIMID'] = wimId;
      if (boomerBarrierId?.isNotEmpty == true) json['BoomerBarrierID'] = boomerBarrierId;
      if (ledScreenId?.isNotEmpty == true) json['LEDScreenID'] = ledScreenId;
      if (magneticLoopId?.isNotEmpty == true) json['MagneticLoopID'] = magneticLoopId;
  
      return json;
    }
  
    Map<String, dynamic> toJsonForUpdate() {
      if (laneId == null) {
        throw StateError("Cannot serialize for update: laneId is null.");
      }
      if (recordStatus == null) {
        throw StateError("Cannot serialize for update: recordStatus is null.");
      }
  
      final Map<String, dynamic> json = {
        'laneId': laneId,
        'plazaId': plazaId,
        'plazaLaneId': plazaLaneId,
        'LaneName': laneName,
        'LaneDirection': laneDirection,
        'LaneType': laneType,
        'LaneStatus': laneStatus,
        'RecordStatus': recordStatus,
      };
  
      json['RFIDReaderID'] = rfidReaderId?.isNotEmpty == true ? rfidReaderId : null;
      json['CameraID'] = cameraId?.isNotEmpty == true ? cameraId : null;
      json['WIMID'] = wimId?.isNotEmpty == true ? wimId : null;
      json['BoomerBarrierID'] = boomerBarrierId?.isNotEmpty == true ? boomerBarrierId : null;
      json['LEDScreenID'] = ledScreenId?.isNotEmpty == true ? ledScreenId : null;
      json['MagneticLoopID'] = magneticLoopId?.isNotEmpty == true ? magneticLoopId : null;
  
      return json;
    }
  
    // --- Validation Constants ---
    static const List<String> validDirections = ['EAST', 'WEST', 'NORTH', 'SOUTH'];
    static const List<String> validTypes = ['entry', 'exit'];
    static const List<String> validStatuses = ['active', 'close', 'Temp-Inactive'];
    static const List<String> validRecordStatuses = ['active', 'disabled'];
  
    // --- Validation Helper for Optional IDs ---
    String? _validateOptionalId(String? value, String fieldName) {
      if (value != null) {
        if (value.isEmpty) {
          return '$fieldName cannot be empty if provided.';
        }
        if (value.length > 100) {
          return '$fieldName must not exceed 100 characters.';
        }
      }
      return null;
    }
  
    // --- Contextual Validation Methods ---
  
    String? validateForCreate() {
      if (plazaId < 0) {
        return 'Plaza ID must be a non-negative number (>= 0).';
      }
      if (plazaLaneId == null || plazaLaneId! < 1) {
        return 'Plaza Lane ID must be a positive number.';
      }
      if (laneName.isEmpty || laneName == 'Unknown') {
        return 'Lane name cannot be empty.';
      }
      if (laneName.length > 50) {
        return 'Lane name must not exceed 50 characters.';
      }
      if (!validDirections.contains(laneDirection.toUpperCase())) {
        return 'Invalid lane direction. Must be one of: ${validDirections.join(", ")}';
      }
      if (!validTypes.contains(laneType.toLowerCase())) {
        return 'Invalid lane type. Must be one of: ${validTypes.join(", ")}';
      }
      if (!validStatuses.contains(laneStatus)) {
        return 'Invalid lane status. Must be one of: ${validStatuses.join(", ")}';
      }
  
      var validationError = _validateOptionalId(rfidReaderId, 'RFID Reader ID');
      if (validationError != null) return validationError;
      validationError = _validateOptionalId(cameraId, 'Camera ID');
      if (validationError != null) return validationError;
      validationError = _validateOptionalId(wimId, 'WIM ID');
      if (validationError != null) return validationError;
      validationError = _validateOptionalId(boomerBarrierId, 'Boomer Barrier ID');
      if (validationError != null) return validationError;
      validationError = _validateOptionalId(ledScreenId, 'LED Screen ID');
      if (validationError != null) return validationError;
      validationError = _validateOptionalId(magneticLoopId, 'Magnetic Loop ID');
      if (validationError != null) return validationError;
  
      return null;
    }
  
    String? validateForUpdate() {
      if (laneId == null) {
        return 'Lane ID is required for update.';
      }
      if (laneId! < 1) {
        return 'Lane ID must be a positive number.';
      }
      if (plazaId < 1) {
        return 'Plaza ID must be a positive number (>= 1).';
      }
      if (plazaLaneId == null || plazaLaneId! < 1) {
        return 'Plaza Lane ID must be a positive number.';
      }
      if (laneName.isEmpty || laneName == 'Unknown') {
        return 'Lane name cannot be empty.';
      }
      if (laneName.length > 50) {
        return 'Lane name must not exceed 50 characters.';
      }
      if (!validDirections.contains(laneDirection.toUpperCase())) {
        return 'Invalid lane direction. Must be one of: ${validDirections.join(", ")}';
      }
      if (!validTypes.contains(laneType.toLowerCase())) {
        return 'Invalid lane type. Must be one of: ${validTypes.join(", ")}';
      }
      if (!validStatuses.contains(laneStatus)) {
        return 'Invalid lane status. Must be one of: ${validStatuses.join(", ")}';
      }
      if (recordStatus == null) {
        return 'Record Status is required for update.';
      }
      if (!validRecordStatuses.contains(recordStatus!.toLowerCase())) {
        return 'Invalid record status. Must be one of: ${validRecordStatuses.join(", ")}';
      }
  
      var validationError = _validateOptionalId(rfidReaderId, 'RFID Reader ID');
      if (validationError != null) return validationError;
      validationError = _validateOptionalId(cameraId, 'Camera ID');
      if (validationError != null) return validationError;
      validationError = _validateOptionalId(wimId, 'WIM ID');
      if (validationError != null) return validationError;
      validationError = _validateOptionalId(boomerBarrierId, 'Boomer Barrier ID');
      if (validationError != null) return validationError;
      validationError = _validateOptionalId(ledScreenId, 'LED Screen ID');
      if (validationError != null) return validationError;
      validationError = _validateOptionalId(magneticLoopId, 'Magnetic Loop ID');
      if (validationError != null) return validationError;
  
      return null;
    }
  
    // --- Equality and hashCode ---
    @override
    bool operator ==(Object other) {
      if (identical(this, other)) return true;
      return other is Lane &&
          other.laneId == laneId &&
          other.plazaId == plazaId &&
          other.plazaLaneId == plazaLaneId &&
          other.laneName == laneName &&
          other.laneDirection == laneDirection &&
          other.laneType == laneType &&
          other.laneStatus == laneStatus &&
          other.rfidReaderId == rfidReaderId &&
          other.cameraId == cameraId &&
          other.wimId == wimId &&
          other.boomerBarrierId == boomerBarrierId &&
          other.ledScreenId == ledScreenId &&
          other.magneticLoopId == magneticLoopId &&
          other.recordStatus == recordStatus;
    }
  
    @override
    int get hashCode {
      return Object.hash(
        laneId,
        plazaId,
        plazaLaneId,
        laneName,
        laneDirection,
        laneType,
        laneStatus,
        rfidReaderId,
        cameraId,
        wimId,
        boomerBarrierId,
        ledScreenId,
        magneticLoopId,
        recordStatus,
      );
    }
  
    // --- toString Method ---
    @override
    String toString() {
      return 'Lane(laneId: $laneId, plazaId: $plazaId, plazaLaneId: $plazaLaneId, laneName: $laneName, laneDirection: $laneDirection, laneType: $laneType, laneStatus: $laneStatus, rfidReaderId: $rfidReaderId, cameraId: $cameraId, wimId: $wimId, boomerBarrierId: $boomerBarrierId, ledScreenId: $ledScreenId, magneticLoopId: $magneticLoopId, recordStatus: $recordStatus)';
    }
  }