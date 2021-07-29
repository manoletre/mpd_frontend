import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data_types.dart';
import 'shared.dart';
import 'data_models.dart';
import 'main.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          actions: <Widget>[
            IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.shopping_cart,
                  color: darkSpringGreen,
                ))
          ],
        ),
        body: Padding(
            padding: EdgeInsets.only(left: 8, right: 8),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text("Welcome to your cart Helen.", style: h1),
                ),
                Cart(),
                CartFooter(inCart: true),
                Footer(active: 1)
              ],
            )));
  }
}

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  @override
  Widget build(BuildContext buildContext) {
    return Expanded(
        child: Column(
      children: <Widget>[
        Expanded(
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.7),
                      spreadRadius: 0,
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Consumer<CartModel>(
                  builder: (context, meds, child) => Padding(
                      padding: EdgeInsets.all(8),
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: meds.length,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          if (index < meds.length) {
                            return Column(children: <Widget>[
                              CartItem(medInfo: meds.items[index]),
                              SizedBox(
                                height: 8,
                              ),
                            ]);
                          } else {
                            return CartItem(medInfo: meds.items[index]);
                          }
                        },
                      )),
                ))),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Total Price:",
                    style: h3,
                    textAlign: TextAlign.right,
                  )),
            ),
            Expanded(
                child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Consumer<CartModel>(
                      builder: (context, meds, child) =>
                          Text(meds.priceString + "€", style: h3),
                    )))
          ],
        ),
        Consumer<CartModel>(
          builder: (context, meds, child) =>
              (meds.length > 2) ? SizedBox.shrink() : Packages(),
        ),
        SizedBox(
          height: 8,
        ),
      ],
    ));
  }
}

class CartItem extends StatefulWidget {
  final MedicationInfo medInfo;

  CartItem({required this.medInfo});

  @override
  _CartItemState createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  @override
  Widget build(BuildContext buildContext) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
            child: Row(
              children: <Widget>[
                Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.medInfo.medicationName,
                          style: h3,
                        ),
                        Text(
                            widget.medInfo.dosageInMg.toString() +
                                "mg, " +
                                widget.medInfo.medicationType,
                            style: TextStyle(color: Colors.grey.shade700)),
                        Chip(
                          label: Text(widget.medInfo.prescription
                              ? "Prescription"
                              : "Over the counter"),
                          backgroundColor: widget.medInfo.prescription
                              ? apricot
                              : uranianBlue,
                        )
                      ],
                    )),
                Expanded(
                    flex: 2,
                    child: Text(
                        widget.medInfo.totalPriceInEur.toStringAsFixed(2) + "€",
                        style: h3)),
                Expanded(
                  flex: 1,
                  child: Consumer<CartModel>(
                      builder: (context, cart, child) => IconButton(
                          onPressed: () {
                            cart.remove(widget.medInfo);
                          },
                          icon: Icon(Icons.remove_circle_outline,
                              color: Colors.grey.shade700))),
                )
              ],
            )));
  }
}

class Packages extends StatefulWidget {
  @override
  _PackagesState createState() => _PackagesState();
}

class _PackagesState extends State<Packages> {
  void _goBackHome(BuildContext buildContext) {
    Navigator.of(buildContext).pushAndRemoveUntil(
        MaterialPageRoute(builder: (buildContext) => UserPage()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext buildContext) {
    return Container(
        width: double.infinity,
        child: Padding(
            padding: EdgeInsets.only(top: 16, bottom: 16),
            child: Consumer<MedicationListModel>(
              builder: (context, model, child) => ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(uranianBlue),
                    padding: MaterialStateProperty.all(EdgeInsets.all(16)),
                  ),
                  onPressed: () {
                    model.addFilter(
                        "Finishes soon", (MedicationInfo m) => m.daysLeft < 7);
                    _goBackHome(buildContext);
                  },
                  child:
                      Text("Some medicine will be over soon!", style: h3Black)),
            )));
  }
}
