import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';

import 'url.dart';

import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:jiffy/jiffy.dart';

class MyHomePage extends StatefulWidget {
  
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SocketIO socketIO;
  Map<String,String> response;
  bool _prescriptionReady;
  List<bool> isSelected;
  String questionPicked;
  DateTime chosenDate;
  TextEditingController _followDayController= new TextEditingController();
  
  @override
  void initState() {
    _prescriptionReady=false;
    questionPicked='Question';
    socketIO = SocketIOManager().createSocketIO(
     socketUrl,
      '/',
    );
    isSelected=[false,false,false];
    socketIO.init();
    getSharedPrefsSocketID().then((String socketID){
      socketIO.subscribe(socketID, (jsonResponse) {
      response=json.decode(jsonResponse);
      _prescriptionReady=true;
    });
    });    
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
              Text("Your prescription is getting ready"):
              Text("Your Prescription is ready"),
              RaisedButton.icon(
              icon: Icon(Icons.skip_next),
              label: Text("Skip Follow Up"),
              onPressed: (){
                print("Goes to Edit Prescription Tab");
              },
            ) ,
            Flexible(
              child: ListView(
                children: <Widget>[
                  this.SetFollowUpWidget()
                ],
              ),
            )
            ,

            
          ],
            ), 
);
  }

  // Widget prescriptionRowWidget(String keyText, String valueTextField, TextEditingController _valueController){
  //    _valueController.text=valueTextField;
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceAround,
  //     children: <Widget>[
  //       Text(keyText),
  //       TextFormField(
  //         controller: _valueController,
  //       )
  //     ],
  //   );
  // }

  Widget SetFollowUpWidget(){
    var now = new DateTime.now();
    
    print(chosenDate);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text("Follow Up After: "),
            NumberIncrementDecrementWidget(_followDayController),
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
            QuestionsWidget(),
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
  Widget QuestionsWidget(){
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

  Widget NumberIncrementDecrementWidget(TextEditingController _followDayController){
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
      // Row(
      // // mainAxisAlignment: MainAxisAlignment.spaceAround,
      // children: <Widget>[
      //   Flexible(
      //   flex: 1,
      //   child: TextFormField(
      //     keyboardType: TextInputType.numberWithOptions(
      //       signed: true,
      //       decimal: false
      //     ),
      //   )),
        // Column(
        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //   children: <Widget>[
        //     IconButton(
        //       icon: Icon(Icons.arrow_drop_up),
        //       onPressed: (){
        //         print("Increment");
        //       },
        //     ),
        //     IconButton(
        //       icon: Icon(Icons.arrow_drop_down),
        //       onPressed: (){
        //         print("Decrement");
        //       },
        //     )
        //   ],
        // )
      // ],
    // )
    // );
  }

  Future<String> getSharedPrefsSocketID() async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String socketID= _prefs.getString("Socket-Id");
    _prefs.remove("Socket-Id");
    return socketID;
  }
}