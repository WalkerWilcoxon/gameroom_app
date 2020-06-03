import 'package:gameroom_app/utils/imports.dart';

class GameHistoryPage extends StatelessWidget with Page {
  @override
  String get title => 'Game History';

  @override
  PageSelection get selection => PageSelection.history;

  GameHistoryPage({Key key, this.user}) : super(key: key);

  final User user;

  @override
  Widget build(BuildContext context) {
    return DownloadBuilder<ResponseValue<List<GameRecord>>>(
        future: internetService(context).getGameHistory(user ?? currentUser(context)),
        builder: (context, data) {
          final history = data?.value;
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) =>
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Card(
                    color: Colors.white,
                    child: FlatButton(
                      onPressed: () async {
                        Page.goto(
                            context,
                            ViewGamePage(
                                game: history[index].game,
                                moves: (await internetService(context)
                                    .getGameMoves(history[index].id))
                                    .value));
                      },
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              history[index].game.title,
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                                '${history[index].player1
                                    .username} vs ${history[index].player2
                                    .username}',
                                style: TextStyle(fontSize: 18)),
                            Text('Winner: ${history[index].winner.username}',
                                style: TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
          );
        },
      );
  }
}

class ViewGamePage extends StatefulWidget with Page {
  @override
  String get title => 'View Game';

  @override
  PageSelection get selection => PageSelection.history;

  final GameTitle game;
  final List moves;

  ViewGamePage({Key key, this.game, this.moves}) : super(key: key);

  @override
  _ViewGamePageState createState() => _ViewGamePageState();
}

class _ViewGamePageState extends State<ViewGamePage> {
  int turn;

  Game<Jsonable, dynamic> game;

  @override
  void initState() {
    super.initState();
    turn = widget.moves.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton.icon(
                label: Text('Turn before', style: TextStyle(color: Colors.white)),
                color: turn > -1 ? Colors.lightBlue : Colors.grey,
                icon: Icon(Icons.arrow_back, color: Colors.white,),
                onPressed: () {
                  if (turn > -1)
                    setState(() {
                      turn--;
                    });
                },
              ),
              FlatButton.icon(
                color:
                turn < widget.moves.length - 1 ? Colors.lightBlue : Colors.grey,
                label: Text('Turn after', style: TextStyle(color: Colors.white),),
                icon: Icon(Icons.arrow_forward, color: Colors.white),
                onPressed: () {
                  if (turn < widget.moves.length - 1)
                    setState(() {
                      turn++;
                    });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ActiveGamePage(
            GameFound(
              game: widget.game,
              online: false,
              player1: User(username: 'Player one', id: 1),
              player2: User(username: 'Player two', id: 2),
              moves: widget.moves.getRange(0, turn + 1).toList(),
            ),
            key: Key('$turn'),
          ),
        ),
      ],
    );
  }
}
