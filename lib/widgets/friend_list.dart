import 'package:gameroom_app/utils/imports.dart';

/// Widget for displaying a list of friends as a list
class FriendList extends StatelessWidget {
  final List<User> friends;
  final List<FriendStatus> statuses;
  final void Function(User, FriendStatus) onTap;

  FriendList({this.friends, this.statuses, this.onTap});

  FriendList.fromMap(
      {Map<User, FriendStatus> map, void Function(User, FriendStatus) onTap})
      : this(
            friends: map.keys.toList(),
            statuses: map.values.toList(),
            onTap: onTap);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: friends.length,
        itemBuilder: (context, i) {
          final friend = friends[i];
          final status = statuses?.elementAt(i);
          return Column(
            children: <Widget>[
              Divider(
                height: 1,
                color: Colors.black26,
                thickness: 1,
              ),
              ListTile(
                title: Text(
                    '${friend.username} (${enumToString(friend.status).titleCase})'),
                leading: CircleAvatar(
                  backgroundColor: Colors.black26,
                  child: CircleAvatar(
                    radius: 19,
                    backgroundColor: Colors.white70,
                    backgroundImage:
                        AssetImage(friend.avatar == null ? "" : friend.avatar),
                  ),
                ),
                trailing: statusIcon(status),
                subtitle: Text(friend.bio == null ? "" : friend.bio),
                onTap: () {
                  onTap(friend, status);
                },
              ),
            ],
          );
        });
  }

  Icon statusIcon(FriendStatus status) {
    if (status == null) return null;
    if (status == FriendStatus.friend) {
      return Icon(Icons.person_add, color: Colors.green);
    } else if (status == FriendStatus.receive || status == FriendStatus.sent) {
      return Icon(Icons.person_add, color: Colors.orange);
    }
    return Icon(Icons.person_add, color: Colors.grey);
  }
}
