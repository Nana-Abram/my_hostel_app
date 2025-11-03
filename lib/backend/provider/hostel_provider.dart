import 'package:flutter/material.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';


class HostelProvider extends ChangeNotifier {
  // All hostels
  final List<Hostel> _allHostels = [
    Hostel(
      name: "Baidoo Hostel",
      campus: "UENR Sunyani campus",
      roomType: "Single",
      gender: "Male",
      rating: 4.5,
      reviewsCount: 220,
      price: 3000,
      description:"Affordable accommodation with top-notch facilities and clean environment." ,
      amenities: ["Wi-Fi", "Kitchen", "Study Room"],
      image: "assets/images/h1.jpg",
    ),
    Hostel(
      name: "Victory Towers",
      campus: "KSTU Sunyani campus",
      roomType: "Two in a room",
      gender: "Mixed",
      price: 2500,
      reviewsCount: 180,
      rating: 4.0,
      description: "Well-furnished rooms with all utilities. 3 mins walk to campus.",
      amenities: ["Wi-Fi", "Gym", "Security"],
      image: "assets/images/h2.jpg",
    ),
    Hostel(
      name: "Jayson Hostel",
      campus: "UENR Sunyani campus",
      roomType: "Four in a room",
      gender: "Female",
      rating: 4.6,
      reviewsCount: 347,
      price: 2000,
      description: "Spacious rooms and reliable water supply. Perfect for students.",
      amenities: ["Wi-Fi", "Laundry", "Kitchen"],
      image: "assets/images/top2.jpg",
    ),
    Hostel(
      name: "Berlin Hostel",
      campus: "UENR Sunyani campus",
      roomType: "Four in a room",
      gender: "Female",
      rating: 4.6,
      reviewsCount: 347,
      price: 2000,
      description: "Spacious rooms and reliable water supply. Perfect for students.",
      amenities: ["Wi-Fi", "Laundry", "Kitchen"],
      image: "assets/images/vegas1.jpg",
    ),
    Hostel(
      name: "Las Vegas Hostel",
      campus: "UENR Sunyani campus",
      roomType: "Four in a room",
      gender: "Female",
      rating: 4.6,
      reviewsCount: 347,
      price: 2000,
      description: "Spacious rooms and reliable water supply. Perfect for students.",
      amenities: ["Wi-Fi", "Laundry", "Kitchen"],
      image: "assets/images/h1.jpg",
    ),
  ];

  // Filters
  String? selectedCampus;
  String? selectedRoomType;
  String? selectedGender;

  // Get filtered hostels
  List<Hostel> get filteredHostels {
    return _allHostels.where((h) {
      final campusMatch = selectedCampus == null || h.campus == selectedCampus;
      final roomMatch = selectedRoomType == null || h.roomType == selectedRoomType;
      final genderMatch = selectedGender == null || h.gender == selectedGender;
      return campusMatch && roomMatch && genderMatch;
    }).toList();
  }

  // Update filters
  void updateFilters({String? campus, String? roomType, String? gender}) {
    selectedCampus = campus ?? selectedCampus;
    selectedRoomType = roomType ?? selectedRoomType;
    selectedGender = gender ?? selectedGender;
    notifyListeners();
  }

  // Reset filters
  void clearFilters() {
    selectedCampus = null;
    selectedRoomType = null;
    selectedGender = null;
    notifyListeners();
  }
}
