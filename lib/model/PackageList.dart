class PackageListModel {
  int idPackage;
  String packageName;
  String priceMax;
  String description;
  int verif;

  PackageListModel(this.idPackage, this.packageName, this.priceMax,this.verif);

  PackageListModel.fromJson(Map<String, dynamic> json) {
    idPackage = json['id'];
    packageName = json['package_name'];
    priceMax = json['price_max'];
    verif = json['verif'];
  }
}
