import 'package:gameroom_app/utils/imports.dart';

/// Page that shows the game screen
class ActiveGamePage extends StatefulWidget {
  @override
  bool get hasBackButton => false;

  @override
  PageSelection get selection => PageSelection.game;

  final GameFound game;

  ActiveGamePage(this.game, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => game.createGame();
}

enum GameTitle {
  chess,
  tic_tac_toe,
  checkers,
}
