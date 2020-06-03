import 'package:gameroom_app/utils/imports.dart';
import 'package:recase/recase.dart';

/// Page for choosing the game to be played
class GameLobbyPage extends StatefulWidget with Page {
  @override
  String get title => 'Game Lobby';

  @override
  PageSelection get selection => PageSelection.game;

  GameLobbyPage({Key key}) : super(key: key);
  
  @override
  GameLobbyPageState createState() => GameLobbyPageState();
}

class GameLobbyPageState extends State<GameLobbyPage> {
  GameTitle _selectedGame = GameTitle.tic_tac_toe;
  GameMode _selectedMode = GameMode.offline;
  User _invitedFriend; // needed to initialize this to empty user to prevent getting red screened

  List<Widget> games = [];
  int selectedGame = 0;

  void addGame(Widget game) {
    setState(() {
      games.add(game);
    });
  }

  void createGame(GameTitle game) {
      selectedGame = games.length;
      if (_selectedMode == GameMode.match_make) {
        addGame(MatchMakingPage(game: game));
      } else if (_selectedMode == GameMode.offline) {
        addGame(
          ActiveGamePage(
            GameFound(
              game: game,
              online: false,
              player1: User(username: 'Player One', id: 1),
              player2: User(username: 'Player Two', id: 2),
            ),
          ),
        );
      }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: games.isEmpty
          ? null
          : BottomNavigationBar(
              onTap: (i) {
                selectedGame = i - 1;
              },
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  title: Text('Create Game'),
                  icon: Icon(Icons.create),
                ),
                ...games.mapIndexed((e, i) => BottomNavigationBarItem(
                      title: Text('Game $i'),
                      icon: Icon(Icons.gamepad),
                    ))
              ],
            ),
      body: games.isNotEmpty
          ? games[selectedGame]
          : SingleChildScrollView(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Column(
                    children: <Widget>[
                      DropdownButton<GameTitle>(
                        style: TextStyle(fontSize: 24, color: Colors.black),
                        value: _selectedGame,
                        onChanged: (GameTitle game) {
                          setState(() {
                            _selectedGame = game;
                          });
                        },
                        items: GameTitle.values
                            .map<DropdownMenuItem<GameTitle>>(
                                (GameTitle value) {
                          return DropdownMenuItem<GameTitle>(
                            value: value,
                            child: Text(value.title),
                          );
                        }).toList(),
                      ),
                      DropdownButton<GameMode>(
                        style: TextStyle(fontSize: 24, color: Colors.black),
                        value: _selectedMode,
                        onChanged: (GameMode gameMode) async {
                          setState(() {
                            _selectedMode = gameMode;
                          });
                        },
                        items: GameMode.values
                            .map<DropdownMenuItem<GameMode>>((GameMode value) {
                          return DropdownMenuItem<GameMode>(
                            value: value,
                            child: Text(enumToString(value).titleCase),
                          );
                        }).toList(),
                      ),
                      Visibility(
                        visible: _selectedMode != GameMode.invite_friend,
                        child: MaterialButton(
                          color: Colors.lightBlueAccent,
                          textColor: Colors.white,
                          child: Text('Play'),
                          onPressed: () {
                            createGame(_selectedGame);
                          },
                        ),
                      ),
                      Visibility(
                        visible: _selectedMode == GameMode.invite_friend,
                        child: MaterialButton(
                          color: Colors.lightBlueAccent,
                          textColor: Colors.white,
                          child: Text('Invite'),
                          onPressed: () async {
                            if (_selectedMode == GameMode.invite_friend) {
                              final service = internetService(context);
                              final friends = (await service.getFriends())
                                  .value
                                  .where((e) => e.status == UserStatus.online)
                                  .toList();
                              if (friends.isEmpty) {
                                PopUps.alert(context, 'No Online Friends',
                                    'You do not have any friends online');
                                return;
                              }
                              _invitedFriend = await showModalBottomSheet<User>(
                                context: context,
                                builder: (context) => FriendList(
                                  friends: friends,
                                  onTap: (friend, status) {
                                    setState(() {
                                      _selectedMode = GameMode.invite_friend;
                                    });
                                    Navigator.pop(context, friend);
                                    service.inviteToGame(_selectedGame, friend);
                                  },
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      Visibility(
                        visible: _invitedFriend?.username != null &&
                            _selectedMode == GameMode.invite_friend,
                        child: Column(
                          children: <Widget>[
                            Align(
                              alignment: FractionalOffset.bottomCenter,
                              child: Padding(
                                padding: EdgeInsets.only(top: 100),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 24.0),
                              child: Text(
                                  'Waiting for "${_invitedFriend?.username}" to accept...'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class MatchMakingPage extends StatelessWidget {
  final GameTitle game;

  MatchMakingPage({Key key, this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    internetService(context).findGame(game);
    return Center(
      child: Column(
        children: <Widget>[
          Text('Waiting to find a match for ${game.title}'),
          FlatButton(
            onPressed: () {

            },
            child: Text('Exit'),
          ),
        ],
      ),
    );
  }
}

enum GameMode { invite_friend, match_make, offline }
