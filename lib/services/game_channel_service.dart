import 'package:gameroom_app/utils/imports.dart';

class GameChannelService<Move extends Jsonable> {
  final String gameId;
  final Move Function(Map<String, dynamic> json) moveFromJson;
  final InternetService internetService;

  GameChannelService(this.gameId, this.moveFromJson, this.internetService);

  void onMoveReceived(void Function(Move move, int playerId) onMoveReceived) {
    internetService.stompClient.subscribeJson('$gameId', '/topic/game/$gameId',
        (headers, message) {
      onMoveReceived(moveFromJson(message['move']), message['playerId']);
    });
  }

  void sendMove(Move move, int playerId) {
    internetService.stompClient.sendString('/app/game/$gameId', jsonEncode({'playerId': playerId, 'move': move}));
  }

  Future<void> finishGame(int winnerId) async {
    await internetService.post('/game/winner/$gameId/${winnerId ?? -1}');
  }

  void dispose() {
    internetService.stompClient.unsubscribe('/topic/game/$gameId');
    internetService.changeStatus(UserStatus.online);
  }
}
