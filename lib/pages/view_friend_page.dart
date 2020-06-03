import 'package:gameroom_app/services/internet_service.dart';
import 'package:gameroom_app/utils/imports.dart';
import 'package:gameroom_app/widgets/friend_list.dart';

class ViewFriendPage extends StatefulWidget with Page {
  @override
  String get title => 'View Friends';

  @override
  PageSelection get selection => PageSelection.friends;

  /// User whose friends are viewed
  final User user;

  /// Constructs page to view the friends of [user]
  ViewFriendPage({this.user, Key key}) : super(key: key);

  /// Create state call
  @override
  _ViewFriendPageState createState() => _ViewFriendPageState();
}

class _ViewFriendPageState extends State<ViewFriendPage> {
  @override
  Widget build(BuildContext context) {
    final notification = Provider.of<Notification>(context);

    final user = widget.user ?? currentUser(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Visibility(
          visible: widget.user == null,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: MaterialButton(
                color: Colors.blue,
                onPressed: () {
                  Page.goto(context, AddFriendPage());
                },
                child: Text(
                  'Search for friends',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Friends',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        DownloadBuilder<ResponseValue<List<User>>>(
          key: ValueKey(1),
          future: internetService(context).getFriends(user),
          builder: (context, data) => FriendList(
            friends: data.value,
            statuses: data.value.map((e) => FriendStatus.friend).toList(),
            onTap: (friend, status) {
              PopUps.viewFriendAlert(context, friend, FriendStatus.friend,
                  () async {
                await Future.delayed(Duration(milliseconds: 50));
                setState(() {});
              });
            },
          ),
        ),
        DownloadBuilder<ResponseValue<List<User>>>(
          key: ValueKey(2),
          future: internetService(context).getFriendRequests(user),
          builder: (context, data) => Visibility(
            key: ValueKey(5),
            visible: data.value.isNotEmpty,
            child: Column(
              children: <Widget>[
                Divider(
                  height: 1,
                  color: Colors.black26,
                  thickness: 1,
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Requests',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                FriendList(
                  friends: data.value,
                  statuses:
                      data.value.map((e) => FriendStatus.receive).toList(),
                  onTap: (friend, status) {
                    PopUps.viewFriendAlert(
                        context, friend, FriendStatus.receive, () async {
                      await Future.delayed(Duration(milliseconds: 50));
                      setState(() {});
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        DownloadBuilder<ResponseValue<List<User>>>(
          key: ValueKey(3),
          future: internetService(context).getSentFriendRequests(user),
          builder: (context, data) => Visibility(
            key: ValueKey(6),
            visible: data.value.isNotEmpty,
            child: Column(
              children: <Widget>[
                Divider(
                  height: 1,
                  color: Colors.black26,
                  thickness: 1,
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Sent Requests',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                FriendList(
                  friends: data.value,
                  statuses: data.value.map((e) => FriendStatus.sent).toList(),
                  onTap: (friend, status) {
                    PopUps.viewFriendAlert(context, friend, FriendStatus.sent,
                        () async {
                      await Future.delayed(Duration(milliseconds: 50));
                      setState(() {});
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
