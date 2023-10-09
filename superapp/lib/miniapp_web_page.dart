import 'dart:convert';

import 'package:bridge/bridge.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'bridge_service.dart';

class MiniappWebPage extends StatefulWidget {
  const MiniappWebPage({
    Key? key,
    required this.url,
  }) : super(key: key);

  final String url;

  @override
  State<MiniappWebPage> createState() => _MiniappPageState();
}

class _MiniappPageState extends State<MiniappWebPage> {
  final IBridgeService _bridgeService = BridgeService();
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController.fromPlatformCreationParams(
      const PlatformWebViewControllerCreationParams(),
    )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        superappMiniappChannel,
        onMessageReceived: _messageReceived,
      )
      ..setOnConsoleMessage((message) {
        print(message);
      })
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _messageReceived(JavaScriptMessage message) async {
    final map = json.decode(message.message) as Map<String, dynamic>;
    final request = BridgeRequest(map);
    final response = await _bridgeService.onMessageReceived(request);
    final data = json.encode(response.data);
    final js = 'window.postMessage($data, window.location.origin)';
    final result = await _controller.runJavaScriptReturningResult(js);
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.url),
      ),
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }
}
