// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatroom.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatRoom _$ChatRoomFromJson(Map<String, dynamic> json) {
  return ChatRoom(
    json['roomId'] as int,
    (json['users'] as List)
        ?.map(
            (e) => e == null ? null : User.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$ChatRoomToJson(ChatRoom instance) => <String, dynamic>{
      'roomId': instance.roomId,
      'users': instance.users,
    };
