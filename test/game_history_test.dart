import 'test_helpers.dart';

void main() {
  InternetService mockService = MockInternetService();
  testWidgets('Game History Empty Tests', (WidgetTester tester) async {

    when(mockService.getGameHistory(any))
        .thenAnswer((_) => Future.value(ResponseValue([], 200)));

    await startWidgetTest(tester, GameHistoryPage(), mockService);

    expect(find.text('Checkers'), findsNothing);
    expect(find.text('Chess'), findsNothing);
    expect(find.text('Tic Tac Toe'), findsNothing);
  });

  testWidgets('Game History Tests', (WidgetTester tester) async {
    List<GameRecord> gameRecord = <GameRecord>[
//    GameRecord(testUser1, testUser2, testUser1, 100, GameTitle.checkers),
      GameRecord(testUser1, testUser2, testUser1, 101, GameTitle.chess),
      GameRecord(testUser1, testUser2, testUser1, 102, GameTitle.tic_tac_toe),
    ];

    when(mockService.getGameHistory(any))
        .thenAnswer((_) => Future.value(ResponseValue(gameRecord, 200)));

    await tester.pumpWidget(MaterialApp(home: GameHistoryPage()));
    await tester.pump();

    expect(find.byType(ListView), findsNWidgets(1));
//    expect(find.text('Checkers'), findsOneWidget);
    expect(find.text(GameTitle.chess.title), findsOneWidget);
    expect(find.text(GameTitle.tic_tac_toe.title), findsOneWidget);
  });
}
