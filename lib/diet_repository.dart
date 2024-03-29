import 'package:mobile_tools/diet_food.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
  Future<List<DietRecord>> getDateRecords(String date);

  Future<bool> update(DietRecord record);
}

class FakeDietRepository extends DietRepository {
  var data = [
    DietRecord("2024-03-27", "奶及奶制品", 50).toMap(),
    DietRecord("2024-03-27", "大豆及坚果类", 30).toMap(),
    DietRecord("2024-03-27", "鸡蛋", 100).toMap(),
    DietRecord("2024-03-27", "蔬菜", 0).toMap(),
  ];

  @override
  Future<List<DietRecord>> getDateRecords(String date) {
    return Future(() {
      var res = <DietRecord>[];
      for (var value in data) {
        res.add(DietRecord.fromMap(value));
      }
      return res;
    });
  }

  @override
  Future<bool> update(DietRecord record) {
    for (int i = 0; i < data.length; ++i) {
      var value = data[i];
      if (value["foodName"] == record.foodName) {
        data[i] = record.toMap();
        return Future(() => true);
      }
    }
    return Future(() => false);
  }
}

class DatabaseDietRepository extends DietRepository {
  static Database? _db;

  connectIfNot() async {
    _db = await openDatabase(join(await getDatabasesPath(), 'diet_datebase.db'),
        onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE diet(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, foodName TEXT, percent INTEGER)',
      );
    }, version: 1);
  }

  initDailyRecords(String date) async {
    for (var food in DietFood.fullList) {
      var newRecord = DietRecord(date, food.name, 0);
      await insert(newRecord);
    }
  }

  insert(DietRecord record) async {
    if (await _db!.insert("diet", record.toMap()) == 0) {
      throw Error();
    }
  }

  @override
  Future<List<DietRecord>> getDateRecords(String date) async {
    await connectIfNot();
    var listOfMap =
        await _db!.query("diet", where: "date = ?", whereArgs: [date]);
    if (listOfMap.isNotEmpty) {
      print(listOfMap);
      var res = <DietRecord>[];
      for (var map in listOfMap) {
        res.add(DietRecord.fromMap(map));
      }
      return res;
    } else {
      await initDailyRecords(date);
      var listOfMap =
          await _db!.query("diet", where: "date = ?", whereArgs: [date]);
      print(listOfMap);
      if (listOfMap.isEmpty) {
        throw Error();
      }
      var res = <DietRecord>[];
      for (var map in listOfMap) {
        res.add(DietRecord.fromMap(map));
      }
      return res;
    }
  }

  @override
  Future<bool> update(DietRecord record) async {
    await connectIfNot();
    if (await _db!.update("diet", record.toMap(), where: "date = ? AND foodName = ?", whereArgs: [record.date, record.foodName]) == 0) {
      return false;
    }
    return true;
  }
}
