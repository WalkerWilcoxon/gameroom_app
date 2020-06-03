import 'package:gameroom_app/utils/imports.dart';

part 'chatroom.g.dart';

@JsonSerializable()
class ChatRoom {
  final int roomId;
  final List<User> users;

  ChatRoom(this.roomId, this.users);
}