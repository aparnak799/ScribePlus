import 'package:ScribePlus/screens/add_prescription.dart';
import 'package:ScribePlus/screens/doctor_login.dart';
import 'package:ScribePlus/screens/processing_prescription.dart';
import 'package:ScribePlus/screens/scan_patient.dart';
import 'package:ScribePlus/screens/view_patient.dart';
import 'package:ScribePlus/screens/add_prescription.dart';
import 'package:ScribePlus/screens/view_appointments.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'Scribe Plus';
    String text = "test";
    return MaterialApp(title: title, home: DoctorLogin());
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
    Text('Upload Call'),
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.green,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text("Home")),
          BottomNavigationBarItem(
              icon: Icon(Icons.camera), title: Text("Scan")),
          BottomNavigationBarItem(
              icon: Icon(Icons.call_to_action), title: Text("Upload Call")),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), title: Text("Account"))
        ],
      ),
    );
  }
}
