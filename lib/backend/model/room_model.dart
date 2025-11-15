class RoomModel {
  final String id;
  final String hostelId;
  final String type;
  final String image;
  final String gender;
  final int capacity;
  final double price;
  final bool available;
  final int availableRooms;
  final List<String> features; // Bed, Fan, Wardrobe etc.

  RoomModel({
    required this.id,
    required this.hostelId,
    required this.type,
    required this.image,
    required this.gender,
    required this.capacity,
    required this.price,
    required this.available,
    required this.availableRooms,
    required this.features,
  });

  factory RoomModel.fromMap(Map<String, dynamic> map, String id) {
    return RoomModel(
      id: id,
      hostelId: map['hostelId'],
      type: map['type'],
      image: map['image'],
      gender: map['gender'],
      capacity: map['capacity'],
      price: (map['price'] as num).toDouble(),
      available: map['available'],
      availableRooms: map['availableRooms'],
      features: List<String>.from(map['features']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "hostelId": hostelId,
      "type": type,
      "image": image,
      "gender": gender,
      "capacity": capacity,
      "price": price,
      "available": available,
      "availableRooms": availableRooms,
      "features": features,
    };
  }
}
