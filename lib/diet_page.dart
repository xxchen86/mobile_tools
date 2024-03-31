import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_tools/diet_model.dart';
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
                  .lastSevenDays()
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
            : const Center(child: Text("开发中")),
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
                      child: Text("1"),
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
