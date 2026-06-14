import 'dart:convert';

class RoomModel {
  final String id;
  final String hostelId;
  final String type;
  final String image;
  final List<String> images;
  final String gender;
  final int capacity;
  final double price;
  final bool available;
  final int availableRooms;
  final List<String> features;
  final String? videoUrl;
  final int occupiedSpaces;
  final String roomStatus;

  /// Total bookable spaces = capacity × number of physical rooms.
  int get totalSpaces => capacity * availableRooms;

  /// Spaces still open for booking.
  int get availableSpaces => (totalSpaces - occupiedSpaces).clamp(0, totalSpaces);

  /// True when every space is taken.
  bool get isFull => totalSpaces > 0 && availableSpaces <= 0;

  RoomModel({
    required this.id,
    required this.hostelId,
    required this.type,
    required this.image,
    List<String>? images,
    required this.gender,
    required this.capacity,
    required this.price,
    required this.available,
    required this.availableRooms,
    required this.features,
    this.videoUrl,
    this.occupiedSpaces = 0,
    this.roomStatus = 'available',
  }) : images = images ?? [image];

  factory RoomModel.fromMap(Map<String, dynamic> map, String id) {
    final String mainImage = map['image'];
    final List<String> imagesList = map['images'] != null
        ? List<String>.from(map['images'])
        : [mainImage];

    return RoomModel(
      id: id,
      hostelId: map['hostelId'],
      type: map['type'],
      image: mainImage,
      images: imagesList,
      gender: map['gender'],
      capacity: (map['capacity'] as num).toInt(),
      price: (map['price'] as num).toDouble(),
      available: map['available'] as bool? ?? true,
      availableRooms: (map['availableRooms'] as num?)?.toInt() ?? 0,
      features: List<String>.from(map['features'] ?? []),
      videoUrl: map['videoUrl'],
      // Backward-compatible defaults for existing Firestore documents
      occupiedSpaces: (map['occupiedSpaces'] as num?)?.toInt() ?? 0,
      roomStatus: map['roomStatus'] as String? ?? 'available',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "hostelId": hostelId,
      "type": type,
      "image": image,
      "images": images,
      "gender": gender,
      "capacity": capacity,
      "price": price,
      "available": available,
      "availableRooms": availableRooms,
      "features": features,
      "videoUrl": videoUrl,
      "occupiedSpaces": occupiedSpaces,
      "roomStatus": roomStatus,
    };
  }

  String toJson() => json.encode(toMap());

  factory RoomModel.fromJson(String source, {String? id}) {
    final map = json.decode(source) as Map<String, dynamic>;
    return RoomModel.fromMap(map, id ?? map['id'] ?? '');
  }
}
