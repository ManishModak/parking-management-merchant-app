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
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      imageUrl: '',
      mobileNumber: json['mobileNumber'] ?? '',
      address: json['address'],
      state: json['state'],
      city: json['city'],
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
    };
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, mobile: $mobileNumber, address: $address, city: $city, state: $state, role: $role)';
  }
}