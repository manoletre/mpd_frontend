import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mpd_frontend/cart_screen.dart';
import 'package:mpd_frontend/data_models.dart';
import 'package:provider/provider.dart';

import 'data_types.dart';
import 'shared.dart';

class PrescriptionScreen extends StatefulWidget {
  final List<Prescription> prescriptions;

  PrescriptionScreen({required this.prescriptions});

  @override
  _PrescriptionScreenState createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  void goToCart(BuildContext buildContext) {
    Navigator.of(buildContext)
        .push(MaterialPageRoute(builder: (buildContext) => CartScreen()));
  }

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.shopping_cart_outlined, color: Colors.black),
              onPressed: () {
                goToCart(buildContext);
              },
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Text("We found this prescriptions for you", style: h1),
            ),
            Expanded(
                child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: widget.prescriptions.length,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return Padding(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: NewPrescription(
                      prescription: widget.prescriptions[index],
                    ));
              },
            )),
            CartFooter(inCart: false),
            Footer(
              active: 1,
            )
          ],
        ),
      );
  }
}

class NewPrescription extends StatelessWidget {
  final Prescription prescription;

  NewPrescription({required this.prescription});

  @override
  Widget build(BuildContext buildContext) {
    /*
    final DateTime prescriptionDate = prescription.date;
    final DateFormat formatter = DateFormat("yy.MM.dd");
    final String dateString = formatter.format(prescriptionDate);
    */

    final String dateString = prescription.validUntil.substring(0, 11);

    final List<PrescriptedMedication> prescriptedMedications = this
        .prescription
        .medications
        .map((med) => PrescriptedMedication(medInfo: med))
        .toList();

    return Column(
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 16, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Dr. " + prescription.doctorName, style: h3),
                Text(dateString.replaceAll("-", "."),
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300))
              ],
            )),
        Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Column(
              children: prescriptedMedications,
            )),
        Padding(
            padding: EdgeInsets.only(top: 8, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                    child: ElevatedButton(
                        onPressed: () {},
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(uranianBlue)),
                        child: Text("More info",
                            style: TextStyle(color: Colors.black)))),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: Consumer<CartModel>(
                        builder: (context, meds, child) => ElevatedButton(
                            onPressed: () {
                              meds.addList(this.prescription.medications);
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        darkSpringGreen)),
                            child: Text("Add to cart"))))
              ],
            ))
      ],
    );
  }
}

class PrescriptedMedication extends StatefulWidget {
  final MedicationInfo medInfo;

  PrescriptedMedication({required this.medInfo});

  @override
  _PrescriptedMedicationState createState() => _PrescriptedMedicationState();
}

class _PrescriptedMedicationState extends State<PrescriptedMedication> {
  bool bought = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext buildContext) {
    return Padding(
        padding: EdgeInsets.all(5),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(widget.medInfo.medicationName, style: h3),
                        Text(
                            widget.medInfo.dosageInMg.toString() +
                                " mg, " +
                                widget.medInfo.medicationType,
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w300)),
                      ],
                    )),
              ),
              Text(widget.medInfo.totalPriceInEur.toStringAsFixed(2) + "€",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
              Consumer<CartModel>(
                builder: (context, meds, child) {
                  bought = meds.indexOf(widget.medInfo) >= 0;
                  return IconButton(
                    icon: bought ? circledRemove : circledPlus,
                    onPressed: () {
                      if (bought) {
                        meds.remove(widget.medInfo);
                      } else {
                        meds.add(widget.medInfo);
                      }
                    },
                  );
                },
              )
            ]));
  }
}
