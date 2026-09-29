import 'package:flutter/material.dart';

class ShareChatContact {
  final String name;
  final String role;
  final String avatar;
  final Color avatarColor;
  final bool isGroup;
  final bool online;

  const ShareChatContact({
    required this.name,
    required this.role,
    required this.avatar,
    required this.avatarColor,
    this.isGroup = false,
    this.online = false,
  });
}

/// In-app chat contacts available for sharing (matches Messages tab data).
class ShareChatContacts {
  ShareChatContacts._();

  static const _blue = Color(0xFF2563EB);
  static const _emerald = Color(0xFF10B981);
  static const _purple = Color(0xFF7C3AED);
  static const _amber = Color(0xFFF59E0B);
  static const _red = Color(0xFFEF4444);
  static const _teal = Color(0xFF0F766E);

  static final List<ShareChatContact> all = [
    const ShareChatContact(avatar: 'RM', avatarColor: _blue, name: 'Dr. Rohan Mehta', role: 'Cardiologist', online: true),
    const ShareChatContact(avatar: 'NV', avatarColor: _emerald, name: 'Dr. Neha Verma', role: 'Dermatologist', online: true),
    const ShareChatContact(avatar: 'ICU', avatarColor: _purple, name: 'ICU Team Group', role: '8 members', isGroup: true),
    const ShareChatContact(avatar: 'PN', avatarColor: _amber, name: 'Dr. Priya Nair', role: 'Pediatrician'),
    const ShareChatContact(avatar: 'KP', avatarColor: _red, name: 'Dr. Karan Patel', role: 'Orthopedic Surgeon'),
    const ShareChatContact(avatar: 'ND', avatarColor: _teal, name: 'Night Duty Doctors', role: '10 members', isGroup: true),
    const ShareChatContact(avatar: 'AK', avatarColor: _purple, name: 'Dr. Ayesha Khan', role: 'Anesthesiologist', online: true),
    const ShareChatContact(avatar: 'ET', avatarColor: _red, name: 'Emergency Team', role: '6 members', isGroup: true),
    const ShareChatContact(avatar: 'SK', avatarColor: _blue, name: 'Dr. Simran Kaur', role: 'Radiologist'),
    const ShareChatContact(avatar: 'BS', avatarColor: _emerald, name: 'Dr. Bharat Singh', role: 'General Physician'),
  ];
}
