import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'data_types.dart';
import 'data_models.dart';
import 'cart_screen.dart';
import 'main.dart';
import 'successful_oder.dart';
import 'prescription_request.dart';

final darkSpringGreen = Color(0xff1f6d48);
final apricot = Color(0xffffc9ad);
final uranianBlue = Color(0xffb8dff5);

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class Footer extends StatelessWidget {
  final int active;
  final Color normalColor = Colors.black;
  final Color activeColor = darkSpringGreen;
  final double iconsSize = 30;

  Footer({required this.active});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 3),
        child: Container(
            height: 60,
            color: Colors.white,
            child: Row(children: <Widget>[
              Expanded(
                  child: IconButton(
                      icon: Icon(Icons.store,
                          size: iconsSize,
                          color: active == 0 ? activeColor : normalColor),
                      onPressed: () {})),
              Expanded(
                  child: IconButton(
                      icon: Icon(Icons.medication,
                          size: iconsSize,
                          color: active == 1 ? activeColor : normalColor),
                      onPressed: () {})),
              Expanded(
                  child: IconButton(
                      icon: Icon(Icons.chat,
                          size: iconsSize,
                          color: active == 2 ? activeColor : normalColor),
                      onPressed: () {})),
            ])));
  }
}

class Bubble extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color color;

  Bubble(
      {required this.text,
      required this.backgroundColor,
      this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: this.backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Padding(
            padding: EdgeInsets.only(top: 3, bottom: 3, left: 10, right: 10),
            child: Text(this.text, style: TextStyle(fontSize: 15))));
  }
}

class TwoButtonFooter extends StatefulWidget {
  final Function onPressedBtn1;
  final Widget widgetBtn1;
  final Function onPressedBtn2;
  final Widget widgetBtn2;

  TwoButtonFooter(
      {required this.onPressedBtn1,
      required this.widgetBtn1,
      required this.onPressedBtn2,
      required this.widgetBtn2});

  @override
  _TwoButtonFooterState createState() => _TwoButtonFooterState();
}

class _TwoButtonFooterState extends State<TwoButtonFooter> {
  @override
  Widget build(BuildContext buildContext) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
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
            child: Column(
              children: <Widget>[
                Container(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          widget.onPressedBtn1();
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.grey.shade100),
                            padding:
                                MaterialStateProperty.all(EdgeInsets.all(16))),
                        child: widget.widgetBtn1)),
                SizedBox(
                  height: 16,
                ),
                Container(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          widget.onPressedBtn2();
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                darkSpringGreen),
                            padding:
                                MaterialStateProperty.all(EdgeInsets.all(16))),
                        child: Padding(
                            padding: EdgeInsets.only(left: 32, right: 32),
                            child: widget.widgetBtn2))),
              ],
            )));
  }
}

class MedToReorderInfo extends StatelessWidget {
  final MedicationInfo mInfo;

  MedToReorderInfo({required this.mInfo});

  @override
  Widget build(BuildContext buildContext) {
    return Padding(
        padding: EdgeInsets.only(right: 4, left: 4),
        child: Chip(
          backgroundColor: mInfo.prescription ? apricot : uranianBlue,
          label: Text(mInfo.medicationName, style: TextStyle(fontSize: 18)),
        ));
  }
}

class CartFooter extends StatefulWidget {
  final bool inCart;

  CartFooter({required this.inCart});

  @override
  _ReorderWarningState createState() => _ReorderWarningState();
}

class _ReorderWarningState extends State<CartFooter> {
  void _postOrder(List<MedicationInfo> cartElements) async {
    List<Map<String, dynamic>> ids = cartElements
        .map((e) => {"medication_id": e.medicationId, "patient_id": 1})
        .toList();
    Map data = {"ids": ids};
    String body = json.encode(data);

    final response = await http.post(
      Uri.parse(
          'https://medicaite.herokuapp.com/quickstart/api/redeem_prescription/'),
      headers: {"Content-Type": "application/json"},
      body: body,
    );
    print("response sent");
    print(body);
  }

  void _order(BuildContext buildContext, List<MedicationInfo> cartElements) {
    _postOrder(cartElements);

    Navigator.of(buildContext).pushAndRemoveUntil(
        MaterialPageRoute(builder: (buildContext) => SuccessScreen()),
        (Route<dynamic> route) => false);
  }

  void _navigateToCart(BuildContext buildContext) {
    Navigator.of(buildContext)
        .push(MaterialPageRoute(builder: (buildContext) => CartScreen()));
  }

  void _navigateToUser(BuildContext buildContext) {
    Navigator.of(buildContext).pushAndRemoveUntil(
        MaterialPageRoute(builder: (buildContext) => UserPage()),
        (Route<dynamic> route) => false);
  }

  void _navigateToPrescriptionRequestScreen(BuildContext buildContext) {
    Navigator.of(buildContext).push(
        MaterialPageRoute(builder: (buildContext) => PrescriptionReqScreen()));
  }

  @override
  Widget build(BuildContext buildContext) {
    return Consumer<CartModel>(builder: (context, meds, child) {
      if (meds.empty) {
        return SizedBox.shrink();
      } else {
        return Container(
            width: MediaQuery.of(context).size.width-16,
            child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(darkSpringGreen),
                        padding: MaterialStateProperty.all(EdgeInsets.all(5))),
                    onPressed: () {
                      if (widget.inCart) {
                        if (meds.prescriptionMeds.length > 0) {
                          _navigateToPrescriptionRequestScreen(buildContext);
                        } else {
                          _order(buildContext, meds.items);
                        }
                      } else {
                        _navigateToCart(buildContext);
                      }
                    },
                    child: Text(
                        widget.inCart
                            ? "Order now for ${meds.priceString}€"
                            : "Go to cart: ${meds.priceString}€",
                        style: h3)));
      }
    });
  }
}

final TextStyle h3 = TextStyle(fontWeight: FontWeight.w500, fontSize: 18);
final TextStyle h3Black =
    TextStyle(fontWeight: FontWeight.w500, fontSize: 18, color: Colors.black);
final TextStyle h1 =
    TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.black);
final Icon circledPlus = Icon(Icons.add_circle_outline, color: darkSpringGreen);
final Icon circledCheck =
    Icon(Icons.check_circle_outline, color: Colors.grey.shade700);
final Icon circledRemove =
    Icon(Icons.remove_circle_outline, color: Colors.grey.shade700);
