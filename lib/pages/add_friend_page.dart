import 'package:gameroom_app/services/internet_service.dart';
import 'package:gameroom_app/utils/imports.dart';
import 'package:gameroom_app/widgets/friend_list.dart';

/// Page for adding and searching for friends
class AddFriendPage extends StatefulWidget with Page {
  @override
  String get title => 'Add Friends';

  @override
  PageSelection get selection => PageSelection.friends;

  AddFriendPage({Key key}) : super(key: key);

  @override
  _AddFriendPageState createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  /// Controller used to get the text from the textField
  final textController = TextEditingController();

  /// Overrode to dispose [textController]
  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notification = Provider.of<Notification>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      // Vertical alignment of search field and user list
      child: Column(
        children: [
          // Horizontal alignment of widgets
          Container(
            padding: const EdgeInsets.all(8.0),
            width: 280.0,
            child: TextField(
                autofocus: true,
                controller: textController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a username',
                  // 'x' button to clear text field
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        textController.text = '';
                      });
                    },
                    icon: Icon(Icons.clear),
                  ),
                ),
                onChanged: (String str) {
                  // When text is changed, the textController is also changed
                  setState(() {
                    textController.text;
                  });
                }),
          ),
          Flexible(
            flex: 3,
            child: Container(
              // Future builder for a list of response value user lists
              child: DownloadBuilder<ResponseValue<Map<User, FriendStatus>>>(
                  future: internetService(context).getUsersBySearch(textController.text),
                  builder: (context, data) => FriendList.fromMap(
                      map: data.value,
                      onTap: (friend, status) {
                        PopUps.viewFriendAlert(
                            context, friend, status, () => setState(() {}));
                      })),
            ),
          ),
        ],
      ),
    );
  }
}
