import 'package:flutter/material.dart';
import 'package:test_idcore/router/routerGenerator.dart';

class PageDetailOrder extends StatefulWidget {
  @override
  _PageDetailOrderState createState() => _PageDetailOrderState();
}

class _PageDetailOrderState extends State<PageDetailOrder> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => setState(() => Navigator.pushNamedAndRemoveUntil(
                context,
                RouterGenerator.dashboardScreen,
                (route) => false,
              )),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.arrow_left,
                size: 30.0,
              ),
              Text("Dashboard"),
            ],
          ),
        ),
      ),
      body: Center(
        child: Text("Detail Order"),
      ),
    );
  }
}
