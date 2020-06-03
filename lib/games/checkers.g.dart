// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkers.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckersMove _$CheckersMoveFromJson(Map<String, dynamic> json) {
  return CheckersMove(
    TilePosition.fromJson(json['fromPos'] as Map<String, dynamic>),
    TilePosition.fromJson(json['toPos'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$CheckersMoveToJson(CheckersMove instance) =>
    <String, dynamic>{
      'fromPos': instance.fromPos,
      'toPos': instance.toPos,
    };
