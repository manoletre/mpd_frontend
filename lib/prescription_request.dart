import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'shared.dart';
import 'data_types.dart';
import 'data_models.dart';
import 'stacked_card_carousel.dart';
import 'package:provider/provider.dart';
import 'successful_oder.dart';

class PrescriptionReqScreen extends StatefulWidget {
  @override
  _PrescriptionReqScreenState createState() => _PrescriptionReqScreenState();
}

class _PrescriptionReqScreenState extends State<PrescriptionReqScreen> {
  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Text("Edit and send the requests to your doctors Helen",
                  style: h1)),
          MedicineToReorder(),
          Consumer<CartModel>(
            builder: (context, meds, child) {
              return ChangeNotifierProvider(
                  create: (context) => ReviewedMailsModel(),
                  child: ReorderRequest(meds: meds));
            },
          ),
          Footer(
            active: 1,
          )
        ],
      ),
    );
  }
}

class MedicineToReorder extends StatefulWidget {
  @override
  _MedicineToReorderState createState() => _MedicineToReorderState();
}

class _MedicineToReorderState extends State<MedicineToReorder> {
  @override
  Widget build(BuildContext buildContext) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 16,
        ),
        Text("This medications need a prescription:", style: h3),
        Consumer<CartModel>(
          builder: (context, meds, child) {
            return Wrap(
              alignment: WrapAlignment.spaceAround,
              children: meds.prescriptionMeds
                  .map<MedToReorderInfo>((e) => MedToReorderInfo(mInfo: e))
                  .toList(),
            );
          },
        )
      ],
    );
  }
}

class MailInfo {
  final ResponsibleDoctor drInfo;
  final String emailText;

  MailInfo({required this.drInfo, required this.emailText});

  void send() async {
    Set<int> prescriptionIds =
        drInfo.medInfos.map((e) => e.prescriptionId).toSet();
    print(prescriptionIds);

    for (int id in prescriptionIds) {
      Map data = {
        "doctor_id": drInfo.drId,
        "email_body": emailText,
        "prescription_id": id
      };
      String body = json.encode(data);
      print(body);

      final response = await http.post(
        Uri.parse(
            'https://medicaite.herokuapp.com/quickstart/api/reorder_prescription/'),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      print("mailResponse " + response.statusCode.toString());
    }
  }
}

class ReviewedMailsModel extends ChangeNotifier {
  final List<MailInfo> _mails = [];

  void add(MailInfo m) {
    _mails.add(m);
    notifyListeners();
  }

  void sendAll() {
    for (MailInfo m in _mails) {
      m.send(); //TODO: error handling
    }
  }
}

class ReorderRequest extends StatefulWidget {
  final CartModel meds;

  ReorderRequest({required this.meds});

  @override
  _ReorderRequestState createState() => _ReorderRequestState();
}

class _ReorderRequestState extends State<ReorderRequest> {
  Future<List<ResponsibleDoctor>>? drList;
  List<MailInfo>? reviewedMails;

  @override
  void initState() {
    super.initState();
    drList = fetchDrList();
    reviewedMails = [];
  }

  Future<List<ResponsibleDoctor>> fetchDrList() async {
    List<int> ids =
        widget.meds.prescriptionMeds.map<int>((e) => e.medicationId).toList();
    Map data = {"patient_id": 1, "medication_ids": ids};
    String body = json.encode(data);

    final response = await http.post(
      Uri.parse(
          "https://medicaite.herokuapp.com/quickstart/api/responsible_doctors/"),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      Iterable l = jsonDecode(response.body);
      return List<ResponsibleDoctor>.from(
          l.map((model) => ResponsibleDoctor.fromJson(model)));
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Failed to load backend information (Responsible Dr.)');
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    PageController controller = PageController();

    return FutureBuilder<List<ResponsibleDoctor>>(
      future: drList,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          int len = snapshot.data!.length;
          List<ResponsibleDoctor> data = snapshot.data!;

          int i = 0;
          List<Widget> items = data.map((e) {
            i++;
            return ReorderCard(
              drInfo: e,
              controller: controller,
              last: (i == len),
            );
          }).toList();

          return Expanded(
              child: StackedCardCarousel(
                  type: StackedCardCarouselType.fadeOutStack,
                  initialOffset: 16,
                  spaceBetweenItems: 460,
                  items: items,
                  pageController: controller));
        } else if (snapshot.hasError) {
          return Text(
              "error while getting responsibleDoctor: ${snapshot.error}");
        }

        return CircularProgressIndicator();
      },
    );
  }
}

class ReorderCard extends StatelessWidget {
  final ResponsibleDoctor drInfo;
  final PageController controller;
  final bool last;

  ReorderCard(
      {required this.drInfo, required this.controller, required this.last});

  String _buildEmail() {
    String drIntro = "Dear Dr. " + drInfo.drName + ",\n\n";
    String medInfos = drInfo.medInfos.where((e) => e.prescription).fold(
        "",
        (str, e) =>
            str +
            "- " +
            e.medicationName +
            ", " +
            e.dosageInMg.toString() +
            " mg, " +
            e.totalDosage.toString() +
            " " +
            e.medicationType +
            "s\n\n");
    String text1 =
        "I would like to kindly request new prescriptions for the following medication:\n";
    String text2 = "Thank you very much in advance!\nSincerely,\nHelen\n";
    return drIntro + text1 + medInfos + text2;
  }

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
  }

  void _order(BuildContext buildContext, List<MedicationInfo> cartElements) {
    _postOrder(cartElements);

    Navigator.of(buildContext).pushAndRemoveUntil(
        MaterialPageRoute(builder: (buildContext) => SuccessScreen()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext buildContext) {
    String firstName = drInfo.drName.split(" ")[0].toLowerCase();
    String lastName = drInfo.drName.split(" ")[1].toLowerCase();

    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
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
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Dr. " + drInfo.drName,
                      style: h3,
                    )),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text("${firstName}.${lastName}@remedica.de")),
                Wrap(
                  children: drInfo.medInfos
                      .where((e) => e.prescription)
                      .map((e) => MedToReorderInfo(mInfo: e))
                      .toList(),
                ),
                TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: 8,
                    initialValue: _buildEmail()),
                SizedBox(
                  height: 16,
                ),
                Consumer<ReviewedMailsModel>(
                  builder: (context, mails, child) => Center(
                      child: last
                          ? Consumer<CartModel>(
                              builder: (context, meds, child) => ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              darkSpringGreen),
                                      padding: MaterialStateProperty.all(
                                          EdgeInsets.all(16))),
                                  onPressed: () {
                                    meds.justOrdered = true;
                                    meds.removeAll();
                                    mails.add(MailInfo(
                                        drInfo: drInfo,
                                        emailText: _buildEmail()));
                                    mails.sendAll();
                                    _order(
                                        buildContext, meds.noPrescriptionMeds);
                                  },
                                  child: Text("Send requests and place order")),
                            )
                          : ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          darkSpringGreen),
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.all(16))),
                              onPressed: () {
                                mails.add(MailInfo(
                                    drInfo: drInfo, emailText: _buildEmail()));
                                controller.nextPage(
                                    duration: Duration(milliseconds: 400),
                                    curve: Curves.easeIn);
                              },
                              child: Text("Sounds good!"))),
                )
              ],
            )));
  }
}
