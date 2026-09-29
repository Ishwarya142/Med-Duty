import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {

  String name = "";

  void updateName(String value) {
    name = value;
    notifyListeners();
  }
}