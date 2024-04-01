extension DateCasting on DateTime {
  Date toDate() {
    return Date.fromDateTime(this);
  }
}

class Date {
  final DateTime _dateTime;

  Date.parse(String format) : _dateTime = DateTime.parse(format);

  Date.now() : _dateTime = DateTime.now();

  Date.fromDateTime(DateTime dateTime) : _dateTime = dateTime;

  List<Date> lastSevenDays() {
    var res = <Date>[];
    for (int i = 0; i < 6; ++i) {
      res.add(_dateTime.subtract(Duration(days: i)).toDate());
    }
    return res;
  }

  List<Date> daysInWeek() {
    var res = <Date>[];
    for(var i = _dateTime.weekday - 1;i >= 0; --i) {
      res.add(_dateTime.subtract(Duration(days: i)).toDate());
    }
    return res;
  }

  Date yesterday() {
    return _dateTime.subtract(const Duration(days: 1)).toDate();
  }

  @override
  String toString() {
    return _dateTime.toString().split(" ").first;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Date &&
          runtimeType == other.runtimeType &&
          toString() == other.toString();

  @override
  int get hashCode => _dateTime.hashCode;
}
