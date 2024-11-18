class Plaza {
  final String id;
  final String imageUrl;
  final String name;
  final String location;

  Plaza({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.location,
  });

  Plaza copyWith({
    String? id,
    String? imageUrl,
    String? name,
    String? location,
  }) {
    return Plaza(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      location: location ?? this.location,
    );
  }

  factory Plaza.fromJson(Map<String, dynamic> json) {
    return Plaza(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'name': name,
      'location': location,
    };
  }
}
