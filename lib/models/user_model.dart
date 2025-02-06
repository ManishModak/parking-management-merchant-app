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
  List<String> subEntity;  // Changed to List<String>
  String? entityName;
  String? entityId;

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
    this.entityName,
    List<String>? subEntity,  // Changed parameter type
    this.entityId,
  }) : subEntity = subEntity ?? [];  // Initialize with empty list if null

  factory User.fromJson(Map<String, dynamic> json) {
    // Handle subEntity list conversion
    List<String> subEntityList = [];
    if (json['subEntity'] != null) {
      if (json['subEntity'] is List) {
        subEntityList = (json['subEntity'] as List)
            .map((item) => item.toString())
            .toList();
      } else if (json['subEntity'] is String) {
        // If it's a single string, wrap it in a list
        subEntityList = [json['subEntity'] as String];
      }
    }

    return User(
      id: json['id'].toString(),
      name: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      imageUrl: '',
      mobileNumber: json['mobileNumber']?.toString() ?? '',
      address: json['address'],
      state: json['state'],
      city: json['city'],
      entityName: json['entityName'],
      entityId: json['entityId'],
      subEntity: subEntityList,  // Pass the converted list
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': name,
      'email': email,
      'role': role,
      'mobileNumber': mobileNumber,
      'address': address,
      'state': state,
      'city': city,
      'subEntity': subEntity,  // This will now correctly serialize the list
      'entityName': entityName,
      'entityId': entityId
    };
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, mobile: $mobileNumber, address: $address, city: $city, state: $state, role: $role, entity: $entityName, sub-entity: $subEntity, entityId: $entityId)';
  }
}