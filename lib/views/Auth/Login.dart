import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:test_idcore/component/pop_up.dart';
import 'package:test_idcore/model/Api.dart';
import 'package:test_idcore/model/Auth.dart';
import 'package:test_idcore/router/routerGenerator.dart';
import 'package:test_idcore/utils/AuthUserPrefs.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  final RegExp emailValidatorRegExp =
      RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _secureText = true, _disabledButton = false;

  PopUp popUp = new PopUp();

  _showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  _checkLogin(context) async {
    try {
      print("ss");
      Map<String, String> reqHeaders = {'Accept': 'application/json'};

      final response = await http.post(
        Uri.parse(UrlAPI.login),
        headers: reqHeaders,
        body: {
          "emailorphone": _emailController.text,
          "password": _passwordController.text
        },
      );
      final responseData = jsonDecode(response.body);

      if (responseData['status'] == 200 && response.statusCode == 200) {
        final Auth userData = Auth.fromJson(responseData);
        setState(() {
          _savePref(userData, responseData['access_token']);
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouterGenerator.dashboardScreen,
            (Route<dynamic> route) => false,
          );
        });
      } else {
        setState(() {
          popUp.dialogPopUp(context, "Invalid Username/Password");
          _disabledButton = false;
        });
      }
    } catch (e) {
      print("Error");
      print(e);
      setState(() {
        popUp.dialogPopUp(context, "Request Failed");
        _disabledButton = false;
      });
    }
  }

  _savePref(Auth userData, String accessToken) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("authUser", jsonEncode(userData));
  }

  _getPref() async {
    AuthUserPrefs userPrefs = new AuthUserPrefs();
    await userPrefs.getUserInfo();

    if (userPrefs.userdata != null) {
      setState(() {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouterGenerator.dashboardScreen,
          (Route<dynamic> route) => false,
        );
      });
    }
  }

  // Email
  Future<void> getUserInfo() async {
    AuthUserPrefs uath = new AuthUserPrefs();
    await uath.getUserInfo();
    print('print ${uath.userdata.email}');
  }

  @override
  void initState() {
    super.initState();
    _getPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.only(top: 90.0, left: 20.0, right: 20.0),
          children: <Widget>[
            Text(
              "Test ID Core \nV0.1",
              textAlign: TextAlign.center,
              textScaleFactor: 1.2,
            ),
            SizedBox(
              height: 20.0,
            ),
            emailFormField(),
            SizedBox(
              height: 20.0,
            ),
            passwordFormField(),
            SizedBox(
              height: 20.0,
            ),
            TextButton(
              onPressed: () {
                // if (!_disabledButton) {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  setState(() {
                    _disabledButton = true;
                  });
                  _checkLogin(context);
                }
              },
              child: Text(
                _disabledButton ? "waiting..." : "LOGIN",
                style: TextStyle(
                    color: _disabledButton ? Colors.white70 : Colors.blue,
                    fontWeight: FontWeight.bold),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  _disabledButton ? Colors.grey[300] : Colors.transparent,
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
            SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Don't have an account?  ",
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    RouterGenerator.registerScreen,
                  ),
                  child: Text(
                    "Sign Up",
                    style: TextStyle(color: Colors.blue),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  TextFormField emailFormField() {
    return TextFormField(
      style: TextStyle(color: Colors.black),
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      onChanged: (value) {
        if (value.isEmpty) {
          return "Email Is Required";
        } else if (!emailValidatorRegExp.hasMatch(value)) {
          return "Format Email Invalid";
        }
      },
      validator: (value) {
        if (value.isEmpty) {
          return "Email Is Required";
        }
        if (RegExp('^[0-9]').hasMatch(value)) {
          if (!RegExp('^[0-9]').hasMatch(value) &&
              !emailValidatorRegExp.hasMatch(value)) {
            return "Format Email Invalid";
          }
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Email Or Phone Number",
        labelStyle: TextStyle(backgroundColor: Colors.transparent),
        hintText: "Example@gmail.com",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        suffixIcon: Icon(
          Icons.person,
          color: Colors.grey,
        ),
      ),
    );
  }

  TextFormField passwordFormField() {
    return TextFormField(
      style: TextStyle(color: Colors.black),
      controller: _passwordController,
      keyboardType: TextInputType.visiblePassword,
      obscureText: _secureText,
      obscuringCharacter: '*',
      onChanged: (value) {
        if (value.isEmpty) {
          return "Password Is Required";
        }
      },
      validator: (value) {
        if (value.isEmpty) {
          return "Password Is Required";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Password",
        labelStyle: TextStyle(backgroundColor: Colors.transparent),
        hintText: "xxxxxxxxxxx",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _secureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () => _showHide(),
        ),
      ),
    );
  }
}
