import 'package:gameroom_app/utils/imports.dart';


typedef FromJson<T> = T Function(dynamic json);

abstract class Jsonable {
  Map<String, dynamic> toJson();
}

extension FlattenExtension<T> on List<List<T>> {
  List<T> flatten() => expand((list) => list).toList();
}

extension MapExtension<T> on List<T> {
  List<R> mapIndexed<R>(R Function(T, int) func) {
    int i = 0;
    return map((e) => func(e, i++)).toList();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

final _gameConstructors = <GameTitle, Game Function()> {
  GameTitle.chess: () => ChessGame(),
  GameTitle.tic_tac_toe: () => TicTacToeGame(),
  GameTitle.checkers: () => CheckersGame(),
};

extension GameInfoExtension on GameFound {
  Game createGame() => _gameConstructors[game]();
}

extension GameTitleExtension on GameTitle {
  String get name => enumToString(this);
  String get title => enumToString(this).titleCase;
}

String enumToString(dynamic enumVal) => enumVal.toString().split('.').last;