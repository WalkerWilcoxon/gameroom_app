import 'package:gameroom_app/pages/home_page.dart';
import 'package:gameroom_app/services/internet_service.dart';
import 'package:gameroom_app/utils/imports.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

void main() {
  final internetService = InternetService();
  runApp(App(internetService));
  WidgetsBinding.instance.addObserver(LifeCycleHandler(internetService));
}

class App extends StatefulWidget {
  final InternetService internetService;

  const App(this.internetService, {Key key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    () async {
      String ip;

      const url = 'https://api.ipify.org';
      var response = await http.get(url);
      if (response.statusCode == 200) {
        ip = response.body;
      } else {
        print('Could not get public ip');
      }
      print('IP: $ip');
      InternetService.ip =
          ip != '63.152.126.229' ? '63.152.126.229' : '192.168.0.10';
    }();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gameroom App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MultiProvider(
          providers: [
            ChangeNotifierProvider<InternetService>(
                create: (_) => widget.internetService),
            ProxyProvider<InternetService, User>(
              update: (_, value, __) => value.currentUser,
            ),
            ProxyProvider<User, bool>(
              create: (_) => widget.internetService.currentUser != null,
              update: (context, user, previous) => user != null,
            ),
            StreamProvider<Notification>.value(
              value: widget.internetService.notifications,
            ),
          ],
          child: Consumer<bool>(
            builder: (_, loggedIn, __) => loggedIn ? HomePage() : LoginPage(),
          )),
    );
  }
}

class LifeCycleHandler extends WidgetsBindingObserver {
  final InternetService internetService;

  LifeCycleHandler(this.internetService);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
        internetService.changeStatus(UserStatus.offline);
        break;
      case AppLifecycleState.resumed:
        internetService.changeStatus(UserStatus.online);
        break;
      default:
    }
  }
}
