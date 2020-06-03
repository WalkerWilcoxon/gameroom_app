import 'package:gameroom_app/services/internet_service.dart';
import 'package:gameroom_app/utils/imports.dart';

import 'package:stomp/websocket.dart' show connect;
import 'package:stomp/stomp.dart';

Future<StompClient> createStompClient() => connect(InternetService.websocketUrl);
