/// A model class representing fare details for a parking plaza.
class PlazaFare {
  final int? fareId;
  final int plazaId;
  final String vehicleType;
  final String fareType;
  int? baseHours;
  double fareRate;
  double? discountRate;
  DateTime startEffectDate;
  DateTime? endEffectDate;
  final bool isDeleted;
  int? from; // Already Added for Progressive fare type
  int? toCustom; // Already Added for Progressive fare type

  PlazaFare({
    this.fareId,
    required this.plazaId,
    required this.vehicleType,
    required this.fareType,
    this.baseHours,
    required this.fareRate,
    this.discountRate,
    required this.startEffectDate,
    this.endEffectDate,
    this.isDeleted = false,
    this.from, // Already Added
    this.toCustom, // Already Added
  });

  /// Creates a [PlazaFare] instance from a JSON map.
  factory PlazaFare.fromJson(Map<String, dynamic> json) {
    return PlazaFare(
      fareId: json['fareId'],
      plazaId: json['plazaId'],
      vehicleType: json['vehicleType'],
      fareType: json['FareType'],
      baseHours: json['baseHours'],
      fareRate: double.parse(json['fareRate'].toString()),
      discountRate: json['discountRate'] != null
          ? double.parse(json['discountRate'].toString())
          : null,
      startEffectDate: DateTime.parse(json['startEffectDate']),
      endEffectDate: json['endEffectDate'] != null
          ? DateTime.parse(json['endEffectDate'])
          : null,
      isDeleted: json['isDeleted'] ?? false,
      from: json['from'],
      toCustom: json['toCustom'],
    );
  }

  /// Converts the [PlazaFare] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      if (fareId != null) 'fareId': fareId,
      'plazaId': plazaId,
      'vehicleType': vehicleType,
      'FareType': fareType,
      if (baseHours != null) 'baseHours': baseHours,
      'fareRate': fareRate,
      if (discountRate != null) 'discountRate': discountRate,
      'startEffectDate': startEffectDate.toIso8601String().split('T')[0],
      if (endEffectDate != null)
        'endEffectDate': endEffectDate!.toIso8601String().split('T')[0],
      if (from != null) 'from': from,
      if (toCustom != null) 'toCustom': toCustom,
      // Note: isDeleted is usually not sent in add/update payload unless specifically needed
    };
  }

  /// Creates a copy of this [PlazaFare] with the given fields replaced with new values.
  PlazaFare copyWith({
    int? fareId,
    int? plazaId,
    String? vehicleType,
    String? fareType,
    int? baseHours,
    double? fareRate,
    double? discountRate,
    DateTime? startEffectDate,
    DateTime? endEffectDate,
    bool? isDeleted,
    int? from,
    int? toCustom,
  }) {
    return PlazaFare(
      fareId: fareId ?? this.fareId,
      plazaId: plazaId ?? this.plazaId,
      vehicleType: vehicleType ?? this.vehicleType,
      fareType: fareType ?? this.fareType,
      baseHours: baseHours ?? this.baseHours,
      fareRate: fareRate ?? this.fareRate,
      discountRate: discountRate ?? this.discountRate,
      startEffectDate: startEffectDate ?? this.startEffectDate,
      endEffectDate: endEffectDate ?? this.endEffectDate,
      isDeleted: isDeleted ?? this.isDeleted,
      from: from ?? this.from,
      toCustom: toCustom ?? this.toCustom,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PlazaFare &&
              runtimeType == other.runtimeType &&
              fareId == other.fareId &&
              plazaId == other.plazaId &&
              vehicleType == other.vehicleType &&
              fareType == other.fareType &&
              baseHours == other.baseHours &&
              fareRate == other.fareRate &&
              discountRate == other.discountRate &&
              startEffectDate == other.startEffectDate &&
              endEffectDate == other.endEffectDate &&
              isDeleted == other.isDeleted &&
              from == other.from &&
              toCustom == other.toCustom;

  @override
  int get hashCode =>
      fareId.hashCode ^
      plazaId.hashCode ^
      vehicleType.hashCode ^
      fareType.hashCode ^
      baseHours.hashCode ^
      fareRate.hashCode ^
      discountRate.hashCode ^
      startEffectDate.hashCode ^
      endEffectDate.hashCode ^
      isDeleted.hashCode ^
      from.hashCode ^
      toCustom.hashCode;

// Helper extension for logging PlazaFare details easily (already present in ViewModel file)
// Consider moving this extension here if it's not in the ViewModel file.
// Map<String, dynamic> toJsonLog() => { ... };
}

/// Constants for vehicle types supported by the system.
class VehicleTypes {
  static const String bike = 'Bike';
  static const String threeWheeler = '3-Wheeler';
  static const String fourWheeler = '4-Wheeler';
  static const String bus = 'Bus';
  static const String truck = 'Truck';
  static const String heavyMachineryVehicle = 'Heavy Machinery Vehicle';
  //static const String invalidCarriage = 'Invalid Carriage';

  static const List<String> values = [
    bike,
    threeWheeler,
    fourWheeler,
    bus,
    truck,
    heavyMachineryVehicle,
    //invalidCarriage,
  ];
}

/// Constants for fare types supported by the system.
class FareTypes {
  static const String hourly = 'Hourly';
  static const String daily = 'Daily';
  static const String hourWiseCustom = 'Hour-wise Custom';
  static const String monthlyPass = 'Monthly Pass';
  static const String progressive = 'Progressive'; // Already Added
  static const String freePass = 'FREEPASS'; // Already Added

  static const List<String> values = [
    hourly,
    daily,
    hourWiseCustom,
    monthlyPass,
    progressive,
    freePass,
  ];
}