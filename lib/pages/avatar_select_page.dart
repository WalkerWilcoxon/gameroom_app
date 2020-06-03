import 'package:gameroom_app/services/internet_service.dart';
import 'package:gameroom_app/utils/imports.dart';

class AvatarSelectPage extends StatefulWidget with Page {
  @override
  String get title => 'Profile Picture';

  @override
  PageSelection get selection => PageSelection.profile;

  @override
  _AvatarSelectPageState createState() => _AvatarSelectPageState();
}

class _AvatarSelectPageState extends State<AvatarSelectPage> {
  int _selectedAvatarIndex;
  static final List<String> _avatars = [
    'assets/empty-avatar.png',
    'assets/chess/black-bishop.png',
    'assets/chess/black-king.png',
    'assets/chess/black-pawn.png',
    'assets/chess/black-queen.png',
    'assets/chess/black-rook.png',
    'assets/chess/white-bishop.png',
    'assets/chess/white-king.png',
    'assets/chess/white-knight.png',
    'assets/chess/white-pawn.png',
    'assets/chess/white-queen.png',
    'assets/tic-tac-toe/o.png',
    'assets/tic-tac-toe/x.png'
  ];
  static final List<Image> _avatarImages =
      _avatars.map((avatar) => Image.asset(avatar)).toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: GridView.count(
        crossAxisCount: 3,
        children: List.generate(_avatars.length, (index) {
          return FlatButton(
            key: Key(_avatars[index]),
            color:
                index == _selectedAvatarIndex ? Colors.lightBlue : Colors.white,
            onPressed: () async {
              await internetService(context).changeAvatar(_avatars[index]);
              setState(() {
                _selectedAvatarIndex = index;
              });
            },
            child: Center(
              child: _avatarImages[index],
            ),
          );
        }),
      ),
    );
  }
}
