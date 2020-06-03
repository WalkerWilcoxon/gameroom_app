import 'dart:async';
import 'package:gameroom_app/utils/imports.dart';
import 'package:provider/provider.dart';
import 'package:stomp/stomp.dart';
import 'package:gameroom_app/services/websocket_connect/stub.dart'
// ignore: uri_does_not_exist
    if (dart.library.html) 'package:gameroom_app/services/websocket_connect/web.dart'
// ignore: uri_does_not_exist
    if (dart.library.io) 'package:gameroom_app/services/websocket_connect/vm.dart';

/// Helper class for sending and receiving http and websocket requests to the server
class InternetService extends ChangeNotifier {
//  static const httpUrl = 'http://coms-309-bs-7.cs.iastate.edu:8080';
  static String ip;
  static get httpUrl => 'http://$ip:8080';
  static get websocketUrl => 'ws://$ip:8080/ws';


  static const _jsonHeaders = {'Content-type': 'application/json'};

  User _currentUser;

  User get currentUser => _currentUser;

  set currentUser(User newUser) {
    _currentUser = newUser;
    notifyListeners();
  }

  InternetService([this._currentUser]);

  final StreamController<Notification> notificationController =
      StreamController.broadcast();

  Stream<Notification> get notifications => notificationController.stream;

  Client _httpClient = Client();

  Future<ResponseValue<T>> get<T>(String route, [FromJson<T> fromJson]) async {
    print('Post: $httpUrl$route');
    return ResponseValue.fromResponse(
          await _httpClient.get('$httpUrl$route'), fromJson);
  }

  Future<ResponseValue<T>> post<T, B extends Jsonable>(String route,
      [B body, FromJson<T> fromJson]) async {
    final jsonPost = body != null;
    print('Post: $httpUrl$route');
    return ResponseValue.fromResponse(
        await _httpClient.post('$httpUrl$route',
            headers: jsonPost ? _jsonHeaders : null,
            body: jsonPost ? jsonEncode(body) : null),
        fromJson);
  }

  Future<ResponseValue<List<T>>> getList<T>(
          String route, FromJson<T> fromJson) =>
      get(route, (json) => json.map((e) => fromJson(e)).toList().cast<T>());

  /// Logs in with [username] and [password] and  sets [currentUser] to the user that logs in
  Future<ResponseValue<User>> login(String username, String password) async {
    final user = User(username: username, password: password);
    final response = await post<User, User>('/login', user, User.fromJson);
    this.currentUser = response.value;
    return response;
  }

  void logout() {
    changeStatus(UserStatus.offline);
    currentUser = null;
  }

  /// Creates an account for a new [user].
  ///
  /// [user] must have a username, password and email and sends
  /// it to the server to create a new user account that is stored in the database.
  ///
  /// Returns the string "success" if the sign up was successful.
  Future<ResponseValue<void>> signUp(User user) {
    assert(user.username != null);
    assert(user.email != null);
    assert(user.password != null);
    return post('/signup', user);
  }

  /// Returns all friends of [user] from the database on the server
  Future<ResponseValue<List<User>>> getFriends([User user]) {
    user ??= currentUser;
    assert(user.id != null);
    return getList('/friends/${user.id}', User.fromJson);
  }

  Future<ResponseValue<List<User>>> getFriendRequests([User user]) {
    user ??= currentUser;
    assert(user.id != null);
    return getList('/friends/requests/${user.id}', User.fromJson);
  }

  Future<ResponseValue<List<User>>> getSentFriendRequests([User user]) {
    user ??= currentUser;
    assert(user.id != null);
    return getList('/friends/sentRequests/${user.id}', User.fromJson);
  }

  /// Returns all users with a username that matches [search]
  Future<ResponseValue<Map<User, FriendStatus>>> getUsersBySearch(
      String search) async {
    if (search == '') return ResponseValue({}, 200);
    final users = (await getList('/users/search/$search', User.fromJson)).value;
    users.remove(currentUser);
    final friends = await getFriends(currentUser);
    final requests = await getFriendRequests();
    final sentRequests = await getSentFriendRequests();
    if (!friends.successful || !requests.successful || !sentRequests.successful)
      return ResponseValue(null, 400);
    final map = Map.fromEntries(users.map((user) {
      FriendStatus status;
      if (friends.value.contains(user))
        status = FriendStatus.friend;
      else if (requests.value.contains(user))
        status = FriendStatus.receive;
      else if (sentRequests.value.contains(user))
        status = FriendStatus.sent;
      else
        status = FriendStatus.none;
      return MapEntry(user, status);
    }));
    return ResponseValue(map, 200);
  }

  /// Removes [user] from the currently logged in user's friends list
  Future<ResponseValue<void>> removeFriend(User user) {
    return post('/friends/delete/${currentUser.id}/${user.id}');
  }

  /// Either sends a friend request to [user] from the currently logged in user or accepts a friend request sent by [user]
  Future<ResponseValue<void>> addFriend(User user) {
    return post('/friends/add/${currentUser.id}/${user.id}');
  }

  /// Returns the user that has the given [id]
  Future<ResponseValue<User>> getUser(int id) {
    return get('/user/$id', User.fromJson);
  }

  /// Changes the password of [user] with the id and password fields
  Future<ResponseValue<void>> changePassword(User user) {
    assert(user.id != null && user.password != null);
    return post('/user/changePassword', user);
  }

  /// Changes the bio of [currentUser] with the id and bio fields
  Future<ResponseValue<void>> changeBio(String newBio) async {
    currentUser = currentUser.copyWith(bio: newBio);
    return post('/user/changeBio', currentUser);
  }

  Future<ResponseValue<void>> changeAvatar(String newAvatar) async {
    currentUser = currentUser.copyWith(avatar: newAvatar);
    return post<void, User>('/user/changeAvatar', currentUser);
  }

  Future<ResponseValue<void>> changeStatus(UserStatus newStatus) async {
    currentUser = currentUser.copyWith(status: newStatus);
    return post('/status/${currentUser.id}/${enumToString(newStatus)}');
  }

  /// Deletes [currentUser] from the database on the server
  Future<ResponseValue<void>> deleteAccount() async {
    final id = currentUser.id;
    currentUser = null;
    return post('/users/delete/$id');
  }

  Future<ResponseValue<List<Message>>> getChatHistory(User friend) async {
    return getList(
        '/directMessage/${currentUser.id}/${friend.id}', Message.fromJson);
  }

  Future<ResponseValue<List<GameRecord>>> getGameHistory(User user) async {
    return getList<GameRecord>('/gameHistory/${user.id}', GameRecord.fromJson);
  }

  Future<ResponseValue<List>> getGameMoves(int gameId) async {
    return get('/game/$gameId', (s) => (s as List));
  }

  /// The client for the websocket connection
  StompClient stompClient;

  int _id = 0;

  /// Creates a websocket connection with the server
  Future<void> connect() async {
    stompClient = await createStompClient();
    stompClient
        .subscribeJson('notification', '/topic/notification/${currentUser.id}',
            (headers, message) {
      notificationController.sink.add(Notification.fromJson(message));
    });
    await changeStatus(UserStatus.online);
  }

  @override
  Future<void> dispose() async {
    await changeStatus(UserStatus.offline);
    super.dispose();
    stompClient.unsubscribe('notification');
    await stompClient.disconnect();
    await notificationController.close();
  }

  void removeNotificationListener(int id) {
    stompClient.unsubscribe(String.fromCharCode(id));
  }

  int addNotificationListener<T extends Notification>(
      void listener(T notification), String name, FromJson<T> fromJson) {
    stompClient?.subscribeJson(
        String.fromCharCode(_id++), '/topic/notification/${currentUser.id}',
        (headers, message) {
      if (message['type'] == name) {
        listener(fromJson(message['data']));
      }
    });
    return _id - 1;
  }

  void sendMessage(String message, User friend) {
    stompClient.sendString(
        '/app/directMessage/${currentUser.id}/${friend.id}', message);
  }

  void findGame(GameTitle game) {
    stompClient.sendString('/app/findGame/${currentUser.id}/${game.name}', '');
  }

  void inviteToGame(GameTitle game, User invitee) {
    stompClient.sendString(
        '/app/invite/${game.name}/${currentUser.id}/${invitee.id}', 'a');
  }

  void acceptGameInvite(GameTitle game, User inviter) {
    stompClient.sendString(
        '/app/acceptInvite/${game.name}/${inviter.id}/${currentUser.id}', 'a');
  }

  void spectateUser(User user) {
    stompClient.sendString('/app/spectate/${currentUser.id}/${user.id}', 'a');
  }
}

/// Represents an http response sent by the server
class ResponseValue<T> {
  static const _statusMessages = {
    200: 'OK',
    201: 'Created',
    401: 'Unauthorized',
    403: 'Forbidden',
    404: 'Not Found',
  };

  final T value;
  final int statusCode;
  final String statusMessage;
  final bool successful;

  ResponseValue(this.value, this.statusCode)
      : statusMessage = _statusMessages[statusCode],
        successful = _successful(statusCode);

  static ResponseValue<T> fromResponse<T>(Response response,
      [FromJson<T> fromJson]) {
    return ResponseValue(
        _successful(response.statusCode) && fromJson != null
            ? fromJson(jsonDecode(response.body))
            : null,
        response.statusCode);
  }

  static _successful(int statusCode) => 200 <= statusCode && statusCode < 300;

  @override
  String toString() {
    return 'ResponseValue{value: $value, statusCode: $statusCode, statusMessage: $statusMessage}';
  }
}

InternetService internetService(BuildContext context) =>
    Provider.of<InternetService>(context, listen: false);

User currentUser(BuildContext context) =>
    Provider.of<User>(context, listen: false);
