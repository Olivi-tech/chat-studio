import 'package:flutter/cupertino.dart';

class SignInProvider extends ChangeNotifier {
  bool _isAnimate = false;
  get isAnimate => _isAnimate;

  set isAnimate(value) {
    _isAnimate = value;
    notifyListeners();
  }

  bool _isSigningIn = false;
  bool get isSigningIn => this._isSigningIn;

  set isSigningIn(bool value) {
    this._isSigningIn = value;
    notifyListeners();
  }
}
