import 'dart:io' as io;
import 'dart:core';
import 'dart:convert';

import 'url.dart';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';



class UploadAudioPrescription extends StatefulWidget {

  final LocalFileSystem localFileSystem;
  UploadAudioPrescription({localFileSystem})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();
  @override
  _UploadAudioPrescriptionState createState() => new _UploadAudioPrescriptionState();
}


class _UploadAudioPrescriptionState extends State<UploadAudioPrescription> {
  bool _isRecording = false;
  Recording _recording;
  PermissionStatus _permissionStatus = PermissionStatus.undetermined;
  Permission _permission=Permission.speech;
  String _audioFullPath;
  TextEditingController _controller = new TextEditingController();
  String _uploadResponseStatus;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    requestPermission(_permission);
  }

@override
  Widget build(BuildContext context) {
    return new Scaffold(
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
                onPressed: () async {
                  var reasonPhrase = await uploadAudio();
                  setState(() {
                    _uploadResponseStatus = reasonPhrase;
                    print(reasonPhrase);
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
  var request = http.MultipartRequest('POST', Uri.parse('$apiUrl/doctor/upload/audio'));
  final SharedPreferences prefs = await _prefs;
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
  prefs.setString("Socket-ID", parsedJson['socketID']);
  // return parsedJson['socketID'];
  return streamedResponse.reasonPhrase;
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
    print("  File length: ${await file.length()}");
    setState(() {
      _recording = recording;
      _isRecording = isRecording;
    });
    _controller.text = recording.path;
  }
  
}

