import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_idcore/component/pop_up.dart';
import 'package:test_idcore/model/Api.dart';
import 'package:test_idcore/model/PackageList.dart';
import 'package:test_idcore/router/routerGenerator.dart';
import 'package:test_idcore/utils/AuthUserPrefs.dart';

// ignore: must_be_immutable
class PackageList extends StatefulWidget {
  int idService;

  PackageList({@required this.idService});

  @override
  _PackageListState createState() => _PackageListState();
}

class _PackageListState extends State<PackageList> {
  bool loading = false, nullData = false, verif = false;
  final money = NumberFormat("#,##0", "en_US");
  final listPackage = new List<PackageListModel>();
  final listDataPackage = new Map<String, dynamic>();
  var getData;

  TextEditingController _commentController = TextEditingController();
  TextEditingController _qtyController = TextEditingController();

  AuthUserPrefs userPref = new AuthUserPrefs();
  PopUp popUp = new PopUp();
  final GlobalKey<RefreshIndicatorState> _refresh =
      GlobalKey<RefreshIndicatorState>();

  void _setListData(String key, List<String> value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<String> keyOrder = [];
    var oldPref = pref.getStringList(key);
    var oldPrefKey = pref.getStringList('keyOrder');

    if (oldPrefKey != null && oldPrefKey.length > 0) {
      oldPrefKey.forEach((element) {
        var inPrefData = pref.getStringList(element);
        if (inPrefData != null && inPrefData[0] != key) {
          keyOrder.add(element);
        }
      });
    }
    keyOrder.add(key);

    if (oldPref != null) {
      await pref.remove(key);
      await pref.remove('keyOrder');
    }

    pref.setStringList(key, value);
    pref.setStringList('keyOrder', keyOrder);
    setState(() {
      Navigator.pop(context);
      _getPackageList();
    });
  }

  Future<void> _getListData(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    getData = pref.getStringList(key);
    _commentController.clear();
    _qtyController.clear();
    if (getData != null) {
      _commentController.text = getData[2];
      _qtyController.text = getData[1];
    } else {
      _qtyController.text = '1';
    }
  }

  Future<void> _resetFromList(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool getData = await pref.remove(key);
    var getKey = pref.getStringList('keyOrder');

    if (getKey != null) {
      getKey.remove(key);
      pref.setStringList('keyOrder', getKey);
    }
    // await pref.remove('keyOrder');
    if (getData) {
      listDataPackage.remove(key);
      setState(() {
        Navigator.pop(context);
        _getPackageList();
      });
    } else {
      print(getData);
    }
  }

  Future<int> _checkAdded(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final getData = pref.getStringList(key);
    if (getData == null) {
      return 0;
    } else {
      if (listDataPackage[key] == null) {
        listDataPackage.addAll({key: getData});
      }
      return 1;
    }
  }

  Future<void> _getPackageList() async {
    listPackage.clear();
    setState(() {
      loading = true;
    });
    try {
      await userPref.getUserInfo();
      // print(userPref.accessToken);
      Map<String, String> reqHeaders = {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${userPref.accessToken}'
      };

      final response = await http.get(
        Uri.parse(UrlAPI.packageList + '${widget.idService}'),
        headers: reqHeaders,
      );
      final responseData = jsonDecode(response.body);
      Map<String, dynamic> resdta = responseData;
      String msg = resdta['message'];

      if (resdta['status'] == 200 && response.statusCode == 200) {
        if (resdta['data'] == null) {
          setState(() {
            loading = false;
            nullData = true;
          });
        } else {
          resdta['data'].forEach((obj) async {
            var checkAdded = await _checkAdded(obj['id'].toString());
            final ab = new PackageListModel(
                obj['id'], obj['package_name'], obj['price_max'], checkAdded);
            listPackage.add(ab);
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
    }
  }

  remo() async {
    SharedPreferences r = await SharedPreferences.getInstance();
    r.clear();
  }

  @override
  void initState() {
    super.initState();
    _getPackageList();
    _qtyController.text = '1';
    // remo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Package List"),
      ),
      floatingActionButton: Container(
        alignment: Alignment.bottomCenter,
        width: MediaQuery.of(context).size.width,
        child: FloatingActionButton.extended(
          backgroundColor: Colors.grey[500],
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onPressed: () => listDataPackage.length > 0
              ? Navigator.pushNamed(context, RouterGenerator.pageOrderScreen)
              : null,
          label: Text((listDataPackage.length > 0
              ? '${listDataPackage.length} Item, Selanjutnya'
              : "Mari Order")),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _getPackageList,
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
                    itemCount: listPackage.length,
                    itemBuilder: (context, i) {
                      final resData = listPackage[i];
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
                              height: MediaQuery.of(context).size.height / 7.5,
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(
                                left: 10.0,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  // Text(resData.idPackage.toString()),
                                  Text(
                                    '${resData.packageName}\n\nRp.${money.format(int.parse(resData.priceMax))}',
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
                              onTap: () => _showModalBottomSheet(context,
                                  resData.idPackage.toString(), resData.verif),
                              child: Container(
                                width: MediaQuery.of(context).size.width / 4.5,
                                height:
                                    MediaQuery.of(context).size.height / 15.5,
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(
                                  top: 25.0,
                                ),
                                decoration: BoxDecoration(
                                  // ignore: unrelated_type_equality_checks
                                  color: (resData.verif != 0
                                      ? Colors.green[200]
                                      : Colors.grey[500]),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      (resData.verif == 1 ? "Added" : "Add"),
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

  Widget _qtyComp(String key) {
    var digitsOnly = WhitelistingTextInputFormatter.digitsOnly;
    return Padding(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: TextFormField(
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(8.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              controller: _qtyController,
              keyboardType: TextInputType.numberWithOptions(
                decimal: false,
                signed: true,
              ),
              inputFormatters: <TextInputFormatter>[digitsOnly],
            ),
          ),
          Container(
            height: 38.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: InkWell(
                    child: Icon(
                      Icons.arrow_drop_up,
                      size: 18.0,
                    ),
                    onTap: () {
                      int currentValue = int.parse(_qtyController.text);
                      setState(() {
                        currentValue++;
                        _qtyController.text =
                            (currentValue).toString(); // incrementing value
                      });
                    },
                  ),
                ),
                InkWell(
                  child: Icon(
                    Icons.arrow_drop_down,
                    size: 18.0,
                  ),
                  onTap: () {
                    int currentValue = int.parse(_qtyController.text);
                    setState(() {
                      // print("Setting state");
                      currentValue--;
                      _qtyController.text =
                          (currentValue > 0 ? currentValue : 0)
                              .toString(); // decrementing value
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showModalBottomSheet(context, String idPackage, int verif) async {
    await _getListData(idPackage);
    // l.add("");
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext bc) {
          return Container(
            padding: EdgeInsets.all(10.0),
            child: Wrap(
              children: <Widget>[
                SizedBox(
                  height: 15.0,
                ),
                Text(
                  "Quantity",
                  style: TextStyle(
                    fontSize: 18.0,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                _qtyComp(
                  idPackage,
                ),
                SizedBox(
                  height: 15.0,
                ),
                TextFormField(
                  controller: _commentController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Comment",
                    hintText: "comment.....",
                    labelStyle: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                GestureDetector(
                  onTap: () {
                    final l = new List<String>();
                    l.add(idPackage);
                    l.add(_qtyController.text);
                    l.add(_commentController.text);
                    // print(l);
                    _setListData(idPackage, l);
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 10.0),
                    padding: EdgeInsets.only(right: 15.0),
                    alignment: Alignment.centerRight,
                    // width: MediaQuery.of(context).size.width /2,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 35.0,
                        ),
                        Text(
                          "Save",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                (verif == 1
                    ? GestureDetector(
                        onTap: () {
                          _resetFromList(idPackage);
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 10.0),
                          padding: EdgeInsets.only(right: 15.0),
                          alignment: Alignment.centerRight,
                          // width: MediaQuery.of(context).size.width /2,
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 35.0,
                              ),
                              Text(
                                "Reset",
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
                    : SizedBox(
                        width: 0.0,
                      )),
              ],
            ),
          );
        });
  }
}
