import 'package:gameroom_app/utils/imports.dart';
import 'package:gameroom_app/utils/helpers.dart';

part 'chess.g.dart';

class ChessGame extends GridGame<ChessMove, ChessPiece> {
  ChessGame() : super(8, 8);

  @override
  String imageNameOf(ChessPiece piece) =>
      '${piece.side.name}-${piece.type.name}.png';

  ChessSide sideOf(Player player) =>
      player == player1 ? ChessSide.white : ChessSide.black;

  ChessSide otherSide(ChessSide side) =>
      side == ChessSide.white ? ChessSide.black : ChessSide.white;

  ChessPiece kingOf(ChessSide side) =>
      side == ChessSide.black ? ChessPiece.blackKing : ChessPiece.whiteKing;

  Tile<ChessPiece> kingTileOf(ChessSide side) =>
      allTiles().firstWhere((tile) => tile.piece == kingOf(side));

  bool whiteCanCastle = true;
  bool blackCanCastle = true;

  bool canCastle(ChessSide side) =>
      side == ChessSide.white ? whiteCanCastle : blackCanCastle;

  void setCanCastle(ChessSide side, bool canCastle) => side == ChessSide.white
      ? whiteCanCastle = canCastle
      : blackCanCastle = canCastle;

  @override
  void resetGame() {
    super.resetGame();
    setBoard([
      [
        ChessPiece.blackRook,
        ChessPiece.blackKnight,
        ChessPiece.blackBishop,
        ChessPiece.blackQueen,
        ChessPiece.blackKing,
        ChessPiece.blackBishop,
        ChessPiece.blackKnight,
        ChessPiece.blackRook,
      ],
      [
        ChessPiece.blackPawn,
        ChessPiece.blackPawn,
        ChessPiece.blackPawn,
        ChessPiece.blackPawn,
        ChessPiece.blackPawn,
        ChessPiece.blackPawn,
        ChessPiece.blackPawn,
        ChessPiece.blackPawn,
      ],
      [],
      [],
      [],
      [],
      [
        ChessPiece.whitePawn,
        ChessPiece.whitePawn,
        ChessPiece.whitePawn,
        ChessPiece.whitePawn,
        ChessPiece.whitePawn,
        ChessPiece.whitePawn,
        ChessPiece.whitePawn,
        ChessPiece.whitePawn,
      ],
      [
        ChessPiece.whiteRook,
        ChessPiece.whiteKnight,
        ChessPiece.whiteBishop,
        ChessPiece.whiteQueen,
        ChessPiece.whiteKing,
        ChessPiece.whiteBishop,
        ChessPiece.whiteKnight,
        ChessPiece.whiteRook,
      ],
    ]);
  }

  void setBoard(List<List<ChessPiece>> pieces) {
    allTiles().forEach((tile) => tile.piece = null);
    for (int i = 0; i < pieces.length; i++) {
      for (int j = 0; j < pieces[i].length; j++) {
        getTile(i, j).piece = pieces[i][j];
      }
    }
  }

  Tile<ChessPiece> selectedTile;
  List<Tile<ChessPiece>> selectableTiles;

  bool inCheck(ChessSide side) => attackable(kingTileOf(side).pos, side);

  bool castling = false;
  Tile<ChessPiece> enPassantTile;

  @override
  ChessMove onEvent(Tile<ChessPiece> tappedTile) {
    ChessMove move;
    if (selectedTile == null &&
        tappedTile.piece?.side == sideOf(currentPlayer) &&
        !currentPlayer.remote) {
      selectTile(tappedTile);
      if (selectableTiles.isEmpty) unselectTile();
    } else if (selectedTile == tappedTile) {
      unselectTile();
    } else if (selectableTiles?.contains(tappedTile) == true) {
      final tile = selectedTile;
      unselectTile();
      move = ChessMove(tile.pos, tappedTile.pos);
    }
    return move;
  }

  /// Selects the piece at [tile] so the current player can see what moves the piece at the [tile] can be made
  void selectTile(Tile<ChessPiece> tile) {
    selectedTile = tile;
    selectedTile.color = Colors.yellowAccent;
    selectableTiles = availableMoves(selectedTile);
    for (final selectableTile in selectableTiles) {
      if (selectableTile.piece != null ||
          isEnPassantMove(tile, selectableTile)) {
        selectableTile.color = Colors.red;
      } else {
        selectableTile.color = Colors.blue;
      }
    }
    return null;
  }

  /// Unselects the currently selected piece
  void unselectTile() {
    selectedTile.color = Colors.white;
    selectedTile = null;
    for (final tile in selectableTiles) {
      tile.color = Colors.white;
    }
    selectableTiles = null;
  }

  @override
  TurnState makeMove(ChessMove move) {
    final toTile = tileAt(move.toPos);
    final fromTile = tileAt(move.fromPos);
    if (isEnPassantMove(tileAt(move.fromPos), tileAt(move.toPos))) {
      enPassantTile.piece = null;
    }
    enPassantTile = null;
    setEnPassant(fromTile, toTile);
    checkForCastleMove(fromTile, toTile);

    toTile.piece = fromTile.piece;
    fromTile.piece = null;

    promotePawn(toTile);
    final enemyHasLegalMove = allTiles().any((tile) {
      if (tile.piece?.side == otherSide(sideOf(currentPlayer))) {
        return availableMoves(tile).isNotEmpty;
      } else {
        return false;
      }
    });

    if (!enemyHasLegalMove) {
      if (inCheck(otherSide(sideOf(currentPlayer)))) {
        return TurnState.game_won;
      } else {
        return TurnState.game_tie;
      }
    }

    return TurnState.turn_finished;
  }

  /// Returns whether a piece at [fromTile] going to [toTile] is an en passant move
  bool isEnPassantMove(Tile<ChessPiece> fromTile, Tile<ChessPiece> toTile) {
    return enPassantTile != null &&
        toTile.piece == null &&
        fromTile.piece != null &&
        fromTile.piece.type == ChessPieceType.pawn &&
        enPassantTile.piece.side == otherSide(fromTile.piece.side) &&
        (toTile.pos.add(1, 0) == enPassantTile.pos ||
            toTile.pos.add(-1, 0) == enPassantTile.pos) &&
        fromTile.pos.j != enPassantTile.pos.j;
  }

  /// Sets [enPassantTile] if a piece moving from [fromTile] to [toTile] is an en passant move
  void setEnPassant(Tile<ChessPiece> fromTile, Tile<ChessPiece> toTile) {
    if (fromTile.piece.type == ChessPieceType.pawn &&
        fromTile.piece.side == sideOf(currentPlayer)) {
      if (fromTile.pos.i == toTile.pos.i + 2 ||
          fromTile.pos.i == toTile.pos.i - 2) {
        enPassantTile = toTile;
      }
    }
  }

  /// Promotes the piece at the [tile] to a queen if it is a pawn and should be promoted
  void promotePawn(Tile<ChessPiece> tile) {
    if (tile.piece.type == ChessPieceType.pawn) {
      if (tile.pos.i == 0 || tile.pos.i == 7) {
        tile.piece = tile.piece.copyWith(type: ChessPieceType.queen);
      }
    }
  }

  /// Checks to see if the a move from [fromTile] to [toTile] is a castling move
  void checkForCastleMove(Tile<ChessPiece> fromTile, Tile<ChessPiece> toTile) {
    if (fromTile.piece.type == ChessPieceType.king ||
        fromTile.piece.type == ChessPieceType.rook) {
      setCanCastle(fromTile.piece.side, false);
    }
    if (fromTile.piece.type == ChessPieceType.king) {
      final rightCastle = fromTile.pos.add(0, 2) == toTile.pos;
      final leftCastle = fromTile.pos.add(0, -2) == toTile.pos;
      if (leftCastle || rightCastle) {
        if (rightCastle) {
          final oldRookTile = getTile(fromTile.pos.i, 7);
          final newRookTile = tileAt(fromTile.pos.add(0, 1));
          newRookTile.piece = oldRookTile.piece;
          oldRookTile.piece = null;
        } else if (leftCastle) {
          final oldRookTile = getTile(fromTile.pos.i, 0);
          final newRookTile = tileAt(fromTile.pos.add(0, -1));
          newRookTile.piece = oldRookTile.piece;
          oldRookTile.piece = null;
        }
      }
    }
  }

  @override
  ChessMove moveFromJson(Map<String, dynamic> json) => ChessMove.fromJson(json);

  /// Returns whether the player of [side] can attack the tile at [pos]
  bool attackable(TilePosition pos, ChessSide side) {
    for (final type in [
      ChessPieceType.pawn,
      ChessPieceType.rook,
      ChessPieceType.knight,
      ChessPieceType.bishop,
      ChessPieceType.queen,
      ChessPieceType.king,
    ]) {
      if (movesOf(pos, ChessPiece(type, side))
          .any((tile) => tile.piece == ChessPiece(type, otherSide(side))))
        return true;
    }
    return false;
  }

  /// Returns all of the legal moves the piece at the [tile] has
  List<Tile<ChessPiece>> availableMoves(Tile<ChessPiece> tile) {
    final moves = movesOf(tile.pos, tile.piece);
    final side = tile.piece.side;
    final retMoves = <Tile<ChessPiece>>[];
    for (final move in moves) {
      simulateMove(ChessMove(tile.pos, move.pos), () {
        if (!inCheck(side)) {
          retMoves.add(move);
        }
      });
    }
    return retMoves;
  }

  /// Simulates [move] so that board state in [simulation] will have the move made but no changes will be made after function call
  void simulateMove(ChessMove move, void Function() simulation) {
    final deletedPiece = tileAt(move.toPos).piece;
    tileAt(move.toPos).piece = pieceAt(move.fromPos);
    tileAt(move.fromPos).piece = null;
    simulation();
    tileAt(move.fromPos).piece = pieceAt(move.toPos);
    tileAt(move.toPos).piece = deletedPiece;
  }

  /// Returns all moves from [fromPos] that [piece] would be able to make whether legal or not
  List<Tile<ChessPiece>> movesOf(TilePosition fromPos, ChessPiece piece) {
    final moves = <Tile<ChessPiece>>[];
    final side = piece.side;
    bool addMove(int i, int j,
        {bool attackOnly = false, bool moveOnly = false}) {
      final toPos = fromPos.add(i, j);
      if (inBoard(toPos)) {
        final isEmpty = pieceAt(toPos) == null;
        final isEnemy = !isEmpty && pieceAt(toPos).side != side;
        var toTile = tileAt(toPos);
        if (isEnemy && !moveOnly) {
          moves.add(toTile);
          return false;
        }
        if (isEmpty && !attackOnly) {
          moves.add(toTile);
          return isEmpty;
        }
        if (attackOnly && isEnPassantMove(tileAt(fromPos), toTile)) {
          moves.add(toTile);
          return false;
        }
      }
      return false;
    }

    void addPawnMoves() {
      switch (piece.side) {
        case ChessSide.black:
          if (addMove(1, 0, moveOnly: true) && fromPos.i == 1) addMove(2, 0, moveOnly: true);
          addMove(1, 1, attackOnly: true);
          addMove(1, -1, attackOnly: true);
          break;
        case ChessSide.white:
          if (addMove(-1, 0, moveOnly: true) && fromPos.i == 6) addMove(-2, 0, moveOnly: true);
          addMove(-1, 1, attackOnly: true);
          addMove(-1, -1, attackOnly: true);
          break;
      }
    }

    void addRookMoves() {
      int i = 1;
      while (addMove(0, i)) i++;
      i = 1;
      while (addMove(0, -i)) i++;
      i = 1;
      while (addMove(i, 0)) i++;
      i = 1;
      while (addMove(-i, 0)) i++;
    }

    void addKnightMoves() {
      addMove(1, 2);
      addMove(2, 1);
      addMove(-1, 2);
      addMove(-2, 1);
      addMove(1, -2);
      addMove(2, -1);
      addMove(-1, -2);
      addMove(-2, -1);
    }

    void addBishopMoves() {
      int i = 1;
      while (addMove(i, i)) i++;
      i = 1;
      while (addMove(-i, i)) i++;
      i = 1;
      while (addMove(i, -i)) i++;
      i = 1;
      while (addMove(-i, -i)) i++;
    }

    void addKingMoves() {
      addMove(1, 1);
      addMove(1, 0);
      addMove(1, -1);
      if (addMove(0, -1) && canCastle(piece.side)) {
        addMove(0, -2);
      }
      addMove(-1, -1);
      addMove(-1, 0);
      addMove(-1, 1);
      if (addMove(0, 1) && canCastle(piece.side)) {
        addMove(0, 2);
      }
    }

    void addQueenMoves() {
      addRookMoves();
      addBishopMoves();
    }

    switch (piece.type) {
      case ChessPieceType.pawn:
        addPawnMoves();
        break;
      case ChessPieceType.rook:
        addRookMoves();
        break;
      case ChessPieceType.knight:
        addKnightMoves();
        break;
      case ChessPieceType.bishop:
        addBishopMoves();
        break;
      case ChessPieceType.king:
        addKingMoves();
        break;
      case ChessPieceType.queen:
        addQueenMoves();
        break;
    }
    return moves;
  }
}

class ChessPiece {
  final ChessPieceType type;
  final ChessSide side;

  ChessPiece(this.type, this.side);

  ChessPiece copyWith({ChessPieceType type, ChessSide side}) => ChessPiece(type ?? this.type, side ?? this.side);

  @override
  bool operator ==(Object other) =>
      other is ChessPiece && type == other.type && side == other.side;

  @override
  int get hashCode => type.hashCode ^ side.hashCode;

  @override
  String toString() {
    return 'ChessPiece{type: $type, side: $side}';
  }

  static final blackPawn = ChessPiece(ChessPieceType.pawn, ChessSide.black);
  static final blackRook = ChessPiece(ChessPieceType.rook, ChessSide.black);
  static final blackKnight = ChessPiece(ChessPieceType.knight, ChessSide.black);
  static final blackBishop = ChessPiece(ChessPieceType.bishop, ChessSide.black);
  static final blackQueen = ChessPiece(ChessPieceType.queen, ChessSide.black);
  static final blackKing = ChessPiece(ChessPieceType.king, ChessSide.black);
  static final whitePawn = ChessPiece(ChessPieceType.pawn, ChessSide.white);
  static final whiteRook = ChessPiece(ChessPieceType.rook, ChessSide.white);
  static final whiteKnight = ChessPiece(ChessPieceType.knight, ChessSide.white);
  static final whiteBishop = ChessPiece(ChessPieceType.bishop, ChessSide.white);
  static final whiteQueen = ChessPiece(ChessPieceType.queen, ChessSide.white);
  static final whiteKing = ChessPiece(ChessPieceType.king, ChessSide.white);
}

enum ChessPieceType {
  pawn,
  rook,
  knight,
  bishop,
  king,
  queen,
}

enum ChessSide {
  white,
  black,
}

extension on ChessPieceType {
  String get name => enumToString(this);
}

extension on ChessSide {
  String get name => enumToString(this);
}

@JsonSerializable(nullable: false)
class ChessMove extends Jsonable {
  final TilePosition fromPos;
  final TilePosition toPos;

  ChessMove(this.fromPos, this.toPos);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChessMove &&
          runtimeType == other.runtimeType &&
          fromPos == other.fromPos &&
          toPos == other.toPos;

  @override
  int get hashCode => fromPos.hashCode ^ toPos.hashCode;

  Map<String, dynamic> toJson() => _$ChessMoveToJson(this);

  static ChessMove fromJson(Map<String, dynamic> json) =>
      _$ChessMoveFromJson(json);

  @override
  String toString() {
    return 'ChessMove{fromPos: $fromPos, toPos: $toPos}';
  }
}
