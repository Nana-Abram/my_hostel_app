import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; // booking, payment, checkin, general, review, account
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      type: map['type'] as String? ?? 'general',
      data: Map<String, dynamic>.from(map['data'] as Map? ?? {}),
      isRead: map['isRead'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
        'type': type,
        'data': data,
        'isRead': isRead,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        title: title,
        body: body,
        type: type,
        data: data,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );

  IconData get icon {
    switch (type) {
      case 'booking':
        return Icons.hotel_outlined;
      case 'payment':
        return Icons.payment_outlined;
      case 'checkin':
        return Icons.login_outlined;
      case 'review':
        return Icons.star_outline;
      case 'account':
        return Icons.verified_user_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color get color {
    switch (type) {
      case 'booking':
        return const Color(0xFF2196F3);
      case 'payment':
        return const Color(0xFF4CAF50);
      case 'checkin':
        return const Color(0xFFFF9800);
      case 'review':
        return const Color(0xFFFFC107);
      case 'account':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF607D8B);
    }
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  bool get isToday {
    final now = DateTime.now();
    return createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return createdAt.year == yesterday.year &&
        createdAt.month == yesterday.month &&
        createdAt.day == yesterday.day;
  }
}
