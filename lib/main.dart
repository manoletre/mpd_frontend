import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'medication_info.dart';

void main() => runApp(Home());

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicaid',
      theme: ThemeData(
        primaryColor: Colors.amber,
      ),
      home: RandomWords(),
    );
  }
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <MedicationInfo>[];
  final _saved = <MedicationInfo>{};
  final _biggerFont = const TextStyle(fontSize: 18.0);

  late Future<List<MedicationInfo>> medicationInfos; //what's late?

  @override
  void initState() {
    super.initState();
    medicationInfos = fetchMedicationInfo();
  }

  Future<List<MedicationInfo>> fetchMedicationInfo() async {
    final response = await http
      .get(Uri.parse('http://192.168.0.41:8000/quickstart/api/products/'));

    if (response.statusCode == 200) {
      Iterable l = jsonDecode(response.body); // Iterable<Response>
      return List<MedicationInfo>.from(
          l.map((model) => MedicationInfo.fromJson(model)));
    } else {
      throw Exception('Failed to load album');
    }
  }

  Widget _buildSuggestions() {
    return FutureBuilder<List<MedicationInfo>>(
      future: medicationInfos,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, i) {
              if (i.isOdd) return const Divider();

              final index = i ~/ 2;
              if (index >= _suggestions.length) {
                _suggestions.addAll(snapshot.data!);
              }
              return _buildRow(_suggestions[index]);
            },
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        return CircularProgressIndicator();
      },
    );
  }

  Widget _buildRow(MedicationInfo mInfo) {
    final alreadySaved = _saved.contains(mInfo);
    return ListTile(
      title: Text(
        mInfo.name + " - " + mInfo.description,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(mInfo);
          } else {
            _saved.add(mInfo);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Name Generator'),
        actions: [
          IconButton(icon: const Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // NEW lines from here...
        builder: (context) {
          final tiles = _saved.map(
            (mInfo) {
              return ListTile(
                title: Text(
                  mInfo.name + " - " + mInfo.description,
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(context: context, tiles: tiles).toList()
              : <Widget>[];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        }, //...to here.
      ),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  State<RandomWords> createState() => _RandomWordsState();
}

/*


import 'package:flutter/material.dart';

void main() => runApp(Home());

class Home extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        body: Container(
          margin: EdgeInsets.only(top: 25.0),
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    color: Colors.red,
                    child: Icon(Icons.person)
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    color: Colors.blue,
                    child: Icon(Icons.add)
                  )
                ],
              ),
              Container(
                child: Text("Hola", style: TextStyle(fontSize: 25.0)),
                color: Colors.green,
                alignment: Alignment.topRight,
              ),
              Container(
                child: Text("Chao", style: TextStyle(fontSize: 25.0)),
                color: Colors.amber,
                alignment: Alignment.topLeft,
              )
            ],
          )
        )
        
      ),
    );
  }
}

*/
