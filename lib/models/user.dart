import 'package:gameroom_app/utils/imports.dart';

part 'user.g.dart';

@JsonSerializable()
class User extends Jsonable {
  final int id;
  final String username;
  final String password;
  final String email;
  @JsonKey(defaultValue: '')
  final String bio;
  @JsonKey(defaultValue: 'assets/empty-avatar.png')
  final String avatar;
  final UserStatus status;

  User({
    this.id,
    this.username,
    this.email,
    this.password,
    this.bio,
    this.avatar,
    this.status,
  });

  Map<String, dynamic> toJson() => _$UserToJson(this);

  static User fromJson(dynamic json) => _$UserFromJson(json);

  bool equalsExact(User other) =>
      id == other.id &&
      username == other.username &&
      email == other.email &&
      bio == other.bio;

  @override
  bool operator ==(other) => other is User && id == other.id;

  @override
  int get hashCode => id;

  @override
  String toString() {
    return 'User{id: $id, username: $username, password: $password, email: $email, bio: $bio}';
  }

  User copyWith(
          {int id,
          String username,
          String password,
          String email,
          String bio,
          String avatar,
            UserStatus status,
          }) =>
      User(
          id: id ?? this.id,
          username: username ?? this.username,
          password: password ?? this.password,
          email: email ?? this.email,
          bio: bio ?? this.bio,
          avatar: avatar ?? this.avatar,
          status: status ?? this.status,
      );
}

enum UserStatus {
  offline, online, in_game,
}

enum FriendStatus { none, sent, receive, friend }
