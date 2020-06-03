// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameRecord _$GameRecordFromJson(Map<String, dynamic> json) {
  return GameRecord(
    json['player1'] == null
        ? null
        : User.fromJson(json['player1'] as Map<String, dynamic>),
    json['player2'] == null
        ? null
        : User.fromJson(json['player2'] as Map<String, dynamic>),
    json['winner'] == null
        ? null
        : User.fromJson(json['winner'] as Map<String, dynamic>),
    json['id'] as int,
    _$enumDecodeNullable(_$GameTitleEnumMap, json['game']),
  );
}

Map<String, dynamic> _$GameRecordToJson(GameRecord instance) =>
    <String, dynamic>{
      'player1': instance.player1,
      'player2': instance.player2,
      'winner': instance.winner,
      'game': _$GameTitleEnumMap[instance.game],
      'id': instance.id,
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$GameTitleEnumMap = {
  GameTitle.chess: 'chess',
  GameTitle.tic_tac_toe: 'tic_tac_toe',
  GameTitle.checkers: 'checkers',
};
