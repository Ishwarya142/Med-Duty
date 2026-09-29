import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {

  List messages = [];

  void addMessage(dynamic message) {
    messages.add(message);
    notifyListeners();
  }
}