import 'dart:collection';

import 'package:flutter/cupertino.dart';

import 'diet_repository.dart';

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

  String getYesterday(String today) {
    return DateTime.parse(today)
        .subtract(const Duration(days: 1))
        .toString()
        .split(" ")[0];
  }

  List<String> getLastSevenDates() {
    var now = getNowDate();
    var days = <String>[now];
    for (int i = 0; i < 6; ++i) {
      var yesterday = getYesterday(now);
      days.add(yesterday);
      now = yesterday;
    }
    return days;
  }

  void update(String name, DietRecord record) {
    _repository.update(record).whenComplete(() {
      _records[name] = record;
      notifyListeners();
    });
  }
}
