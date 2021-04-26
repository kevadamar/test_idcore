class UserModel {
  int id;
  String name;
  String email;
  String userid;
  String phone;
  String mobilePhone;
  String birthPlace;
  String birthDate;
  String sex;
  String description;
  String image;
  String status;
  String emailVerifiedAt;
  String createdAt;
  String updatedAt;
  String imageUrl;

  UserModel(
    this.id,
    this.name,
    this.email,
    this.userid,
    this.phone,
    this.mobilePhone,
    this.birthPlace,
    this.birthDate,
    this.sex,
    this.description,
    this.image,
    this.status,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.imageUrl,
  );

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    userid = json['userid'];
    phone = json['phone'];
    mobilePhone = json['mobilePhone'];
    birthPlace = json['birthPlace'];
    birthDate = json['birthDate'];
    sex = json['sex'];
    description = json['description'];
    image = json['image'];
    status = json['status'];
    emailVerifiedAt = json['emailVerifiedAt'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    imageUrl = json['imageUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['userid'] = this.userid;
    data['phone'] = this.phone;
    data['mobilePhone'] = this.mobilePhone;
    data['birthPlace'] = this.birthPlace;
    data['birthDate'] = this.birthDate;
    data['sex'] = this.sex;
    data['description'] = this.description;
    data['image'] = this.image;
    data['status'] = this.status;
    data['emailVerifiedAt'] = this.emailVerifiedAt;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['imageUrl'] = this.imageUrl;
    return data;
  }

  @override
  String toString() {
    return '"user_data" : {"id":$id,"name":$name,"email":$email,"userid":$userid,"phone":$phone,"mobilePhone":$mobilePhone,"birthPlace":$birthPlace,"birthDate":$birthDate,"sex":$sex,"description":$description,"image":$image,"status":$status,"emailVerifiedAt":$emailVerifiedAt,"createdAt":$createdAt,"updatedAt":$updatedAt,"imageUrl":$imageUrl}';
  }
}
