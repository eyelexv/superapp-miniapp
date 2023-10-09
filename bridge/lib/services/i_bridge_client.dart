abstract class IBridgeClient {
  void init();

  void subscribe(void Function(dynamic event) handler);

  bool unsubscribe(void Function(dynamic event) handler);

  Future<Object> sendTestMessage();
}
