import 'package:flutter/material.dart';

import 'url.dart';

import 'package:qrscan/qrscan.dart' as scanner;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DoctorLogin extends StatefulWidget {
  DoctorLogin({Key key}) : super(key: key);

  _DoctorLoginState createState() => _DoctorLoginState();
}

class _DoctorLoginState extends State<DoctorLogin> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String _doctorAddress;

  @override
  void initState() {
    _doctorAddress='';
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _doctorAddress==''?
            this.scanQRButton():
            this.postScanWidget()
        ],
      )
    );
  }

  Widget scanQRButton(){
    return RaisedButton.icon(
      icon: Icon(Icons.photo_camera),
      label: Text("Scan Your QR"),
      onPressed: (){
        _scan().then((String scannedString){
          setState(() {
          _doctorAddress=scannedString;
        });
        });
        
        }
    );

  }

  Widget postScanWidget(){
    TextEditingController passwordController=TextEditingController();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextFormField(
          controller: passwordController,
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
        ),
        RaisedButton(
          child: Text("login"),
          onPressed: (){
            _postLoginRequest(_doctorAddress, passwordController.text);
            print(passwordController.text);
            // login();
          },
        )
      ],
    );

  }
  Future _postLoginRequest(String userAddress, String password) async{
    String loginURL="$apiUrl/doctor/login";
    print({'address':userAddress,'password':password});
    var response=await http.post(loginURL,body:{'address':userAddress,'password':password});
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');   
  }

  Future<String> _scan() async{
    final SharedPreferences prefs = await _prefs;
    String scannedString= await scanner.scan();
    prefs.setString("doctorAddress", scannedString);
    return scannedString;

  }
}