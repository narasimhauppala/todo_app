import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:todoapp/models/category.dart';

part 'todo.g.dart';

@HiveType(typeId: 0)
class Todo extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  DateTime? dueDate;

  @HiveField(4)
  int priority;

  @HiveField(5)
  String categoryId;

  @HiveField(6)
  TimeOfDay? dueTime;

  @HiveField(7)
  final Category? category;

  Todo({
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.dueDate,
    this.dueTime,
    this.priority = 0,
    this.categoryId = '',
    this.category,
  });

  DateTime? get dueDateWithTime {
    if (dueDate == null || dueTime == null) return dueDate;
    return DateTime(
      dueDate!.year,
      dueDate!.month,
      dueDate!.day,
      dueTime!.hour,
      dueTime!.minute,
    );
  }

  Todo copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    int? priority,
    String? categoryId,
    Category? category,
  }) {
    return Todo(
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
    );
  }
} 