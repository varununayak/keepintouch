// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FriendAdapter extends TypeAdapter<Friend> {
  @override
  final int typeId = 1;

  @override
  Friend read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Friend(
      id: fields[0] as String,
      name: fields[1] as String,
      closenessTier: fields[2] as ClosenessTier,
      notes: fields[3] as String?,
      lastContacted: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Friend obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.closenessTier)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.lastContacted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FriendAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ClosenessTierAdapter extends TypeAdapter<ClosenessTier> {
  @override
  final int typeId = 0;

  @override
  ClosenessTier read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ClosenessTier.close;
      case 1:
        return ClosenessTier.medium;
      case 2:
        return ClosenessTier.distant;
      default:
        return ClosenessTier.close;
    }
  }

  @override
  void write(BinaryWriter writer, ClosenessTier obj) {
    switch (obj) {
      case ClosenessTier.close:
        writer.writeByte(0);
        break;
      case ClosenessTier.medium:
        writer.writeByte(1);
        break;
      case ClosenessTier.distant:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClosenessTierAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
