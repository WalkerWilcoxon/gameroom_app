import 'package:flutter_test/flutter_test.dart';
import 'package:gameroom_app/utils/imports.dart';
import 'package:mockito/mockito.dart';

import 'test_helpers.dart';

void main() {
  final mockService = MockInternetService();
  testWidgets('Login Page Sign-in Tests', (WidgetTester tester) async {
    User user = User(username: 'jill', password: '123');
    when(mockService.login(any, any))
        .thenAnswer((_) => Future.value(ResponseValue(user, 200)));

    await startWidgetTest(tester, LoginPage(), mockService);
    await tester.enterText(find.bySemanticsLabel('Username'), 'jill');
    await tester.enterText(find.bySemanticsLabel('Password'), '123');
    //when(mockService.login(user)).thenAnswer((_) => Future.value(ResponseValue(user,404)));
    await tester.tap(find.byKey(Key('signin')));
    await tester.tap(find.byKey(Key('createinfo')));
  });

  testWidgets('Create Account Page Tests', (WidgetTester tester) async {
    User user =
        User(username: 'jackie', password: '123', email: 'jackie@example.com');

    when(mockService.signUp(user))
        .thenAnswer((_) => Future.value(ResponseValue('success', 201)));

    await startWidgetTest(tester, CreateAccountPage(), mockService);

    await tester.enterText(find.bySemanticsLabel('Username'), 'jackie');
    await tester.enterText(find.bySemanticsLabel('Password'), '123');
    await tester.enterText(find.bySemanticsLabel('Verify Password'), '123');
    await tester.enterText(
        find.bySemanticsLabel('Email'), 'jackie@example.com');
    await tester.tap(find.byKey(Key('createbutton')));
  });
}
