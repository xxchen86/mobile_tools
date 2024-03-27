import 'dart:collection';

import 'package:flutter/cupertino.dart';

import 'DietRepository.dart';

class DietModel extends ChangeNotifier {
  final _repository = DatabaseDietRepository();

  final _records = <String, DietRecord>{};

  UnmodifiableMapView<String, DietRecord> get records =>
      UnmodifiableMapView(_records);

  DietModel() {
    _repository.getDateRecords(getNowDate()).then((records) {
      if (records.isNotEmpty) {
        for (var record in records) {
          _records[record.foodName] = record;
        }
      }
    }).whenComplete(() => notifyListeners());
  }

  String getNowDate() {
    return DateTime.now().toString().split(" ")[0];
  }

  void update(String name, DietRecord record) {
    _repository.update(record).whenComplete(() {
      _records[name] = record;
      notifyListeners();
    });
  }
}
