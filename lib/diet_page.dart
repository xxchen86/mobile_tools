import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_tools/diet_model.dart';
import 'package:provider/provider.dart';

import 'date.dart';
import 'diet_food.dart';

class DietPage extends StatelessWidget {
  const DietPage({super.key});

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
        body: Center(
            child: ListView.builder(
          itemCount: DietFood.fullList.length,
          itemBuilder: (context, index) {
            var food = DietFood.fullList[index];
            return DietListTile(name: food.name, desc: food.desc);
          },
        )),
      ),
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
                  ),
                ),
              ),
              title: Text(name),
              subtitle: Text(desc),
              trailing: SizedBox(
                width: 150,
                child: Row(children: [
                  Expanded(
                    flex: 1,
                    child: TextButton(
                      onPressed: () {
                        if (record != null && percent != null) {
                          diet.update(name,
                              record.copyWith(_getIncreasedTarget(percent, 1)));
                        }
                      },
                      child: const Text("1"),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextButton(
                      onPressed: () {
                        if (record != null && percent != null) {
                          diet.update(
                              name,
                              record.copyWith(
                                  _getIncreasedTarget(percent, 1 / 2)));
                        }
                      },
                      child: const Text("1/2"),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextButton(
                      onPressed: () {
                        if (record != null && percent != null) {
                          diet.update(
                              name,
                              record.copyWith(
                                  _getIncreasedTarget(percent, 1 / 3)));
                        }
                      },
                      child: const Text("1/3"),
                    ),
                  ),
                ]),
              )),
        );
      },
    );
  }
}
