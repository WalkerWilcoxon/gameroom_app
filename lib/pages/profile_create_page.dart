import 'package:gameroom_app/services/internet_service.dart';
import 'package:gameroom_app/utils/imports.dart';

/// Page for creating accounts
class CreateAccountPage extends StatefulWidget {
  CreateAccountPage({Key key}) : super(key: key);

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final fkey = GlobalKey<FormState>();

  String _username = '';
  String _password = '';
  String _verifyPass = '';
  String _email = '';

  int maxUsernameLength = 20;
  int maxPasswordLength = 45;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(40.0),
          child: Form(
            key: fkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                    labelText: 'Username',
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.text,
                  validator: validateUsername,
                  onSaved: (input) => _username = input.trim(),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                    labelText: 'Password',
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.text,
                  obscureText: true,
//                  validator: validatePassword,
                  onSaved: (input) => _password = input,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                    labelText: 'Verify Password',
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  onSaved: (input) => _verifyPass = input,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                    labelText: 'Email (Optional)',
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.text,
//                  validator: validateEmail,
                  onSaved: (input) => _email = input,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                ),
                MaterialButton(
                  color: Colors.lightBlueAccent,
                  textColor: Colors.white,
                  key: Key('createbutton'),
                  child: Text('Create'),
                  onPressed: () async {
                    if (_createAccount(context)) {
                      User user = User(
                        username: _username,
                        email: _email,
                        password: _password,
                      );
                      final response =
                          await internetService(context).signUp(user);
                      if (response.successful) {
                        PopUps.alert(
                            context, 'Success', 'Your account was created!');
                        await internetService(context)
                            .login(user.username, user.password);
                      } else {
                        PopUps.alert(
                            context, 'Failed!', 'Username already exists!');
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Creates the user account.
  ///
  /// Checks if the username or password is less than 12 characters. It also
  /// checks if the username and password fields are empty or if the username already
  /// exists. The email must be in the right format, separated by the @ symbol.
  /// If all conditions are properly met then account creation will return true.
  bool _createAccount(BuildContext context) {
    fkey.currentState.save();

    if (_username.length >= maxUsernameLength) {
      PopUps.alert(context, 'Error!',
          'Username is too long! Must be less than $maxUsernameLength characters');
      return false;
    }
    if (_password.length >= maxPasswordLength) {
      PopUps.alert(context, 'Error!',
          'Password length is too long! Must be less than $maxPasswordLength characters');
      return false;
    }

    if (_username.isEmpty) {
      PopUps.alert(context, 'Error!', 'Username field cannot be empty!');
      return false;
//    } else if (_password.isEmpty) {
//      PopUps.alert(context, 'Error!', 'Password field cannot be empty!');
//      return false;
    } else if (_password != _verifyPass) {
      PopUps.alert(context, 'Error!', 'Password does not match!');
      return false;
//    } else if (_email.isEmpty) {
//      PopUps.alert(context, 'Error!', 'Email field cannot be empty!');
//      return false;
    }

//    if (!RegExp(r'(\w|\d|\.)+@\w+\.\w+').hasMatch(_email)) {
//      PopUps.alert(context, 'Error!', 'Email must be in the right format!');
//      return false;
//    }
    return true;
  }
}

String validateUsername(String s) =>
    s.isEmpty ? 'Username field cannot be empty!' : null;

//String validatePassword(String s) =>
//    s.isEmpty ? 'Password field cannot be empty!' : null;
//
//String validateEmail(String s) => s.isEmpty ? 'Email field cannot be empty!' : null;
