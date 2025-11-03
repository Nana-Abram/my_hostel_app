// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Hostel {
  final String name;
   final String campus;
  final double rating;
  final int reviewsCount;
  final String roomType;
  final String gender;
  final double price;
  final String description;
  final List<String> amenities;
  final String image;
  Hostel({
    required this.name,
    required this.campus,
    required this.rating,
    required this.reviewsCount,
    required this.roomType,
    required this.gender,
    required this.price,
    required this.description,
    required this.amenities,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'campus': campus,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'roomType': roomType,
      'gender': gender,
      'price': price,
      'description':description,
      'amenities': amenities,
      'image': image,
    };
  }

  factory Hostel.fromMap(Map<String, dynamic> map) {
    return Hostel(
      name: map['name'] as String,
      campus: map['campus'] as String,
      rating: map['rating'] as double,
      reviewsCount: map['reviewsCount'] as int,
      roomType: map['roomType'] as String,
      gender: map['gender'] as String,
      price: map['price'] as double,
      description: map['description'] as String,
      amenities: List<String>.from((map['amenities'] as List<String>),),
      image: map['image'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Hostel.fromJson(String source) => Hostel.fromMap(json.decode(source) as Map<String, dynamic>);
}
