class MethodPaymentModel {
  int idMethodPayment;
  String nameMethodPayment;

  MethodPaymentModel(this.idMethodPayment, this.nameMethodPayment);

  MethodPaymentModel.fromJson(Map<String, dynamic> json) {
    idMethodPayment = json['id'];
    nameMethodPayment = json['name'];
  }
}
