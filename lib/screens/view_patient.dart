import 'dart:convert';

import 'package:ScribePlus/screens/add_prescription.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:ScribePlus/url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';


class Prescription{
  final String prescriptionID;
  final String date;
  final String doctorName;
  final String medicines;
  final String symptoms;
  final String diagnosis;
  final String advice;
  Prescription({this.prescriptionID,this.date,this.doctorName,this.advice,this.symptoms,this.diagnosis,this.medicines});
}

class Patient{
  final String name;
  final String id;
  final String email;
  final String phone;
  final String doctorsVisitedCount;
  final List<Prescription> prescriptions;
  Patient({this.name,this.id,this.email,this.phone,this.doctorsVisitedCount,this.prescriptions});

  factory Patient.fromJson(Map<String,dynamic> response){
    List<Prescription> prescriptionsList=new List<Prescription>();
    for (var prescriptionItem in response['prescriptions']) {
      Prescription prescription=Prescription(
        prescriptionID: prescriptionItem['prescriptionID'],
        date: prescriptionItem['date'],
        doctorName: prescriptionItem['doctorName'],
        medicines: prescriptionItem['medicines'],
        symptoms: prescriptionItem['symptoms'],
        diagnosis: prescriptionItem['diagnosis'],
        advice: prescriptionItem['advice']        
      );
      prescriptionsList.add(prescription);
    }
    print('Inside factory: $response');
    return Patient(
      name: response['name'],
      id: response['id'],
      email: response['email'],
      phone: response['phone'],
      doctorsVisitedCount: response['doctorsVisitedCount'],
      prescriptions: prescriptionsList
    );
  }

}

class ViewPatient extends StatefulWidget {
  final String patientQr;
  
  ViewPatient({Key key,@required this.patientQr}): super(key: key);
  @override
  _ViewPatientState createState() => _ViewPatientState(patientQr);
}

class _ViewPatientState extends State<ViewPatient> {  
  String patientAddress;
  Future patientDetails;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  _ViewPatientState(this.patientAddress);
  String doctorAddress;
  String authToken;
  String otp;
  String enteredOtp;
  bool newPatient=false;
   final GlobalKey<ScaffoldState> _viewPatientScaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getAuthTokenAndAddress().then((details){
      setState(() {
        doctorAddress=details['doctorAddress'];
        authToken=details['authToken'];
        patientDetails=getPatientDetails(details['doctorAddress'],details['authToken']);
      });
      
    });
    // patientDetails=getPatientDetails();
  }
  

  @override
  Widget build(BuildContext context) {
   
    print(patientAddress);
    return Scaffold(
      key: _viewPatientScaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon:Icon(Icons.arrow_back_ios),
          onPressed: (){
            Navigator.pop(context);
          },),
      ),
      body: patientWidget(),
    );
  }

  Widget patientWidget(){
    return FutureBuilder(
      future: patientDetails,
      builder: (context,snapshot){
        
        if(snapshot.hasError){          
          return errorWidget(snapshot.error.toString());
        }
        else if(snapshot.connectionState==ConnectionState.done && snapshot.hasData==false){
          return errorWidget('No Data');
        }
        else if(snapshot.hasData){
          print('Snapshot Data: ${snapshot.data}');
          if(snapshot.data is Patient)
            return Scaffold(
              body: ListView(
              children: <Widget>[
                Text(snapshot.data.name),
                Text(snapshot.data.email),
                Text(snapshot.data.phone),
                for(var prescription in snapshot.data.prescriptions)
                  prescriptionCard(prescription),

              ],
            ),
            floatingActionButton:FloatingActionButton(
                  backgroundColor: Colors.lightBlueAccent,
                  child: Icon(Icons.add),
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>new UploadAudioPrescription(patientAddress: this.patientAddress)));
                    print("Go to add prescription");
                  },
                ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            );
          else if(snapshot.data is String)
            return Scaffold(
              body: Column(
                children: <Widget>[
                  PinEntryTextField(
              fields: 6,
              showFieldAsBox: false,
              onSubmit: (String pin){
                print('Pin: $pin');
                if(pin==snapshot.data){
                  allowPatientAccess().then((bool result){
                    if(result==true){
                      setState(() {
                        patientDetails=getPatientDetails(this.doctorAddress, this.authToken);
                      });
                    }
                    else{
                      final SnackBar snackBar=SnackBar(content:Text('Login Failed'));
                      _viewPatientScaffoldKey.currentState.showSnackBar(snackBar);
                    }
                  });
                }
              },
            )
                ],
              ),
            );

        }
        print(snapshot.connectionState);
        print(snapshot.hasData);
        return loadingWidget();
      },
    );
  }

  Widget errorWidget(String error){
    return Center(
      child: Text(error),
    );
  }

  Widget loadingWidget(){
    return Center(
      child: Text("Loading"),
    );
  }

  Widget prescriptionCard(Prescription prescription){
    return Card(
      borderOnForeground: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Text(prescription.date),
          Text('Diagnosis: ${prescription.diagnosis}'),
          Text('Treated by: ${prescription.doctorName}')
        ],
      ),
    );
  }
  Future getPatientDetails(String doctorAddress, String authToken) async{
    print('patient adrress  ${this.patientAddress}');
    final http.Response response = await http.post(
      '$apiUrl/patient/details',
      headers: <String,String>{
        'Content-Type': 'application/json',
        'auth-token': authToken
      },
      body: jsonEncode(<String,String>{
        'patientQrCode':patientAddress.toString(),
        'address':doctorAddress
      })
    );
    print(response.reasonPhrase);
    print(response.body);
    if (response.statusCode==200) {
      return Patient.fromJson(json.decode(response.body)['patient']);
    }
    else if(response.statusCode==401){
      return json.decode(response.body)['OTP'];
    } 
    else 
    {
      throw Exception('Failed to load patient details');
    }
  }
  Future<bool> allowPatientAccess() async{
    final http.Response response = await http.post(
      '$apiUrl/patient/prescription/access',
      headers: <String,String>{
        'Content-Type': 'application/json',
        'auth-token': authToken
      },
      body: jsonEncode(<String,String>{
        'patientQrCode':patientAddress.toString(),
        'address':doctorAddress
      })
    );
    if(response.statusCode==200){
      return true;
    }
    return false;
  }
  Future<Map<String,String>> getAuthTokenAndAddress() async{
    final SharedPreferences prefs = await _prefs;
    return {'authToken':prefs.get("doctorToken"),
            'doctorAddress':prefs.get("doctorAddress")};
  }
}