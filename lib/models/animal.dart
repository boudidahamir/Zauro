class Animal {
  final String id;
  final String ownerId;
  final String name;
  final String status; // e.g. 'alive', 'sick', 'dead'
  final String? imageUrl; // nullable because image might not be provided
  final DateTime? createdAt;

  Animal({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.status,
    this.imageUrl,
    this.createdAt,
  });

  // Factory constructor to create Animal from JSON (Map)
  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  // Convert Animal instance to JSON Map (for inserting/updating)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'status': status,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
