import 'dart:collection';

class DietFood {
  final String name;
  final String desc;

  DietFood(this.name, this.desc);

  static var fullList = UnmodifiableListView([
    DietFood("奶及奶制品", "300-500g"),
    DietFood("大豆及坚果类", "25-35g"),
    DietFood("鸡蛋", "1个"),
    DietFood("蔬菜", "300-500g"),
    DietFood("水果", "200-350g"),
    DietFood("全谷物和杂豆", "50-150g"),
    DietFood("薯类", "50-100g"),
  ]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DietFood &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          desc == other.desc;

  @override
  int get hashCode => name.hashCode ^ desc.hashCode;
}
