// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TodoAdapter extends TypeAdapter<Todo> {
  @override
  final int typeId = 0;

  @override
  Todo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Todo(
      title: fields[0] as String,
      description: fields[1] as String,
      isCompleted: fields[2] as bool,
      dueDate: fields[3] as DateTime?,
      priority: fields[4] as int,
      categoryId: fields[5] as String,
      dueTime: fields[6] as TimeOfDay?,
      category: fields[7] as Category?,
    );
  }

  @override
  void write(BinaryWriter writer, Todo obj) {
    writer.writeByte(8);
    writer.writeByte(0);
    writer.write(obj.title);
    writer.writeByte(1);
    writer.write(obj.description);
    writer.writeByte(2);
    writer.write(obj.isCompleted);
    writer.writeByte(3);
    writer.write(obj.dueDate);
    writer.writeByte(4);
    writer.write(obj.priority);
    writer.writeByte(5);
    writer.write(obj.categoryId);
    writer.writeByte(6);
    writer.write(obj.dueTime);
    writer.writeByte(7);
    writer.write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
} 