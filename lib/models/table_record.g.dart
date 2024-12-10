// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TableRecordAdapter extends TypeAdapter<TableRecord> {
  @override
  final int typeId = 3;

  @override
  TableRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TableRecord(
      id: fields[0] as String,
      name: fields[1] as String,
      columns: (fields[2] as List).cast<String>(),
      rows: (fields[3] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
    );
  }

  @override
  void write(BinaryWriter writer, TableRecord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.columns)
      ..writeByte(3)
      ..write(obj.rows);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
