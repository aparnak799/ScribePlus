import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';


class PermissionWidget extends StatefulWidget {
  /// Constructs a [PermissionWidget] for the supplied [Permission].

  @override
  _PermissionState createState() => _PermissionState();
}

class _PermissionState extends State<PermissionWidget> {
  _PermissionState();

  
  PermissionStatus _permissionStatus = PermissionStatus.undetermined;
  Permission _permission=Permission.speech;

  

  @override
  void initState() {
    super.initState();
    
  }



  Color getPermissionColor() {
    switch (_permissionStatus) {
      case PermissionStatus.denied:
        return Colors.red;
      case PermissionStatus.granted:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Permissions"),
      ),
      body: RaisedButton(
        onPressed: () async {
          requestPermission(_permission);
        },
      )
      
    );
  }

  void checkServiceStatus(BuildContext context, Permission permission) async {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text((await permission.status).toString()),
    ));
  }

  Future<void> requestPermission(Permission permission) async {
    final status = await permission.request();

    setState(() {
      print(status);
      _permissionStatus = status;
      print(_permissionStatus);
    });
  }
}