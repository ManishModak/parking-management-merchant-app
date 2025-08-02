class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String imageUrl;
  final String mobileNumber;
  final String? address;
  final String? state;
  final String? city;
  final String? pincode;
  final List<String> subEntity; // List of plaza IDs for API requests
  final List<Map<String, dynamic>>?
      subEntityData; // Raw subEntity objects for dropdowns
  final String? entityName;
  final String? entityId;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.imageUrl,
    required this.mobileNumber,
    this.address,
    this.state,
    this.city,
    this.pincode,
    this.entityName,
    List<String>? subEntity,
    this.subEntityData,
    this.entityId,
  }) : subEntity = subEntity ?? [];

  factory User.fromJson(Map<String, dynamic> json) {
    // Handle subEntity list conversion
    List<String> subEntityList = [];
    List<Map<String, dynamic>>? subEntityDataList;

    if (json['subEntity'] != null) {
      if (json['subEntity'] is List) {
        final subEntityRaw = json['subEntity'] as List<dynamic>;
        subEntityDataList = subEntityRaw
            .whereType<Map<String, dynamic>>()
            .cast<Map<String, dynamic>>()
            .toList();
        subEntityList = subEntityRaw.map((item) {
          if (item is String) {
            return item; // Direct plaza ID (e.g., "3")
          } else if (item is Map<String, dynamic> && item['plazaId'] != null) {
            return item['plazaId'].toString(); // Extract plazaId from object
          }
          return item.toString(); // Fallback for unexpected types
        }).toList();
      } else if (json['subEntity'] is String) {
        subEntityList = [json['subEntity'] as String]; // Single string
      }
    }

    return User(
      id: json['id'].toString(),
      name: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      mobileNumber: json['mobileNumber']?.toString() ?? '',
      address: json['address'],
      state: json['state'],
      city: json['city'],
      pincode: json['pincode'],
      entityName: json['entityName'],
      entityId: json['entityId']?.toString(),
      subEntity: subEntityList,
      subEntityData: subEntityDataList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': name,
      'email': email,
      'role': role,
      'imageUrl': imageUrl,
      'mobileNumber': mobileNumber,
      'address': address,
      'state': state,
      'city': city,
      'pincode': pincode,
      'subEntity': subEntity, // Serializes as List<String>
      'entityName': entityName,
      'entityId': entityId,
    };
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, mobile: $mobileNumber, address: $address, city: $city, state: $state, pincode: $pincode, role: $role, entity: $entityName, subEntity: $subEntity, subEntityData: $subEntityData, entityId: $entityId)';
  }
}
