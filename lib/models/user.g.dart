// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    id: json['id'] as int,
    username: json['username'] as String,
    email: json['email'] as String,
    password: json['password'] as String,
    bio: json['bio'] as String ?? '',
    avatar: json['avatar'] as String ?? 'assets/empty-avatar.png',
    status: _$enumDecodeNullable(_$UserStatusEnumMap, json['status']),
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'password': instance.password,
      'email': instance.email,
      'bio': instance.bio,
      'avatar': instance.avatar,
      'status': _$UserStatusEnumMap[instance.status],
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

const _$UserStatusEnumMap = {
  UserStatus.offline: 'offline',
  UserStatus.online: 'online',
  UserStatus.in_game: 'in_game',
};
