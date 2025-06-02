import 'dart:convert';

class RentalItem {
  final String id;
  final String title;
  final String description;
  final double pricePerDay;
  final String? imageUrl;
  final String ownerId;
  final String category;
  final List<String>? features;
  final bool isAvailable;
  final String? location;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RentalItem({
    required this.id,
    required this.title,
    required this.description,
    required this.pricePerDay,
    this.imageUrl,
    required this.ownerId,
    required this.category,
    this.features,
    required this.isAvailable,
    this.location,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price_per_day': pricePerDay,
      'image_url': imageUrl,
      'owner_id': ownerId,
      'category': category,
      'features': features,
      'is_available': isAvailable,
      'location': location,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory RentalItem.fromMap(Map<String, dynamic> map) {
    return RentalItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      pricePerDay: map['price_per_day']?.toDouble() ?? 0.0,
      imageUrl: map['image_url'],
      ownerId: map['owner_id'] ?? '',
      category: map['category'] ?? '',
      features:
          map['features'] != null ? List<String>.from(map['features']) : null,
      isAvailable: map['is_available'] ?? true,
      location: map['location'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory RentalItem.fromJson(String source) =>
      RentalItem.fromMap(json.decode(source));

  RentalItem copyWith({
    String? id,
    String? title,
    String? description,
    double? pricePerDay,
    String? imageUrl,
    String? ownerId,
    String? category,
    List<String>? features,
    bool? isAvailable,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RentalItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId ?? this.ownerId,
      category: category ?? this.category,
      features: features ?? this.features,
      isAvailable: isAvailable ?? this.isAvailable,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
