import 'package:gameroom_app/utils/imports.dart';

import 'test_helpers.dart';

void main() {
  Future<void> pause() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  test('Game Notifications', () async {
    final internetService1 = InternetService(testUser1);
    final internetService2 = InternetService(testUser2);

    await internetService1.connect();
    await internetService2.connect();

    await pause();

    expect(internetService1.notifications.first, isNull);
    expect(internetService2.notifications.first, isNull);

    internetService1.findGame(GameTitle.tic_tac_toe);
    internetService2.findGame(GameTitle.tic_tac_toe);

    await pause();
    dynamic gameFound1 = internetService1.notifications.first;
    dynamic gameFound2 = internetService2.notifications.first;

    expect(gameFound1, isNotNull);
    expect(gameFound2, isNotNull);
    expect(gameFound1, isInstanceOf<GameFound>());
    expect(gameFound2, isInstanceOf<GameFound>());
    expect(gameFound1.gameId, gameFound2.gameId);

    await internetService1.dispose();
    await internetService2.dispose();
  });

  test('Chat Notifications', () async {
    final internetService1 = InternetService(testUser1);
    final internetService2 = InternetService(testUser2);

    await internetService1.connect();
    await internetService2.connect();
    await pause();
    expect(internetService1.notifications.first, isNull);
    expect(internetService2.notifications.first, isNull);
    final messageString = 'Message String';
    internetService1.sendMessage(messageString, testUser2);
    await pause();
    dynamic message1 = internetService1.notifications.first;
    dynamic message2 = internetService2.notifications.first;

    expect(message1, isNotNull);
    expect(message2, isNotNull);
    expect(message1, isInstanceOf<Message>());
    expect(message1.message, messageString);
    expect(message1.from, testUser1);
    expect(message1.to, testUser2);
    expect(message2, isInstanceOf<Message>());
    expect(message2.message, messageString);
    expect(message2.from, testUser1);
    expect(message2.to, testUser2);

    await internetService1.dispose();
    await internetService2.dispose();
  });

  test('Game inviting notifications', () async {
    final internetService1 = InternetService(testUser1);
    final internetService2 = InternetService(testUser2);

    await internetService1.connect();
    await internetService2.connect();
    internetService1.inviteToGame(GameTitle.tic_tac_toe, testUser2);
    GameInvite gameInvite = await internetService2.notifications.first;
    expect(gameInvite, isNotNull);
    expect(gameInvite.sender, testUser1);
    expect(gameInvite.game, GameTitle.tic_tac_toe);

    await internetService1.dispose();
    await internetService2.dispose();
  });

  test('Accepting game invitations', () async {
    final internetService1 = InternetService(testUser1);
    final internetService2 = InternetService(testUser2);

    await internetService1.connect();
    await internetService2.connect();
    internetService2.acceptGameInvite(GameTitle.tic_tac_toe, testUser1);
    dynamic gameFoundFuture1 = internetService1.notifications.first;
    dynamic gameFoundFuture2 = internetService2.notifications.first;
    GameFound gameFound1 = await gameFoundFuture1;
    expect(gameFound1, isNotNull);
    expect([gameFound1.player1, gameFound1.player2], containsAll([testUser1, testUser2]));
    expect(gameFound1.game, GameTitle.tic_tac_toe);
    expect(gameFound1.gameId, isNotNull);
    GameFound gameFound2 = await gameFoundFuture2;
    expect(gameFound2, isNotNull);
    expect([gameFound2.player1, gameFound2.player2], containsAll([testUser1, testUser2]));
    expect(gameFound2.game, GameTitle.tic_tac_toe);
    expect(gameFound2.gameId, isNotNull);
    await internetService1.dispose();
    await internetService2.dispose();
  });
}

Future pause() async {
  await Future.delayed(const Duration(seconds : 1));
}
