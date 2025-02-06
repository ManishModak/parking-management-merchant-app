class Plaza {
  static const List<String> validPlazaCategories = ['Public', 'Private'];
  static const List<String> validPlazaSubCategories = ['Apartment', 'Society', 'OPEN', 'CLOSE'];
  static const List<String> validStructureTypes = ['Open', 'Multistory', 'Underground'];
  static const List<String> validPlazaStatuses = ['Active', 'Inactive'];
  static const List<String> validPriceCategories = ['Premium', 'Standard'];

  String? plazaId;
  final String plazaName;
  final String plazaOwner;
  final String plazaOwnerId;
  final String plazaOperatorName;
  final String plazaOperatorId;
  final String mobileNumber;
  final String address;
  final String email;
  final String city;
  final String district;
  final String state;
  final String pincode;
  final double geoLatitude;
  final double geoLongitude;
  final String plazaCategory;
  final String plazaSubCategory;
  final String structureType;
  final String plazaStatus;
  final int noOfParkingSlots;
  final bool freeParking;
  final String priceCategory;
  final int capacityTwoWheeler;
  final int capacityFourLMV;
  final int capacityFourLCV;
  final int capacityHMV;
  final String plazaOpenTimings;
  final String plazaClosingTime;
  final bool isDeleted;

  Plaza({
    this.plazaId,
    required this.plazaName,
    required this.plazaOwner,
    required this.plazaOwnerId,
    required this.plazaOperatorName,
    required this.plazaOperatorId,
    required this.mobileNumber,
    required this.address,
    required this.email,
    required this.city,
    required this.district,
    required this.state,
    required this.pincode,
    required this.geoLatitude,
    required this.geoLongitude,
    required this.plazaCategory,
    required this.plazaSubCategory,
    required this.structureType,
    required this.plazaStatus,
    required this.noOfParkingSlots,
    required this.freeParking,
    required this.priceCategory,
    required this.capacityTwoWheeler,
    required this.capacityFourLMV,
    required this.capacityFourLCV,
    required this.capacityHMV,
    required this.plazaOpenTimings,
    required this.plazaClosingTime,
    this.isDeleted = false,
  });

  Plaza copyWith({
    String? plazaId,
    String? plazaName,
    String? plazaOwner,
    String? plazaOwnerId,
    String? plazaOperatorName,
    String? plazaOperatorId,
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
    int? capacityTwoWheeler,
    int? capacityFourLMV,
    int? capacityFourLCV,
    int? capacityHMV,
    String? plazaOpenTimings,
    String? plazaClosingTime,
    bool? isDeleted,
  }) {
    return Plaza(
      plazaId: plazaId ?? this.plazaId,
      plazaName: plazaName ?? this.plazaName,
      plazaOwner: plazaOwner ?? this.plazaOwner,
      plazaOwnerId: plazaOwnerId ?? this.plazaOwnerId,
      plazaOperatorName: plazaOperatorName ?? this.plazaOperatorName,
      plazaOperatorId: plazaOperatorId ?? this.plazaOperatorId,
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
      capacityTwoWheeler: capacityTwoWheeler ?? this.capacityTwoWheeler,
      capacityFourLMV: capacityFourLMV ?? this.capacityFourLMV,
      capacityFourLCV: capacityFourLCV ?? this.capacityFourLCV,
      capacityHMV: capacityHMV ?? this.capacityHMV,
      plazaOpenTimings: plazaOpenTimings ?? this.plazaOpenTimings,
      plazaClosingTime: plazaClosingTime ?? this.plazaClosingTime,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  factory Plaza.fromJson(Map<String, dynamic> json) {
    return Plaza(
      plazaId: json['plazaId']?.toString(),
      plazaName: json['plazaName'] as String? ?? '',
      plazaOwner: json['plazaOwner'] as String? ?? '',
      plazaOwnerId: json['plazaOwnerId']?.toString() ?? '',
      plazaOperatorName: json['plazaOperatorName'] as String? ?? '',
      plazaOperatorId: json['plazaOperatorId'] as String? ?? '',
      mobileNumber: json['mobileNumber']?.toString() ?? '',
      address: json['address'] as String? ?? '',
      email: json['email'] as String? ?? '',
      city: json['city'] as String? ?? '',
      district: json['district'] as String? ?? '',
      state: json['state'] as String? ?? '',
      pincode: json['pincode']?.toString() ?? '',
      geoLatitude: _parseDouble(json['geoLatitude']) ?? 0.0,
      geoLongitude: _parseDouble(json['geoLongitude']) ?? 0.0,
      plazaCategory: json['plazaCategory'] as String? ?? 'Private',
      plazaSubCategory: json['plazaSubCategory'] as String? ?? 'OPEN',
      structureType: json['structureType'] as String? ?? 'Open',
      plazaStatus: json['plazaStatus'] as String? ?? 'Active',
      noOfParkingSlots: _parseInt(json['noOfParkingSlots']) ?? 0,
      freeParking: json['freeParking'] as bool? ?? false,
      priceCategory: json['priceCategory'] as String? ?? 'Standard',
      capacityTwoWheeler: _parseInt(json['capacityTwoWheeler']) ?? 0,
      capacityFourLMV: _parseInt(json['capacityFourLMV']) ?? 0,
      capacityFourLCV: _parseInt(json['capacityFourLCV']) ?? 0,
      capacityHMV: _parseInt(json['capacityHMV']) ?? 0,
      plazaOpenTimings: json['plazaOpenTimings'] as String? ?? '00:00',
      plazaClosingTime: json['plazaClosingTime'] as String? ?? '23:59',
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      try {
        return int.parse(value);
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
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'plazaName': plazaName,
      'plazaOwner': plazaOwner,
      'plazaOwnerId': plazaOwnerId,
      'plazaOperatorName': plazaOperatorName,
      'plazaOperatorId': plazaOperatorId,
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
      'capacityTwoWheeler': capacityTwoWheeler,
      'capacityFourLMV': capacityFourLMV,
      'capacityFourLCV': capacityFourLCV,
      'capacityHMV': capacityHMV,
      'plazaOpenTimings': plazaOpenTimings,
      'plazaClosingTime': plazaClosingTime,
      'isDeleted': isDeleted,
    };

    if (plazaId != null) {
      data['plazaId'] = plazaId;
    }

    return data;
  }

  // Add this constructor to the Plaza class
  factory Plaza.empty() {
    return Plaza(
        plazaId: '',
        plazaName: '',
        plazaOwner: '',
        plazaOwnerId: '',
        plazaOperatorName: '',
        plazaOperatorId: '',
        mobileNumber: '',
        address: '',
        email: '',
        city: '',
        district: '',
        state: '',
        pincode: '',
        geoLatitude: 0.0,
        geoLongitude: 0.0,
        plazaCategory: 'Private',
        plazaSubCategory: 'OPEN',
        structureType: 'Open',
        plazaStatus: 'Active',
        noOfParkingSlots: 0,
        freeParking: false,
        priceCategory: 'Standard',
        capacityTwoWheeler: 0,
        capacityFourLMV: 0,
        capacityFourLCV: 0,
        capacityHMV: 0,
        plazaOpenTimings: '00:00',
        plazaClosingTime: '23:59'
    );
  }

  @override
  String toString() => plazaName; // Already implemented in your code
}
