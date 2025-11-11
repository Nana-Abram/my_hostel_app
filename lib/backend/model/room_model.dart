class RoomModel {
  final String id;
  final String hostelId;
  final String type;
  final int capacity;
  final double price;
  final bool available;
  final List<String> features; // Bed, Fan, Wardrobe etc.

  RoomModel({
    required this.id,
    required this.hostelId,
    required this.type,
    required this.capacity,
    required this.price,
    required this.available,
    required this.features,
  });

  factory RoomModel.fromMap(Map<String, dynamic> map, String id) {
    return RoomModel(
      id: id,
      hostelId: map['hostelId'],
      type: map['type'],
      capacity: map['capacity'],
      price: (map['price'] as num).toDouble(),
      available: map['available'],
      features: List<String>.from(map['features']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "hostelId": hostelId,
      "type": type,
      "capacity": capacity,
      "price": price,
      "available": available,
      "features": features,
    };
  }
}
