import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'data_types.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicaite',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: UserPage(),
    );
  }
}

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  // TODO: state is the user's data that comes from database

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(100),
              child: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  toolbarHeight: 100,
                  title: Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: AssetImage("assets/images/profile.jpg"),
                            fit: BoxFit.fill)),
                  ),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.black),
                      onPressed: () {},
                    )
                  ]),
            ),
            body: Column(
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                              "Good morning John,\nthese are your medications",
                              style: new TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.bold)),
                        ))),
                MedicationList(),
                Footer(active: 1,),
              ],
            )));
  }
}

class MedicationList extends StatefulWidget {
  @override
  _MedicationListState createState() => _MedicationListState();
}

class _MedicationListState extends State<MedicationList> {
  late Future<List<MedicationInfo>> medInfos;

  @override
  void initState() {
    super.initState();
    medInfos = fetchMedInfo();
  }

  Future<List<MedicationInfo>> fetchMedInfo() async {
    final response = await http
        .get(Uri.parse('https://jsonplaceholder.typicode.com/comments'));

    if (response.statusCode == 200) {
      Iterable l = jsonDecode(response.body); // Iterable<Response>
      return List<MedicationInfo>.from(
          l.map((model) => MedicationInfo.fromJson(model)));
    } else {
      throw Exception('Failed to load backend information (MedInfo)');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 16),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Medication to take today:",
                  style: new TextStyle(
                    fontSize: 23,
                  ))),
        ),
        Expanded(
          child: FutureBuilder<List<MedicationInfo>>(
              future: medInfos,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: snapshot.data!.length,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        MedicationInfo mInfo = snapshot.data![index];
                        return Medication(mInfo: mInfo);
                      });
                } else if (snapshot.hasError) {
                  return Text(
                      "error while building medInfos: ${snapshot.error}");
                }
                return CircularProgressIndicator();
              }),
        )
      ],
    ));
  }
}

class Medication extends StatelessWidget {
  final MedicationInfo mInfo;

  Medication({required this.mInfo});

  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Container(
            child: Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    Image.asset(
                      "assets/images/thyronajod50.png",
                      height: 100,
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(mInfo.name,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                )),
                            Text(
                              mInfo.dosageInMg.toString() +
                                  " mg, " +
                                  mInfo.consumption,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 5),
                            Bubble(
                                text: mInfo.time,
                                backgroundColor: Colors.blueGrey.shade100),
                          ],
                        )),
                  ],
                ))));
  }
}

class Footer extends StatelessWidget {
  final int active;
  final Color normalColor = Colors.black;
  final Color activeColor = Colors.amber;
  final double iconsSize = 30;

  Footer({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 60,
        child: Row(children: <Widget>[
          Expanded(
          child: IconButton(icon: Icon(
            Icons.store, 
            size: iconsSize,
            color: active == 0 ? activeColor : normalColor),
            onPressed: () {})),
          Expanded(
          child: IconButton(icon: Icon(
            Icons.person, 
            size: iconsSize,
            color: active == 1 ? activeColor : normalColor),
            onPressed: () {})),
          Expanded(
          child: IconButton(icon: Icon(
            Icons.chat, 
            size: iconsSize,
            color: active == 2 ? activeColor : normalColor),
            onPressed: () {})),
        ]));
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
