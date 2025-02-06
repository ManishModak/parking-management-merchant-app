class Lane {
  String? laneId;
  int plazaId;
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
  String? recordStatus;

  Lane({
    this.laneId,
    required this.plazaId,
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
    return Lane(
      laneId: json['laneId']?.toString(),
      plazaId: int.parse(json['plazaId'].toString()),
      laneName: json['LaneName'] as String,
      laneDirection: json['LaneDirection'] as String,
      laneType: json['LaneType'] as String,
      laneStatus: json['LaneStatus'] as String,
      rfidReaderId: json['RFIDReaderID'] as String?,
      cameraId: json['CameraID'] as String?,
      wimId: json['WIMID'] as String?,
      boomerBarrierId: json['BoomerBarrierID'] as String?,
      ledScreenId: json['LEDScreenID'] as String?,
      magneticLoopId: json['MagneticLoopID'] as String?,
      recordStatus: json['RecordStatus'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'plazaId': plazaId,
      'LaneName': laneName,
      'LaneDirection': laneDirection,
      'LaneType': laneType,
      'LaneStatus': laneStatus,
    };

    if (laneId != null) json['laneId'] = laneId;
    // Only add non-empty strings
    if (rfidReaderId?.isNotEmpty == true) json['RFIDReaderID'] = rfidReaderId;
    if (cameraId?.isNotEmpty == true) json['CameraID'] = cameraId;
    if (wimId?.isNotEmpty == true) json['WIMID'] = wimId;
    if (boomerBarrierId?.isNotEmpty == true) json['BoomerBarrierID'] = boomerBarrierId;
    if (ledScreenId?.isNotEmpty == true) json['LEDScreenID'] = ledScreenId;
    if (magneticLoopId?.isNotEmpty == true) json['MagneticLoopID'] = magneticLoopId;
    if (recordStatus != null) json['RecordStatus'] = recordStatus;

    return json;
  }

  static const List<String> validDirections = ['EAST', 'WEST', 'NORTH', 'SOUTH'];
  static const List<String> validTypes = ['entry', 'exit'];
  static const List<String> validStatuses = ['active', 'close', 'Temp-Inactive'];

  String? validate() {
    if (plazaId < 1 || plazaId > 100) {
      return 'Plaza ID must be between 1 and 100';
    }

    if (laneName.isEmpty || laneName.length > 50) {
      return 'Lane name must be between 1 and 50 characters';
    }

    if (!validDirections.contains(laneDirection)) {
      return 'Invalid lane direction. Must be one of: ${validDirections.join(", ")}';
    }

    if (!validTypes.contains(laneType)) {
      return 'Invalid lane type. Must be one of: ${validTypes.join(", ")}';
    }

    if (!validStatuses.contains(laneStatus)) {
      return 'Invalid lane status. Must be one of: ${validStatuses.join(", ")}';
    }

    // Optional field validations - only check if value is provided
    if (rfidReaderId?.isNotEmpty == true && rfidReaderId!.length > 100) {
      return 'RFID Reader ID must not exceed 100 characters';
    }

    if (cameraId?.isNotEmpty == true && cameraId!.length > 100) {
      return 'Camera ID must not exceed 100 characters';
    }

    if (wimId?.isNotEmpty == true && wimId!.length > 100) {
      return 'WIM ID must not exceed 100 characters';
    }

    if (boomerBarrierId?.isNotEmpty == true && boomerBarrierId!.length > 100) {
      return 'Boomer Barrier ID must not exceed 100 characters';
    }

    if (ledScreenId?.isNotEmpty == true && ledScreenId!.length > 100) {
      return 'LED Screen ID must not exceed 100 characters';
    }

    if (magneticLoopId?.isNotEmpty == true && magneticLoopId!.length > 100) {
      return 'Magnetic Loop ID must not exceed 100 characters';
    }

    return null;
  }

  Lane copyWith({
    String? laneId,
    int? plazaId,
    String? laneName,
    String? laneDirection,
    String? laneType,
    String? laneStatus,
    String? rfidReaderId,
    String? cameraId,
    String? wimId,
    String? boomerBarrierId,
    String? ledScreenId,
    String? magneticLoopId,
    String? recordStatus,
  }) {
    return Lane(
      laneId: laneId ?? this.laneId,
      plazaId: plazaId ?? this.plazaId,
      laneName: laneName ?? this.laneName,
      laneDirection: laneDirection ?? this.laneDirection,
      laneType: laneType ?? this.laneType,
      laneStatus: laneStatus ?? this.laneStatus,
      rfidReaderId: rfidReaderId ?? this.rfidReaderId,
      cameraId: cameraId ?? this.cameraId,
      wimId: wimId ?? this.wimId,
      boomerBarrierId: boomerBarrierId ?? this.boomerBarrierId,
      ledScreenId: ledScreenId ?? this.ledScreenId,
      magneticLoopId: magneticLoopId ?? this.magneticLoopId,
      recordStatus: recordStatus ?? this.recordStatus,
    );
  }
}