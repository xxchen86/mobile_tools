import 'dart:collection';

import 'package:flutter/cupertino.dart';

import 'date.dart';
import 'diet_repository.dart';

class DietModel extends ChangeNotifier {
  final _repository = DatabaseDietRepository();
  final _records = <String, DietRecord>{};
  Date _date = Date.now();

  DietModel() {
    _updateDateRecords();
  }

  UnmodifiableMapView<String, DietRecord> get records =>
      UnmodifiableMapView(_records);

  Date get date => _date;

  setDate(Date date) {
    _date = date;
    _updateDateRecords();
  }

  _updateDateRecords() {
    _records.clear();
    _repository.getRecords(_date).then((records) {
      for (var record in records) {
        _records[record.foodName] = record;
      }
    }).whenComplete(() => notifyListeners());
  }

  update(String name, DietRecord record) {
    _repository.update(record).whenComplete(() {
      _records[name] = record;
      notifyListeners();
    });
  }
}
