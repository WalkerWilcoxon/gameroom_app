import 'package:flutter_test/flutter_test.dart';
import 'package:gameroom_app/utils/imports.dart';
import 'test_helpers.dart';

void main() {
  InternetService mockService = MockInternetService();
  String search = '';

  //Widget tests for friendlist
  testWidgets('Empty friend list', (WidgetTester tester) async {
    search = '';

//    Mocking the server response
    when(mockService.getUsersBySearch(search))
        .thenAnswer((_) => Future.value(ResponseValue({}, 200)));

    await startWidgetTest(tester, ViewFriendPage(user: testUser1), mockService);

    //Checks the FriendsList for zero results
    expect(find.byType(FriendList), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('Friend list with results', (WidgetTester tester) async {
    search = 'h';
    final usersMap = <User, FriendStatus>{
        User(id: 5, username: 'h'): FriendStatus.none,
        User(id: 2, username: 'he'): FriendStatus.none,
        User(id: 3, username: 'hi'): FriendStatus.none,
        User(id: 4, username: 'hello'): FriendStatus.none,
    };

    //Mocking the server response
    when(mockService.getUsersBySearch(search))
        .thenAnswer((_) => Future.value(ResponseValue(usersMap, 200)));

    await startWidgetTest(tester, ViewFriendPage(user: testUser1), mockService);

    //Checks for that the friends list has 4 user entries
    expect(find.byType(FriendList), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(4));
  });
}
