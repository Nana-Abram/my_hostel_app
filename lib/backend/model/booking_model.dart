import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final String hostelId;
  final String roomId;
  final String duration;
  final String status; // pending, approved, rejected
  final String paymentStatus; // paid, unpaid
  final DateTime date;
 

  BookingModel({
    required this.id,
    required this.userId,
    required this.hostelId,
    required this.roomId,
    required this.duration,
    required this.status,
    required this.paymentStatus,
    required this.date,
   
  });

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      id: id,
      userId: map['userId'],
      hostelId: map['hostelId'],
      roomId: map['roomId'],
      duration: map['duration'],
      status: map['status'],
      paymentStatus: map['paymentStatus'],
      date: (map['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "hostelId": hostelId,
      "roomId": roomId,
      "duration": duration,
      "status": status,
      "paymentStatus": paymentStatus,
      "date": date,
    };
  }
}
