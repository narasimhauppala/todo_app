import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'category.g.dart';

@HiveType(typeId: 2)
class Category extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int colorValue;

  @HiveField(2)
  final int iconData;

  Category({
    required this.name,
    required this.colorValue,
    required this.iconData,
  });

  Color get color => Color(colorValue);
  IconData get icon => IconData(iconData, fontFamily: 'MaterialIcons');

  Category copyWith({
    String? name,
    int? colorValue,
    int? iconData,
  }) {
    return Category(
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      iconData: iconData ?? this.iconData,
    );
  }

  @override
  String toString() => name;
} 