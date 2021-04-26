import 'package:flutter/material.dart';
import 'package:test_idcore/views/Auth/Login.dart';
import 'package:test_idcore/views/Auth/Register.dart';
import 'package:test_idcore/views/Dashboard/Dashboard.dart';
import 'package:test_idcore/views/Package/PackageList.dart';
import 'package:test_idcore/views/PageOrder/PageOrder.dart';
import 'package:test_idcore/views/PageOrder/PageOrderDetail.dart';
import 'package:test_idcore/views/PageWaitingPayment/PageWaitingPayment.dart';

class RouterGenerator {
  static const loginScreen = "/login";
  static const registerScreen = "/register";
  static const dashboardScreen = "/dashboard";
  static const packageListScreen = "/package-list";
  static const pageOrderScreen = "/page-order";
  static const pageWaitingPaymentScreen = "/page-waiting-payment";
  static const pageDetailOrderScrren = "/page-detail-order";

  // ignore: missing_return
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case loginScreen:
        return MaterialPageRoute(builder: (_) => Login());
        break;
      case registerScreen:
        return MaterialPageRoute(builder: (_) => Register());
        break;
      case dashboardScreen:
        return MaterialPageRoute(builder: (_) => Dashboard());
        break;
      case packageListScreen:
        return MaterialPageRoute(
            builder: (_) => PackageList(
                  idService: args,
                ));
        break;
      case pageOrderScreen:
        return MaterialPageRoute(builder: (_) => PageOrder());
        break;
      case pageWaitingPaymentScreen:
        return MaterialPageRoute(builder: (_) => PageWaitingPayment());
        break;
      case pageDetailOrderScrren:
        return MaterialPageRoute(builder: (_) => PageDetailOrder());
        break;
    }
  }
}
