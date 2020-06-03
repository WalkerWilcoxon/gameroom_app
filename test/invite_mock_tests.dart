import 'test_helpers.dart';
import 'package:gameroom_app/utils/imports.dart';

main() {
  testWidgets('Game invites changes page', (tester) async {
    final mockService = MockInternetService();

    when(mockService.acceptGameInvite(GameTitle.tic_tac_toe, testUser2)).thenAnswer((realInvocation) {
      mockService.notificationController.add(GameFound(gameId: '0', game: GameTitle.tic_tac_toe, player1: testUser1, player2: testUser2, online: true));
    });

    final homePage = HomePage();

    await startWidgetTest(tester, homePage, mockService);

    mockService.acceptGameInvite(GameTitle.tic_tac_toe, testUser2);

    final homePageState = tester.state(find.byWidget(homePage)) as HomePageState;

    expect(homePageState.selectedPage, isInstanceOf<GameLobbyPage>());
  });
}