import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpirationTimePage extends StatelessWidget {
  const ExpirationTimePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('食品过期时间计算器'),
        ),
        body: FoodExpiryForm(),
      ),
    );
  }
}

class FoodExpiryForm extends StatefulWidget {
  @override
  _FoodExpiryFormState createState() => _FoodExpiryFormState();
}

enum ExpiryType {
  Date,
  Month,
}

class _FoodExpiryFormState extends State<FoodExpiryForm> {
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _customDaysController = TextEditingController();
  final FocusNode _yearFocus = FocusNode();
  final FocusNode _monthFocus = FocusNode();
  final FocusNode _dayFocus = FocusNode();
  ExpiryType _expiryType = ExpiryType.Date; // 默认选择日期输入
  String _expiryMessage = '';

  void _calculateExpiry(int days) {
    try {
      final year = int.parse(_yearController.text);
      final month = int.parse(_monthController.text);
      final day = int.parse(_dayController.text);
      final inputDate = DateTime(year, month, day);
      final expiryDate = inputDate.add(Duration(days: days));
      final currentDate = DateTime.now();

      setState(() {
        if (currentDate.isAfter(expiryDate)) {
          _expiryMessage =
              '食品已过期，过期时间为 ${DateFormat('yyyy-MM-dd').format(expiryDate)}';
        } else {
          _expiryMessage =
              '食品未过期，有效期至 ${DateFormat('yyyy-MM-dd').format(expiryDate)}';
        }
      });
    } catch (e) {
      setState(() {
        _expiryMessage = '输入日期格式有误，请输入有效的日期';
      });
    }
  }

  void _onYearChanged(String value) {
    if (value.length == 4) {
      _monthController.clear();
      _monthFocus.requestFocus();
    }
  }

  void _onMonthChanged(String value) {
    if (value.length == 2) {
      _dayController.clear();
      _dayFocus.requestFocus();
    }
  }

  void _inputDateOver(String value) {
    final year = int.tryParse(_yearController.text);
    final month = int.tryParse(_monthController.text);
    final day = int.tryParse(value);

    if (year == null || month == null || day == null) {
      _yearController.clear();
      _yearFocus.requestFocus();
      setState(() {
        _expiryMessage = '请输入有效的日期';
      });
      return;
    }

    if (!_isValidDate(year, month, day)) {
      _yearController.clear();
      _yearFocus.requestFocus();
      setState(() {
        _expiryMessage = '请输入有效的日期';
      });
      return;
    }

    _dayFocus.unfocus();
  }

  void _onDayChanged(String value) {
    if (value.length == 2) {
      _inputDateOver(value);
    }
  }

  bool _isValidDate(int year, int month, int day) {
    try {
      final dateString = '$year-$month-$day';
      final formatter = DateFormat('yyyy-MM-dd');
      final parsedDate = formatter.parseStrict(dateString);
      return parsedDate.year == year &&
          parsedDate.month == month &&
          parsedDate.day == day;
    } catch (e) {
      return false;
    }
  }

  void _calculateCustomExpiry() {
    late int? customDays;
    if (_expiryType == ExpiryType.Date) {
      customDays = int.tryParse(_customDaysController.text);
    } else {
      customDays = int.tryParse(_customDaysController.text);
      if (customDays != null) {
        customDays *= 30;
      }
    }
    if (customDays != null && customDays > 0) {
      _calculateExpiry(customDays);
    } else {
      setState(() {
        _expiryMessage = '请输入有效的天数';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _yearController,
                  focusNode: _yearFocus,
                  decoration: InputDecoration(
                    labelText: '年 (yyyy)',
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  onChanged: _onYearChanged,
                  onTap: () => _yearController.clear(),
                  onSubmitted: (v) {
                    _monthController.clear();
                    _monthFocus.requestFocus();
                  },
                ),
              ),
              SizedBox(width: 8.0),
              Text(
                '—',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: TextField(
                  controller: _monthController,
                  focusNode: _monthFocus,
                  decoration: InputDecoration(
                    labelText: '月 (MM)',
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 2,
                  onChanged: _onMonthChanged,
                  onTap: () => _monthController.clear(),
                  onSubmitted: (v) {
                    _dayController.clear();
                    _dayFocus.requestFocus();
                  },
                ),
              ),
              SizedBox(width: 8.0),
              Text(
                '—',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: TextField(
                  controller: _dayController,
                  focusNode: _dayFocus,
                  decoration: InputDecoration(
                    labelText: '日 (dd)',
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 2,
                  onChanged: _onDayChanged,
                  onTap: () => _dayController.clear(),
                  onSubmitted: (v) {
                    _dayFocus.unfocus();
                    _inputDateOver(_dayController.text);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Wrap(
            spacing: 8.0,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => _calculateExpiry(30),
                child: Text('30天'),
              ),
              ElevatedButton(
                onPressed: () => _calculateExpiry(120),
                child: Text('120天/4个月'),
              ),
              ElevatedButton(
                onPressed: () => _calculateExpiry(180),
                child: Text('180天/6个月'),
              ),
              ElevatedButton(
                onPressed: () => _calculateExpiry(240),
                child: Text('240天/8个月'),
              ),
              ElevatedButton(
                onPressed: () => _calculateExpiry(18 * 30),
                child: Text('18个月'),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: _customDaysController,
                  decoration: InputDecoration(
                    labelText: '自定义保质期',
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  onChanged: (value) {
                    setState(() {
                      _expiryMessage = '';
                    });
                  },
                  onFieldSubmitted: (value) {
                    _calculateCustomExpiry();
                  },
                ),
              ),
              SizedBox(width: 8.0),
              DropdownButton<ExpiryType>(
                value: _expiryType,
                onChanged: (value) {
                  setState(() {
                    if (value != null) {
                      _expiryType = value;
                    }
                  });
                },
                items: [
                  DropdownMenuItem(
                    value: ExpiryType.Date,
                    child: Text('日'),
                  ),
                  DropdownMenuItem(
                    value: ExpiryType.Month,
                    child: Text('月'),
                  ),
                ],
              ),
              SizedBox(width: 8.0),
              ElevatedButton(
                onPressed: () {
                  _calculateCustomExpiry();
                },
                child: Text('计算'),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Text(
            _expiryMessage,
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
