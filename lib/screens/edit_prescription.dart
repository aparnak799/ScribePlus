import 'dart:convert';
import 'dart:io';

import 'package:ScribePlus/backWidget.dart';
import 'package:ScribePlus/screens/view_patient.dart';
import 'package:beauty_textfield/beauty_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:ScribePlus/url.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Medicine {
  final String dosage;
  final String duration;
  final String foodtime;
  final String form;
  final String freq;
  final String medicine;
  final String route;
  final String strength;
  final String onone;
  Medicine(
      {this.dosage,
      this.duration,
      this.foodtime,
      this.form,
      this.freq,
      this.medicine,
      this.route,
      this.strength,
      this.onone});
}

List<Map> items = [
  {
    "dosage": "3",
    "duration": "",
    "foodtime": "(AF)",
    "form": "tablets",
    "frequency": "every morning and night after meal and apply",
    "medicine": "Hydroxychloroquine 20 mg",
    "onone": "1-0-1",
    "route": "",
    "strength": "20 mg"
  },
  {
    "dosage": "20ml",
    "duration": "for the next 7 days",
    "foodtime": "",
    "form": "Ointment",
    "frequency": "every night once a day",
    "medicine": "QC 8 Eye Ointment 20ml",
    "onone": "0-0-1",
    "route": "",
    "strength": ""
  }
];

class EditPrescription extends StatefulWidget {
  final List prescription;
  final String patientAddress;
  final String patientName;
  final String patientAge;
  final String patientPhone;
  final String patientGender;
  final String patientEmail;
  EditPrescription(
      {Key key,
      @required this.patientAddress,
      @required this.prescription,
      @required this.patientName,
      @required this.patientEmail,
      @required this.patientGender,
      @required this.patientAge,
      @required this.patientPhone})
      : super(key: key);
  @override
  _EditPrescriptionState createState() => _EditPrescriptionState(
      this.patientAddress,
      this.prescription,
      this.patientName,
      this.patientEmail,
      this.patientGender,
      this.patientAge,
      this.patientPhone);
}

class _EditPrescriptionState extends State<EditPrescription> {
  List prescription;
  String patientAddress;
  String doctorAddress;
  String doctorAuthToken;
  String patientName;
  String patientAge;
  String patientEmail;
  String patientGender;
  String patientPhone;
  final GlobalKey<ScaffoldState> _editPrescriptionScaffoldKey =
      new GlobalKey<ScaffoldState>();

  TextEditingController diagnosisController;
  TextEditingController medicinesController;
  TextEditingController symptomsController;
  TextEditingController adviceController;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  _EditPrescriptionState(
      this.patientAddress,
      this.prescription,
      this.patientName,
      this.patientEmail,
      this.patientGender,
      this.patientAge,
      this.patientPhone);

  @override
  void initState() {
    print('Prescription: $prescription');
    print('Patient address: $patientAddress');

    // diagnosisController =
    //     new TextEditingController(text: prescription['Disease']);
    // medicinesController =
    //     new TextEditingController(text: prescription['Drugs']);
    // symptomsController =
    //     new TextEditingController(text: prescription['Symptoms']);
    adviceController = new TextEditingController();

    //Create Patient

    getDoctorCredentialsfromSharedPrefs().then((docCredentials) {
      setState(() {
        doctorAddress = docCredentials['doctorAddress'];
        doctorAuthToken = docCredentials['doctorAuth'];
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // double width=MediaQuery.of(context).size.width;
    // double height=MediaQuery.of(context).size.height;
    return Scaffold(
        key: _editPrescriptionScaffoldKey,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            backButton(_editPrescriptionScaffoldKey.currentContext),
            topBarStyled(),
            Expanded(
              child: displayPrescription(),
            )
          ],
        ));
  }

  Widget topBarStyled() {
    return Stack(children: <Widget>[
      Container(
          width: MediaQuery.of(context).size.width,
          height: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(100),
            ),
            color: Color.fromRGBO(24, 199, 99, 1),
          )),
      Positioned(
          right: 40,
          top: 70,
          left: 110,
          child: Text(
            'Edit Prescription',
            textAlign: TextAlign.left,
            style: TextStyle(
                color: Color.fromRGBO(255, 255, 255, 0.800000011920929),
                fontFamily: 'Montserrat',
                fontSize: 18,
                letterSpacing:
                    0 /*percentages not used in flutter. defaulting to zero*/,
                fontWeight: FontWeight.normal,
                height: 1),
          )),
    ]);
  }

  Widget prescriptionRowWidget(
      String textKey, TextEditingController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(textKey),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: TextField(
            controller: controller,
          ),
        )
      ],
    );
  }

  Widget fullDetailsWidget() {
    return Column(
      children: <Widget>[
        prescriptionRowWidget('Diagnosis', diagnosisController),
        prescriptionRowWidget('Medicines', medicinesController),
        prescriptionRowWidget('Symptoms', symptomsController),
        prescriptionRowWidget('Advice', adviceController),
      ],
    );
  }

  Widget halfDetailsWidget() {
    return Column(
      children: <Widget>[
        prescriptionRowWidget('Diagnosis', diagnosisController),
        prescriptionRowWidget('Medicines', medicinesController),
        prescriptionRowWidget('Symptoms', symptomsController),
        prescriptionRowWidget('Advice', adviceController),
      ],
    );
  }

  Widget displayPrescription() {
    return ListView.builder(
        itemCount: prescription.length,
        itemBuilder: (context, index) {
          final item = prescription[index];
          TextEditingController formC = new TextEditingController();
          TextEditingController medC = new TextEditingController();
          TextEditingController dosageC = new TextEditingController();
          TextEditingController freqC=new TextEditingController();
          formC.text = item['form'];
          medC.text = item['medicine'];
          dosageC.text = item['dosage'];
          freqC.text=item['frequency'];
          return Dismissible(
            // Specify the direction to swipe and delete
            direction: DismissDirection.endToStart,
            key: Key(item['medicine']),
            onDismissed: (direction) {
              // Removes that item the list on swipwe
              setState(() {
                items.removeAt(index);
              });
              // Shows the information on Snackbar
              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text("$item dismissed")));
            },
            background: Container(color: Colors.red),
            child: 
            Padding(
              padding:EdgeInsets.all(10),
              child:Container(
                
                color: Colors.green[50],
                width:
                    MediaQuery.of(_editPrescriptionScaffoldKey.currentContext)
                        .size
                        .width,
                height: MediaQuery.of(context).size.height * 0.2,
                child: Column(
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.all(10),
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: CupertinoTextField(
                                    controller: formC,
                                  ),
                                )),
                            Expanded(
                              child: CupertinoTextField(
                                controller: medC,
                              ),
                            ),
                            // Text(item['form']),
                          ],
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: CupertinoTextField(
                            padding: EdgeInsets.all(10),
                            controller: dosageC,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: CupertinoTextField(
                            padding: EdgeInsets.all(10),
                            controller: freqC,
                          ),
                        ),
                        // Expanded(
                        //   child: CupertinoTextField(
                        //     controller: medC,
                        //   ),
                        // ),
                        // Text(item['form']),
                      ],
                    )
                  ],
                ))),
            // ListTile(title: Text('${item['medicine']}')),
          );
        });
  }

  Future getDoctorCredentialsfromSharedPrefs() async {
    final SharedPreferences prefs = await _prefs;
    return {
      'doctorAddress': prefs.get('doctorAddress'),
      'doctorAuth': prefs.get('doctorToken')
    };
  }

  Future<String> createPatient(var requestBody) {
    String createPatientUrl = '$apiUrl/patient/create';
    return http
        .post(createPatientUrl,
            headers: <String, String>{
              'Content-Type': 'application/json',
              'auth-token': this.doctorAuthToken,
            },
            body: jsonEncode(<String, String>{
              'name': patientName,
              'phno': patientPhone,
              'email': patientEmail,
              'dob': patientAge,
              'gender': patientGender,
            }))
        .then((value) {
      print("op");
      print(value.body);
      print(value.statusCode);
      if (value.statusCode == 200) {
        print("if" + value.body);
        return json.decode(value.body)['result']['account'];
      } else {
        print("else" + value.body);
        return null;
      }
    });
  }

  Future<String> getAccess(var requestBody) {
    String uploadUrl = '$apiUrl/patient/prescription/access';
    return http
        .post(uploadUrl,
            headers: <String, String>{
              'Content-Type': 'application/json',
              'auth-token': this.doctorAuthToken,
            },
            body: jsonEncode(<String, String>{
              "patientQrCode": requestBody['patientQrCode'],
              "address": requestBody['address']
            }))
        .then((value) {
      if (value.statusCode == 200) {
        return json.decode(value.body)['access'];
      } else {
        return null;
      }
    });
  }

  Future<bool> createPrescription(var requestBody) {
    String uploadUrl = '$apiUrl/patient/prescription/create';
    // final http.Response response = await
    return http
        .post(uploadUrl,
            headers: <String, String>{
              'Content-Type': 'application/json',
              'auth-token': this.doctorAuthToken,
            },
            body: jsonEncode(<String, String>{
              // "medicines": "Dolo",
              // "symptoms": "Cough",
              // "diagnosis": "Cold",
              // "advice": "Take Rest",
              // "patientQrCode": requestBody['patientQrCode'],
              // "doctorAddress": requestBody['doctorAddress']
              'medicines': requestBody['medicines'],
              'symptoms': requestBody['symptoms'],
              'diagnosis': requestBody['diagnosis'],
              'advice': requestBody['advice'],
              'patientQrCode': requestBody['patientQrCode'],
              'doctorAddress': requestBody['doctorAddress'],
            }))
        .then((value) {
      print('res: $value');
      if (value.statusCode == 200) {
        print('Success');
        return true;
      } else {
        print('Failed');
        return false;
      }
    });
  }
}
