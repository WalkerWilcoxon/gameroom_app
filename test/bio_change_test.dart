import 'package:flutter/services.dart';
import 'package:gameroom_app/utils/imports.dart';
import 'test_helpers.dart';

main() {
  final mockService = MockInternetService();
  testWidgets('Changing bio changes the user object', (tester) async {
    final newBio = 'New bio';
    when(mockService.changeBio(any)).thenAnswer((realInvocation) {
      mockService.currentUser = mockService.currentUser.copyWith(bio: newBio);
      return Future.value(ResponseValue(null, 200));
    });

    final profilePage = ProfilePage();

    await startWidgetTest(tester, profilePage, mockService);
    
    await tester.tap(find.byKey(Key('bio-text')));
    await tester.pump();
    await tester.enterText(find.byKey(Key('bio-text-field')), newBio);
    await tester.pump();

    expect(find.text('Bio: $newBio'), findsOneWidget);
  });
}
