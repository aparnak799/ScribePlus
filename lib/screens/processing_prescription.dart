import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:jiffy/jiffy.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'package:ScribePlus/screens/edit_prescription.dart';
import 'package:ScribePlus/url.dart';


class FollowUp extends StatefulWidget {
  final String socketEvent;
  final String patientAddress;
  FollowUp({@required this.patientAddress,@required this.socketEvent});
  
  @override
  _FollowUpState createState() => _FollowUpState(patientAddress,socketEvent);
}

class _FollowUpState extends State<FollowUp> {
  SocketIO socketIO;
  var response;
  var prescription;
  bool _prescriptionReady;
  List<bool> isSelected;
  String questionPicked;
  DateTime chosenDate;
  TextEditingController _followDayController= new TextEditingController();
  bool _skipFollowUp;
  String socketEvent;
  String patientAddress;

  _FollowUpState(this.patientAddress,this.socketEvent);
  @override
  void initState() {
    _prescriptionReady=false;
    _skipFollowUp=false;
    questionPicked='Question';
    isSelected=[false,false,false];
    socketIO = SocketIOManager().createSocketIO(socketUrl,'/');
    socketIO.init();
    print('socketEvent: $socketEvent');
    getPrescription();
    // getSharedPrefsSocketID().then((String socketID){
    //   getPrescription(socketID);
    // });   
    socketIO.connect();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: Text("Socket"),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _prescriptionReady==false?
              gettingReadyNotificationWidget():
              readyNotificationWidget(),
            _skipFollowUp==false?
              Flexible(
                child: ListView(
                  children: <Widget>[
                  RaisedButton.icon(
                      icon: Icon(Icons.skip_next),
                      label: Text("Skip Follow Up"),
                      onPressed: (){
                        setState(() {
                          _skipFollowUp=true;
                        });
                      },
                                  ),
                    this.setFollowUpWidget()
                  ],
                ),
              ):
              Flexible(
              child: ListView(
                children: <Widget>[
                    RaisedButton(
                      child: Text("Set Follow Up"),
                      onPressed: (){
                        setState(() {
                          _skipFollowUp=false;
                        });
                      },
                    ),
                    Text("Insert Loading Spinner")
                ],
              ),
            )
            ,

            
          ],
            ), 
);
  }

  Widget gettingReadyNotificationWidget(){
    return LayoutBuilder(
      builder: (BuildContext context,BoxConstraints constraints){
        return Container(
        height: MediaQuery.of(context).size.height * 0.05,
        width: constraints.maxWidth,
        color: Colors.lightGreen,
        child: Text("Your prescription is getting ready")
      );
      },
    );
  }

  Widget readyNotificationWidget(){
    return LayoutBuilder(
      builder: (BuildContext context,BoxConstraints constraints){
        return Container(
        height: MediaQuery.of(context).size.height * 0.05,
        width: constraints.maxWidth,
        color: Colors.lightGreen,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("Your Prescription is ready"),
            FlatButton(
              child: Text("View"),
              onPressed: (){
                socketIO.disconnect();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>new EditPrescription(prescription: this.prescription,patientAddress:this.patientAddress)));
                print(prescription);},
            )
          ],
        )
      );
      },
    );
  }

  Widget setFollowUpWidget(){
   
    print(chosenDate);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text("Follow Up After: "),
            numberIncrementDecrementWidget(_followDayController),
          ],
        ),
          ToggleButtons(
              children: <Widget>[
                Text('Day'),
                Text('Month'),
                Text('Year'),
              ],
              onPressed: (int index) {
                setState(() {
                  for (int buttonIndex = 0; buttonIndex < isSelected.length; buttonIndex++) {
                    if (buttonIndex == index) {
                      this.isSelected[buttonIndex] = true;
                    } else {
                      this.isSelected[buttonIndex] = false;
                    }
                  }

                switch (this.isSelected.indexOf(true)) {
                  case 0: this.chosenDate=Jiffy().add(days: int.parse(_followDayController.text));
                    
                    break;
                  case 1: this.chosenDate=Jiffy().add(months: int.parse(_followDayController.text));
                    
                    break;
                  case 2: this.chosenDate=Jiffy().add(years: int.parse(_followDayController.text));
                    
                    break;
                  default: this.chosenDate=null;
                }
                

                });
              },
              isSelected: this.isSelected,
            ),
            chosenDate!=null?
            Text("${this.chosenDate.day} ${this.chosenDate.month} ${this.chosenDate.year}"):
            Text('Date Not Chosen'),
            questionsWidget(),
            RaisedButton(
              child: Text("Submit"),
              onPressed: (){
                print("Date:${this.chosenDate}");
                print("Question: $questionPicked");

              },
            )
      ],
    );
  }

  Widget questionsWidget(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text("Pick a Question to be asked"),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
          Radio(
            groupValue: questionPicked,
            value: "Are you feeling better now?",
            onChanged: (T){
              print(T);
              setState(() {
                this.questionPicked=T;
              });
            }
          ),
          Text("Are you feeling better now?")
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
          Radio(
            groupValue: questionPicked,
            value: "Are the symptoms still present?",
            onChanged: (T){
              print(T);
              setState(() {
                this.questionPicked=T;
              });
            }
          ),
          Text("Are the symptoms still present?")
          ],
        ),
        Text("Enter a Custom Question"),
        Padding(
          padding: EdgeInsets.all(20.0),
          child:TextField(
            autofocus:false,
            onChanged: (String value){
              setState(() {
                this.questionPicked=value;
              });
            },
        ),
        )

      ],
    );
  }

  Widget numberIncrementDecrementWidget(TextEditingController _followDayController){
    return 
    // Text("data");
    Container(
      child: Flexible(
        flex: 2,
        fit: FlexFit.loose,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
              SizedBox(
              width: 30.0,
              child: TextFormField(
              controller: _followDayController,
              maxLength: 3,
              keyboardType: TextInputType.numberWithOptions(
                signed: true,
                decimal: false
              ),
              validator: (String value){
                if((int.parse(value)<0) | (int.parse(value)>366)){
                  _followDayController.text= '0';
                }
                return '';

              },
              ),
            ),
            SizedBox(
              height: 100.0,
              child:Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.arrow_drop_up),
                      iconSize: 34,
                      onPressed: (){
                        _followDayController.text='${int.parse(_followDayController.text)+1}';
                        print("Increment");
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_drop_down),
                      iconSize: 34,
                      onPressed: (){
                        _followDayController.text='${int.parse(_followDayController.text)-1}';
                        print("Decrement");
                      },
                    )
                  ],
        ),
            )


          ],
        ),
      )
      
      );
  }

    Future<void> getPrescription() async{      
      // print(this.socketEvent);
      return await socketIO.subscribe(this.socketEvent, (jsonResponse) {
      print("Inside Subscribe");
      response=json.decode(jsonResponse);
      print(response);
      setState(() {
        _prescriptionReady=true;
        prescription={'Disease':response['disease'],
                      'Drugs':response['drug'],
                      'Symptoms':response['symptoms']};
      });
    });
    
  }

  // Future<String> getSharedPrefsSocketID() async{
  //   SharedPreferences _prefs = await SharedPreferences.getInstance();
  //   String socketID= _prefs.getString("Socket-Id");
  //   _prefs.remove("Socket-Id");
  //   return "1594098288464";//Change Socket ID
  // }
}