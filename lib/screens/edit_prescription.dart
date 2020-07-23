import 'dart:math';

import 'package:ScribePlus/backWidget.dart';
import 'package:ScribePlus/screens/view_patient.dart';
import 'package:flutter/material.dart';

import 'package:ScribePlus/url.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

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
  TextEditingController diagnosisController = new TextEditingController();
  TextEditingController medicinesController = new TextEditingController();
  TextEditingController symptomsController = new TextEditingController();
  TextEditingController adviceController = new TextEditingController();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  _EditPrescriptionState(this.patientAddress, this.prescription);
  final SpeechToText speech = SpeechToText();
  bool _hasSpeech = false;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = "";
  String lastError = "";
  String lastStatus = "";
  String _currentLocaleId = "";
  List<LocaleName> _localeNames = [];
  List<bool> focusList = [false, false, false, false];
  final GlobalKey<ScaffoldState> _editPrescriptionScaffoldKey =
      new GlobalKey<ScaffoldState>();
  bool isVoice = false;

  @override
  void initState() {
    print('Prescription: $prescription');
    print('Patient address: $patientAddress');
    getDoctorCredentialsfromSharedPrefs().then((docCredentials) {
      setState(() {
        diagnosisController.text = prescription['Disease'];
        medicinesController.text = prescription['Drugs'];
        symptomsController.text = prescription['Symptoms'];
        this.doctorAddress = docCredentials['doctorAddress'];
        this.doctorAuthToken = docCredentials['doctorAuth'];
      });
    });
    initSpeechState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // double width=MediaQuery.of(context).size.width;
    // double height=MediaQuery.of(context).size.height;
    return Scaffold(
      key: _editPrescriptionScaffoldKey,
      body: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          backButton(context),
          topBarStyled(),
          isVoice?
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              FlatButton(
                child: Text('Start'),
                onPressed:
                    !_hasSpeech || speech.isListening ? null : startListening,
              ),
              FlatButton(
                child: Text('Stop'),
                onPressed: speech.isListening ? stopListening : null,
              ),
              FlatButton(
                child: Text('Cancel'),
                onPressed: speech.isListening ? cancelListening : null,
              ),
            ],
          ):SizedBox(),
          Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                prescriptionRowWidget('Diagnosis', diagnosisController, 0),
                prescriptionRowWidget('Medicines', medicinesController, 1),
                prescriptionRowWidget('Symptoms', symptomsController, 2),
                prescriptionRowWidget('Advice', adviceController, 3),
                generateReport(),
              ],
            ),
          )
        ],
      )),
    );
  }

  Widget topBarStyled() {
    return Stack(children: <Widget>[
      Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(100),
            ),
            color: Color.fromRGBO(24, 199, 99, 1),
          )),
      Container(
          height: MediaQuery.of(context).size.height * 0.15,
          // alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Edit Prescription',
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontFamily: 'Montserrat',
                    fontSize: 30,
                    letterSpacing:
                        0 /*percentages not used in flutter. defaulting to zero*/,
                    fontWeight: FontWeight.normal,
                    height: 1),
              ),
              IconButton(
                icon: Icon(
                  Icons.info,
                  color: Colors.white,
                ),
                onPressed: () => showDialog(
                    context: _editPrescriptionScaffoldKey.currentContext,
                    child: new SimpleDialog(
                      title: Text('Instructions to edit Prescription',
                          style: TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontFamily: 'Montserrat',
                              fontSize: 20,
                              letterSpacing:
                                  0 /*percentages not used in flutter. defaulting to zero*/,
                              fontWeight: FontWeight.bold,
                              height: 1)),
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'Toggle the switch to enable voice prescription',
                            style: TextStyle(
                                color: Color.fromRGBO(0, 0, 0, 1),
                                fontFamily: 'Montserrat',
                                fontSize: 15,
                                letterSpacing:
                                    0 /*percentages not used in flutter. defaulting to zero*/,
                                fontWeight: FontWeight.normal,
                                height: 1),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'Say the name of the field to be edited',
                            style: TextStyle(
                                color: Color.fromRGBO(0, 0, 0, 1),
                                fontFamily: 'Montserrat',
                                fontSize: 15,
                                letterSpacing:
                                    0 /*percentages not used in flutter. defaulting to zero*/,
                                fontWeight: FontWeight.normal,
                                height: 1),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'Say the changes in that field once you hear the sound',
                            style: TextStyle(
                                color: Color.fromRGBO(0, 0, 0, 1),
                                fontFamily: 'Montserrat',
                                fontSize: 15,
                                letterSpacing:
                                    0 /*percentages not used in flutter. defaulting to zero*/,
                                fontWeight: FontWeight.normal,
                                height: 1),
                          ),
                        )
                      ],
                    )),
              )
            ],
          )),
      // Container(
      //   height: MediaQuery.of(context).size.height * 0.30,
      //   child:
      Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.3,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Voice Editing',
                style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                    letterSpacing:
                        0 /*percentages not used in flutter. defaulting to zero*/,
                    fontWeight: FontWeight.normal,
                    height: 1)),
            Switch(
                activeColor: Colors.blue,
                inactiveTrackColor: Colors.white,
                value: isVoice,
                onChanged: (value) {
                  setState(() {
                    isVoice = value;
                    print(isVoice);
                  });
                }),
            // Visibility(
            //   visible: isVoice,
            //   child: AlertDialog(
            //     title: Text('Instructions to Edit by voice'),
            //     content: Container(
            //       width: MediaQuery.of(context).size.width*0.6,
            //       height: MediaQuery.of(context).size.height*0.4,
            //       child: Column(
            //         children: <Widget>[
            //             Padding(
            //               padding: EdgeInsets.all(10),
            //               child: Text(
            //                 'Toggle the switch to enable voice prescription',
            //                 style: TextStyle(
            //                     color: Color.fromRGBO(0, 0, 0, 1),
            //                     fontFamily: 'Montserrat',
            //                     fontSize: 15,
            //                     letterSpacing:
            //                         0 /*percentages not used in flutter. defaulting to zero*/,
            //                     fontWeight: FontWeight.normal,
            //                     height: 1),
            //               ),
            //             ),
            //             Padding(
            //               padding: EdgeInsets.all(10),
            //               child: Text(
            //                 'Say the name of the field to be edited',
            //                 style: TextStyle(
            //                     color: Color.fromRGBO(0, 0, 0, 1),
            //                     fontFamily: 'Montserrat',
            //                     fontSize: 15,
            //                     letterSpacing:
            //                         0 /*percentages not used in flutter. defaulting to zero*/,
            //                     fontWeight: FontWeight.normal,
            //                     height: 1),
            //               ),
            //             ),
            //             Padding(
            //               padding: EdgeInsets.all(10),
            //               child: Text(
            //                 'Say the changes in that field once you hear the sound',
            //                 style: TextStyle(
            //                     color: Color.fromRGBO(0, 0, 0, 1),
            //                     fontFamily: 'Montserrat',
            //                     fontSize: 15,
            //                     letterSpacing:
            //                         0 /*percentages not used in flutter. defaulting to zero*/,
            //                     fontWeight: FontWeight.normal,
            //                     height: 1),
            //               ),
            //             )
            //           ],
            //         )
                  
            //     ),
            //   )
            // )
          ],
        ),
      ),
      // ),
    ]);
  }

  Widget prescriptionRowWidget(
      String textKey, TextEditingController controller, int index) {
    // print('$index,${this.focusList[index]}');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(textKey),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          // height: MediaQuery.of(context).size.height * 0.2,
          child: TextField(
            // decoration: new InputDecoration(
            //     border: this.focusList[index]?new OutlineInputBorder(
            //         borderSide: new BorderSide(color: Colors.green)):new OutlineInputBorder(borderSide: BorderSide(color: Colors.black))),            // expands: true,
            minLines: 1,
            maxLines: null,
            controller: controller,
            // autofocus: true,
          ),
        )
      ],
    );
  }

  Widget generateReport() {
    return InkWell(
      onTap: () {
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
                content: Text('Could not upload prescription! Try later'));
            _editPrescriptionScaffoldKey.currentState.showSnackBar(snackBar);
          }
        });
      },
      child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          height: 50,
          child: Stack(children: <Widget>[
            Positioned(
                top: 0,
                left: 0,
                child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.25),
                            offset: Offset(0, 4),
                            blurRadius: 4)
                      ],
                      color: Color.fromRGBO(24, 199, 99, 0.800000011920929),
                    ))),
            Positioned(
                top: 13,
                left: 18,
                child: Text(
                  'Generate Report',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      fontFamily: 'Montserrat',
                      fontSize: 20,
                      letterSpacing:
                          0 /*percentages not used in flutter. defaulting to zero*/,
                      fontWeight: FontWeight.normal,
                      height: 1),
                )),
          ])),
    );
  }

  Future getDoctorCredentialsfromSharedPrefs() async {
    final SharedPreferences prefs = await _prefs;
    return {
      'doctorAddress': prefs.get('doctoAddress'),
      'doctorAuth': prefs.get('auth-token')
    };
  }

  Future<void> initSpeechState() async {
    bool hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener);
    if (hasSpeech) {
      _localeNames = await speech.locales();

      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale.localeId;
    }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
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

  void startListening() {
    lastWords = "";
    lastError = "";
    speech.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 15),
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        partialResults: true,
        onDevice: true,
        listenMode: ListenMode.search);
    setState(() {});
  }

  void stopListening() {
    speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    print(result.confidence);
    print(result.finalResult);
    print(result.isConfident());
    print(result.alternates);
    print(result.recognizedWords);
    print(result.recognizedWords.split(' ')[0]);
    setState(() {
      lastWords = "${result.recognizedWords}";
    });
    switch (lastWords.split(' ')[0]) {
      case 'diagnosis':
        setState(() {
          this.focusList[0] = true;
        });
        stopListening();
        final SnackBar snackBar = SnackBar(
            duration: Duration(seconds: 3),
            content: Text('Speak after this snackbar disappers!'));
        _editPrescriptionScaffoldKey.currentState.showSnackBar(snackBar);
        Future.delayed(Duration(seconds: 3)).then((onValue) {
          speech.listen(
              onResult: diagnosisListener,
              listenFor: Duration(seconds: 30),
              pauseFor: Duration(seconds: 15),
              localeId: _currentLocaleId,
              onSoundLevelChange: soundLevelListener,
              cancelOnError: true,
              partialResults: true,
              onDevice: true,
              listenMode: ListenMode.dictation);
        });

        break;
      case 'medicines':
        setState(() {
          this.focusList[1] = true;
        });
        stopListening();
        final SnackBar snackBar = SnackBar(
            duration: Duration(seconds: 3),
            content: Text('Speak after this snackbar disappers!'));
        _editPrescriptionScaffoldKey.currentState.showSnackBar(snackBar);
        Future.delayed(Duration(seconds: 3)).then((onValue) {
          speech.listen(
              onResult: medicinesListener,
              listenFor: Duration(seconds: 30),
              pauseFor: Duration(seconds: 15),
              localeId: _currentLocaleId,
              onSoundLevelChange: soundLevelListener,
              cancelOnError: true,
              partialResults: true,
              onDevice: true,
              listenMode: ListenMode.dictation);
        });

        break;

      case 'symptoms':
        setState(() {
          this.focusList[2] = true;
        });
        stopListening();
        final SnackBar snackBar = SnackBar(
            duration: Duration(seconds: 3),
            content: Text('Speak after this snackbar disappers!'));
        _editPrescriptionScaffoldKey.currentState.showSnackBar(snackBar);
        Future.delayed(Duration(seconds: 3)).then((onValue) {
          speech.listen(
              onResult: symptomsListener,
              listenFor: Duration(seconds: 30),
              pauseFor: Duration(seconds: 15),
              localeId: _currentLocaleId,
              onSoundLevelChange: soundLevelListener,
              cancelOnError: true,
              partialResults: false,
              onDevice: true,
              listenMode: ListenMode.dictation);
        });

        break;
      case 'advice':
        setState(() {
          this.focusList[3] = true;
        });
        stopListening();
        final SnackBar snackBar = SnackBar(
            duration: Duration(seconds: 3),
            content: Text('Speak after this snackbar disappers!'));
        _editPrescriptionScaffoldKey.currentState.showSnackBar(snackBar);
        Future.delayed(Duration(seconds: 3)).then((onValue) {
          speech.listen(
              onResult: adviceListener,
              listenFor: Duration(seconds: 30),
              pauseFor: Duration(seconds: 15),
              localeId: _currentLocaleId,
              onSoundLevelChange: soundLevelListener,
              cancelOnError: true,
              partialResults: false,
              onDevice: true,
              listenMode: ListenMode.dictation);
        });

        break;
      default:
        print('Try saying the name of one of the available fields');
    }
  }

  void diagnosisListener(SpeechRecognitionResult result) {
    print(result.recognizedWords);
    print(focusList);
    setState(() {
      diagnosisController.text =
          diagnosisController.text + result.recognizedWords;
      // focusList[0] = false;
    });
  }

  void medicinesListener(SpeechRecognitionResult result) {
    print(result.recognizedWords);
    setState(() {
      medicinesController.text =
          medicinesController.text + result.recognizedWords;
      // focusList[1] = false;
    });
  }

  void symptomsListener(SpeechRecognitionResult result) {
    print(result);
    print(result.finalResult);
    print(result.recognizedWords);
    if (result.finalResult) {
      setState(() {
        symptomsController.text =
            symptomsController.text + result.recognizedWords;
        // focusList[2] = false;
      });
    }
  }

  void adviceListener(SpeechRecognitionResult result) {
    print(result.recognizedWords);
    setState(() {
      adviceController.text = adviceController.text + result.recognizedWords;
      // focusList[3] = false;
    });
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    // print("sound level $level: $minSoundLevel - $maxSoundLevel ");
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    // print("Received error status: $error, listening: ${speech.isListening}");
    setState(() {
      lastError = "${error.errorMsg} - ${error.permanent}";
    });
  }

  void statusListener(String status) {
    // print(
    // "Received listener status: $status, listening: ${speech.isListening}");
    setState(() {
      lastStatus = "$status";
    });
  }
}
