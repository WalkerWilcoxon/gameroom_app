import 'package:gameroom_app/utils/imports.dart';
import 'package:gameroom_app/utils/helpers.dart';

part 'checkers.g.dart';

class CheckersGame extends GridGame<CheckersMove, CheckersPiece> {
  CheckersGame() : super(8, 8);

  @override
  String imageNameOf(CheckersPiece piece) =>
      '${piece.side.name}-${piece.type.name}.png';

  CheckersSide sideOf(Player player) =>
      player == player1 ? CheckersSide.red : CheckersSide.black;

  CheckersSide otherSide(CheckersSide side) =>
      side == CheckersSide.red ? CheckersSide.black : CheckersSide.red;

  @override
  void resetGame() {
    super.resetGame();
    allTiles().forEach((tile) => tile.piece = null);
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if ((i + j) % 2 == 1) {
          if (i <= 2) {
            getTile(i, j).piece =
                CheckersPiece(CheckersPieceType.man, CheckersSide.black);
          } else if (i >= 5) {
            getTile(i, j).piece =
                CheckersPiece(CheckersPieceType.man, CheckersSide.red);
          }
        }
      }
    }
  }

  Tile<CheckersPiece> selectedTile;
  List<Tile<CheckersPiece>> selectableTiles = [];
  List<Tile<CheckersPiece>> attackableTiles = [];

  @override
  CheckersMove onEvent(Tile<CheckersPiece> tappedTile) {
    if (selectedTile == null &&
        tappedTile.piece?.side == sideOf(currentPlayer) &&
        !currentPlayer.remote) {
      selectTile(tappedTile);
      if (selectableTiles.isEmpty) unselectTile();
    } else if (selectedTile == tappedTile) {
      unselectTile();
    } else if (selectableTiles.contains(tappedTile)) {
      final tile = selectedTile;
      unselectTile();
      return CheckersMove(tile.pos, tappedTile.pos);
    }
    return null;
  }

  /// Selects the piece at [tile] so the current player can see what moves the piece at the [tile] can be made
  void selectTile(Tile<CheckersPiece> tile) {
    selectedTile = tile;
    selectedTile.color = Colors.yellowAccent;
    final moves = availableMoves(selectedTile);
    if (hasAttackMoves(tile.piece.side)) {
      moves.removeWhere((moveInfo) => moveInfo.attackPos == null);
    }
    for (final moveInfo in moves) {
      final moveTile = tileAt(moveInfo.movePos);
      moveTile.color = Colors.blue;
      selectableTiles.add(moveTile);
      if (moveInfo.attackPos != null) {
        final attackTile = tileAt(moveInfo.attackPos);
        attackableTiles.add(attackTile);
        attackTile.color = Colors.red;
      }
    }
  }

  /// Unselects the currently selected piece
  void unselectTile() {
    selectedTile.color = Colors.white;
    selectedTile = null;
    for (final tile in selectableTiles) {
      tile.color = Colors.white;
    }
    for (final tile in attackableTiles) {
      tile.color = Colors.white;
    }
    selectableTiles.clear();
  }

  @override
  TurnState makeMove(CheckersMove move) {
    final toPos = move.toPos;
    final fromPos = move.fromPos;
    final toTile = tileAt(toPos);
    final fromTile = tileAt(fromPos);

    toTile.piece = fromTile.piece;
    fromTile.piece = null;

    var turnFinished = true;
    if ((toPos.i - fromPos.i).abs() == 2) {
      getTile((toPos.i + fromPos.i) ~/ 2, (toPos.j + fromPos.j) ~/ 2).piece =
          null;
      if(hasAttackMoves(sideOf(currentPlayer))){
        turnFinished = false;
      }
    }

    promoteMan(toTile);

    final enemyHasPieces = allTiles()
        .any((tile) => tile.piece?.side == otherSide(sideOf(currentPlayer)));

    if (!enemyHasPieces) {
      return TurnState.game_won;
    }
    return turnFinished ? TurnState.turn_finished : TurnState.turn_unfinished;
  }

  /// Promotes the piece at the [tile] to a king if it is a man that should be promoted
  void promoteMan(Tile<CheckersPiece> tile) {
    if (tile.piece.type == CheckersPieceType.man) {
      if (tile.pos.i == 0 || tile.pos.i == 7) {
        tile.piece = tile.piece.copyWith(type: CheckersPieceType.king);
      }
    }
  }

  @override
  CheckersMove moveFromJson(Map<String, dynamic> json) =>
      CheckersMove.fromJson(json);

  /// Returns all of the legal moves the piece at the [tile] has
  List<MoveInfo> availableMoves(Tile<CheckersPiece> tile) {
    if (tile.piece == null) return [];
    final moves = <MoveInfo>[];
    final side = tile.piece.side;
    void addMove(int i, int j) {
      final movePos = tile.pos.add(i, j);
      if (inBoard(movePos)) {
        if (tileAt(movePos).piece == null) {
          moves.add(MoveInfo(movePos));
        }
        final attackPos = tile.pos.add(i * 2, j * 2);
        if (inBoard(attackPos) &&
            tileAt(attackPos).piece == null &&
            tileAt(movePos).piece?.side == otherSide(side)) {
          moves.add(MoveInfo(attackPos, movePos));
        }
      }
    }

    final manMoveDirection = side == CheckersSide.black ? 1 : -1;
    addMove(manMoveDirection, 1);
    addMove(manMoveDirection, -1);
    if (tile.piece.type == CheckersPieceType.king) {
      addMove(-manMoveDirection, 1);
      addMove(-manMoveDirection, -1);
    }
    return moves;
  }

  bool hasAttackMoves(CheckersSide side) {
    return allTiles().any((tile) {
      if (tile.piece?.side == side) {
        return availableMoves(tile)
            .any((moveInfo) => moveInfo.attackPos != null);
      } else {
        return false;
      }
    });
  }
}

extension on CheckersPieceType {
  String get name => enumToString(this);
}

extension on CheckersSide {
  String get name => enumToString(this);
}

class CheckersPiece {
  final CheckersPieceType type;
  final CheckersSide side;

  CheckersPiece(this.type, this.side);

  CheckersPiece copyWith({CheckersPieceType type, CheckersSide side}) => CheckersPiece(type ?? this.type, side ?? this.side);

  @override
  bool operator ==(Object other) =>
      other is CheckersPiece && type == other.type && side == other.side;

  @override
  int get hashCode => type.hashCode ^ side.hashCode;

  @override
  String toString() {
    return 'ChessPiece{type: $type, side: $side}';
  }
}

enum CheckersPieceType {
  man,
  king,
}

enum CheckersSide {
  red,
  black,
}

class MoveInfo {
  final TilePosition movePos;
  final TilePosition attackPos;

  MoveInfo(this.movePos, [this.attackPos]);
}

@JsonSerializable(nullable: false)
class CheckersMove extends Jsonable {
  final TilePosition fromPos;
  final TilePosition toPos;

  CheckersMove(this.fromPos, this.toPos);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckersMove &&
          runtimeType == other.runtimeType &&
          fromPos == other.fromPos &&
          toPos == other.toPos;

  @override
  int get hashCode => fromPos.hashCode ^ toPos.hashCode;

  Map<String, dynamic> toJson() => _$CheckersMoveToJson(this);

  static CheckersMove fromJson(Map<String, dynamic> json) =>
      _$CheckersMoveFromJson(json);

  @override
  String toString() {
    return 'ChessMove{fromPos: $fromPos, toPos: $toPos}';
  }
}
