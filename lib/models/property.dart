class Property {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> images;
  final String location;
  final String ownerId;
  final String ownerName;

  Property({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
    required this.location,
    required this.ownerId,
    required this.ownerName,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'images': images,
      'location': location,
      'ownerId': ownerId,
      'ownerName': ownerName,
    };
  }

  factory Property.fromMap(String id, Map<String, dynamic> map) {
    if (map['name'] == null || map['description'] == null || map['price'] == null || map['images'] == null || map['location'] == null || map['ownerId'] == null || map['ownerName'] == null) {
      throw ArgumentError('Missing required fields for Property.');
    }
    return Property(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? 0.0,
      images: List<String>.from(map['images'] ?? []),
      location: map['location'] ?? '',
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? '',
    );
  }
}
