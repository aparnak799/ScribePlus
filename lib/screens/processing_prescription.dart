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
  FollowUp({@required this.patientAddress, @required this.socketEvent});

  @override
  _FollowUpState createState() => _FollowUpState(patientAddress, socketEvent);
}

class _FollowUpState extends State<FollowUp> {
  SocketIO socketIO;
  var response;
  var prescription;
  bool _prescriptionReady;
  List<bool> isSelected;
  String questionPicked;
  DateTime chosenDate;
  TextEditingController _followDayController = new TextEditingController();
  bool _skipFollowUp;
  String socketEvent;
  String patientAddress;

  _FollowUpState(this.patientAddress, this.socketEvent);
  @override
  void initState() {
    _prescriptionReady = false;
    _skipFollowUp = false;
    questionPicked = 'Question';
    isSelected = [false, false, false];
    socketIO = SocketIOManager().createSocketIO(socketUrl, '/');
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
    return topBarStyled();
    /*  return Scaffold(
      appBar: AppBar(
        title: Text("Socket"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _prescriptionReady == false
              ? gettingReadyNotificationWidget()
              : readyNotificationWidget(),
          _skipFollowUp == false
              ? Flexible(
                  child: ListView(
                    children: <Widget>[
                      RaisedButton.icon(
                        icon: Icon(Icons.skip_next),
                        label: Text("Skip Follow Up"),
                        onPressed: () {
                          setState(() {
                            _skipFollowUp = true;
                          });
                        },
                      ),
                      this.setFollowUpWidget()
                    ],
                  ),
                )
              : Flexible(
                  child: ListView(
                    children: <Widget>[
                      RaisedButton(
                        child: Text("Set Follow Up"),
                        onPressed: () {
                          setState(() {
                            _skipFollowUp = false;
                          });
                        },
                      ),
                      Text("Insert Loading Spinner")
                    ],
                  ),
                ),
        ],
      ),
    );*/
  }

  Widget topBarStyled() {
    return Scaffold(
        body: Stack(children: <Widget>[
      Positioned(
          top: 50,
          left: 5,
          child: Container(
              width: 350,
              height: 221,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
                color: Color.fromRGBO(187, 220, 250, 1),
              ))),
      Positioned(
          top: 60,
          left: 20,
          child: Text(
            'Processing Audio File',
            textAlign: TextAlign.left,
            style: TextStyle(
                color: Color.fromRGBO(0, 0, 0, 1),
                fontFamily: 'Roboto',
                fontSize: 32,
                letterSpacing:
                    0 /*percentages not used in flutter. defaulting to zero*/,
                fontWeight: FontWeight.normal,
                height: 1),
          )),
      Positioned(
          top: 100,
          left: 100,
          child: Container(
              width: 123,
              height: 121.00000762939453,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/Appletouchicon21.png'),
                    fit: BoxFit.fitWidth),
              ))),
    ]));
  }

  Widget gettingReadyNotificationWidget() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
            height: MediaQuery.of(context).size.height * 0.05,
            width: constraints.maxWidth,
            color: Colors.lightGreen,
            child: Text("Your prescription is getting ready"));
      },
    );
  }

  Widget readyNotificationWidget() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
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
                  onPressed: () {
                    socketIO.disconnect();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => new EditPrescription(
                                prescription: this.prescription,
                                patientAddress: this.patientAddress)));
                    print(prescription);
                  },
                )
              ],
            ));
      },
    );
  }

  Widget followBodyWidget() {
    return Column(
      children: <Widget>[
        Container(
            width: 339,
            height: 50,
            child: Stack(children: <Widget>[
              Positioned(
                  top: 12,
                  left: 0,
                  child: Text(
                    'Follow Up :   ',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Color.fromRGBO(0, 0, 0, 1),
                        fontFamily: 'Montserrat',
                        fontSize: 26,
                        letterSpacing:
                            0 /*percentages not used in flutter. defaulting to zero*/,
                        fontWeight: FontWeight.normal,
                        height: 1),
                  )),
              Positioned(
                  top: 0,
                  left: 189,
                  child: Container(
                      width: 150,
                      height: 50,
                      child: Stack(children: <Widget>[
                        Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                                width: 150,
                                height: 50,
                                child: Stack(children: <Widget>[
                                  Positioned(
                                      top: 40.625,
                                      left: 0,
                                      child: Transform.rotate(
                                        angle: 1.6434499492364262e-16 *
                                            (3.14 / 180),
                                        child: Divider(
                                            color: Color.fromRGBO(0, 0, 0, 1),
                                            thickness: 1),
                                      )),
                                  Positioned(
                                      top: 2.2737367544323206e-13,
                                      left: 124.2855453491211,
                                      child: null),
                                  Positioned(top: 50, left: 150, child: null),
                                ]))),
                        Positioned(
                            top: 2,
                            left: 80,
                            child: Text(
                              '5',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Color.fromRGBO(0, 0, 0, 1),
                                  fontFamily: 'Roboto',
                                  fontSize: 32,
                                  letterSpacing:
                                      0 /*percentages not used in flutter. defaulting to zero*/,
                                  fontWeight: FontWeight.normal,
                                  height: 1),
                            )),
                      ]))),
            ])),
        Container(
            width: 348,
            height: 40,
            child: Stack(children: <Widget>[
              Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                      width: 348,
                      height: 40,
                      child: Stack(children: <Widget>[
                        Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                                width: 105,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(24, 199, 99, 1),
                                ))),
                        Positioned(
                            top: 0,
                            left: 243,
                            child: Container(
                                width: 105,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(
                                      196, 196, 196, 0.800000011920929),
                                ))),
                        Positioned(
                            top: 0,
                            left: 124,
                            child: Container(
                                width: 105,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(
                                      196, 196, 196, 0.800000011920929),
                                ))),
                      ]))),
              Positioned(
                  top: 3,
                  left: 16,
                  child: Text(
                    'Days',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Color.fromRGBO(0, 0, 0, 1),
                        fontFamily: 'Montserrat',
                        fontSize: 26,
                        letterSpacing:
                            0 /*percentages not used in flutter. defaulting to zero*/,
                        fontWeight: FontWeight.normal,
                        height: 1),
                  )),
              Positioned(
                  top: 3,
                  left: 132,
                  child: Text(
                    'Month',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Color.fromRGBO(0, 0, 0, 1),
                        fontFamily: 'Montserrat',
                        fontSize: 26,
                        letterSpacing:
                            0 /*percentages not used in flutter. defaulting to zero*/,
                        fontWeight: FontWeight.normal,
                        height: 1),
                  )),
              Positioned(
                  top: 3,
                  left: 256,
                  child: Text(
                    'Week',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Color.fromRGBO(0, 0, 0, 1),
                        fontFamily: 'Montserrat',
                        fontSize: 26,
                        letterSpacing:
                            0 /*percentages not used in flutter. defaulting to zero*/,
                        fontWeight: FontWeight.normal,
                        height: 1),
                  )),
            ])),
        Container(
            width: 327,
            height: 32,
            child: Stack(children: <Widget>[
              Positioned(
                  top: 0,
                  left: 0,
                  child: Text(
                    'Date Chosen :',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Color.fromRGBO(0, 0, 0, 1),
                        fontFamily: 'Montserrat',
                        fontSize: 26,
                        letterSpacing:
                            0 /*percentages not used in flutter. defaulting to zero*/,
                        fontWeight: FontWeight.normal,
                        height: 1),
                  )),
              Positioned(
                  top: 0,
                  left: 222,
                  child: Text(
                    '13/07/20',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Color.fromRGBO(0, 0, 0, 1),
                        fontFamily: 'Montserrat',
                        fontSize: 26,
                        letterSpacing:
                            0 /*percentages not used in flutter. defaulting to zero*/,
                        fontWeight: FontWeight.normal,
                        height: 1),
                  )),
            ])),
      ],
    );
  }

  Widget questionsWidget() {
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
                onChanged: (T) {
                  print(T);
                  setState(() {
                    this.questionPicked = T;
                  });
                }),
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
                onChanged: (T) {
                  print(T);
                  setState(() {
                    this.questionPicked = T;
                  });
                }),
            Text("Are the symptoms still present?")
          ],
        ),
        Text("Enter a Custom Question"),
        Padding(
          padding: EdgeInsets.all(20.0),
          child: TextField(
            autofocus: false,
            onChanged: (String value) {
              setState(() {
                this.questionPicked = value;
              });
            },
          ),
        )
      ],
    );
  }

  Widget numberIncrementDecrementWidget(
      TextEditingController _followDayController) {
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
              keyboardType:
                  TextInputType.numberWithOptions(signed: true, decimal: false),
              validator: (String value) {
                if ((int.parse(value) < 0) | (int.parse(value) > 366)) {
                  _followDayController.text = '0';
                }
                return '';
              },
            ),
          ),
          SizedBox(
            height: 100.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.arrow_drop_up),
                  iconSize: 34,
                  onPressed: () {
                    _followDayController.text =
                        '${int.parse(_followDayController.text) + 1}';
                    print("Increment");
                  },
                ),
                IconButton(
                  icon: Icon(Icons.arrow_drop_down),
                  iconSize: 34,
                  onPressed: () {
                    _followDayController.text =
                        '${int.parse(_followDayController.text) - 1}';
                    print("Decrement");
                  },
                )
              ],
            ),
          )
        ],
      ),
    ));
  }

  Future<void> getPrescription() async {
    // print(this.socketEvent);
    return await socketIO.subscribe(this.socketEvent, (jsonResponse) {
      print("Inside Subscribe");
      response = json.decode(jsonResponse);
      print(response);
      setState(() {
        _prescriptionReady = true;
        prescription = {
          'Disease': response['disease'],
          'Drugs': response['drug'],
          'Symptoms': response['symptoms']
        };
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
