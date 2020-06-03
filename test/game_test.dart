import 'package:flutter_test/flutter_test.dart';
import 'package:gameroom_app/utils/imports.dart';
import 'package:mockito/mockito.dart';

class MockGameSocket<Move extends Jsonable> extends Mock
    implements GameChannelService<Move> {
  final List<Move> sentMoves = [];

  @override
  void sendMove(Move move, int playerId) {
    sentMoves.add(move);
    onMoveReceivedListener(move, playerId);
  }

  void Function(Move event, int playerId) onMoveReceivedListener;

  @override
  void onMoveReceived(
      void Function(Move moveEvent, int playerId) onMoveReceivedListener) {
    this.onMoveReceivedListener = onMoveReceivedListener;
  }

  void receiveMove(Move move, Player player) {
    onMoveReceivedListener(move, player.id);
  }
}

final user1 = User(username: 'Player one', id: 1);
final user2 = User(username: 'Player two', id: 2);

class GridGameSimulator<Move extends Jsonable> {
  final WidgetTester tester;
  final gameKey = GlobalKey<GridGame>();
  final Game game;
  final bool online;
  MockGameSocket<Move> mockGameSocket;

  GridGameSimulator(this.tester, this.game, {this.online});

  Future<void> initialize() async {
    if (online) {
      mockGameSocket = MockGameSocket<Move>();
      game.gameChannel = mockGameSocket;
    }
    final TestWidgetsFlutterBinding binding =
        TestWidgetsFlutterBinding.ensureInitialized();

    binding.window.physicalSizeTestValue = Size(2000, 2000);
    binding.window.devicePixelRatioTestValue = 1.0;

//    await tester.pumpWidget(
//      MaterialApp(
//        home: ActiveGamePage(
//          GameFound(
//            game: game,
//            gameMode: gameMode,
//            player1: user1,
//            player2: user2,
//          ),
//          key: gameKey,
//        ),
//      ),
//    );
  }

  Future<void> tap(TilePosition tap, Move expectedMove, Player playerAfter,
      [TurnState gameStateAfter = TurnState.turn_finished]) async {
    await tester.tap(find.byKey(ValueKey(tap)));
    final move =
        game.attemptedMoves.isNotEmpty ? game.attemptedMoves.last : null;
    if (online && move != null) {
      expect(mockGameSocket.sentMoves.last, move);
    }
    expect(move, expectedMove);
    expect(game.turnState, gameStateAfter);
    expect(game.currentPlayer, playerAfter);
  }

  Future<void> moveReceived(Move receivedMove, Player playerAfter,
      [TurnState gameStateAfter = TurnState.turn_finished]) async {
    mockGameSocket.receiveMove(receivedMove, game.currentPlayer);
    expect(game.turnState, gameStateAfter);
    expect(game.currentPlayer, playerAfter);
  }
}

void main() {
  testWidgets('Tic Tac Toe offline mode wins', (WidgetTester tester) async {
    final game = TicTacToeGame();
    final simulator = GridGameSimulator(tester, game, online: false);
    await simulator.initialize();

    await simulator.tap(TilePosition(0, 0), TTTMove(0, 0), game.player2);
    await simulator.tap(TilePosition(1, 0), TTTMove(1, 0), game.player1);
    await simulator.tap(TilePosition(0, 1), TTTMove(0, 1), game.player2);
    await simulator.tap(TilePosition(1, 1), TTTMove(1, 1), game.player1);
    await simulator.tap(TilePosition(0, 2), TTTMove(0, 2), null, TurnState.game_won);

    game.resetGame();

    await simulator.tap(TilePosition(0, 0), TTTMove(0, 0), game.player2);
    await simulator.tap(TilePosition(0, 1), TTTMove(0, 1), game.player1);
    await simulator.tap(TilePosition(0, 2), TTTMove(0, 2), game.player2);
    await simulator.tap(TilePosition(1, 0), TTTMove(1, 0), game.player1);
    await simulator.tap(TilePosition(1, 1), TTTMove(1, 1), game.player2);
    await simulator.tap(TilePosition(1, 2), TTTMove(1, 2), game.player1);
    await simulator.tap(TilePosition(2, 0), TTTMove(2, 0), null, TurnState.game_won);
  });

  testWidgets('Tic Tac Toe offline mode tap repeats',
      (WidgetTester tester) async {
    final game = TicTacToeGame();
    final simulator = GridGameSimulator(tester, game, online: false);
    await simulator.initialize();

    await simulator.tap(TilePosition(0, 0), TTTMove(0, 0), game.player2);
    await simulator.tap(TilePosition(0, 0), null, game.player2);
    await simulator.tap(TilePosition(0, 1), TTTMove(0, 1), game.player1);
    await simulator.tap(TilePosition(0, 0), null, game.player1);
    await simulator.tap(TilePosition(0, 1), null, game.player1);
    await simulator.tap(TilePosition(0, 1), null, game.player1);
  });

  testWidgets('Tic Tac Toe online mode win', (WidgetTester tester) async {
    final game = TicTacToeGame();
    final simulator = GridGameSimulator(tester, game, online: true);
    await simulator.initialize();

    await simulator.tap(TilePosition(0, 0), TTTMove(0, 0), game.player2);
    await simulator.moveReceived(TTTMove(1, 0), game.player1);
    await simulator.tap(TilePosition(0, 1), TTTMove(0, 1), game.player2);
    await simulator.moveReceived(TTTMove(1, 1), game.player1);
    await simulator.tap(TilePosition(0, 2), TTTMove(0, 2), null, TurnState.game_won);
  });

  testWidgets(
      'Tic Tac Toe online mode '
      'repeats', (WidgetTester tester) async {
    final game = TicTacToeGame();
    final simulator = GridGameSimulator(tester, game, online: true);
    await simulator.initialize();

    await simulator.tap(TilePosition(0, 0), TTTMove(0, 0), game.player2);
    await simulator.tap(TilePosition(0, 0), null, game.player2);
    await simulator.moveReceived(TTTMove(1, 0), game.player1);
    await simulator.tap(TilePosition(0, 1), TTTMove(0, 1), game.player2);
    await simulator.tap(TilePosition(0, 0), null, game.player2);
    await simulator.tap(TilePosition(0, 1), null, game.player2);
    await simulator.moveReceived(TTTMove(1, 1), game.player1);
  });

  testWidgets('Tic Tac Toe offline tie', (WidgetTester tester) async {
    final game = TicTacToeGame();
    final simulator = GridGameSimulator(tester, game, online: false);
    await simulator.initialize();

    await simulator.tap(TilePosition(0, 0), TTTMove(0, 0), game.player2);
    await simulator.tap(TilePosition(0, 1), TTTMove(0, 1), game.player1);
    await simulator.tap(TilePosition(0, 2), TTTMove(0, 2), game.player2);
    await simulator.tap(TilePosition(1, 1), TTTMove(1, 1), game.player1);
    await simulator.tap(TilePosition(2, 1), TTTMove(2, 1), game.player2);
    await simulator.tap(TilePosition(1, 0), TTTMove(1, 0), game.player1);
    await simulator.tap(TilePosition(1, 2), TTTMove(1, 2), game.player2);
    await simulator.tap(TilePosition(2, 2), TTTMove(2, 2), game.player1);
    await simulator.tap(TilePosition(2, 0), TTTMove(2, 0), null, TurnState.game_tie);
  });

  testWidgets('Chess game white side move pawn', (WidgetTester tester) async {
    final game = ChessGame();
    final simulator = GridGameSimulator(tester, game, online: false);
    await simulator.initialize();

    await simulator.tap(TilePosition(6, 0), null, game.player1);
    await simulator.tap(TilePosition(5, 0),
        ChessMove(TilePosition(6, 0), TilePosition(5, 0)), game.player2);
  });

  testWidgets('Chess game black side cannot move pawn on first turn',
      (WidgetTester tester) async {
    final game = ChessGame();
    final simulator = GridGameSimulator(tester, game, online: false);
    await simulator.initialize();

    await simulator.tap(TilePosition(1, 0), null, game.player1);
    await simulator.tap(TilePosition(2, 0), null, game.player1);
  });

  testWidgets('Chess game basic checkmate', (WidgetTester tester) async {
    final game = ChessGame();
    final simulator = GridGameSimulator(tester, game, online: false);
    await simulator.initialize();

    game.whiteCanCastle = false;
    game.blackCanCastle = false;

    game.setBoard([
      [ChessPiece.blackKing],
      [],
      [ChessPiece.whiteKing, null, null, ChessPiece.whiteRook],
    ]);

    await simulator.tap(TilePosition(2, 3), null, game.player1);
    await simulator.tap(TilePosition(0, 3), ChessMove(TilePosition(2, 3), TilePosition(0, 3)), null, TurnState.game_won);
  });

  testWidgets('Chess game basic stalemate', (WidgetTester tester) async {
    final game = ChessGame();
    final simulator = GridGameSimulator(tester, game, online: false);
    await simulator.initialize();

    game.whiteCanCastle = false;
    game.blackCanCastle = false;

    game.setBoard([
      [ChessPiece.blackKing],
      [],
      [ChessPiece.whiteKing, null, null, ChessPiece.whiteRook],
    ]);

    await simulator.tap(TilePosition(2, 3), null, game.player1);
    await simulator.tap(TilePosition(2, 1), ChessMove(TilePosition(2, 3), TilePosition(2, 1)), null, TurnState.game_tie);
  });
}
