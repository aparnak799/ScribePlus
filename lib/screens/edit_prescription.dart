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
  TextEditingController symptomsController;
  TextEditingController adviceController;
  _EditPrescriptionState(this.patientAddress,this.prescription);
  @override
  void initState() { 
    print('Prescription: $prescription');
    print('Patient address: $patientAddress');
    diagnosisController=new TextEditingController(text: prescription['Disease']);
    medicinesController=new TextEditingController(text: prescription['Drugs']);
    symptomsController=new TextEditingController(text: prescription['Symptoms']);
    adviceController=new TextEditingController();
    super.initState();
    
  }
  
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
          prescriptionRowWidget('Medicines',medicinesController),
          prescriptionRowWidget('Symptoms', symptomsController),
          prescriptionRowWidget('Advice', adviceController),
          RaisedButton.icon(
            icon: Icon(Icons.send),
            label: Text("Generate Report"),
            onPressed: (){
              print({
                'Diagnosis':diagnosisController.text,
                'Medicines':medicinesController.text,
                'Symptoms':medicinesController.text,
                'Advice':adviceController.text
              });
            },
          )

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
