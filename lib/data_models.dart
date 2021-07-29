import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'data_types.dart';
import 'shared.dart';

class CartModel extends ChangeNotifier {
  final List<MedicationInfo> _items = [];

  bool justOrdered = false;

  bool get empty => _items.length == 0;

  int get length => _items.length;

  num get totalPrice => _items.fold(0, (sum, e) => (sum + e.totalPriceInEur));

  String get priceString => totalPrice.toStringAsFixed(2);

  List<MedicationInfo> get items => _items;

  List<MedicationInfo> get prescriptionMeds =>
      _items.where((element) => element.prescription).toList();
  List<MedicationInfo> get noPrescriptionMeds =>
      _items.where((element) => !element.prescription).toList();

  List<Widget> get medInfoWidgets =>
      toWidgetList((MedicationInfo m) => MedToReorderInfo(mInfo: m));

  List<Widget> toWidgetList(Function(MedicationInfo) widgetCreator) {
    return _items.map<Widget>((e) => widgetCreator(e)).toList();
  }

  void add(MedicationInfo mInfo) {
    if (_items.indexOf(mInfo) < 0) {
      _items.add(mInfo);
      notifyListeners();
    }
  }

  void addList(List<MedicationInfo> mInfos) {
    _items.addAll(mInfos);
    notifyListeners();
  }

  int indexOf(MedicationInfo mInfo) {
    return _items.indexOf(mInfo);
  }

  void removeAll() {
    _items.clear();
    notifyListeners();
  }

  void remove(MedicationInfo medInfo) {
    _items.remove(medInfo);
    notifyListeners();
  }
}

class MedicationListModel extends ChangeNotifier {
  List<MedicationInfo> _items = [];
  bool loaded = false;
  Map<String, Function> currentFilter = {};

  void finishLoading() {
    loaded = true;
    //print("loading finished");
    //loading repeats with timer
    notifyListeners();
  }

  void startLoading() {
    loaded = false;
    notifyListeners();
  }

  List<MedicationInfo> get meds => _items
      .where((med) =>
          currentFilter.values.fold(true, (prev, func) => prev && func(med)))
      .toList();

  void updateMeds() {
    fetchMeds().then((meds) => _items = meds);
  }

  Future<List<MedicationInfo>> fetchMeds() async {
    Map data = {'patient_id': 1};
    String body = json.encode(data);

    final response = await http.post(
      Uri.parse(
          'https://medicaite.herokuapp.com/quickstart/api/current_medication/'),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      Iterable l = jsonDecode(response.body);
      finishLoading();
      return List<MedicationInfo>.from(
          l.map((model) => MedicationInfo.fromJson(model)));
    } else if (response.statusCode == 404) {
      finishLoading();
      return [];
    } else {
      finishLoading();
      throw Exception('Failed to load backend information (MedInfo)');
    }
  }

  void addFilter(String s, Function f) {
    currentFilter[s] = f;
    notifyListeners();
  }

  void removeFilter(String s) {
    currentFilter.remove(s);
    notifyListeners();
  }

  void removeFilters() {
    currentFilter.clear();
    notifyListeners();
  }
}
