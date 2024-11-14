class User {
  final String id;
  final String username;
  final String email;
  final String? name;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'name': name,
    };
  }
}