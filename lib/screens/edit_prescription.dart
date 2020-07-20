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
    getDoctorCredentialsfromSharedPrefs().then((docCredentials) {
      setState(() {
        this.doctorAddress = docCredentials['doctorAddress'];
        this.doctorAuthToken = docCredentials['doctorAuth'];
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          backButton(context),
          topBarStyled(),
          prescriptionRowWidget('Diagnosis', diagnosisController),
          prescriptionRowWidget('Medicines', medicinesController),
          prescriptionRowWidget('Symptoms', symptomsController),
          prescriptionRowWidget('Advice', adviceController),
          RaisedButton.icon(
            icon: Icon(Icons.send),
            label: Text("Generate Report"),
            onPressed: () {
              print({
                'Diagnosis': diagnosisController.text,
                'Medicines': medicinesController.text,
                'Symptoms': medicinesController.text,
                'Advice': adviceController.text
              });
              var requestBody = {
                'medicines': medicinesController.text,
                'symptoms': symptomsController.text,
                'diagnosis': diagnosisController.text,
                'advice': adviceController.text,
                'patientQrCode': this.patientAddress,
                'doctorAddress': this.doctorAddress,
              };
              createPrescription(requestBody).then((bool result) {
                if (result == true)
                  Navigator.pushReplacement(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new ViewPatient(
                                patientQr: patientAddress,
                              )));
                else {
                  final SnackBar snackBar = SnackBar(
                      content:
                          Text('Could not upload prescription! Try later'));
                  _editPrescriptionScaffoldKey.currentState
                      .showSnackBar(snackBar);
                }
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

  Future getDoctorCredentialsfromSharedPrefs() async {
    final SharedPreferences prefs = await _prefs;
    return {
      'doctorAddress': prefs.get('doctoAddress'),
      'doctorAuth': prefs.get('auth-token')
    };
  }

  Future<bool> createPrescription(var requestBody) async {
    String uploadUrl = '$apiUrl/patient/prescription/create';
    var response = await http.post(uploadUrl,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'auth-token': this.doctorAuthToken
        },
        body: requestBody);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
