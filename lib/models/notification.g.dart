// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameFound _$GameFoundFromJson(Map<String, dynamic> json) {
  return GameFound(
    gameId: json['gameId'] as String,
    game: _$enumDecodeNullable(_$GameTitleEnumMap, json['game']),
    player1: json['player1'] == null
        ? null
        : User.fromJson(json['player1'] as Map<String, dynamic>),
    player2: json['player2'] == null
        ? null
        : User.fromJson(json['player2'] as Map<String, dynamic>),
    moves: json['moves'] as List ?? [],
    online: json['online'] as bool ?? true,
  );
}

Map<String, dynamic> _$GameFoundToJson(GameFound instance) => <String, dynamic>{
      'gameId': instance.gameId,
      'game': _$GameTitleEnumMap[instance.game],
      'player1': instance.player1,
      'player2': instance.player2,
      'moves': instance.moves,
      'online': instance.online,
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

GameInvite _$GameInviteFromJson(Map<String, dynamic> json) {
  return GameInvite(
    _$enumDecodeNullable(_$GameTitleEnumMap, json['game']),
    json['sender'] == null
        ? null
        : User.fromJson(json['sender'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$GameInviteToJson(GameInvite instance) =>
    <String, dynamic>{
      'game': _$GameTitleEnumMap[instance.game],
      'sender': instance.sender,
    };

Message _$MessageFromJson(Map<String, dynamic> json) {
  return Message(
    json['message'] as String,
    json['from'] == null
        ? null
        : User.fromJson(json['from'] as Map<String, dynamic>),
    json['to'] == null
        ? null
        : User.fromJson(json['to'] as Map<String, dynamic>),
    json['time'] == null ? null : DateTime.parse(json['time'] as String),
  );
}

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'message': instance.message,
      'from': instance.from,
      'to': instance.to,
      'time': instance.time?.toIso8601String(),
    };
