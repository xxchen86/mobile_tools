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

abstract class DietRepository {
  Future<List<DietRecord>> getRecords(String date);

  Future<bool> update(DietRecord record);
}

class DatabaseDietRepository extends DietRepository {
  static Database? _db;

  _connectIfNot() async {
    _db = await openDatabase(join(await getDatabasesPath(), 'diet_datebase.db'),
        onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE diet(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, foodName TEXT, percent INTEGER)',
      );
    }, version: 1);
  }

  _initDailyRecords() async {
    final date = Date.now().toString();
    await _connectIfNot();
    for (var food in DietFood.fullList) {
      var newRecord = DietRecord(date, food.name, 0);
      await _insert(newRecord);
    }
  }

  _insert(DietRecord record) async {
    if (await _db!.insert("diet", record.toMap()) == 0) {
      throw Error();
    }
  }

  @override
  Future<List<DietRecord>> getRecords(String date) async {
    await _connectIfNot();
    var listOfMap =
        await _db!.query("diet", where: "date = ?", whereArgs: [date]);
    if (listOfMap.isEmpty && date == Date.now().toString()) {
      await _initDailyRecords();
      listOfMap =
          await _db!.query("diet", where: "date = ?", whereArgs: [date]);
    }
    print(listOfMap);
    var res = <DietRecord>[];
    for (var map in listOfMap) {
      res.add(DietRecord.fromMap(map));
    }
    return res;
  }

  @override
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
}
