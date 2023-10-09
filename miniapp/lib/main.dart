import 'package:bridge/bridge.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: WebApp(),
  ));
}

class WebApp extends StatefulWidget {
  const WebApp({Key? key}) : super(key: key);

  @override
  State<WebApp> createState() => _WebAppState();
}

class _WebAppState extends State<WebApp> {
  late final IBridgeClient _client = WebViewBridgeClient();
  Object? _result;

  @override
  void initState() {
    super.initState();
    _client.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              try {
                final result = await _client.sendTestMessage();
                setState(() {
                  _result = result;
                });
              } catch (error) {
                setState(() {
                  _result = 'Error=$error';
                });
              }
            },
            child: const Text('Run 3'),
          ),
          Expanded(
            child: Text('Result=$_result'),
          ),
        ],
      ),
    );
  }
}
