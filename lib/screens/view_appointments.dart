import 'dart:convert';
import 'package:ScribePlus/screens/scan_patient.dart';
import 'package:ScribePlus/screens/view_patient.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

import 'package:ScribePlus/url.dart';
import 'package:intl/intl.dart';

class Patient{
  final String name;
  final String phNo;
  final String patientId;
  final String email;

  Patient({this.name,this.phNo,this.patientId,this.email});

  factory Patient.fromJson(Map<String,dynamic> responsePatient){
    return Patient(
      name: responsePatient['name'],
      phNo: responsePatient['phone'],
      email: responsePatient['email']
    );
  }
}

class Appointment{
  final int appointmentNo;
  final String time;
  // final String date;
  final Patient patientDetails;
  final bool isNewPatient;
  final String patientQrCode;

  Appointment({this.appointmentNo,this.time,this.patientDetails,this.isNewPatient, this.patientQrCode});

  factory Appointment.fromJson(Map<String,dynamic> response){
    return Appointment(
      appointmentNo: response['appointment']['appointmentNumber'],
      time: response['appointment']['time'],
      patientDetails: Patient.fromJson(response['patientDetails']),
      isNewPatient: response['isNewPatient'],
      patientQrCode: response['appointment']['patientQrCode']
      // date: response['date']
    );
  }

}

List<Appointment> initAppointments(var response){
  List<Appointment> appointmentsList= new List();
  for (var appointment in response) {
    appointmentsList.add(Appointment.fromJson(appointment));    
  }
  return appointmentsList;
}

class ViewAppointments extends StatefulWidget {
  @override
  _ViewAppointmentsState createState() => _ViewAppointmentsState();
}

class _ViewAppointmentsState extends State<ViewAppointments> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future appointments;
  String doctorAddress;
  String authToken;
  DateTime selectedDate=DateTime.now();
  var newFormat = DateFormat("yyyy-MM-dd");

  final GlobalKey<ScaffoldState> _viewAppointmentsScaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getAuthTokenAndAddress().then((details){
      setState(() {
        doctorAddress=details['doctorAddress'];
        authToken=details['authToken'];
        appointments=getAppointments(this.doctorAddress,this.authToken,newFormat.format(this.selectedDate));
      });
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _viewAppointmentsScaffoldKey,
      body: getAppointmentsWidget(),      
    );
  }

  Widget getAppointmentsWidget(){
    return FutureBuilder(
      future: appointments,
      builder: (context,snapshot){
        if(snapshot.hasError){          
          return errorWidget(snapshot.error.toString());
        }
        else if(snapshot.connectionState==ConnectionState.done && snapshot.hasData==false){
          return errorWidget('No Data');
        }
        else if(snapshot.hasData){
          if(snapshot.data is List<Appointment>)
            {print(snapshot.data);
            return ListView(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                Text('Appointments'),
                IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: (){
                  pickDate();
                },
              ),
                  ],
                ),

                for(Appointment appointment in snapshot.data)
                  appointmentCardWidget(appointment),
              ],
            );}
          return ListView(
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                Text('Appointments'),
                IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: (){
                  pickDate();
                },
              ),
                  ],
                ),
              Center(child: Text("No Appointments")),
            ],
          );
        }
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

  Widget appointmentCardWidget(Appointment appointment){
    print('Appointmen: $appointment');
    print('time: ${appointment.time}');
    print('name: ${appointment.patientDetails.name}');
    print('phone: ${appointment.patientDetails.phNo}');
    return Card(
      child: Column(
        children: <Widget>[
          Text('${appointment.appointmentNo}'),
          Text(appointment.time),
          Text(appointment.patientDetails.name),
          Text(appointment.patientDetails.phNo),
          appointment.isNewPatient?
          Text('New Patient'):
          RaisedButton(
            child: Text('View Patient History'),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>new ViewPatient(patientQr: appointment.patientQrCode,)));
            },
          ),
          RaisedButton(
            child: Text('Attend'),
            onPressed: (){
              attendAppointment(appointment.appointmentNo).then((bool result){
                if(result==true)
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>new ScanPatient()));
                else
                {
                  final SnackBar snackBar=SnackBar(content:Text('Could not process! Try again later.'));
                  _viewAppointmentsScaffoldKey.currentState.showSnackBar(snackBar);
                }
              });
               
            },
          )

        ],
      ),
    );

  }

  Future getAppointments(String doctorAddress, String authToken,String date) async{
    print(authToken);
      final http.Response response = await http.post(
      '$apiUrl/doctor/appointment/date',
      headers: <String,String>{
        'Content-Type': 'application/json',
        'auth-token': authToken
      },
      body: jsonEncode(<String,String>{
        'doctorAddress':doctorAddress,
        'date': date
      })
    );
    if(response.statusCode==200){
      print('Inside call: ${response.body}');
      if(response.body.toString()!='[]')
        return initAppointments(json.decode(response.body));
      return "No appointments";
      
    }

  }

  Future<bool> attendAppointment(int appointmentNo) async{
    final http.Response response=await http.put(
      '$apiUrl/doctor/appointment/visited',
      headers: <String,String>{
        'Content-Type': 'application/json',
        'auth-token': authToken
      },
      body: jsonEncode(<String,int>{
        'appointmentNumber':appointmentNo
      })
    );
    if(response.statusCode==200)
      return true;
    else
      return false;
  }

  Future<void> pickDate() async {
    final DateTime picked = await showDatePicker(
        context: _viewAppointmentsScaffoldKey.currentContext,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        appointments=getAppointments(this.doctorAddress,this.authToken,newFormat.format(this.selectedDate));
      });
  }

  Future<Map<String,String>> getAuthTokenAndAddress() async{
    final SharedPreferences prefs = await _prefs;
    return {'authToken':prefs.get("doctorToken"),
            'doctorAddress':prefs.get("doctorAddress")};
  }
}