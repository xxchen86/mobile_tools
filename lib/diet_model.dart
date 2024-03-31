import 'dart:collection';

import 'package:flutter/cupertino.dart';

import 'date.dart';
import 'diet_repository.dart';

class DietModel extends ChangeNotifier {
  final _repository = DatabaseDietRepository();

  final _records = <String, DietRecord>{};

  Date _date = Date.now();

  set date(Date value) {
    _date = value;
    _updateDateRecords();
  }

  Date get date => _date;

  UnmodifiableMapView<String, DietRecord> get records =>
      UnmodifiableMapView(_records);

  DietModel() {
    _updateDateRecords();
  }

  _updateDateRecords() {
    print("change to $_date");
    _records.clear();
    _repository.getRecords(_date.toString()).then((records) {
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
