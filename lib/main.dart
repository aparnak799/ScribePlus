import 'package:flutter/material.dart';
import 'socket.dart';
import 'form.dart';
import 'add_prescription.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'Scribe Plus';
    return MaterialApp(
      title: title,
      home:
      //  MyHomePage()
      UploadAudioPrescription()      
    );
  }
}

