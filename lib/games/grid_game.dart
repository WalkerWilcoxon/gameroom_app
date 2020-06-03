import 'package:gameroom_app/utils/imports.dart';

part 'grid_game.g.dart';

/// Abstract class for creating games that are represented as a grid with pieces in the grid
abstract class GridGame<Move extends Jsonable, Piece>
    extends Game<Move, Tile<Piece>> {
  //The number of horizontal tiles the game has
  final int width;

  //The number of vertical tiles the game has
  final int height;

  //The 2d list of the tiles of the board. Tiles
  List<List<Tile<Piece>>> _board;

  Tile<Piece> getTile(int i, int j) => _board[i][j];

  Tile<Piece> tileAt(TilePosition pos) => _board[pos.i][pos.j];

  Piece getPiece(int i, int j) => _board[i][j].piece;

  Piece pieceAt(TilePosition pos) => _board[pos.i][pos.j].piece;

  List<Tile<Piece>> allTiles() => _board.flatten();

  GridGame(this.width, this.height);

  @override
  void resetGame() {
    super.resetGame();
    _board = List.generate(width,
        (i) => List.generate(height, (j) => Tile(i, j, null, Colors.white)));
  }

  static const maxSize = 600.0;

  @override
  Widget buildGameBoard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      constraints: BoxConstraints(maxWidth: maxSize, maxHeight: maxSize),
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: width,
        children: List.generate(width, (i) {
          return List.generate(height, (j) {
            return InkWell(
              onTap: () {
                if (turnState == TurnState.turn_finished || turnState == TurnState.turn_unfinished) {
                  doEvent(getTile(i, j));
                }
              },
              key: ValueKey(TilePosition(i, j)),
              child: Container(
                decoration: BoxDecoration(
                  color: _board[i][j].color,
                  border: Border.all(color: Colors.black),
                ),
                padding: EdgeInsets.all(5),
                child: _board[i][j].piece != null
                    ? Image.asset(
                        'assets/${enumToString(game.game).paramCase}/${imageNameOf(_board[i][j].piece)}',
                      )
                    : null,
              ),
            );
          });
        }).flatten(),
      ),
    );
  }

  bool inBoard(TilePosition pos) =>
      0 <= pos.i && pos.i < width && 0 <= pos.j && pos.j < height;

  //Abstract method that returns the uri of the image that should be displayed to represent pieces on the board
  String imageNameOf(Piece piece);
}

class Tile<Piece> {
  final TilePosition pos;
  Piece piece;
  Color color;

  Tile(int i, int j, this.piece, this.color) : pos = TilePosition(i, j);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Tile && pos == other.pos;

  @override
  int get hashCode => pos.hashCode;

  @override
  String toString() {
    return 'Tile{pos: $pos, piece: $piece, color: $color}';
  }
}

//The event that is sent to the local player of the game
@JsonSerializable(nullable: false)
class TilePosition extends Jsonable {
  final int i;
  final int j;

  TilePosition(this.i, this.j);

  TilePosition add(int i, int j) => TilePosition(this.i + i, this.j + j);

  @override
  Map<String, dynamic> toJson() => _$TilePositionToJson(this);

  static TilePosition fromJson(Map<String, dynamic> json) =>
      _$TilePositionFromJson(json);

  @override
  bool operator ==(Object other) =>
      other is TilePosition && i == other.i && j == other.j;

  @override
  int get hashCode => i.hashCode ^ j.hashCode;

  @override
  String toString() {
    return 'TilePosition{i: $i, j: $j}';
  }
}
