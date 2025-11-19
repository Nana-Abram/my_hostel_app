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
    required this.status
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
      reviewsCount: (data["reviewsCount"]as num).toDouble(),
      status: data['status'],
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
      "startPrice":startPrice,
      "reviewsCount":reviewsCount,
      "status":status
    };
  }
}
