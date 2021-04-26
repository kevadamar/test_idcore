import 'dart:async';

import 'package:flutter/material.dart';
import 'package:test_idcore/router/routerGenerator.dart';

class PageWaitingPayment extends StatefulWidget {
  @override
  _PageWaitingPaymentState createState() => _PageWaitingPaymentState();
}

class _PageWaitingPaymentState extends State<PageWaitingPayment> {
  Timer _timer;
  _waitingPayment() {
    _timer = new Timer(const Duration(seconds: 10), () {
      setState(() {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouterGenerator.pageDetailOrderScrren,
          (route) => false,
        );
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _waitingPayment();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Waiting Payment"),
      ),
    );
  }
}
