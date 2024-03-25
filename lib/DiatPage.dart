import 'dart:math';

import 'package:flutter/material.dart';

class DietPage extends StatelessWidget {
  const DietPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Diet Page"),
      ),
      body: Center(
        child: ListView(
          children: const <Widget>[
            DietListTile(
              name: '奶及奶制品',
              desc: '300-500g',
            ),
            DietListTile(
              name: '大豆及坚果类',
              desc: '25-35g',
            ),
            DietListTile(
              name: '鸡蛋',
              desc: '1个',
            ),
            DietListTile(
              name: '蔬菜',
              desc: '300-500g',
            ),
            DietListTile(
              name: '水果',
              desc: '200-350g',
            ),
            DietListTile(
              name: '全谷物和杂豆',
              desc: '50-150g',
            ),
            DietListTile(
              name: '薯类',
              desc: '50-100g',
            ),
          ],
        ),
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
    print(name);
    // TODO: 这里加个数据库
    return _DietListTileState();
  }
}

class _DietListTileState extends State<DietListTile> {
  int _targetPercent = 0;

  void _increaseTarget(double percent) {
    setState(() {
      int delta = (percent * 100).ceil();
      _targetPercent = min(_targetPercent + delta, 100);
      _targetPercent = max(_targetPercent, 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: TextButton(
          onPressed: () {
            _increaseTarget(-1);
          },
          child: Text("$_targetPercent%", ),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        title: Text(widget.name),
        subtitle: Text(widget.desc),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          TextButton(
            onPressed: () {
              _increaseTarget(1);
            },
            child: const Text("1"),
          ),
          TextButton(
            onPressed: () {
              _increaseTarget(1 / 2);
            },
            child: const Text("1/2"),
          ),
          TextButton(
            onPressed: () {
              _increaseTarget(1 / 3);
            },
            child: const Text("1/3"),
          ),
        ]));
  }
}
