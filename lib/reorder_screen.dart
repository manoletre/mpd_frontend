import 'package:flutter/material.dart';
import 'package:mpd_frontend/shared.dart';
import 'package:provider/provider.dart';

import 'prescription_request.dart';
import 'data_types.dart';
import 'data_models.dart';
import 'shared.dart';

class ReorderScreen extends StatefulWidget {
  @override
  _ReorderScreenState createState() => _ReorderScreenState();
}

class _ReorderScreenState extends State<ReorderScreen> {
  void _navigateToPrescReq(BuildContext buildContext) {
    Navigator.of(buildContext).push(
        MaterialPageRoute(builder: (buildContext) => PrescriptionReqScreen()));
  }

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: Colors.black),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.shopping_cart_outlined, color: Colors.black),
                  onPressed: () {
                    //goToCart(buildContext, shoppingCart);
                  },
                )
              ],
            ),
            body: Container(
                color: Colors.white,
                child: Stack(children: <Widget>[
                  Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: <Widget>[
                          Text("This are the meds you wish to reorder",
                              style: h1),
                          SizedBox(
                            height: 16,
                          ),
                          Consumer<CartModel>(
                            builder: (context, meds, child) => Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                ),
                                child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Column(
                                      children: meds.items
                                          .map((e) => MedToReorder(mInfo: e))
                                          .toList(),
                                    ))),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text("More meds that might help you:",
                                  style: h3Black)),
                          SizedBox(
                            height: 16,
                          ),
                        ],
                      )),
                  Positioned(
                      bottom: 0,
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.7),
                                spreadRadius: 0,
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Consumer<CartModel>(
                                builder: (context, meds, child) {
                                  return ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                darkSpringGreen),
                                        padding: MaterialStateProperty.all(
                                            EdgeInsets.all(16)),
                                      ),
                                      onPressed: () {
                                        _navigateToPrescReq(buildContext);
                                      },
                                      child: Text(
                                          "Order now: " +
                                              meds.totalPrice.toString() +
                                              "€",
                                          style: h3));
                                },
                              )))),
                ])));
  }
}

class MedToReorder extends StatelessWidget {
  final MedicationInfo mInfo;

  MedToReorder({required this.mInfo});

  @override
  Widget build(BuildContext buildContext) {
    return Padding(
        padding: EdgeInsets.all(8),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      children: <Widget>[
                        Text(mInfo.medicationName,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(mInfo.medicationName,
                            style: TextStyle(
                                fontSize: 17, color: Colors.grey.shade700)),
                      ],
                    )),
              ),
              Text(mInfo.totalPriceInEur.toString() + "€",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              Consumer<CartModel>(
                builder: (context, meds, child) {
                  return IconButton(
                      onPressed: () {
                        meds.remove(mInfo);
                      },
                      icon: Icon(Icons.remove_circle_outline,
                          color: Colors.grey.shade700));
                },
              )
            ]));
  }
}
