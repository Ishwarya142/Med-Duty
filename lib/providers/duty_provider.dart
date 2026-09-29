import 'package:flutter/material.dart';

class DutyProvider extends ChangeNotifier {

  List duties = [];

  void addDuty(dynamic duty) {
    duties.add(duty);
    notifyListeners();
  }
}