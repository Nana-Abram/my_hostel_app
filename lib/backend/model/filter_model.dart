class HostelFilter {
  final String? campus;
  final String? roomType;
  final String? gender;
  final double? maxPrice;
  final List<String> amenities;

  HostelFilter({
    this.campus,
    this.roomType,
    this.gender,
    this.maxPrice,
    this.amenities = const [],
  });

  HostelFilter copyWith({
    String? campus,
    String? roomType,
    String? gender,
    double? maxPrice,
    List<String>? amenities,
  }) {
    return HostelFilter(
      campus: campus ?? this.campus,
      roomType: roomType ?? this.roomType,
      gender: gender?? this.gender,
      maxPrice: maxPrice ?? this.maxPrice,
      amenities: amenities ?? this.amenities,
    );
  }
}
