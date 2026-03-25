import 'dart:convert';

class RoomModel {
  final String id;
  final String hostelId;
  final String type;
  final String image;
  final List<String> images; // Multiple room images
  final String gender;
  final int capacity;
  final double price;
  final bool available;
  final int availableRooms;
  final List<String> features; // Bed, Fan, Wardrobe etc.
  final String? videoUrl; // Room video tour

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
      capacity: map['capacity'],
      price: (map['price'] as num).toDouble(),
      available: map['available'],
      availableRooms: map['availableRooms'],
      features: List<String>.from(map['features'] ?? []),
      videoUrl: map['videoUrl'],
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
      if (videoUrl != null) "videoUrl": videoUrl,
    };
  }

  /// Converts this model to a JSON string
  String toJson() => json.encode(toMap());

  /// Creates a RoomModel from a JSON string
  factory RoomModel.fromJson(String source, {String? id}) {
    final map = json.decode(source) as Map<String, dynamic>;
    return RoomModel.fromMap(map, id ?? map['id'] ?? '');
  }
}
