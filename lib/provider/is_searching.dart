import 'package:flutter/material.dart';

class IsSearching extends ChangeNotifier {
  bool _isSearching = false;
  get isSearching => _isSearching;

  set isSearching(value) {
    _isSearching = value;
    notifyListeners();
  }
}
