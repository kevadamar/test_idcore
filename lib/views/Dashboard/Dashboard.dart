import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test_idcore/component/pop_up.dart';
import 'package:test_idcore/model/Api.dart';
import 'package:test_idcore/model/Service.dart';
import 'package:test_idcore/router/routerGenerator.dart';
import 'package:test_idcore/utils/AuthUserPrefs.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String name, accessToken;
  bool loading = false, nullData = false;
  final listService = new List<ServiceModel>();
  AuthUserPrefs userPref = new AuthUserPrefs();
  PopUp popUp = new PopUp();

  final GlobalKey<RefreshIndicatorState> _refresh =
      GlobalKey<RefreshIndicatorState>();

  void _getPref() async {
    await userPref.getUserInfo();
    if (userPref.userdata == null) {
      setState(() {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouterGenerator.loginScreen,
          (Route<dynamic> route) => false,
        );
      });
    }
    setState(() {
      name = userPref.name;
      accessToken = userPref.accessToken;
    });
  }

  Future<void> _getListService() async {
    listService.clear();
    setState(() {
      loading = true;
    });
    try {
      await userPref.getUserInfo();

      Map<String, String> reqHeaders = {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${userPref.accessToken}'
      };

      final response = await http.get(
        Uri.parse(UrlAPI.serviceDashboard),
        headers: reqHeaders,
      );
      final responseData = jsonDecode(response.body);
      Map<String, dynamic> resdta = responseData;
      String msg = resdta['message'];

      if (resdta['status'] == 200 && response.statusCode == 200) {
        if (resdta['data'] == null) {
          nullData = true;
        } else {
          resdta['data'].forEach((obj) {
            final ab = new ServiceModel(
              obj['id'],
              obj['service_name'],
            );
            listService.add(ab);
          });
          setState(() {
            loading = false;
            nullData = false;
          });
        }
      } else {
        setState(() {
          loading = false;
          nullData = false;
          popUp.dialogPopUp(context, '${response.statusCode} $msg');
        });
      }
    } catch (e) {
      print("error");
      print(e);
      setState(() {
        popUp.dialogPopUp(context, "Invalid Request");
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _getListService();
    _getPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Welcome, " + (name != null ? name : ""),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _getListService,
        key: _refresh,
        child: loading
            ? Center(child: CircularProgressIndicator())
            : (nullData
                ? ListView(children: <Widget>[
                    Container(
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Center(
                              child: Text(
                                "Data Kosong",
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            )))
                  ])
                : ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: listService.length,
                    itemBuilder: (context, i) {
                      final resData = listService[i];
                      return Container(
                        margin: EdgeInsets.only(
                          top: 10.0,
                          bottom: 10.0,
                          left: 15,
                          right: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          border: Border.all(
                            color: Colors.blue,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              width: 15.0,
                            ),
                            Container(
                              // color: Colors.green,
                              width: MediaQuery.of(context).size.width / 2,
                              height: MediaQuery.of(context).size.height / 10.5,
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(left: 10.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Text(
                                    resData.serviceName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 25.0,
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                  context, RouterGenerator.packageListScreen,
                                  arguments: resData.idService),
                              child: Container(
                                width: MediaQuery.of(context).size.width / 3.7,
                                height:
                                    MediaQuery.of(context).size.height / 12.5,
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(
                                  top: 5.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[500],
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Pilih",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  )),
      ),
    );
  }
}
