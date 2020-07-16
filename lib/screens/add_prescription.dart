import 'dart:io' as io;
import 'dart:core';
import 'dart:convert';

import 'package:ScribePlus/screens/processing_prescription.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ScribePlus/url.dart';


class UploadAudioPrescription extends StatefulWidget {
  final String patientAddress;
  final LocalFileSystem localFileSystem;
  UploadAudioPrescription({@required this.patientAddress, localFileSystem})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();
  @override
  _UploadAudioPrescriptionState createState() => new _UploadAudioPrescriptionState(patientAddress);
}


class _UploadAudioPrescriptionState extends State<UploadAudioPrescription> {
  bool _isRecording = false;
  Recording _recording;
  PermissionStatus _permissionStatus = PermissionStatus.undetermined;
  Permission _permission=Permission.speech;
  String _audioFullPath;
  TextEditingController _controller = new TextEditingController();
  String _uploadResponseStatus;
  String authToken;
  String patientAddress;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  _UploadAudioPrescriptionState(this.patientAddress);

  @override
  void initState() {
    super.initState();
    requestPermission(_permission);
    getAuthToken().then((authToken){
      this.authToken=authToken;
    });
  }

@override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      body: new Center(
      child: new Padding(
        padding: new EdgeInsets.all(8.0),
        child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              new FlatButton(
                onPressed: _isRecording ? null : _start,
                child: new Text("Start"),
                color: Colors.green,
              ),
              new FlatButton(
                onPressed: _isRecording ? _stop : null,
                child: new Text("Stop"),
                color: Colors.red,
              ),
              new RaisedButton(
                child: new Text("Send Data"),
                onPressed: (){
                  // Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context) => FollowUp(patientAddress:this.patientAddress,socketEvent: '1594885789066')));
                  uploadAudio().then((socketEvent){
                    if(socketEvent!='')
                      Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context) => FollowUp(patientAddress:this.patientAddress,socketEvent: socketEvent)));
                    else 
                      {
                        final SnackBar snackBar=SnackBar(content:Text('Could not process audio'));
                        _scaffoldKey.currentState.showSnackBar(snackBar);
                      }
                  });
                },
              )

            ]),
      ),
    ));
  }

  Future<void> requestPermission(Permission permission) async {
    final status = await permission.request();
    setState(() {
       _permissionStatus = status;
      print(_permissionStatus);
    });
  }//Request permissions for Audio

  Future<String> uploadAudio() async {
  final SharedPreferences prefs = await _prefs;
  var request = http.MultipartRequest('POST', Uri.parse('$apiUrl/doctor/upload/audio'));
  request.headers.addAll({'auth-token':this.authToken});
  print("Path"+_audioFullPath);
  request.files.add(
    await http.MultipartFile.fromPath(
      'file',
      _audioFullPath
    )
  );
  var streamedResponse = await request.send();
  var response=await streamedResponse.stream.bytesToString();
  var parsedJson = json.decode(response);
  print(parsedJson);
  print(parsedJson['socketId']);
  prefs.setString("Socket-ID", parsedJson['socketID']);
  // return parsedJson['socketID'];
  return parsedJson['socketId'];
  }

  _start() async {
    try {
      if (_permissionStatus==PermissionStatus.granted) {     
        io.Directory appDocDirectory = await getApplicationDocumentsDirectory();
        String filename= new DateTime.now().millisecondsSinceEpoch.toString() + '.mp4';
        String path = appDocDirectory.path + '/' +filename;
        await AudioRecorder.start(
            path: path, audioOutputFormat: AudioOutputFormat.AAC);
        
        bool isRecording = await AudioRecorder.isRecording;
        setState(() {
          _audioFullPath=path;
          _recording = new Recording(duration: new Duration(), path: "");
          _isRecording = isRecording;
        });
      } else {
        Scaffold.of(context).showSnackBar(
            new SnackBar(content: new Text("You must accept permissions")));
      }
    } catch (e) {
      print(e);
    }
  }

  _stop() async {
    var recording = await AudioRecorder.stop();
    print("Stop recording: ${recording.path}");
    bool isRecording = await AudioRecorder.isRecording;
    File file = widget.localFileSystem.file(recording.path);
    print(" File length: ${await file.length()}");
    setState(() {
      _recording = recording;
      _isRecording = isRecording;
    });
    _controller.text = recording.path;
  }

  Future<String> getAuthToken() async{
    final SharedPreferences prefs = await _prefs;
    return prefs.get("doctorToken");
  }
  
}

