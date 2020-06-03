import 'package:gameroom_app/utils/imports.dart';

part 'game_record.g.dart';

@JsonSerializable()
class GameRecord {
  final User player1;
  final User player2;
  final User winner;
  final GameTitle game;
  final int id;

  GameRecord(this.player1, this.player2, this.winner, this.id, this.game);

  static GameRecord fromJson(dynamic json) => _$GameRecordFromJson(json);
}