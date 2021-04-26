import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:test_idcore/component/pop_up.dart';
import 'package:test_idcore/model/Api.dart';
import 'package:test_idcore/model/Domisili.dart';
import 'package:test_idcore/model/MethodPayment.dart';
import 'package:test_idcore/router/routerGenerator.dart';
import 'package:test_idcore/utils/AuthUserPrefs.dart';
import 'package:test_idcore/utils/LocationUtil.dart';

class PageOrder extends StatefulWidget {
  @override
  _PageOrderState createState() => _PageOrderState();
}

class _PageOrderState extends State<PageOrder> {
  final _formKey = GlobalKey<FormState>();
  AuthUserPrefs userPref = new AuthUserPrefs();
  PopUp popUp = new PopUp();
  bool _disabledButton = false;
  final _locationUtil = new LocationUtil();
  static DateTime now = DateTime.now();
  String formattedDate = DateFormat('dd MMMM yyyy  – kk:mm').format(now);
  bool isFetchLatlong = false,
      isFetchMethodPayment = false,
      isFetchDomisili = false;
  DomisiliModel _currentDomisili;
  // String _currentMethodPaymentId;
  String idDomisili, idMethodPayment;
  List listMethod = List();
  List listDomisili = List();

  TextEditingController _addressController = TextEditingController();
  TextEditingController _addressNoteController = TextEditingController();
  TextEditingController _latitudeController = TextEditingController();
  TextEditingController _longitudeController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isFetchLatlong = true;
      isFetchMethodPayment = true;
      isFetchDomisili = true;
    });
    // print(now);
    _getAllList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Page Order"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            SizedBox(
              height: 15.0,
            ),
            addressFormField(),
            SizedBox(
              height: 15.0,
            ),
            addressNoteFormField(),
            SizedBox(
              height: 15.0,
            ),
            TextFormField(
              controller: _latitudeController,
              readOnly: true,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                alignLabelWithHint: true,
                labelText: "Latitude",
                labelStyle: TextStyle(
                  backgroundColor: Colors.transparent,
                ),
                hintText: (isFetchLatlong
                    ? "Get Location..."
                    : _latitudeController.text),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                  borderSide: BorderSide(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 15.0,
            ),
            TextFormField(
              controller: _longitudeController,
              readOnly: true,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                alignLabelWithHint: true,
                labelText: "Longitude",
                labelStyle: TextStyle(
                  backgroundColor: Colors.transparent,
                ),
                hintText: (isFetchLatlong
                    ? "Get Location..."
                    : _longitudeController.text),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                  borderSide: BorderSide(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 15.0,
            ),
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                alignLabelWithHint: true,
                labelText: "Date Time Ordered",
                labelStyle: TextStyle(
                  backgroundColor: Colors.transparent,
                ),
                hintText: formattedDate,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                  borderSide: BorderSide(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 15.0,
            ),
            Container(
              padding: EdgeInsets.only(
                left: 10.0,
                right: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _dropDownDomisili(),
                  SizedBox(
                    width: 12.0,
                  ),
                  _dropDownMethodPayment(),
                ],
              ),
            ),

            SizedBox(
              height: 15.0,
            ),
            // Button Order
            Container(
              width: MediaQuery.of(context).size.width,
              child: TextButton(
                onPressed: () {
                  // if (!_disabledButton) {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    setState(() {
                      _disabledButton = true;
                    });
                    _checkOrder(context);
                  }
                },
                child: Text(
                  _disabledButton ? "waiting..." : "ORDER",
                  style: TextStyle(
                    color: _disabledButton ? Colors.white70 : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    _disabledButton ? Colors.grey[300] : Colors.blue,
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      side: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _checkOrder(context) async {
    try {
      await userPref.getUserInfo();
      Map<String, String> reqHeaders = {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${userPref.accessToken}'
      };

      final response = await http.post(
        Uri.parse(UrlAPI.orderItem),
        headers: reqHeaders,
        body: {
          "address": _addressController.text,
          "address_note": _addressNoteController.text,
          "latitude": _latitudeController.text,
          "longitude": _longitudeController.text,
          "domisili_id": idDomisili,
          "method_payment_id": idMethodPayment,
          "date_time_ordered": now.toString(),
        },
      );
      final responseData = jsonDecode(response.body);

      if (responseData['status'] == 200 || response.statusCode == 200) {
        // note berhubung api create order error, namun ketika jika saya diberi kesempatan untuk memberbaiki saya perbaiki sesuai response api
        // saya langsung buat ke waiting payment
        setState(() {
          Navigator.pushReplacementNamed(
            context,
            RouterGenerator.pageWaitingPaymentScreen,
          );
          _disabledButton = false;
        });
      } else {
        setState(() {
          popUp.dialogPopUp(context, responseData['message']);
          _disabledButton = false;
        });
      }
    } catch (e) {
      print("error order");
      print(e);
      setState(() {
        _disabledButton = false;
      });
    }
  }

  Future<void> _getAllList() async {
    Position getltlng = await _locationUtil.determinePosition();
    await _getListMethodPayment();
    await _getListDomisili();
    _latitudeController.text = getltlng.latitude.toString();
    _longitudeController.text = getltlng.longitude.toString();
  }

  // ignore: missing_return
  Future<void> _getListDomisili() async {
    try {
      await userPref.getUserInfo();
      // print(userPref.accessToken);
      Map<String, String> reqHeaders = {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${userPref.accessToken}'
      };
      final response = await http.get(
        Uri.parse(UrlAPI.domisiliList),
        headers: reqHeaders,
      );
      final responseData = jsonDecode(response.body);
      Map<String, dynamic> resdta = responseData;
      String msg = resdta['message'];
      if (responseData['status'] == 200 || response.statusCode == 200) {
        final items = responseData['data']['domisili'];
        List<DomisiliModel> listOfDomisili = items.map<DomisiliModel>((json) {
          return DomisiliModel.fromJson(json);
        }).toList();
        setState(() {
          listDomisili = listOfDomisili;
          isFetchMethodPayment = false;
        });
      } else {
        setState(() {
          popUp.dialogPopUp(context, msg);
          _disabledButton = false;
        });
      }
    } catch (e) {
      print("Error domisili");
      print(e);
    }
  }

  // ignore: missing_return
  Future<void> _getListMethodPayment() async {
    try {
      await userPref.getUserInfo();
      // print(userPref.accessToken);
      Map<String, String> reqHeaders = {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${userPref.accessToken}'
      };
      final response = await http.get(
        Uri.parse(UrlAPI.methodPaymentList),
        headers: reqHeaders,
      );
      final responseData = jsonDecode(response.body);
      Map<String, dynamic> resdta = responseData;
      String msg = resdta['message'];
      if (responseData['status'] == 200 || response.statusCode == 200) {
        final items = responseData['data']['method_payment'];
        List<MethodPaymentModel> listOfMethodPayment =
            items.map<MethodPaymentModel>((json) {
          // print(json);
          return MethodPaymentModel.fromJson(json);
        }).toList();
        setState(() {
          listMethod = listOfMethodPayment;
          isFetchMethodPayment = false;
        });
      } else {
        setState(() {
          popUp.dialogPopUp(context, msg);
          _disabledButton = false;
        });
      }
    } catch (e) {
      print("Error method");
      print(e);
    }
  }

  TextFormField addressFormField() {
    return TextFormField(
      style: TextStyle(color: Colors.black),
      controller: _addressController,
      keyboardType: TextInputType.multiline,
      maxLines: 5,
      onChanged: (value) {
        if (value.isEmpty) {
          return "Address Is Required";
        }
      },
      validator: (value) {
        if (value.isEmpty) {
          return "Address Is Required";
        }
        return null;
      },
      decoration: InputDecoration(
        alignLabelWithHint: true,
        labelText: "Address",
        labelStyle: TextStyle(
          backgroundColor: Colors.transparent,
        ),
        hintText: "Jl. example",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
          borderSide: BorderSide(
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _dropDownDomisili() {
    return DropdownButton(
      hint:
          (isFetchMethodPayment ? CircularProgressIndicator() : Text("Select")),
      items: listDomisili.map((e) {
        return DropdownMenuItem(
          child: Text(e.nameDomisili),
          value: e.idDomisili.toString(),
        );
      }).toList(),
      onChanged: (newVal) {
        print(newVal);
        setState(() {
          idDomisili = newVal;
        });
      },
      value: idDomisili,
    );
  }

  Widget _dropDownMethodPayment() {
    // print(listMethod);
    return DropdownButton(
      hint:
          (isFetchMethodPayment ? CircularProgressIndicator() : Text("Select")),
      items: listMethod.map((e) {
        return DropdownMenuItem(
          child: Text(e.nameMethodPayment),
          value: e.idMethodPayment.toString(),
        );
      }).toList(),
      onChanged: (newVal) {
        print(newVal);
        setState(() {
          idMethodPayment = newVal;
        });
      },
      value: idMethodPayment,
    );
  }

  TextFormField addressNoteFormField() {
    return TextFormField(
      style: TextStyle(color: Colors.black),
      controller: _addressNoteController,
      keyboardType: TextInputType.multiline,
      maxLines: 3,
      onChanged: (value) {
        if (value.isEmpty) {
          return "Address Note Is Required";
        }
      },
      validator: (value) {
        if (value.isEmpty) {
          return "Address Note Is Required";
        }
        return null;
      },
      decoration: InputDecoration(
        alignLabelWithHint: true,
        labelText: "Address Note",
        labelStyle: TextStyle(
          backgroundColor: Colors.transparent,
        ),
        hintText: "Example.....",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
          borderSide: BorderSide(
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }
}
