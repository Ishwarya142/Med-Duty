import 'package:flutter/material.dart';

class LocationProvider extends ChangeNotifier {

  double latitude = 0;
  double longitude = 0;

  void updateLocation(double lat, double lng) {
    latitude = lat;
    longitude = lng;
    notifyListeners();
  }
}