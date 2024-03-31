import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile_tools/diet_model.dart';
import 'package:mobile_tools/diet_repository.dart';
import 'package:provider/provider.dart';

import 'date.dart';
import 'diet_food.dart';

class DietPage extends StatefulWidget {
  const DietPage({super.key});

  @override
  State<DietPage> createState() => _DietPageState();
}

class _DietPageState extends State<DietPage> {
  int _bottomNavigationIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DietModel(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Consumer<DietModel>(
            builder: (context, diet, child) => DropdownMenu(
              inputDecorationTheme: const InputDecorationTheme(
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(style: BorderStyle.none)),
              ),
              dropdownMenuEntries: Date.now()
                  .daysInWeek()
                  .reversed
                  .map((e) => DropdownMenuEntry(
                      value: e.toString(), label: e.toString()))
                  .toList(),
              initialSelection: Date.now().toString(),
              onSelected: (String? selected) {
                diet.date = Date.parse(selected!);
              },
            ),
          ),
        ),
        body: _bottomNavigationIndex == 0
            ? const DietRecordBody()
            : const DietStatisticBody(),
        bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            setState(() {
              _bottomNavigationIndex = index;
            });
          },
          currentIndex: _bottomNavigationIndex,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.today),
              label: '记录',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: '统计',
            ),
          ],
        ),
      ),
    );
  }
}

class DietStatisticBody extends StatefulWidget {
  const DietStatisticBody({super.key});

  @override
  State<DietStatisticBody> createState() => _DietStatisticBodyState();
}

class _DietStatisticBodyState extends State<DietStatisticBody> {
  var _todayTotalPercent = 0;
  var _weekTotalPercent = <int>[];
  var _foodMeanPercent = <DietFood, int>{};

  _DietStatisticBodyState() {
    var db = DatabaseDietRepository();
    var today = Date.now().toString();
    db.totalPercentOfDay(today).then((value) => setState(() {
          _todayTotalPercent = value!;
        }));
    db.totalPercentThroughWeek(today).then((value) => setState(() {
          _weekTotalPercent = value;
        }));
    db.percentOfFoodThroughWeek(today).then((value) => setState(() {
          _foodMeanPercent = value;
        }));
  }

  @override
  Widget build(BuildContext context) {
    // return Center(
    //   child: SizedBox(
    //     height: 500,
    //     child: BarChart(
    //       BarChartData(barGroups: [
    //         BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 100)]),
    //         BarChartGroupData(x: 2),
    //         BarChartGroupData(x: 3),
    //       ]),
    //     ),
    //   ),
    // );
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("今日达成情况：$_todayTotalPercent%"),
        ]
            .followedBy(_weekTotalPercent.indexed
                .map((e) => Text("周${e.$1 + 1}达成情况：${e.$2}%")))
            .followedBy(_foodMeanPercent.entries
                .map((e) => Text("本周${e.key.name}平均达成情况：${e.value}%")))
            .toList(),
      ),
    );
  }
}

class DietRecordBody extends StatelessWidget {
  const DietRecordBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DietModel>(
      builder: (BuildContext context, DietModel dietModel, Widget? child) {
        if (dietModel.records.isEmpty) {
          return const Center(
            child: Text("没有数据"),
          );
        }
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: DietFood.fullList.length,
          itemBuilder: (context, index) {
            var food = DietFood.fullList[index];
            return DietListTile(name: food.name, desc: food.desc);
          },
        );
      },
    );
  }
}

class DietListTile extends StatelessWidget {
  const DietListTile({super.key, required this.name, required this.desc});

  final String name;
  final String desc;

  int _getIncreasedTarget(int base, double percent) {
    int delta = (percent * 100).ceil();
    base = min(base + delta, 100);
    base = max(base, 0);
    return base;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DietModel>(
      builder: (context, diet, child) {
        var record = diet.records[name];
        var percent = record?.percent;
        var disabledTextStyle = TextStyle(
            color: percent == 100 ? Theme.of(context).disabledColor : null);
        return TextButtonTheme(
          data: TextButtonThemeData(
              style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8))),
          child: ListTile(
              leading: SizedBox(
                width: 52,
                child: TextButton(
                  onPressed: () {
                    if (record != null && percent != null) {
                      diet.update(name,
                          record.copyWith(_getIncreasedTarget(percent, -1)));
                    }
                  },
                  style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onSurface),
                  child: Text(
                    percent != null ? "$percent%" : "—",
                    style: disabledTextStyle,
                  ),
                ),
              ),
              title: Text(
                name,
                style: disabledTextStyle,
              ),
              subtitle: Text(
                desc,
                style: disabledTextStyle,
              ),
              trailing: SizedBox(
                width: 150,
                child: Row(children: [
                  Expanded(
                    flex: 1,
                    child: TextButton(
                      onPressed: percent == 100
                          ? null
                          : () {
                              if (record != null && percent != null) {
                                diet.update(
                                    name,
                                    record.copyWith(
                                        _getIncreasedTarget(percent, 1)));
                              }
                            },
                      child: const Text("1"),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextButton(
                      onPressed: percent == 100
                          ? null
                          : () {
                              if (record != null && percent != null) {
                                diet.update(
                                    name,
                                    record.copyWith(
                                        _getIncreasedTarget(percent, 1 / 2)));
                              }
                            },
                      child: Text(
                        "1/2",
                        style: disabledTextStyle,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextButton(
                      onPressed: percent == 100
                          ? null
                          : () {
                              if (record != null && percent != null) {
                                diet.update(
                                    name,
                                    record.copyWith(
                                        _getIncreasedTarget(percent, 1 / 3)));
                              }
                            },
                      child: Text(
                        "1/3",
                        style: disabledTextStyle,
                      ),
                    ),
                  ),
                ]),
              )),
        );
      },
    );
  }
}
