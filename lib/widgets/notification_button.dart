import 'package:gameroom_app/utils/imports.dart';

class NotificationButton extends StatefulWidget {
  @override
  _NotificationButtonState createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<NotificationButton> {
  final List<Notification> notifications = [];
  Notification lastNotification;

  @override
  Widget build(BuildContext context) {
    final notification = Provider.of<Notification>(context);
    final homePage = Provider.of<HomePageState>(context, listen: false);
    if (notification != lastNotification &&
        (notification is Message &&
                notification.from != currentUser(context) &&
                homePage.selectedPage is! ChatPage ||
            notification is GameInvite ||
            notification is FriendRequest)) {
      lastNotification = notification;
      notifications.add(notification);
    }
    return IconButton(
      icon: Stack(
        children: <Widget>[
          Icon(Icons.notifications),
          Positioned(
            top: 1.0,
            right: 0.0,
            child: Stack(
              children: <Widget>[
                Icon(Icons.brightness_1, size: 18.0, color: Colors.redAccent),
                Positioned(
                  top: 1.0,
                  right: 4.0,
                  child: Text('${notifications.length}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500)),
                )
              ],
            ),
          )
        ],
      ),
      onPressed: () {
        final service = internetService(context);
        showModalBottomSheet(
          context: context,
          builder: (context) => Column(
            children: [
              Container(
                alignment: Alignment.center,
                child: FlatButton(
                  child: Text(
                    'Clear All Notifications',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    setState(() {
                      notifications.clear();
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              Flexible(
                child: buildNotificationsList(homePage, service),
              ),
            ],
          ),
        );
      },
    );
  }

  ListView buildNotificationsList(
      HomePageState homePage, InternetService service) {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, i) {
        final notification = notifications[i];
        String acceptText;
        VoidCallback onAcceptPressed;
        if (notification is Message) {
          acceptText = 'Message';
          onAcceptPressed = () {
            homePage.selectPage(
              ChatPage(friend: notification.from),
            );
          };
        } else if (notification is GameInvite) {
          acceptText = 'Join game';
          onAcceptPressed = () {
            service.acceptGameInvite(notification.game, notification.sender);
          };
        } else if (notification is FriendRequest) {
          acceptText = 'Accept';
          onAcceptPressed = () {
            service.addFriend(notification.requester);
          };
        }
        return Dismissible(
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              onAcceptPressed();
              setState(() {
                notifications.remove(notification);
              });
              Navigator.pop(context);
            } else if (direction == DismissDirection.endToStart) {
              setState(() {
                notifications.remove(notification);
              });
            }
          },
          background: Container(color: Colors.green),
          secondaryBackground: Container(color: Colors.red),
          key: ObjectKey(notification),
          child: Column(
            children: <Widget>[
              Divider(
                height: 1,
                color: Colors.black26,
                thickness: 1,
              ),
              ListTile(
                title: Text(notification.displayMessage),
                leading: CircleAvatar(
                  radius: 19,
                  backgroundColor: Colors.white70,
                  backgroundImage: AssetImage(notification.user.avatar),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FlatButton(
                      child: Text(acceptText),
                      onPressed: () {
                        onAcceptPressed();
                        setState(() {
                          notifications.remove(notification);
                        });
                        Navigator.pop(context);
                      },
                    ),
                    FlatButton(
                      child: Text("Dismiss"),
                      onPressed: () {
                        setState(() {
                          notifications.remove(notification);
                        });
                      },
                    )
                  ],
                ),
                onTap: () {
                  setState(() {
                    notifications.remove(notification);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
