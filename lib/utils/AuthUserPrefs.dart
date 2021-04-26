import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_idcore/model/Auth.dart';
import 'package:test_idcore/model/User.dart';

class AuthUserPrefs {
  UserModel _userdata;
  String name;
  String _accessToken;

  UserModel get userdata => _userdata;

  String get accessToken => _accessToken;

  String get getName => name;

  Future<void> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userStr = prefs.getString('authUser');
    Map<String, dynamic> userMap;

    if (userStr != null) {
      userMap = jsonDecode(userStr) as Map<String, dynamic>;
    }

    if (userMap != null) {
      final Auth user = Auth.fromJson(userMap);
      // print(user.accessToken);
      _userdata = user.userData;
      name = user.userData.name;
      _accessToken = user.accessToken;
    }

    if (userStr == null || userMap == null) {
      // print("out");
      _userdata = null;
    }

  }
}
