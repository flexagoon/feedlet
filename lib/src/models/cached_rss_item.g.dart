// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_rss_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedRssItemAdapter extends TypeAdapter<CachedRssItem> {
  @override
  final int typeId = 1;

  @override
  CachedRssItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedRssItem(
      guid: fields[0] as String?,
      title: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CachedRssItem obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.guid)
      ..writeByte(1)
      ..write(obj.title);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedRssItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
