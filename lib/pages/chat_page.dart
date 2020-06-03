import 'package:gameroom_app/services/internet_service.dart';
import 'package:gameroom_app/utils/imports.dart';
import 'package:gameroom_app/widgets/chat_history.dart';

/// Page for chatting with friends and in chat rooms
class ChatPage extends StatefulWidget with Page {
  @override
  String get title => 'Chat';

  @override
  PageSelection get selection => PageSelection.chat;

  final User friend;

  ChatPage({@required this.friend, Key key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Provider.of<Notification>(context);
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                child: CircleAvatar(
                  backgroundColor: Colors.black26,
                  child: CircleAvatar(
                    radius: 19,
                    backgroundColor: Colors.white70,
                    backgroundImage: AssetImage(widget.friend.avatar),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.friend.username,
                    style: TextStyle(color: Colors.black),
                  ),
                  Text(
                    '${enumToString(widget.friend.status).titleCase}',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          color: Colors.black26,
          thickness: 1,
        ),
        Flexible(
          flex: 3,
          child: Container(
            child: DownloadBuilder<ResponseValue<List<Message>>>(
                future: internetService(context).getChatHistory(widget.friend),
                builder: (context, data) => ChatHistory(messages: data.value)),
          ),
        ),
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
              color: Colors.grey[300],
              offset: Offset(-2, 0),
              blurRadius: 5,
            ),
          ]),
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 15),
              ),
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  onFieldSubmitted: (value) {
                    if (controller.text != "") {
                      internetService(context)
                          .sendMessage(controller.text, widget.friend);
                      controller.clear();
                    }
                  },
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Enter Message',
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (controller.text != "") {
                    internetService(context)
                        .sendMessage(controller.text, widget.friend);
                    controller.clear();
                  }
                },
                icon: Icon(
                  Icons.send,
                  color: Colors.lightBlue,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class ChatSelectPage extends StatefulWidget with Page {
  @override
  String get title => 'Chat Selection';

  @override
  PageSelection get selection => PageSelection.chat;

  @override
  _ChatSelectPageState createState() => _ChatSelectPageState();
}

class _ChatSelectPageState extends State<ChatSelectPage> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final notification = Provider.of<Notification>(context);
    return Container(
      // Future builder for list of response value users from server.
      child: DownloadBuilder<ResponseValue<List<User>>>(
        // Waits for the server calls which return lists of response value users.
        future: internetService(context).getFriends(user),
        builder: (context, data) => FriendList(
          friends: data.value,
          onTap: (friend, status) {
            Page.goto(context, ChatPage(friend: friend));
          },
        ),
      ),
    );
  }
}
