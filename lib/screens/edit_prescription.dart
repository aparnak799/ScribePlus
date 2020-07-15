import 'package:flutter/material.dart';

import 'package:ScribePlus/url.dart';

class EditPrescription extends StatefulWidget {
  final Map prescription;
  final String patientAddress;
  EditPrescription({Key key,@required this.patientAddress, @required this.prescription}): super(key: key);
  @override
  _EditPrescriptionState createState() => _EditPrescriptionState(this.patientAddress,this.prescription);
}

class _EditPrescriptionState extends State<EditPrescription> {
  Map prescription;
  String patientAddress;
  TextEditingController diagnosisController;
  TextEditingController medicinesController;

  @override
  void initState() { 
    diagnosisController.text=prescription['Disease'];
    medicinesController.text=prescription['Drugs'];
    super.initState();
    
  }
  _EditPrescriptionState(patientAddress,prescription);
  @override
  Widget build(BuildContext context) {
    // double width=MediaQuery.of(context).size.width;
    // double height=MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Prescription"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          prescriptionRowWidget('Diagnosis',diagnosisController),
          prescriptionRowWidget('Medicines',medicinesController)

        ],
      
      ),
    );
  }
  Widget prescriptionRowWidget(String textKey, TextEditingController controller){
    return Row(          
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,  
            children: <Widget>[
              Text(textKey),
              SizedBox(
                width: MediaQuery.of(context).size.width*0.6,
                child: TextField(
                controller: controller,
              ),
              )
              
            ],
          );
  }
}
