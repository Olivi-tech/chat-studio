import 'dart:developer';

import 'package:flutter/material.dart';

class EmojiProvider extends ChangeNotifier {
  bool _isShowingEmoji = false;
  get isShowingEmoji => _isShowingEmoji;

  set isShowingEmoji(value) {
    _isShowingEmoji = value;
    notifyListeners();
    log('Emoji notifi lister is called');
  }
}
