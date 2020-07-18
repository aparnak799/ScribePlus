import 'package:ScribePlus/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:ScribePlus/url.dart';

class DoctorLogin extends StatefulWidget {
  DoctorLogin({Key key}) : super(key: key);

  _DoctorLoginState createState() => _DoctorLoginState();
}

class _DoctorLoginState extends State<DoctorLogin> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String _doctorAddress;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _doctorAddress = '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Container(
      color: Colors.white,
      child: Column(children: <Widget>[
        Padding(
          child: RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: 'Welcome to Scribe+',
                  style: TextStyle(
                      fontSize: 30.0,
                      color: Colors.black,
                      fontFamily: 'Montserrat')),
            ]),
          ),
          padding: EdgeInsets.only(top: 75, bottom: 50),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10, bottom: 50),
          child: Image.asset(
            'assets/images/scribe1.jpg',
            semanticLabel: 'Scribe Intro',
            fit: BoxFit.fill,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10, bottom: 30),
          child: RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: 'Scan QR Code to get started',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                  )),
            ]),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton.icon(
              icon: Icon(Icons.crop_free),
              label: Text('Scan QR'),
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: Colors.lightGreenAccent[400])),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => scanQRButton()));
              },
              color: Colors.lightGreenAccent[400],
            ),
            RaisedButton.icon(
              icon: Icon(Icons.lock),
              label: Text('Password'),
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: Colors.lightGreenAccent[400])),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => postScanWidget()));
              },
              color: Colors.lightGreenAccent[400],
            )
          ],
        ),
        InkWell(
            child: SizedBox(
                width: double.infinity,
                height: 50,
                child: Container(
                    width: 71,
                    height: 30,
                    child: Stack(children: <Widget>[
                      Positioned(
                          top: 30,
                          left: 71,
                          child: Transform.rotate(
                            angle: 180 * (3.14 / 180),
                            child: SvgPicture.asset('assets/images/vector.svg',
                                semanticsLabel: 'vector'),
                          )),
                      Positioned(
                          top: 4,
                          left: 0,
                          child: Transform.rotate(
                            angle: -3.0617613445625937e-22 * (3.14 / 180),
                            child: Text(
                              'next',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Color.fromRGBO(24, 199, 99, 1),
                                  fontFamily: 'Montserrat',
                                  fontSize: 18,
                                  letterSpacing:
                                      0 /*percentages not used in flutter. defaulting to zero*/,
                                  fontWeight: FontWeight.normal,
                                  height: 1),
                            ),
                          )),
                    ]))))
      ]),
    ));
  }

  Widget scanQRButton() {
    return Center(
        child: RaisedButton.icon(
            icon: Icon(Icons.photo_camera),
            label: Text("Scan Your QR"),
            onPressed: () {
              _scan().then((String scannedString) {
                setState(() {
                  _doctorAddress = scannedString;
                });
              });
            }));
  }

  Widget postScanWidget() {
    TextEditingController passwordController = TextEditingController();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextFormField(
          controller: passwordController,
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
        ),
        RaisedButton(
          child: Text("Login"),
          onPressed: () {
            _postLoginRequest(_doctorAddress, passwordController.text)
                .then((bool result) {
              if (result == false) {
                setState(() {
                  _doctorAddress = '';
                });

                final SnackBar snackBar =
                    SnackBar(content: Text('Login Failed'));
                _scaffoldKey.currentState.showSnackBar(snackBar);
              } else
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => new Home(),
                    ));
            });
          },
        )
      ],
    );
  }

  Future<bool> _postLoginRequest(String userAddress, String password) async {
    String loginURL = "$apiUrl/doctor/login";
    final SharedPreferences prefs = await _prefs;
    print({'address': userAddress, 'password': password});
    var response = await http
        .post(loginURL, body: {'address': userAddress, 'password': password});
    if (response.statusCode == 200) {
      prefs.setString("doctorToken", response.headers['auth-token']);
      prefs.setString("doctorAddress", userAddress);
      return true;
    } else
      return false;
  }

  Future<String> _scan() async {
    String scannedString = await scanner.scan();
    return scannedString;
  }
}
