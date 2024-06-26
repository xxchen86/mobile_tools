import 'package:mobile_tools/diet_food.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'date.dart';

class DietRecord {
  final String date; // format: 2024-03-27
  final String foodName;
  final int percent;

  DietRecord(this.date, this.foodName, this.percent);

  DietRecord copyWith(int percent) {
    return DietRecord(date, foodName, percent);
  }

  Map<String, Object?> toMap() {
    return {"date": date, "foodName": foodName, "percent": percent};
  }

  static DietRecord fromMap(Map m) {
    return DietRecord(m["date"], m["foodName"], m["percent"]);
  }
}

class DatabaseDietRepository {
  static Database? _db;

  _connectIfNot() async {
    if (_db != null) {
      return;
    }
    _db = await openDatabase(join(await getDatabasesPath(), 'diet_datebase.db'),
        onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE diet(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, foodName TEXT, percent INTEGER)',
      );
    }, version: 1);
  }

  _initDailyRecords() async {
    await _connectIfNot();
    final date = Date.now().toString();
    for (var food in DietFood.fullList) {
      var newRecord = DietRecord(date, food.name, 0);
      await _insert(newRecord);
    }
  }

  _insert(DietRecord record) async {
    await _connectIfNot();
    if (await _db!.insert("diet", record.toMap()) == 0) {
      throw Error();
    }
  }

  Future<List<DietRecord>> getRecords(Date date) async {
    await _connectIfNot();
    var listOfMap = await _db!
        .query("diet", where: "date = ?", whereArgs: [date.toString()]);
    if (listOfMap.isEmpty && date == Date.now()) {
      await _initDailyRecords();
      listOfMap = await _db!
          .query("diet", where: "date = ?", whereArgs: [date.toString()]);
    }
    var res = <DietRecord>[];
    for (var map in listOfMap) {
      res.add(DietRecord.fromMap(map));
    }
    return res;
  }

  Future<bool> update(DietRecord record) async {
    await _connectIfNot();
    if (await _db!.update("diet", record.toMap(),
            where: "date = ? AND foodName = ?",
            whereArgs: [record.date, record.foodName]) ==
        0) {
      return false;
    }
    return true;
  }

  Future<int?> totalPercentOfDay(Date date) async {
    await _connectIfNot();
    var records = await getRecords(date);
    return records.isEmpty
        ? null
        : records
                .map((e) => e.percent)
                .reduce((value, element) => value + element) ~/
            records.length;
  }

  Future<Map<int, int>> totalPercentThroughWeek(Date oneDateInWeek) async {
    await _connectIfNot();
    var res = <int, int>{};
    var weekday = 0;
    for (var date in oneDateInWeek.daysInWeek()) {
      weekday++;
      var p = await totalPercentOfDay(date);
      if (p != null) {
        res[weekday] = p;
      }
    }
    return res;
  }

  Future<Map<DietFood, int>> percentOfFoodThroughWeek(
      Date oneDateInWeek) async {
    await _connectIfNot();
    var recordsThroughWeek = <List<DietRecord>>[];
    for (var date in oneDateInWeek.daysInWeek()) {
      recordsThroughWeek.add(await getRecords(date));
    }
    var res = <DietFood, int>{};
    for (var food in DietFood.fullList) {
      var sum = 0;
      var count = 0;
      for (var oneDayRecords in recordsThroughWeek) {
        if (oneDayRecords.isEmpty) {
          continue;
        }
        var r = oneDayRecords
            .firstWhere((element) => element.foodName == food.name);
        sum += r.percent;
        count++;
      }
      res[food] = sum ~/ count;
    }
    return res;
  }

  Future<int> meanPercentOfWeek(Date oneDateInWeek) async {
    var percents = await totalPercentThroughWeek(oneDateInWeek);
    if (percents.isEmpty) {
      return 0;
    }
    return percents.entries
            .map((e) => e.value)
            .reduce((value, element) => value + element) ~/
        percents.length;
  }
}
