import 'dart:convert';
import 'dart:io';

import 'package:ScribePlus/backWidget.dart';
import 'package:ScribePlus/screens/view_patient.dart';
import 'package:flutter/material.dart';

import 'package:ScribePlus/url.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditPrescription extends StatefulWidget {
  final Map prescription;
  final String patientAddress;
  EditPrescription(
      {Key key, @required this.patientAddress, @required this.prescription})
      : super(key: key);
  @override
  _EditPrescriptionState createState() =>
      _EditPrescriptionState(this.patientAddress, this.prescription);
}

class _EditPrescriptionState extends State<EditPrescription> {
  Map prescription;
  String patientAddress;
  String doctorAddress;
  String doctorAuthToken;

  TextEditingController diagnosisController;
  TextEditingController medicinesController;
  TextEditingController symptomsController;
  TextEditingController adviceController;

  //Create Patient
  TextEditingController patientNameController;
  TextEditingController patientAgeController;
  TextEditingController patientPhoneController;
  TextEditingController patientGenderController;
  TextEditingController patientEmailController;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  _EditPrescriptionState(this.patientAddress, this.prescription);

  @override
  void initState() {
    print('Prescription: $prescription');
    print('Patient address: $patientAddress');

    diagnosisController =
        new TextEditingController(text: prescription['Disease']);
    medicinesController =
        new TextEditingController(text: prescription['Drugs']);
    symptomsController =
        new TextEditingController(text: prescription['Symptoms']);
    adviceController = new TextEditingController();

    //Create Patient
    patientNameController = new TextEditingController();
    patientPhoneController = new TextEditingController();
    patientEmailController = new TextEditingController();
    patientAgeController = new TextEditingController();
    patientGenderController = new TextEditingController();

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
    final GlobalKey<ScaffoldState> _editPrescriptionScaffoldKey =
        new GlobalKey<ScaffoldState>();
    // double width=MediaQuery.of(context).size.width;
    // double height=MediaQuery.of(context).size.height;
    return Scaffold(
      key: _editPrescriptionScaffoldKey,
      body: ListView(
        children: <Widget>[
          backButton(context),
          topBarStyled(),
          patientAddress == null ? fullDetailsWidget() : halfDetailsWidget(),
          // prescriptionRowWidget('Diagnosis', diagnosisController),
          // prescriptionRowWidget('Medicines', medicinesController),
          // prescriptionRowWidget('Symptoms', symptomsController),
          // prescriptionRowWidget('Advice', adviceController),
          RaisedButton.icon(
            icon: Icon(Icons.send),
            label: Text("Generate Report"),
            onPressed: () {
              // print({
              //   'Diagnosis': diagnosisController.text,
              //   'Medicines': medicinesController.text,
              //   'Symptoms': medicinesController.text,
              //   'Advice': adviceController.text
              // });

              var patientRequest = {
                'name': patientNameController.text,
                'phno': patientPhoneController.text,
                'email': patientEmailController.text,
                'dob': patientAgeController.text,
                'gender': patientGenderController.text
              };
              print('Pressed generate pres');
              // var requestBody = {
              //   'medicines': medicinesController.text,
              //   'symptoms': symptomsController.text,
              //   'diagnosis': diagnosisController.text,
              //   'advice': adviceController.text,
              //   'patientQrCode': this.patientAddress,
              //   'doctorAddress': this.doctorAddress,
              // };
              createPatient(patientRequest).then((value) {
                print("RESP BODY" + value);
                print("initial doc addr" + this.doctorAddress);

                getAccess({
                  "patientQrCode": value,
                  "address": this.doctorAddress,
                }).then((resp) {
                  if (resp == "GRANTED") {
                    createPrescription({
                      'medicines': medicinesController.text,
                      'symptoms': symptomsController.text,
                      'diagnosis': diagnosisController.text,
                      'advice': adviceController.text,
                      'patientQrCode': value,
                      'doctorAddress': this.doctorAddress,
                    }).then((bool result) {
                      print('Entering call: $result');
                      print("Pat Qr Code" + value);
                      print("final doc Addr" + this.doctorAddress);
                      if (result == true)
                        Navigator.pushReplacement(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => new ViewPatient(
                                      patientQr: value,
                                    )));
                      else {
                        final SnackBar snackBar = SnackBar(
                            content: Text(
                                'Could not upload prescription! Try later part1'));
                        _editPrescriptionScaffoldKey.currentState
                            .showSnackBar(snackBar);
                      }
                    });
                  } else {
                    final SnackBar snackBar = SnackBar(
                        content: Text(
                            'Could not upload prescription! Try later part2'));
                    _editPrescriptionScaffoldKey.currentState
                        .showSnackBar(snackBar);
                  }
                });
              });
            },
          )
        ],
      ),
    );
  }

  Widget topBarStyled() {
    return Stack(children: <Widget>[
      Container(
          width: 375,
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

  Widget createPatientWidget(String textKey, TextEditingController controller) {
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
        createPatientWidget('Patient Name', patientNameController),
        createPatientWidget('Patient Phone', patientPhoneController),
        createPatientWidget('Patient Email', patientEmailController),
        createPatientWidget('Patient Age', patientAgeController),
        createPatientWidget('Patient Gender', patientGenderController),
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
              'name': patientNameController.text,
              'phno': patientPhoneController.text,
              'email': patientEmailController.text,
              'dob': patientAgeController.text,
              'gender': patientGenderController.text,
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
      // print('Entered Auth was : ' + this.doctorAuthToken);
      // print(response.body);
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
