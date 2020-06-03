import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gameroom_app/utils/imports.dart';
import 'package:mockito/mockito.dart';

export 'package:flutter_test/flutter_test.dart';
export 'package:mockito/mockito.dart';
export 'package:gameroom_app/utils/imports.dart';

User testUser1 = User(
    id: 1, username: 'test-user', avatar: 'assets/empty-avatar.png', bio: '');
User testUser2 = User(
    id: 2, username: 'test-user-2', avatar: 'assets/empty-avatar.png', bio: '');

class MockInternetService extends Mock implements InternetService {
  User _currentUser = testUser1;

  User get currentUser => _currentUser;

  set currentUser(User newUser) {
    _currentUser = newUser;
    notifyListeners();
  }

  final StreamController<Notification> notificationController =
      StreamController.broadcast();

  Stream<Notification> get notifications => notificationController.stream;
}

Future<void> startWidgetTest(
    WidgetTester tester, Widget widget, InternetService mockService) async {
  await tester.pumpWidget(
    Material(
      child: MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<InternetService>.value(
              value: mockService,
            ),
            ProxyProvider<InternetService, User>(
              update: (_, service, __) => service.currentUser,
            ),
            StreamProvider<Notification>.value(
              value: mockService.notifications,
            )
          ],
          child: widget,
        ),
      ),
    ),
  );
}
