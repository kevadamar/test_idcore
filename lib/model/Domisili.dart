class DomisiliModel {
  int idDomisili;
  String nameDomisili;

  DomisiliModel(this.idDomisili, this.nameDomisili);

  DomisiliModel.fromJson(Map<String, dynamic> json) {
    idDomisili = json['id'];
    nameDomisili = json['name'];
  }
}
