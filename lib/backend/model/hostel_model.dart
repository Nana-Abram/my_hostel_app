import 'dart:convert';

class HostelModel {
  final String id;
  final String name;
  final String campus;
  final String ownerName;
  final double totalRooms;
  final List<String> images;
  final String description;
  final double rating;
  final List<dynamic> amenities;
  final String status;
  final String location;
  final double startPrice;
  final double reviewsCount;
  final String ownerId;

  HostelModel({
    required this.id,
    required this.name,
    required this.campus,
    required this.images,
    required this.ownerName,
    required this.totalRooms,
    required this.description,
    required this.rating,
    required this.amenities,
    required this.location,
    required this.startPrice,
    required this.reviewsCount,
    required this.status,
    this.ownerId = '',
  });

  factory HostelModel.fromMap(Map<String, dynamic> data, String id) {
    return HostelModel(
      id: id,
      name: data['name'],
      campus: data['campus'],
      images: List<String>.from(data['images'] ?? []),
      description: data['description'],
      ownerName: data['ownerName'],
      totalRooms: (data['totalRooms'] as num).toDouble(),
      rating: (data['rating'] as num).toDouble(),
      amenities: data['amenities'] ?? [],
      location: data['location'],
      startPrice: (data['startPrice'] as num).toDouble(),
      reviewsCount: (data["reviewsCount"] as num).toDouble(),
      status: data['status'],
      ownerId: data['ownerId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "campus": campus,
      "images": images,
      "description": description,
      "ownerName": ownerName,
      "totalRooms": totalRooms,
      "rating": rating,
      "amenities": amenities,
      "location": location,
      "startPrice": startPrice,
      "reviewsCount": reviewsCount,
      "status": status,
      "ownerId": ownerId,
    };
  }

  /// Converts this model to a JSON string
  String toJson() => json.encode(toMap());

  /// Creates a HostelModel from a JSON string
  factory HostelModel.fromJson(String source, {String? id}) {
    final map = json.decode(source) as Map<String, dynamic>;
    return HostelModel.fromMap(map, id ?? map['id'] ?? '');
  }
}
