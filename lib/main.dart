import 'package:ScribePlus/screens/add_prescription.dart';
import 'package:ScribePlus/screens/doctor_login.dart';
import 'package:ScribePlus/screens/processing_prescription.dart';
import 'package:ScribePlus/screens/scan_patient.dart';
import 'package:ScribePlus/screens/view_patient.dart';
import 'package:ScribePlus/screens/add_prescription.dart';
import 'package:ScribePlus/screens/view_appointments.dart';
import 'package:flutter/material.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'Scribe Plus';
    String text = "test";
    return MaterialApp(title: title, 
    theme: ThemeData(
      backgroundColor: Colors.white,
      scaffoldBackgroundColor: Colors.white,
      primaryColor: Color(0xff18C763)
    ),
    home: DoctorLogin());
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
   int selectedIndex = 0;
  final widgetOptions = [
    ViewAppointments(),
    ScanPatient(),
    // New Screen
    Text('Upload Call'),
    // New Screen
    Text('Profile')
  ];
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widgetOptions.elementAt(selectedIndex),
      bottomNavigationBar: BottomNavyBar(
        backgroundColor: Colors.grey[100],
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
              icon: Icon(Icons.crop_free),
              title: Text("Scan"),
              activeColor: Colors.green[300],
              inactiveColor: Colors.black),
          BottomNavyBarItem(
              icon: Icon(Icons.call_to_action),
              title: Text("Upload Call"),
              activeColor: Colors.green[300],
              inactiveColor: Colors.black),
          BottomNavyBarItem(
              icon: Icon(Icons.account_circle),
              title: Text("Account"),
              activeColor: Colors.green[300],
              inactiveColor: Colors.black)
        ],
      ),
    );
  }
}
