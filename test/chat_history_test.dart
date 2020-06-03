import 'package:flutter_test/flutter_test.dart';
import 'package:gameroom_app/services/internet_service.dart';
import 'package:gameroom_app/utils/imports.dart';
import 'package:gameroom_app/widgets/chat_history.dart';
import 'package:mockito/mockito.dart';

import 'test_helpers.dart';

void main() {
  final mockService = MockInternetService();

  //Widget tests for chat history
  testWidgets('No chat history', (WidgetTester tester) async {
    //Mocking the server response
    when(mockService.getChatHistory(any))
        .thenAnswer((_) => Future.value(ResponseValue([], 200)));

    await startWidgetTest(tester, ChatPage(friend: testUser1), mockService);

    //Checks for chat history and zero results
    expect(find.byType(ChatHistory), findsOneWidget);
    expect(find.byType(Bubble), findsNothing);
  });

  testWidgets('finds history of messages', (WidgetTester tester) async {
    List<Message> messages = <Message>[
      Message("hi", mockService.currentUser, testUser1, DateTime.now()),
      Message("howdy", testUser1, mockService.currentUser, DateTime.now()),
    ];

    //Mocking the server response
    when(mockService.getChatHistory(testUser1))
        .thenAnswer((_) => Future.value(ResponseValue(messages, 200)));

    await startWidgetTest(tester, ChatPage(friend: testUser1), mockService);

    //checks for chat history and number of results
    expect(find.byType(ChatHistory), findsOneWidget);
    expect(find.byType(Bubble), findsNWidgets(2));
    expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Bubble &&
              widget.message == "howdy" &&
              widget.isMe == false,
          description: 'finds testUser1 message',
        ),
        findsOneWidget);
    expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Bubble && widget.message == "hi" && widget.isMe == true,
          description: 'finds your message',
        ),
        findsOneWidget);
  });
}
