import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'main.dart';
import 'shared.dart';

class SuccessScreen extends StatefulWidget {
  @override
  _SuccessScreenState createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  void goBackHome(BuildContext buildContext) {
    Navigator.of(buildContext).pushAndRemoveUntil(
        MaterialPageRoute(builder: (buildContext) => UserPage()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: Colors.black),
            ),
            body: Container(
                color: Colors.white,
                child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Thank you! your order is on its way",
                          style: h1,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 32,
                        ),
                        Container(
                            width: double.infinity,
                            child: ElevatedButton(
                                onPressed: () {
                                  goBackHome(buildContext);
                                },
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            darkSpringGreen),
                                    padding: MaterialStateProperty.all(
                                        EdgeInsets.all(16))),
                                child: Text("Go back home", style: h3))),
                      ],
                    )))));
  }
}
