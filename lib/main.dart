import 'dart:async';
import 'package:ScribePlus/screens/add_prescription.dart';
import 'package:ScribePlus/screens/doctor_login.dart';
import 'package:ScribePlus/screens/processing_prescription.dart';
import 'package:ScribePlus/screens/scan_patient.dart';
import 'package:ScribePlus/screens/view_doctor_details.dart';
import 'package:ScribePlus/screens/view_patient.dart';
import 'package:ScribePlus/screens/add_prescription.dart';
import 'package:ScribePlus/screens/view_appointments.dart';
import 'package:ScribePlus/screens/edit_prescription.dart';
import 'package:flutter/material.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'Scribe Plus';
    // String text1 = "test1";
    // String text2 = "test2";
    return MaterialApp(
        title: title,
        theme: ThemeData(
          backgroundColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
          primaryColor: Color(0xff18C763),
        ),
        home: DoctorLogin(
            // patientAddress: text1,
            // socketEvent: text2,
            ));
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
//  static const platform = const MethodChannel('scribeplus.sendstring');
//  String receivedString = "";
//
//  Future<void> callNativeFunction() async {
//    String msg = "Hello from Flutter", data = "";
//    try {
//      final String temp =
//          await platform.invokeMethod('callSendStringFun', {"arg": msg});
//      data = temp;
//    } on PlatformException catch (e) {
//      data = "Failed";
//    }
//    setState(() {
//      receivedString = data;
//    });
//  }
//
//  Future<void> stopFuncOp() async {
//    bool data = false;
//    try {
//      final bool temp =
//      await platform.invokeMethod('stopRecord');
//      data = temp;
//    } on PlatformException catch (e) {
//      data = false;
//    }
//    print("data is $data");
//  }

  int selectedIndex = 0;
  final widgetOptions = [
    ViewAppointments(),
    ScanPatient(),
    // New Screen
    Text('Upload Call'),
    // New Screen
    DoctorDetails(),
    UploadAudioPrescription(
      patientAddress: null,
    ),
    // EditPrescription(patientAddress: null, prescription: null)
  ];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: AppBar(
//        title: Text("CallNative"),
//      ),
//      body: Center(
//        child: Column(
//          mainAxisAlignment: MainAxisAlignment.center,
//          children: <Widget>[
//            RaisedButton(
//              onPressed:
//                  callNativeFunction, //callNativeFunction is called on button pressed
//              child: Text("Start"),
//            ),
//            RaisedButton(
//              onPressed:
//              stopFuncOp, //callNativeFunction is called on button pressed
//              child: Text("Stop"),
//            ),
//            Text('$receivedString'),
//          ],
//        ),
//      ),
      body: widgetOptions.elementAt(selectedIndex),
      bottomNavigationBar: BottomNavyBar(
        showElevation: false,
        backgroundColor: Colors.white,
        selectedIndex: selectedIndex,
        onItemSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
              icon: Icon(Icons.home),
              title: Text("Home"),
              activeColor: Colors.green[300],
              inactiveColor: Colors.black),
          BottomNavyBarItem(
              icon: Icon(Icons.camera_front),
              title: Text("Scan"),
              activeColor: Colors.green[300],
              inactiveColor: Colors.black),
          BottomNavyBarItem(
              icon: Icon(Icons.call_received),
              title: Text("Upload Call"),
              activeColor: Colors.green[300],
              inactiveColor: Colors.black),
          BottomNavyBarItem(
              icon: Icon(Icons.account_circle),
              title: Text("Account"),
              activeColor: Colors.green[300],
              inactiveColor: Colors.black),
          BottomNavyBarItem(
              icon: Icon(Icons.business_center),
              title: Text("Anonymous"),
              activeColor: Colors.green[300],
              inactiveColor: Colors.black)
        ],
      ),
    );
  }
}
