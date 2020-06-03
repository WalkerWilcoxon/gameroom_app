import 'package:flutter_test/flutter_test.dart';
import 'package:gameroom_app/pages/avatar_select_page.dart';
import 'package:gameroom_app/services/internet_service.dart';
import 'package:gameroom_app/utils/imports.dart';
import 'package:mockito/mockito.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('Avatar selection', (tester) async {
    final mockService = MockInternetService();
    when(mockService.changeAvatar(any)).thenAnswer((realInvocation) async {
//      mockService.currentUser = realInvocation.positionalArguments[0];
      return null;
    });
    when(mockService.getUser(any)).thenAnswer(
        (realInvocation) => Future.value(ResponseValue(testUser1, 200)));
    await startWidgetTest(tester, AvatarSelectPage(), mockService);

    expect(find.byKey(Key('assets/empty-avatar.png')), findsOneWidget);
    await tester.tap(find.byKey(Key('assets/empty-avatar.png')));
    expect(mockService.currentUser.avatar, 'assets/empty-avatar.png');
    expect(find.byKey(Key('assets/black-bishop.png')), findsOneWidget);
    await tester.tap(find.byKey(Key('assets/black-bishop.png')));
    expect(mockService.currentUser.avatar, 'assets/black-bishop.png');
  });

//  testWidgets('Bio selection', (tester) async {
//    mockService.currentUser.value = User(id: 1);
//    when(mockService.changeBio(any)).thenAnswer((realInvocation) async {
//      mockService.currentUser.value = realInvocation.positionalArguments[0];
//      return null;
//    });
//    when(mockService.getUser(any)).thenAnswer((realInvocation) =>
//        Future.value(ResponseValue(mockService.currentUser.value, 200)));
//    mockService.currentUser.value = User(id: 1);
//    await tester.pumpWidget(MaterialApp(home: ProfilePage()));
//
//    expect(find.byKey(Key('bio-text')), findsOneWidget);
//
//    await tester.tap(find.byKey(Key('bio-text')));
//    final a = (tester.firstState<ProfilePageState>(find.byType(ProfilePageState))).editingBio;
//    expect(find.byKey(Key('bio-text-field')), findsOneWidget);
//    await tester.tap(find.byKey(Key('bio-text-field')));
//    await tester.enterText(find.byKey(Key('bio-text-field')), 'Custom bio');
////    await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
//    expect(mockService.currentUser.value.bio, 'Custom bio');
//  });
}
