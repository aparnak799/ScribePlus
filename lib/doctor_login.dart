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
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _doctorAddress='';
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    

    return new Scaffold(
      key: _scaffoldKey,
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
          child: Text("Login"),
          onPressed: (){
            _postLoginRequest(_doctorAddress, passwordController.text).then((bool result){
              if(result==false){
                setState(() {
                  _doctorAddress='';
                });
        
              final SnackBar snackBar=SnackBar(content:Text('Login Failed'));
              _scaffoldKey.currentState.showSnackBar(snackBar);
              }
            });
          },
        )
      ],
    );

  }
  Future<bool> _postLoginRequest(String userAddress, String password) async{
    String loginURL="$apiUrl/doctor/login";
    final SharedPreferences prefs = await _prefs;
    print({'address':userAddress,'password':password});
    var response=await http.post(loginURL,body:{'address':userAddress,'password':password});
    if(response.statusCode==200)
      {prefs.setString("doctorToken", response.headers['auth-token']);
      return true;}
    else 
      return false;

  }

  Future<String> _scan() async{
    String scannedString= await scanner.scan();
    return scannedString;

  }
}