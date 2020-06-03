import 'package:gameroom_app/utils/imports.dart';

class PopUps {
  /// Basic alert with a title, body, and close button
  static void alert(BuildContext context, String title, String body,
      {List<Widget> actions = const []}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: <Widget>[
            ...actions,
            FlatButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Alert for friend list once a user card has been clicked.
  static void viewFriendAlert(BuildContext context, User friend, FriendStatus status,
      VoidCallback setState) {
    String _option = 'Add Friend';
    Color _textColor = Colors.blue;
    if (status == FriendStatus.friend) {
      _option = 'Remove Friend';
      _textColor = Colors.red;
    } else if (status == FriendStatus.sent) {
      _option = 'Cancel Request';
      _textColor = Colors.red;
    } else if (status == FriendStatus.receive) {
      _option = 'Accept Request';
    }
    alert(
      context,
      friend.username,
      '',
      actions: <Widget>[
        // usually buttons at the bottom of the dialog
        // use flat button created from add_friend_page
        FlatButton(
          child: Text(_option),
          textColor: _textColor,
          onPressed: () {
            if (status == FriendStatus.friend ||
                status == FriendStatus.sent) {
              internetService(context).removeFriend(friend);
            } else if (status == FriendStatus.receive) {
              internetService(context).addFriend(friend);
            } else if (status == FriendStatus.none) {
              internetService(context).addFriend(friend);
            }
            Navigator.pop(context);
            setState();
          },
        ),
        FlatButton(
          child: Text('Send Message'),
          onPressed: () {
            Navigator.of(context).pop();
            Page.goto(
              context,
              ChatPage(
                friend: friend,
              ),
            );
          },
        ),
        Visibility(
          visible: friend.status == UserStatus.in_game,
          child: FlatButton(
            child: Text('Spectate game'),
            onPressed: () {
              Navigator.of(context).pop();
              internetService(context).spectateUser(friend);
            },
          ),
        ),
        FlatButton(
          child: Text('View Profile'),
          onPressed: () {
            Navigator.of(context).pop();
            Page.goto(
              context,
              ProfilePage(
                user: friend,
              ),
            );
          },
        ),
      ],
    );
  }
}
