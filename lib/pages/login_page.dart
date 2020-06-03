import 'package:gameroom_app/utils/imports.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final fkey = GlobalKey<FormState>();

  String _username;
  String _password;

  @override
  Widget build(BuildContext context) {
    final service = internetService(context);
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 200, left: 80, right: 80),
        child: Container(
          child: Form(
            key: fkey,
            autovalidate: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                  key: Key('Username Field'),
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
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                ),
                MaterialButton(
                    color: Colors.lightBlueAccent,
                    textColor: Colors.white,
                    key: Key('signin'),
                    child: Text('Login'),
                    onPressed: () async {
                      if (_validateLogin(context)) {
                        if (_username.length == 0 && _password.length == 0) {
                          _username = 'test';
                          _password = '123';
                        }
                        var response = await internetService(context)
                            .login(_username, _password);
                        if (response.successful) {
                          await internetService(context).connect();
                        } else {
                          PopUps.alert(context, 'Failed!',
                              'Check your username/password!');
                        }
                      }
                    }),
                MaterialButton(
                  color: Colors.lightBlueAccent,
                  key: Key('createinfo'),
                  textColor: Colors.white,
                  child: Text('Create'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: service,
                          child: CreateAccountPage(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Validates login credentials.
  ///
  /// Returns false if either the username or password fields are empty.
  bool _validateLogin(BuildContext context) {
    fkey.currentState.save();

    // Testing purpose.
    if (_username.isEmpty && _password.isEmpty) {
      return true;
    }

    if (_username.isEmpty) {
      PopUps.alert(context, 'Error!', 'Username field cannot be empty!');
      return false;
    }
//    else if (_password.isEmpty) {
//      PopUps.alert(context, 'Error!', 'Password field cannot be empty!');
//      return false;
//    }
    return true;
  }
}
