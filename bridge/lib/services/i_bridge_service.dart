import '../models/bridge_request.dart';
import '../models/bridge_response.dart';

abstract class IBridgeService {
  Future<BridgeResponse> onMessageReceived(BridgeRequest request);
}
