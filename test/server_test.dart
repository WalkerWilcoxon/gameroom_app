import 'package:flutter_test/flutter_test.dart';
import 'package:gameroom_app/services/internet_service.dart';
import 'package:gameroom_app/utils/imports.dart';

import 'test_helpers.dart';

void main() {
  final internetService = InternetService(testUser1);

  test('Login test success', () async {
    var response = await internetService.login('test-user', '123');
    expect(response.successful, true, reason: 'Response is: $response');
  });

  test('Login test fails', () async {
    var response = await internetService.login('jackripper', '124');
    expect(response.successful, false, reason: 'Response is: $response');
  });

  test('Login test fails then succeeds', () async {
    var user = User(username: 'jackripper', password: '124');
    var response = await internetService.login(user.username, user.password);

    user = User(username: 'jackripper', password: '1234');
    response = await internetService.login(user.username, user.password);
    expect(response.successful, true, reason: 'Response is: $response');
  });

  // Not properly tested, needs delete user
//  test('Signup test success', () async {
//    var user =
//        User(username: 'newuser', email: 'newuser@test.com', password: '123');
//    var response = await internetService.signUp(user);
//    expect(response.isSuccess, true, reason: 'Response is: $response');
//  });

  // Currently not implemented
//  test('Delete User',()async{
//    var user = User(id:-99);
//    var response = await internetService.deleteUser(user);
//    expect(response.isSuccess,true);
//  });

  test('Signup test fails', () async {
    var user =
        User(username: 'jackripper', email: 'test@gmail.com', password: '123');
    var response = await internetService.signUp(user);
    expect(response.successful, false, reason: 'Response is: $response');
  });

  test('Friends test success', () async {
    var user = User(id: 1);
    var response = await internetService.getFriends(user);
    expect(response.successful, true, reason: 'Response is: $response');
  });

//  test('Friends test fail', () async {
//    var user = User(id: -9000);
//    var response = await internetService.getFriends(user);
//    expect(response.isSuccess, false, reason: 'Response is: $response');
//  });
//
//  test('Get friend request', () async {
//    var user = User(id: 1);
//    var response = await internetService.getFriendRequests(user);
//    expect(response.value.isEmpty, false, reason: 'Response is: $response');
//  });
//
//  test('Get friend request fail', () async {
//    var user = User(id: -1);
//    var response = await internetService.getFriendRequests(user);
//    expect(response.value.isEmpty, true, reason: 'Response is: $response');
//  });

  test('Friend search', () async {
    var response = await internetService.getUsersBySearch('jackripper');
    expect(response.value.isEmpty, false, reason: 'Response is: $response');
  });

  test('Friend search empty', () async {
    var response = await internetService.getUsersBySearch('');
    expect(response.value.isEmpty, true, reason: 'Response is: $response');
  });

  test('Friend search fail', () async {
    var response = await internetService.getUsersBySearch('jilltapper');
    expect(response.value.isEmpty, true, reason: 'Response is: $response');
  });

  // This needs more testing
//  test('Get sent request fails', () async {
//    User user = User(id: 1);
//    User user2 = User(id: 8);
//    mockService.currentUser.value = user2;
//
//    print(mockService.currentUser.value);
//
//    internetService.addFriend(user);
//    var response = await internetService.getSentRequests(user);
//    print('Response is: $response');
//    expect(response.value, null);
//  });

  test('Add friend', () async {
    User user1 = User(id: 7); //jackripper
    User user2 = User(id: 1); //example

    internetService.currentUser = user1;
    internetService.addFriend(user2);

    internetService.currentUser = user2;
    internetService.addFriend(user1);

    var response =
        await internetService.getFriends(user1); //get jackripper's friendslist
    expect(response.value, contains(user2), reason: 'Response is: $response');
    expect(response.successful, true);
  });

  test('Get user', () async {
    var response = await internetService.getUser(1);
    expect(response.successful, true, reason: 'Response is: $response');
  });

  test('Get user fails', () async {
    var response = await internetService.getUser(-1);
    expect(response.successful, false);
  });

//  test('Change password', () async {
//    User userBefore =
//        User(id: 3, username: 'example2', password: 'password123');
//    var response = await internetService.login(userBefore);
//    print('Response is: $response');
//
//    User userAfter =
//        User(id: 3, username: 'example2', password: 'password12345');
//
//    var response2 = await internetService.changePassword(userAfter);
//    print('Response is: $response2');
//
//    var response3 = await internetService.login(userAfter);
//    expect(response3.isSuccess, true,
//        reason: 'Responses: $response, $response2, $response3');
//  });

//  test('Change bio', () async {
//    final newBio = 'New bio';
//    var response = await internetService.changeBio(newBio);
//    expect(response.isSuccess, true);
//    final response2 = await internetService.getUser();
//    expect(response2.value.bio, newBio);
//  });
//
//  test('Change avatar', () async {
//    final newAvatar = 'New avatar';
//    final response = await internetService.changeAvatar(newAvatar);
//    expect(response.isSuccess, true);
//    final response2 = await internetService.getUser(user.id);
//    expect(response2.value.avatar, newAvatar);
//  });

  test('Chat history', () async {
//    internetService.currentUser = User(id: 1);
    final history = await internetService.getChatHistory(User(id: 2));
    expect(history.value, isNotEmpty);
  });
}
