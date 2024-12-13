class User {
  late final String id;
  final String username;
  final String email;
  final String? mobileNumber;
  final String? address;
  final String? city;
  final String? state;
  final String? role;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.mobileNumber,
    this.address,
    this.city,
    this.state,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      username: json['username'],
      email: json['email'],
      mobileNumber: json['mobileNumber'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'mobileNumber': mobileNumber,
      'address': address,
      'city': city,
      'state': state,
      'role': role,
    };
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, mobileNumber: $mobileNumber, address: $address, city: $city, state: $state, role: $role)';
  }
}