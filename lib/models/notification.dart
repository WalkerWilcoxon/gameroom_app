import 'package:gameroom_app/utils/imports.dart';

part 'notification.g.dart';

class Notification {
  static Notification fromJson(dynamic json) {
    final notification = json['data'];
    switch (json['type']) {
      case 'GAMEFOUND':
        return GameFound.fromJson(notification);
        break;
      case 'GAMEINVITE':
        return GameInvite.fromJson(notification);
        break;
      case 'FRIENDUPDATE':
        return FriendUpdate(User.fromJson(notification));
        break;
      case 'FRIENDREQUEST':
        return FriendRequest(User.fromJson(notification));
        break;
      case 'MESSAGERECEIVED':
        return Message.fromJson(notification);
        break;
    }
  }

  User get user => User();
  String get displayMessage => '';
}

@JsonSerializable()
class GameFound extends Notification {
  final String gameId;
  final GameTitle game;
  final User player1;
  final User player2;
  @JsonKey(defaultValue: [])
  final List moves;
  @JsonKey(defaultValue: true)
  final bool online;

  GameFound({this.gameId, this.game, this.player1, this.player2, this.moves = const [], this.online});

  static GameFound fromJson(dynamic json) => _$GameFoundFromJson(json);
}

@JsonSerializable()
class GameInvite extends Notification {
  final GameTitle game;
  final User sender;

  GameInvite(this.game, this.sender);

  User get user => sender;
  String get displayMessage => '${sender.username} wants to play ${game.title} with you';

  static GameInvite fromJson(dynamic json) => _$GameInviteFromJson(json);
}

@JsonSerializable()
class Message extends Notification {
  final String message;
  final User from;
  final User to;
  final DateTime time;

  Message(this.message, this.from, this.to, this.time);

  String get displayMessage => '${from.username}: "$message"';
  User get user => from;

  static Message fromJson(dynamic json) => _$MessageFromJson(json);
}

class FriendUpdate extends Notification {
  final User user;

  FriendUpdate(this.user);
}

class FriendRequest extends Notification {
  final User requester;

  User get user => requester;
  String get displayMessage => '${requester.username} wants to be your friend';

  FriendRequest(this.requester);
}
