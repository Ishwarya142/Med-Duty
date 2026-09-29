import 'package:flutter/material.dart';

class CommunityProvider extends ChangeNotifier {

  List posts = [];

  void addPost(dynamic post) {
    posts.add(post);
    notifyListeners();
  }
}