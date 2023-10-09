import 'package:bridge/bridge.dart';

class BridgeService implements IBridgeService {
  @override
  Future<BridgeResponse> onMessageReceived(BridgeRequest request) async {
    final data = request.data;
    print('onMessageReceived $data');
    return BridgeResponse({
      'request_id': data['request_id'],
      'response': 'hello_from_superapp',
    });
  }
}
