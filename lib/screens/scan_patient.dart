import 'package:ScribePlus/screens/view_patient.dart';
import 'package:flutter/material.dart';

import 'package:qrscan/qrscan.dart' as scanner;

class ScanPatient extends StatefulWidget {
  @override
  _ScanPatientState createState() => _ScanPatientState();
}

class _ScanPatientState extends State<ScanPatient> {
  String patientAddress;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RaisedButton.icon(
          icon: Icon(Icons.camera_alt),
          label: Text("Scan"),
          onPressed: (){
            _scan().then((String scannedString){
              setState(() {
                this.patientAddress=scannedString;
              });
              print('SS');
              print(scannedString);
              Navigator.push(context,new MaterialPageRoute(builder: (context)=>new ViewPatient(patientQr: this.patientAddress)));
            });
            
          },
        ),
      ),
    );
  }
  Future<String> _scan() async{
    String scannedString= await scanner.scan();
    return scannedString;
  }
}