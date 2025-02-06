import 'dart:convert';

class PlazaFare {
  final int? fareId;
  final int plazaId;
  final VehicleType vehicleType;
  final FareType fareType;
  final int? baseHours;
  final double fareRate;
  final double? discountRate;
  final DateTime startEffectDate;
  final DateTime? endEffectDate;
  final bool isDeleted;

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
  });

  factory PlazaFare.fromJson(Map<String, dynamic> json) {
    return PlazaFare(
      fareId: json['fareId'],
      plazaId: json['plazaId'],
      vehicleType: _vehicleTypeFromString(json['vehicleType']),
      fareType: _fareTypeFromString(json['FareType']),
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (fareId != null) 'fareId': fareId,
      'plazaId': plazaId,
      'vehicleType': _vehicleTypeToJson(vehicleType),
      'FareType': _fareTypeToJson(fareType),
      if (baseHours != null) 'baseHours': baseHours,
      'fareRate': fareRate,
      if (discountRate != null) 'discountRate': discountRate,
      'startEffectDate': startEffectDate.toIso8601String().split('T')[0],
      if (endEffectDate != null)
        'endEffectDate': endEffectDate!.toIso8601String().split('T')[0],
    };
  }
}

enum VehicleType {
  Bike,
  ThreeWheeler,
  FourWheeler,
  Bus,
  Truck,
  HeavyMachineryVehicle,
  InvalidCarriage,
}

enum FareType {
  Hourly,
  Fixed24Hour,
  HourWiseCustom,
  MonthlyPass,
}

/// Converts a VehicleType enum to the string that the backend expects.
String _vehicleTypeToJson(VehicleType type) {
  switch (type) {
    case VehicleType.Bike:
      return "Bike";
    case VehicleType.ThreeWheeler:
      return "3-wheeler";
    case VehicleType.FourWheeler:
      return "4-wheeler";
    case VehicleType.Bus:
      return "Bus";
    case VehicleType.Truck:
      return "Truck";
    case VehicleType.HeavyMachineryVehicle:
      return "Heavy Machinery Vehicle";
    case VehicleType.InvalidCarriage:
      return "Invalid Carriage";
  }
}

/// Converts a string from the backend to the corresponding VehicleType enum.
VehicleType _vehicleTypeFromString(String type) {
  switch (type) {
    case "Bike":
      return VehicleType.Bike;
    case "3-wheeler":
      return VehicleType.ThreeWheeler;
    case "4-wheeler":
      return VehicleType.FourWheeler;
    case "Bus":
      return VehicleType.Bus;
    case "Truck":
      return VehicleType.Truck;
    case "Heavy Machinery Vehicle":
      return VehicleType.HeavyMachineryVehicle;
    case "Invalid Carriage":
      return VehicleType.InvalidCarriage;
    default:
      throw Exception("Unknown vehicle type: $type");
  }
}

/// Converts a FareType enum to the string expected by the backend.
String _fareTypeToJson(FareType type) {
  switch (type) {
    case FareType.Hourly:
      return "Hourly";
    case FareType.Fixed24Hour:
      return "Fixed-24-Hour"; // Updated to include hyphen.
    case FareType.HourWiseCustom:
      return "Hour-wise Custom"; // Updated to include hyphen and space.
    case FareType.MonthlyPass:
      return "Monthly Pass"; // Ensure this matches backend expectation.
  }
}

/// Converts a string from the backend to the corresponding FareType enum.
FareType _fareTypeFromString(String type) {
  switch (type) {
    case "Hourly":
      return FareType.Hourly;
    case "Fixed-24-Hour":
      return FareType.Fixed24Hour;
    case "Hour-wise Custom":
      return FareType.HourWiseCustom;
    case "Monthly Pass":
      return FareType.MonthlyPass;
    default:
      throw Exception("Unknown fare type: $type");
  }
}
