import 'package:gameroom_app/utils/imports.dart';

/// Abstract class for creating games
abstract class Game<Move extends Jsonable, Event>
    extends State<ActiveGamePage> {
  GameFound get game => widget.game;
  bool online;

  Player player1;
  Player player2;
  Player currentPlayer;
  Player winner;

  TurnState turnState = TurnState.turn_finished;
  GameChannelService<Move> gameChannel;

  @override
  void initState() {
    super.initState();
    online = game.online;
    if (online) {
      gameChannel ??= GameChannelService<Move>(
          game.gameId, moveFromJson, internetService(context));
      gameChannel.onMoveReceived(_makeMove);
    }

    player1 = Player(
      game.player1.username,
      online && game.player1.username != currentUser(context).username,
      game.player1.id,
    );

    player2 = Player(
      game.player2.username,
      online && game.player2.username != currentUser(context).username,
      game.player2.id,
    );

    currentPlayer = this.player1;
    resetGame();
    for (final move in game.moves) {
      makeMove(moveFromJson(jsonDecode(move['move'])['move']));
      swapPlayers();
    }
  }

  @override
  void dispose() {
    super.dispose();
    gameChannel?.dispose();
  }

  //Builds the top level widget of the game
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 25.0, bottom: 25.0),
              child: Text(
                turnState == TurnState.game_won
                    ? '$winner won!'
                    : turnState == TurnState.game_tie
                        ? 'Tied!'
                        : "${currentPlayer.name}'s turn",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
              ),
            ),
            buildGameBoard(context),
            SizedBox(
              height: 8.0,
            ),
            FlatButton(
              onPressed: () => Page.goto(context, GameLobbyPage()),
              child: Text('Exit'),
            )
          ],
        ),
      ),
    );
  }

  final List<Move> attemptedMoves = [];

  /// Does the given event
  void doEvent(Event event) {
    final move = onEvent(event);
    attemptedMoves.add(move);
    if (move != null) {
      if (!online) {
        _makeMove(move, currentPlayer.id);
      } else if (online && !currentPlayer.remote) {
        gameChannel.sendMove(move, currentPlayer.id);
      }
    }
    setState(() {});
  }

  /// Makes the given move of the player with the given playerId
  void _makeMove(Move move, int playerId) {
    if (playerId == currentPlayer.id) {
      turnState = makeMove(move);
      if (turnState == TurnState.game_won) {
        winner = currentPlayer;
      } else if (turnState == TurnState.turn_finished) {
        swapPlayers();
      }
      if (turnState == TurnState.game_won || turnState == TurnState.game_tie) {
        if (online) gameChannel.finishGame(winner?.id);
        currentPlayer = null;
      }
      setState(() {});
    }
  }

  void swapPlayers() {
    if (currentPlayer == player1) {
      currentPlayer = player2;
    } else {
      currentPlayer = player1;
    }
  }

  /// Resets all the game information. Should be overrode to delete any other game state information
  @mustCallSuper
  void resetGame() {
    currentPlayer = player1;
    winner = null;
    turnState = TurnState.turn_finished;
  }

  /// Returns the widget that displays the for the game board
  Widget buildGameBoard(BuildContext context);

  /// Makes the move for the current player and returns the GameState after the move is made
  TurnState makeMove(Move move);

  /// Returns the move that corresponds to the given event or null if the event does not represent a move.
  Move onEvent(Event event);

  /// Transforms a json string into a Move instance
  Move moveFromJson(Map<String, dynamic> json);
}

enum TurnState { turn_finished, turn_unfinished, game_won, game_tie }

class Player {
  final String name;
  final bool remote;
  int id;

  Player(this.name, this.remote, this.id);

  @override
  String toString() => name;
}
