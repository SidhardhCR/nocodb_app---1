// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkspaceAdapter extends TypeAdapter<Workspace> {
  @override
  final int typeId = 1;

  @override
  Workspace read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Workspace(
      id: fields[0] as String,
      name: fields[1] as String,
      bases: (fields[2] as List).cast<Base>(),
    );
  }

  @override
  void write(BinaryWriter writer, Workspace obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.bases);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkspaceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
