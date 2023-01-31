import 'package:flutter/material.dart';

class ProgressProvider extends ChangeNotifier {
  bool _isUploading = false;
  bool get isUploading => _isUploading;

  set isUploading(bool value) {
    _isUploading = value;
    notifyListeners();
  }
}
