class UrlAPI {
  static const _baseUrl = 'https://olla.idcore.id/apics/';

  // Auth
  static const login = '${_baseUrl}login';
  static const register = '${_baseUrl}register';

  // Service
  static const serviceDashboard = '${_baseUrl}service';
  static const packageList = '${_baseUrl}package-list/';
  static const orderDetail = '${_baseUrl}order-detail/';

  static const orderItem = '${_baseUrl}create-order';
  static const domisiliList = '${_baseUrl}domisili';
  static const methodPaymentList = '${_baseUrl}method-payment';
}
