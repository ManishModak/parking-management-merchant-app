import 'dart:developer' as developer;

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
}

class Plaza {
  // Existing valid options
  static const List<String> validPlazaCategories = ['Public', 'Private'];
  static const List<String> validPlazaSubCategories = [
    'Apartment',
    'Society',
    'OPEN',
    'CLOSE'
  ];
  static const List<String> validStructureTypes = [
    'Open',
    'Multistory',
    'Underground'
  ];
  static const List<String> validPlazaStatuses = ['Active', 'Inactive'];
  static const List<String> validPriceCategories = ['Premium', 'Standard'];
  static const List<String> validCompanyTypes = [
    "Individual",
    "LLP",
    "Private Limited",
    "Public Limited"
  ];

  // Properties (all required fields made nullable)
  String? plazaId;
  String? plazaName;
  String? plazaOwner;
  String? plazaOwnerId;
  String? companyName;
  String? companyType;
  String? plazaOrgId;
  String? mobileNumber;
  String? address;
  String? email;
  String? city;
  String? district;
  String? state;
  String? pincode;
  double? geoLatitude;
  double? geoLongitude;
  String? plazaCategory;
  String? plazaSubCategory;
  String? structureType;
  String? plazaStatus;
  int? noOfParkingSlots;
  bool? freeParking;
  String? priceCategory;
  int? capacityBike;
  int? capacity3Wheeler;
  int? capacity4Wheeler;
  int? capacityBus;
  int? capacityTruck;
  int? capacityHeavyMachinaryVehicle;
  String? plazaOpenTimings;
  String? plazaClosingTime;
  bool isDeleted;

  Plaza({
    this.plazaId,
    this.plazaName,
    this.plazaOwner,
    this.plazaOwnerId,
    this.companyName,
    this.companyType,
    this.plazaOrgId,
    this.mobileNumber,
    this.address,
    this.email,
    this.city,
    this.district,
    this.state,
    this.pincode,
    this.geoLatitude,
    this.geoLongitude,
    this.plazaCategory,
    this.plazaSubCategory,
    this.structureType,
    this.plazaStatus,
    this.noOfParkingSlots,
    this.freeParking,
    this.priceCategory,
    this.capacityBike,
    this.capacity3Wheeler,
    this.capacity4Wheeler,
    this.capacityBus,
    this.capacityTruck,
    this.capacityHeavyMachinaryVehicle,
    this.plazaOpenTimings,
    this.plazaClosingTime,
    this.isDeleted = false,
  });

  Plaza copyWith({
    String? plazaId,
    String? plazaName,
    String? plazaOwner,
    String? plazaOwnerId,
    String? companyName,
    String? companyType,
    String? plazaOrgId,
    String? mobileNumber,
    String? address,
    String? email,
    String? city,
    String? district,
    String? state,
    String? pincode,
    double? geoLatitude,
    double? geoLongitude,
    String? plazaCategory,
    String? plazaSubCategory,
    String? structureType,
    String? plazaStatus,
    int? noOfParkingSlots,
    bool? freeParking,
    String? priceCategory,
    int? capacityBike,
    int? capacity3Wheeler,
    int? capacity4Wheeler,
    int? capacityBus,
    int? capacityTruck,
    int? capacityHeavyMachinaryVehicle,
    String? plazaOpenTimings,
    String? plazaClosingTime,
    bool? isDeleted,
  }) {
    return Plaza(
      plazaId: plazaId ?? this.plazaId,
      plazaName: plazaName ?? this.plazaName,
      plazaOwner: plazaOwner ?? this.plazaOwner,
      plazaOwnerId: plazaOwnerId ?? this.plazaOwnerId,
      companyName: companyName ?? this.companyName,
      companyType: companyType ?? this.companyType,
      plazaOrgId: plazaOrgId ?? this.plazaOrgId,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      address: address ?? this.address,
      email: email ?? this.email,
      city: city ?? this.city,
      district: district ?? this.district,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      geoLatitude: geoLatitude ?? this.geoLatitude,
      geoLongitude: geoLongitude ?? this.geoLongitude,
      plazaCategory: plazaCategory ?? this.plazaCategory,
      plazaSubCategory: plazaSubCategory ?? this.plazaSubCategory,
      structureType: structureType ?? this.structureType,
      plazaStatus: plazaStatus ?? this.plazaStatus,
      noOfParkingSlots: noOfParkingSlots ?? this.noOfParkingSlots,
      freeParking: freeParking ?? this.freeParking,
      priceCategory: priceCategory ?? this.priceCategory,
      capacityBike: capacityBike ?? this.capacityBike,
      capacity3Wheeler: capacity3Wheeler ?? this.capacity3Wheeler,
      capacity4Wheeler: capacity4Wheeler ?? this.capacity4Wheeler,
      capacityBus: capacityBus ?? this.capacityBus,
      capacityTruck: capacityTruck ?? this.capacityTruck,
      capacityHeavyMachinaryVehicle:
          capacityHeavyMachinaryVehicle ?? this.capacityHeavyMachinaryVehicle,
      plazaOpenTimings: plazaOpenTimings ?? this.plazaOpenTimings,
      plazaClosingTime: plazaClosingTime ?? this.plazaClosingTime,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  factory Plaza.fromJson(Map<String, dynamic> json) {
    // Transform time fields from HH:mm:ss to HH:mm if necessary
    String? transformTime(String? time) {
      if (time == null || time.isEmpty) return null;
      // Check if time is in HH:mm:ss format
      final parts = time.split(':');
      if (parts.length == 3) {
        // Return HH:mm by taking first two parts
        return '${parts[0]}:${parts[1]}';
      }
      // Return as is if already in correct format or invalid
      return time;
    }

    return Plaza(
      plazaId: json['plazaId']?.toString(),
      plazaName: json['plazaName'] as String?,
      plazaOwner: json['plazaOwner'] as String?,
      plazaOwnerId: json['plazaOwnerId']?.toString(),
      companyName: json['companyName'] as String?,
      companyType: json['companyType'] as String? ?? validCompanyTypes.first,
      plazaOrgId: json['plazaOrgId']?.toString(),
      mobileNumber: json['mobileNumber']?.toString(),
      address: json['address'] as String?,
      email: json['email'] as String?,
      city: json['city'] as String?,
      district: json['district'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode']?.toString(),
      geoLatitude: _parseDouble(json['geoLatitude']),
      geoLongitude: _parseDouble(json['geoLongitude']),
      plazaCategory:
          json['plazaCategory'] as String? ?? validPlazaCategories.first,
      plazaSubCategory:
          json['plazaSubCategory'] as String? ?? validPlazaSubCategories.first,
      structureType:
          json['structureType'] as String? ?? validStructureTypes.first,
      plazaStatus: json['plazaStatus'] as String? ?? validPlazaStatuses.first,
      noOfParkingSlots: _parseInt(json['noOfParkingSlots']),
      freeParking: json['freeParking'] as bool?,
      priceCategory:
          json['priceCategory'] as String? ?? validPriceCategories.first,
      capacityBike: _parseInt(json['capacityBike']),
      capacity3Wheeler: _parseInt(json['capacity3Wheeler']),
      capacity4Wheeler: _parseInt(json['capacity4Wheeler']),
      capacityBus: _parseInt(json['capacityBus']),
      capacityTruck: _parseInt(json['capacityTruck']),
      capacityHeavyMachinaryVehicle:
          _parseInt(json['capacityHeavyMachinaryVehicle']),
      plazaOpenTimings:
          transformTime(json['plazaOpenTimings'] as String?) ?? '00:00',
      plazaClosingTime:
          transformTime(json['plazaClosingTime'] as String?) ?? '23:59',
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      try {
        return int.parse(value.trim());
      } catch (e) {
        return null;
      }
    }
    if (value is double) return value.toInt();
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value.trim());
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Map<String, String> validate() {
    final errors = <String, String>{};

    if (plazaName == null || plazaName!.isEmpty) {
      errors['plazaName'] = 'Plaza name is required';
    }
    if (plazaOwner == null || plazaOwner!.isEmpty) {
      errors['plazaOwner'] = 'Plaza owner is required';
    }
    if (plazaOwnerId == null || plazaOwnerId!.isEmpty) {
      errors['plazaOwnerId'] = 'Plaza owner ID is required';
    }
    if (companyName == null || companyName!.isEmpty) {
      errors['companyName'] = 'Company name is required';
    }
    if (companyType == null || !validCompanyTypes.contains(companyType)) {
      errors['companyType'] =
          'Valid company type is required (${validCompanyTypes.join(', ')})';
    }
    if (plazaOrgId == null || plazaOrgId!.isEmpty) {
      errors['plazaOrgId'] = 'Plaza organization ID is required';
    }
    if (mobileNumber == null || mobileNumber!.isEmpty) {
      errors['mobileNumber'] = 'Mobile number is required';
    } else if (!_isValidMobile(mobileNumber!)) {
      errors['mobileNumber'] = 'Invalid mobile number format';
    }
    if (address == null || address!.isEmpty) {
      errors['address'] = 'Address is required';
    }
    if (email == null || email!.isEmpty) {
      errors['email'] = 'Email is required';
    } else if (!_isValidEmail(email!)) {
      errors['email'] = 'Invalid email format';
    }
    if (city == null || city!.isEmpty) {
      errors['city'] = 'City is required';
    }
    if (district == null || district!.isEmpty) {
      errors['district'] = 'District is required';
    }
    if (state == null || state!.isEmpty) {
      errors['state'] = 'State is required';
    }
    if (pincode == null || pincode!.isEmpty) {
      errors['pincode'] = 'Pincode is required';
    } else if (!_isValidPincode(pincode!)) {
      errors['pincode'] = 'Invalid pincode format';
    }
    if (geoLatitude == null) {
      errors['geoLatitude'] = 'Geo latitude is required';
    }
    if (geoLongitude == null) {
      errors['geoLongitude'] = 'Geo longitude is required';
    }
    if (plazaCategory == null ||
        !validPlazaCategories.contains(plazaCategory)) {
      errors['plazaCategory'] =
          'Valid plaza category is required (${validPlazaCategories.join(', ')})';
    }
    if (plazaSubCategory == null ||
        !validPlazaSubCategories.contains(plazaSubCategory)) {
      errors['plazaSubCategory'] =
          'Valid plaza sub-category is required (${validPlazaSubCategories.join(', ')})';
    }
    if (structureType == null || !validStructureTypes.contains(structureType)) {
      errors['structureType'] =
          'Valid structure type is required (${validStructureTypes.join(', ')})';
    }
    if (plazaStatus == null || !validPlazaStatuses.contains(plazaStatus)) {
      errors['plazaStatus'] =
          'Valid plaza status is required (${validPlazaStatuses.join(', ')})';
    }
    if (noOfParkingSlots == null) {
      errors['noOfParkingSlots'] = 'Number of parking slots is required';
    } else if (noOfParkingSlots! < 0) {
      errors['noOfParkingSlots'] = 'Number of parking slots cannot be negative';
    }
    if (freeParking == null) {
      errors['freeParking'] = 'Free parking status is required';
    }
    if (priceCategory == null ||
        !validPriceCategories.contains(priceCategory)) {
      errors['priceCategory'] =
          'Valid price category is required (${validPriceCategories.join(', ')})';
    }
    if (capacityBike == null) {
      errors['capacityBike'] = 'Bike capacity is required';
    } else if (capacityBike! < 0) {
      errors['capacityBike'] = 'Bike capacity cannot be negative';
    }
    if (capacity3Wheeler == null) {
      errors['capacity3Wheeler'] = '3-wheeler capacity is required';
    } else if (capacity3Wheeler! < 0) {
      errors['capacity3Wheeler'] = '3-wheeler capacity cannot be negative';
    }
    if (capacity4Wheeler == null) {
      errors['capacity4Wheeler'] = '4-wheeler capacity is required';
    } else if (capacity4Wheeler! < 0) {
      errors['capacity4Wheeler'] = '4-wheeler capacity cannot be negative';
    }
    if (capacityBus == null) {
      errors['capacityBus'] = 'Bus capacity is required';
    } else if (capacityBus! < 0) {
      errors['capacityBus'] = 'Bus capacity cannot be negative';
    }
    if (capacityTruck == null) {
      errors['capacityTruck'] = 'Truck capacity is required';
    } else if (capacityTruck! < 0) {
      errors['capacityTruck'] = 'Truck capacity cannot be negative';
    }
    if (capacityHeavyMachinaryVehicle == null) {
      errors['capacityHeavyMachinaryVehicle'] =
          'Heavy machinery vehicle capacity is required';
    } else if (capacityHeavyMachinaryVehicle! < 0) {
      errors['capacityHeavyMachinaryVehicle'] =
          'Heavy machinery vehicle capacity cannot be negative';
    }
    if (plazaOpenTimings == null || plazaOpenTimings!.isEmpty) {
      errors['plazaOpenTimings'] = 'Plaza open timings are required';
    } else if (!_isValidTime(plazaOpenTimings!)) {
      errors['plazaOpenTimings'] = 'Invalid time format (HH:mm)';
    }
    if (plazaClosingTime == null || plazaClosingTime!.isEmpty) {
      errors['plazaClosingTime'] = 'Plaza closing time is required';
    } else if (!_isValidTime(plazaClosingTime!)) {
      errors['plazaClosingTime'] = 'Invalid time format (HH:mm)';
    }

    return errors;
  }

  bool _isValidMobile(String mobile) {
    // Basic mobile number validation (e.g., 10 digits)
    final regExp = RegExp(r'^\d{10}$');
    return regExp.hasMatch(mobile);
  }

  bool _isValidEmail(String email) {
    // Basic email validation
    final regExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regExp.hasMatch(email);
  }

  bool _isValidPincode(String pincode) {
    // Basic pincode validation (e.g., 6 digits)
    final regExp = RegExp(r'^\d{6}$');
    return regExp.hasMatch(pincode);
  }

  bool _isValidTime(String time) {
    // Validate time format (HH:mm)
    final regExp = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regExp.hasMatch(time);
  }

  Map<String, dynamic> toJson() {
    final validationErrors = validate();
    if (validationErrors.isNotEmpty) {
      final errorMessage =
          'Validation failed: ${validationErrors.entries.map((e) => '${e.key}: ${e.value}').join(', ')}';
      developer.log(errorMessage, name: 'Plaza');
      throw ValidationException(errorMessage);
    }

    final Map<String, dynamic> data = {
      'plazaName': plazaName,
      'plazaOwner': plazaOwner,
      'plazaOwnerId': plazaOwnerId,
      'companyName': companyName,
      'companyType': companyType,
      'plazaOrgId': plazaOrgId,
      'mobileNumber': mobileNumber,
      'address': address,
      'email': email,
      'city': city,
      'district': district,
      'state': state,
      'pincode': pincode,
      'geoLatitude': geoLatitude,
      'geoLongitude': geoLongitude,
      'plazaCategory': plazaCategory,
      'plazaSubCategory': plazaSubCategory,
      'structureType': structureType,
      'plazaStatus': plazaStatus,
      'noOfParkingSlots': noOfParkingSlots,
      'freeParking': freeParking,
      'priceCategory': priceCategory,
      'capacityBike': capacityBike,
      'capacity3Wheeler': capacity3Wheeler,
      'capacity4Wheeler': capacity4Wheeler,
      'capacityBus': capacityBus,
      'capacityTruck': capacityTruck,
      'capacityHeavyMachinaryVehicle': capacityHeavyMachinaryVehicle,
      'plazaOpenTimings': plazaOpenTimings,
      'plazaClosingTime': plazaClosingTime,
      'isDeleted': isDeleted,
    };

    if (plazaId != null && plazaId!.isNotEmpty) {
      data['plazaId'] = plazaId;
    }

    return data;
  }

  factory Plaza.empty() {
    return Plaza(
      plazaId: null,
      plazaName: null,
      plazaOwner: null,
      plazaOwnerId: null,
      companyName: null,
      companyType: null,
      plazaOrgId: null,
      mobileNumber: null,
      address: null,
      email: null,
      city: null,
      district: null,
      state: null,
      pincode: null,
      geoLatitude: null,
      geoLongitude: null,
      plazaCategory: null,
      plazaSubCategory: null,
      structureType: null,
      plazaStatus: null,
      noOfParkingSlots: null,
      freeParking: null,
      priceCategory: null,
      capacityBike: null,
      capacity3Wheeler: null,
      capacity4Wheeler: null,
      capacityBus: null,
      capacityTruck: null,
      capacityHeavyMachinaryVehicle: null,
      plazaOpenTimings: null,
      plazaClosingTime: null,
      isDeleted: false,
    );
  }

  @override
  String toString() => plazaName ?? 'Unnamed Plaza';
}
