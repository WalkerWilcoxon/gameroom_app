// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chess.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChessMove _$ChessMoveFromJson(Map<String, dynamic> json) {
  return ChessMove(
    TilePosition.fromJson(json['fromPos'] as Map<String, dynamic>),
    TilePosition.fromJson(json['toPos'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ChessMoveToJson(ChessMove instance) => <String, dynamic>{
      'fromPos': instance.fromPos,
      'toPos': instance.toPos,
    };
