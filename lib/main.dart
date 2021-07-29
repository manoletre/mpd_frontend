import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:convert';
import 'dart:async';

import 'data_types.dart';
import 'data_models.dart';
import 'shared.dart';
import 'prescription_screen.dart';

void main() => runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartModel()),
        ChangeNotifierProvider(create: (context) => MedicationListModel())
      ],
      child: MyApp(),
    ));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Medicaite',
        theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          iconTheme: IconThemeData(color: Colors.black),
          fontFamily: 'Poppins',
        ),
        home: UserPage());
  }
}

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              toolbarHeight: 60,
              centerTitle: false,
              title: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: AssetImage("assets/images/profile.png"),
                        fit: BoxFit.fill)),
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.add_circle_outline, color: Colors.black),
                  onPressed: () {},
                )
              ]),
        ),
        body: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(left: 16),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Consumer<CartModel>(builder: (context, meds, child) {
                      String text = meds.empty
                          ? "Good morning Helen,\nthese are your medications"
                          : "Select more medicine to reorder Helen!";
                      return Text(text, style: h1);
                    }))),
            PrescriptionWarning(),
            FilterSelector(),
            MedicationList(),
            CartFooter(inCart: false),
            Footer(
              active: 1,
            ),
          ],
        ));
  }
}

class FilterSelector extends StatefulWidget {
  @override
  _FilterSelectorState createState() => _FilterSelectorState();
}

class _FilterSelectorState extends State<FilterSelector> {
  final Map<String, Function> filters = {
    "Finishes soon": (MedicationInfo m) => m.daysLeft < 7,
    "Hypothyroidism": (MedicationInfo m) => m.tags.contains("Hypothyroidism"),
    "Hypertension": (MedicationInfo m) => m.tags.contains("Hypertension"),
  };

  @override
  Widget build(BuildContext buildContext) {
    return Container(
        height: 50,
        width: MediaQuery.of(context).size.width-16,
        child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            physics: BouncingScrollPhysics(),
            separatorBuilder: (context, index) => SizedBox(
                  width: 6,
                ),
            itemBuilder: (context, index) {
              return Consumer<MedicationListModel>(
                  builder: (context, meds, child) => FilterChip(
                      backgroundColor: Colors.white,
                      selectedColor: Colors.grey.shade300,
                      shape: StadiumBorder(
                          side: BorderSide(color: Colors.grey.shade600)),
                      label: Text(filters.keys.elementAt(index)),
                      selected: meds.currentFilter
                          .containsKey(filters.keys.elementAt(index)),
                      onSelected: (bool value) {
                        if (value) {
                          meds.addFilter(filters.keys.elementAt(index),
                              filters.values.elementAt(index));
                        } else {
                          meds.removeFilter(filters.keys.elementAt(index));
                        }
                      }));
            }));
  }
}

class PrescriptionWarning extends StatefulWidget {
  @override
  _PrescriptionWarningState createState() => _PrescriptionWarningState();
}

class _PrescriptionWarningState extends State<PrescriptionWarning> {
  Future<List<Prescription>>? newPrescriptions;

  Timer? timer;

  @override
  void initState() {
    super.initState();
    newPrescriptions = fetchNewPrescriptions();
    timer = Timer.periodic(Duration(seconds: 10), (Timer t) {
      print("fetch prescriptions");
      setState(() {
        newPrescriptions = fetchNewPrescriptions();
      });
    });
  }

  void cancelTimer() {
    timer!.cancel();
  }

  Future<List<Prescription>> fetchNewPrescriptions() async {
    Map data = {'patient_id': 1};
    String body = json.encode(data);

    final response = await http.post(
      Uri.parse(
          'https://medicaite.herokuapp.com/quickstart/api/new_prescriptions/'),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      Iterable l = jsonDecode(response.body);
      return List<Prescription>.from(
          l.map((model) => Prescription.fromJson(model)));
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Failed to load backend information (Prescription)');
    }
  }

  void _navigateToPrescriptionPage(
      BuildContext buildContext, List<Prescription> prescriptions) {
    cancelTimer();
    Navigator.of(buildContext).push(MaterialPageRoute(
        builder: (buildContext) =>
            PrescriptionScreen(prescriptions: prescriptions)));
  }

  @override
  Widget build(BuildContext buildContext) {
    return FutureBuilder<List<Prescription>>(
        future: newPrescriptions,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            int len = snapshot.data!.length;
            String prescText = len.toString() +
                " new prescription" +
                ((len == 1) ? "" : "s") +
                " to redeem";
            if (len > 0) {
              return Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(apricot),
                            padding:
                                MaterialStateProperty.all(EdgeInsets.all(6)),
                          ),
                          onPressed: () {
                            _navigateToPrescriptionPage(
                                buildContext, snapshot.data!);
                          },
                          child: Text(
                            prescText,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ))));
            } else {
              return SizedBox.shrink();
            }
          } else if (snapshot.hasError) {
            return Text(
                "error while getting new prescriptions: ${snapshot.error}");
          }

          return CircularProgressIndicator();
        });
  }
}

class MedicationList extends StatefulWidget {
  @override
  _MedicationListState createState() => _MedicationListState();
}

class _MedicationListState extends State<MedicationList> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Consumer<MedicationListModel>(builder: (context, model, child) {
      model.updateMeds();
      if (model.loaded) {
        return ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: model.meds.length,
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              MedicationInfo mInfo = model.meds[index];
              return Medication(
                mInfo: mInfo,
              );
            });
      } else {
        return CircularProgressIndicator();
      }
    }));
  }
}

class Medication extends StatelessWidget {
  final MedicationInfo mInfo;

  Medication({required this.mInfo});

  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Container(
          child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    children: [
                      Container(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(mInfo.medicationName,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  )),
                              Text(
                                mInfo.dosageInMg.toString() +
                                    " mg, " +
                                    mInfo.medicationType,
                                style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          )),
                      Positioned(
                          right: 0,
                          child: Consumer<CartModel>(
                              builder: (context, meds, child) {
                            bool included = meds.indexOf(mInfo) >= 0;
                            String textState = mInfo.status == "accepted"
                                ? (included
                                    ? "Added"
                                    : (meds.justOrdered
                                        ? "Accepted"
                                        : "Reorder"))
                                : mInfo.status.capitalize();
                            Color colorState = darkSpringGreen;
                            if (textState == "Added" || textState == "Pending")
                              colorState = Colors.grey.shade500;
                            else if (textState == "Call necessary")
                              colorState = uranianBlue;
                            else if (textState == "Appointment necessary")
                              colorState = apricot;
                            return ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            colorState),
                                    padding: MaterialStateProperty.all(
                                        EdgeInsets.all(10))),
                                onPressed: () {
                                  if (textState == "Reorder") meds.add(mInfo);
                                },
                                child: Text(textState));
                          }))
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Bubble(
                          text: mInfo.prescription
                              ? "Prescription"
                              : "Over the counter",
                          backgroundColor:
                              mInfo.prescription ? apricot : uranianBlue),
                      SizedBox(
                        width: 8,
                      ),
                      Bubble(
                          text: mInfo.tags[0], backgroundColor: Colors.white),
                    ],
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: 6, right: 6, top: 8),
                      child: Stack(
                        children: <Widget>[
                          LinearPercentIndicator(
                            progressColor: uranianBlue,
                            backgroundColor: Colors.white,
                            percent: (mInfo.daysLeft / mInfo.totalDosage),
                            lineHeight: 30,
                          ),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                  padding: EdgeInsets.all(3),
                                  child: Text(mInfo.daysLeft.toString() +
                                      " days left")))
                        ],
                      ))
                ],
              )),
        ));
  }
}
