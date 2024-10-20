import 'package:flutter/material.dart';
import 'package:splitsync/Models/user.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  void setUser(User user) {
    _currentUser = user;
    print('User set: ${user.username}, ${user.email}'); // Debugging log

    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}
