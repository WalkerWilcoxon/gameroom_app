import 'package:gameroom_app/utils/imports.dart';

part 'tic_tac_toe.g.dart';

class TicTacToeGame extends GridGame<TTTMove, TTTPiece> {
  TicTacToeGame() : super(3, 3);

  TTTPiece get currentPlayerPiece => playerPiece(currentPlayer);

  TTTPiece playerPiece(Player player) =>
      player == player1 ? TTTPiece.X : TTTPiece.O;

  TTTMove onEvent(Tile<TTTPiece> tappedTile) {
    if (tappedTile.piece == null)
      return TTTMove.fromPos(tappedTile.pos);
    else
      return null;
  }

  static final imageNames = <TTTPiece, String>{
    TTTPiece.X: 'x.png',
    TTTPiece.O: 'o.png',
  };

  @override
  String imageNameOf(TTTPiece piece) => imageNames[piece];

  @override
  TurnState makeMove(TTTMove move) {
    getTile(move.i, move.j).piece = playerPiece(currentPlayer);
    final piece = currentPlayerPiece;
    for (int i = 0; i < 3; i++) {
      if ((getPiece(i, 0) == piece &&
              getPiece(i, 1) == piece &&
              getPiece(i, 2) == piece) ||
          (getPiece(0, i) == piece &&
              getPiece(1, i) == piece &&
              getPiece(2, i) == piece)) {
        return TurnState.game_won;
      }
    }
    if ((getPiece(0, 0) == piece &&
            getPiece(1, 1) == piece &&
            getPiece(2, 2) == piece) ||
        (getPiece(0, 2) == piece &&
            getPiece(1, 1) == piece &&
            getPiece(2, 0) == piece)) {
      return TurnState.game_won;
    }

    if (allTiles().every((tile) => tile.piece != null)) {
      return TurnState.game_tie;
    }

    return TurnState.turn_finished;
  }

  @override
  TTTMove moveFromJson(Map<String, dynamic> json) => TTTMove.fromJson(json);
}

enum TTTPiece { X, O }

@JsonSerializable(nullable: false)
class TTTMove extends Jsonable {
  final int i;
  final int j;

  TTTMove(this.i, this.j);

  TTTMove.fromPos(TilePosition pos)
      : i = pos.i,
        j = pos.j;

  @override
  bool operator ==(Object other) =>
      other is TTTMove && i == other.i && j == other.j;

  @override
  int get hashCode => i.hashCode ^ j.hashCode;

  @override
  Map<String, dynamic> toJson() => _$TTTMoveToJson(this);

  factory TTTMove.fromJson(Map<String, dynamic> json) =>
      _$TTTMoveFromJson(json);

  @override
  String toString() => jsonEncode(this);
}
