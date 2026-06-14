import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String hostelId;
  final String hostelName;
  final String userId;
  final String ownerId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String roomId;
  final String roomType;
  final DateTime checkInDate;
  final String? confirmationImage;
  final String? paymentReference;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final String? specialRequests;

  BookingModel({
    required this.id,
    required this.hostelId,
    required this.hostelName,
    required this.userId,
    required this.ownerId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.roomId,
    required this.roomType,
    required this.checkInDate,
    this.confirmationImage,
    this.paymentReference,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.specialRequests,
  });

  factory BookingModel.fromMap(Map<String, dynamic> data, String id) {
    return BookingModel(
      id: id,
      hostelId: data['hostelId'],
      hostelName: data['hostelName'],
      userId: data['userId'],
      ownerId: data['ownerId'],
      userName: data['userName'],
      userEmail: data['userEmail'],
      userPhone: data['userPhone'],
      roomId: data['roomId'],
      roomType: data['roomType'],
      checkInDate: (data['checkInDate'] as Timestamp).toDate(),
      confirmationImage: data['confirmationImage'],
      paymentReference: data['paymentReference'],
      totalPrice: (data['totalPrice'] as num).toDouble(),
      status: data['status'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      specialRequests: data['specialRequests'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hostelId': hostelId,
      'hostelName': hostelName,
      'userId': userId,
      'ownerId': ownerId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'roomId': roomId,
      'roomType': roomType,
      'checkInDate': Timestamp.fromDate(checkInDate),
      if (confirmationImage != null) 'confirmationImage': confirmationImage,
      if (paymentReference != null) 'paymentReference': paymentReference,
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      if (specialRequests != null) 'specialRequests': specialRequests,
    };
  }

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
  bool get isPaid => paymentReference != null;
}
