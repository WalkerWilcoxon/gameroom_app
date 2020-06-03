import 'package:gameroom_app/utils/imports.dart';

/// Page that displays user's profile
class ProfilePage extends StatefulWidget with Page {
  @override
  String get title => 'Profile';

  @override
  PageSelection get selection => PageSelection.profile;

  final User user;

  ProfilePage({Key key, this.user}) : super(key: key);

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  bool editingBio = false;

  @override
  Widget build(BuildContext context) {
    User user;
    bool isCurrentUser;
    if (widget.user == currentUser(context) || widget.user == null) {
      user = Provider.of<User>(context);
      isCurrentUser = true;
    } else {
      user = widget.user;
      isCurrentUser = false;
    }
    return SingleChildScrollView(
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircleAvatar(
                backgroundColor: Colors.black26,
                radius: 50,
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white70,
                  backgroundImage: AssetImage(user.avatar),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                user.username,
                style: TextStyle(fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('${user.bio}', style: TextStyle(color: Colors.grey)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('${user.email}'),
            ),
            if (editingBio)
              Container(
                  padding: EdgeInsets.all(8),
                  constraints: BoxConstraints(maxWidth: 150),
                  child: TextField(
                    key: Key('bio-text-field'),
                    autofocus: true,
                    decoration: InputDecoration(
                        hintText: user.bio,
                        hintStyle: TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Colors.black),
                        )),
                    onSubmitted: (String newBio) async {
                      await internetService(context).changeBio(newBio);
                      setState(() {
                        editingBio = false;
                      });
                    },
                  ))
            else
              FlatButton(
                key: Key('bio-text'),
                onPressed: () {
                  if (isCurrentUser) {
                    setState(() {
                      editingBio = true;
                    });
                  }
                },
                child: Text(
                  'Change Bio',
                ),
              ),
            FlatButton(
              onPressed: () {
                Page.goto(
                    context,
                    GameHistoryPage(
                      user: user,
                    ));
              },
              child: Text('View Game History'),
            ),
            Visibility(
              visible: isCurrentUser,
              child: Column(
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Page.goto(context, ViewFriendPage());
                    },
                    child: Text('View Friends'),
                  ),
                  FlatButton(
                    onPressed: () {
                      Page.goto(context, AvatarSelectPage());
                    },
                    child: Text('Change Avatar Picture'),
                  ),
                  FlatButton(
                      key: Key('avatar'),
                      onPressed: () {
                        Page.goto(context, NewPasswordPage());
                      },
                      child: Text('Change Password')),
                  FlatButton(
                    onPressed: () {
                      internetService(context).logout();
                    },
                    child: Text('Logout'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewPasswordPage extends StatelessWidget with Page {
  @override
  String get title => 'New Password';
  @override
  PageSelection get selection => PageSelection.profile;

  final fkey = GlobalKey<FormState>();
  String _newPass;
  String _verifyPass;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.all(80),
            child: Form(
              key: fkey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                        labelText: 'New Password',
                        fillColor: Colors.white),
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    onSaved: (input) => _newPass = input,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                        labelText: 'New Password Confirm',
                        fillColor: Colors.white),
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    onSaved: (input) => _verifyPass = input,
                  ),
                  MaterialButton(
                    color: Colors.lightBlueAccent,
                    textColor: Colors.white,
                    key: Key('changepassbutton'),
                    child: Text('OK'),
                    onPressed: () async {
                      fkey.currentState.save();
                      if (_newPass != _verifyPass) {
                        PopUps.alert(
                            context, 'Failed!', 'Passwords do not match.');
                        return;
                      }
                      User user =
                      new User(id: currentUser(context).id, password: _newPass);
                      var response = await internetService(context).changePassword(user);
                      if (response.statusMessage == 'OK') {
                        PopUps.alert(context, 'Success!',
                            'You changed your password!');
                      }
                    },
                  ),
                ],
              ),
            )));
  }
}
