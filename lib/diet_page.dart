import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile_tools/diet_model.dart';
import 'package:provider/provider.dart';

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
                dropdownMenuEntries: diet
                    .getLastSevenDates()
                    .map((e) => DropdownMenuEntry(value: e, label: e))
                    .toList(),
                initialSelection: diet.getNowDate(),
              ),
            )),
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

class DietListTile extends StatefulWidget {
  const DietListTile({super.key, required this.name, required this.desc});

  final String name;
  final String desc;

  @override
  State<StatefulWidget> createState() {
    return _DietListTileState();
  }
}

class _DietListTileState extends State<DietListTile> {
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
        var record = diet.records[widget.name];
        var percent = record?.percent;
        return ListTile(
            leading: TextButton(
              onPressed: () {
                if (record != null && percent != null) {
                  diet.update(widget.name,
                      record.copyWith(_getIncreasedTarget(percent, -1)));
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSurface,
              ),
              child: Text(
                percent != null ? "$percent%" : "—",
              ),
            ),
            title: Text(widget.name),
            subtitle: Text(widget.desc),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              TextButton(
                onPressed: () {
                  if (record != null && percent != null) {
                    diet.update(widget.name,
                        record.copyWith(_getIncreasedTarget(percent, 1)));
                  }
                },
                child: const Text("1"),
              ),
              TextButton(
                onPressed: () {
                  if (record != null && percent != null) {
                    diet.update(widget.name,
                        record.copyWith(_getIncreasedTarget(percent, 1 / 2)));
                  }
                },
                child: const Text("1/2"),
              ),
              TextButton(
                onPressed: () {
                  if (record != null && percent != null) {
                    diet.update(widget.name,
                        record.copyWith(_getIncreasedTarget(percent, 1 / 3)));
                  }
                },
                child: const Text("1/3"),
              ),
            ]));
      },
    );
  }
}
