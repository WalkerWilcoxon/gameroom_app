import 'package:flutter/foundation.dart';
import 'package:gameroom_app/pages/game_history_page.dart';
import 'package:gameroom_app/services/internet_service.dart';
import 'package:gameroom_app/utils/imports.dart';
import 'package:gameroom_app/widgets/notification_button.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {

  static final gameLobbyKey = GlobalKey<GameLobbyPageState>();

  final _mainPages = <PageSelection, Page>{
    PageSelection.game: GameLobbyPage(key: gameLobbyKey),
    PageSelection.friends: ViewFriendPage(),
    PageSelection.chat: ChatSelectPage(),
    PageSelection.history: GameHistoryPage(),
    PageSelection.profile: ProfilePage(),
  };

  final _pages = <PageSelection, Page>{
    PageSelection.game: GameLobbyPage(),
    PageSelection.friends: ViewFriendPage(),
    PageSelection.chat: ChatSelectPage(),
    PageSelection.history: GameHistoryPage(),
    PageSelection.profile: ProfilePage(),
  };

  final _pageIcons = <PageSelection, IconData>{
    PageSelection.game: Icons.gamepad,
    PageSelection.friends: Icons.person_add,
    PageSelection.chat: Icons.chat_bubble,
    PageSelection.history: Icons.history,
    PageSelection.profile: Icons.account_box,
  };

  PageSelection selection = PageSelection.game;

  Page get selectedPage => _pages[selection];

  void selectPage(Page page) {
    setState(() {
      selection = page.selection;
      _pages[selection] = page;
    });
  }

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    final service = internetService(context);
    service.notificationController.stream.listen((notification) {
      if (notification is GameFound) {
        service.changeStatus(UserStatus.in_game);
        gameLobbyKey.currentState.addGame(ActiveGamePage());
      }

      if (notification is Message && (notification.from == currentUser(context) || selectedPage is ChatPage))
        return;
      if (notification.displayMessage.isNotEmpty) {
        scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text('${notification.displayMessage}')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Provider<HomePageState>.value(
      value: this,
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          leading: Visibility(
            visible:
                selectedPage.runtimeType != _mainPages[selection].runtimeType &&
                    selectedPage.hasBackButton,
            child: BackButton(
              onPressed: () {
                setState(() {
                  _pages[selection] = _mainPages[selection];
                });
              },
            ),
          ),
          title: Text(selectedPage.title),
          actions: <Widget>[
            NotificationButton(),
          ],
        ),
        body: Stack(
          children: _pages.values
              .map((page) => Visibility(
                    maintainState: true,
                    visible: page.selection == selection,
                    child: page,
                  ))
              .toList(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: (int index) {
            setState(() {
              selection = PageSelection.values
                  .firstWhere((selection) => selection.index == index);
            });
          },
          items: PageSelection.values
              .map((selection) => BottomNavigationBarItem(
                    icon: Icon(_pageIcons[selection]),
                    title: Text(enumToString(selection).capitalize()),
                    backgroundColor: Colors.white,
                  ))
              .toList(),
          unselectedItemColor: Colors.blueGrey,
          selectedItemColor: Colors.blue,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          currentIndex: selection.index,
        ),
      ),
    );
  }
}
