// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BaseAdapter extends TypeAdapter<Base> {
  @override
  final int typeId = 2;

  @override
  Base read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Base(
      id: fields[0] as String,
      name: fields[1] as String,
      tables: (fields[2] as List).cast<TableRecord>(),
    );
  }

  @override
  void write(BinaryWriter writer, Base obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.tables);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
