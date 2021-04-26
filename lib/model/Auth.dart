import 'package:test_idcore/model/User.dart';

class Auth {
  String accessToken;
  UserModel userData;

  Auth(this.accessToken, this.userData);

  Auth.fromJson(Map<String, dynamic> json) {
    userData =
        json['user_data'] != null ? UserModel.fromJson(json['user_data']) : null;
    accessToken = json['access_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.userData != null) {
      data['user_data'] = this.userData.toJson();
    }
    data['access_token'] = this.accessToken;
    return data;
  }

  @override
  String toString() {
    return '{${userData.toString()},"access_token":$accessToken}';
  }
}
