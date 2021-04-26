import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test_idcore/component/pop_up.dart';
import 'package:test_idcore/model/Api.dart';
import 'package:test_idcore/router/routerGenerator.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  final RegExp emailValidatorRegExp =
      RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  final RegExp numberValidatorRegExp = RegExp("^[0-9]");

  TextEditingController _emailController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _mobilePhoneController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _secureText = true, _disabledButton = false;

  PopUp popUp = new PopUp();

  _showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  _checkRegister(context) async {
    try {
      // print("ss");
      Map<String, String> reqHeaders = {'Accept': 'application/json'};

      final response = await http.post(
        Uri.parse(UrlAPI.register),
        headers: reqHeaders,
        body: {
          "email": _emailController.text,
          "name": _nameController.text,
          "mobile_phone": _mobilePhoneController.text,
          "password": _passwordController.text
        },
      );
      final responseData = jsonDecode(response.body);

      if (responseData['status'] == 200 || response.statusCode == 200) {
        setState(() {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouterGenerator.loginScreen,
            (Route<dynamic> route) => false,
          );
          // _disabledButton = false;
        });
      } else {
        setState(() {
          popUp.dialogPopUp(context, "Invalid Data");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: 10.0,
            left: 15.0,
            right: 15.0,
          ),
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 20.0,
              ),
              Text(
                "Register Account",
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(
                height: 35.0,
              ),
              signUpForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget signUpForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          emailFormField(),
          SizedBox(
            height: 20.0,
          ),
          nameFormField(),
          SizedBox(
            height: 20.0,
          ),
          mobilePhoneFormField(),
          SizedBox(
            height: 20.0,
          ),
          passwordFormField(),
          SizedBox(
            height: 20.0,
          ),
          TextFormField(
            style: TextStyle(color: Colors.black),
            keyboardType: TextInputType.visiblePassword,
            onChanged: (value) {
              if (value.isEmpty) {
                return "Password Is Required";
              }
              if (value != _passwordController.text) {
                return "password doesn't match";
              }
            },
            validator: (value) {
              if (value.isEmpty) {
                return "Password Is Required";
              }
              if (value != _passwordController.text) {
                return "password doesn't match";
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: "Confirmation Password",
              labelStyle: TextStyle(backgroundColor: Colors.transparent),
              hintText: "Re-type Password",
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
          ),
          SizedBox(
            height: 20.0,
          ),
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
                  _checkRegister(context);
                }
              },
              child: Text(
                _disabledButton ? "waiting..." : "REGISTER",
                style: TextStyle(
                  color: _disabledButton ? Colors.white70 : Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
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
          ),
          SizedBox(
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Already have an account?  ",
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouterGenerator.loginScreen,
                  (Route<dynamic> route) => false,
                ),
                child: Text(
                  "Sign In",
                  style: TextStyle(color: Colors.blue),
                ),
              )
            ],
          ),
        ],
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
        } else if (RegExp('^[0-9]').hasMatch(value)) {
          if (!emailValidatorRegExp.hasMatch(value)) {
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

  TextFormField nameFormField() {
    return TextFormField(
      style: TextStyle(color: Colors.black),
      controller: _nameController,
      keyboardType: TextInputType.name,
      onChanged: (value) {
        if (value.isEmpty) {
          return "Name Is Required";
        }
      },
      validator: (value) {
        if (value.isEmpty) {
          return "name Is Required";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Name",
        labelStyle: TextStyle(backgroundColor: Colors.transparent),
        hintText: "Example Name",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        suffixIcon: Icon(
          Icons.featured_play_list,
          color: Colors.grey,
        ),
      ),
    );
  }

  TextFormField mobilePhoneFormField() {
    return TextFormField(
      style: TextStyle(color: Colors.black),
      controller: _mobilePhoneController,
      keyboardType: TextInputType.phone,
      onChanged: (value) {
        if (value.isEmpty) {
          return "Mobile Phone Is Required";
        }
      },
      validator: (value) {
        if (value.isEmpty) {
          return "Mobile Phone Is Required";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Mobile Phone",
        labelStyle: TextStyle(backgroundColor: Colors.transparent),
        hintText: "08xxxxxxx",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        suffixIcon: Icon(
          Icons.phone_android,
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
