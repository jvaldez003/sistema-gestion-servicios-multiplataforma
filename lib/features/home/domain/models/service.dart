class Service {
  final String id;
  final String name;
  final String description;
  final double price;
  final String duration; // e.g., "30 min"
  final bool isActive;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    this.isActive = true,
  });

  factory Service.fromMap(Map<String, dynamic> map, String id) {
    return Service(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] is String
          ? double.tryParse(map['price']) ?? 0.0
          : (map['price'] ?? 0.0).toDouble(),
      duration: map['duration'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'isActive': isActive,
    };
  }
}
