class ServiceModel {
  int idService;
  String serviceName;

  ServiceModel(this.idService,this.serviceName);

  ServiceModel.fromJson(Map<String,dynamic> json){
    idService = json['id'];
    serviceName = json['service_name'];
  }
}