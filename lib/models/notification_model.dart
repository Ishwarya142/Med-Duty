import 'package:flutter/material.dart';

enum NotificationType {
  emergencyDuty,
  dutyApplication,
  dutyAccepted,
  dutyRejected,
  dutyReminder,
  jobRecommendation,
  jobApplication,
  newFollower,
  followRequest,
  communityInteraction,
  newMessage,
  call,
  profileInteraction,
  system,
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String time;
  final NotificationType type;
  final bool isRead;
  final IconData? icon;
  final Color? iconColor;
  final Map<String, dynamic>? navigationData;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.isRead = false,
    this.icon,
    this.iconColor,
    this.navigationData,
  });

  String get category {
    switch (type) {
      case NotificationType.emergencyDuty:
      case NotificationType.dutyApplication:
      case NotificationType.dutyAccepted:
      case NotificationType.dutyRejected:
      case NotificationType.dutyReminder:
        return 'duties';
      case NotificationType.jobRecommendation:
      case NotificationType.jobApplication:
        return 'jobs';
      case NotificationType.newFollower:
      case NotificationType.followRequest:
      case NotificationType.communityInteraction:
        return 'community';
      case NotificationType.newMessage:
      case NotificationType.call:
        return 'messages';
      case NotificationType.profileInteraction:
      case NotificationType.system:
        return 'system';
    }
  }
}
