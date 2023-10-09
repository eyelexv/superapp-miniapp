import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;

import '../services/i_bridge_client.dart';
import 'constants.dart';
import '../models/bridge_response.dart';
import '../models/bridge_request.dart';

class WebViewBridgeClient implements IBridgeClient {
  final _requestResolver = _RequestCompleter();
  final List<void Function(html.Event event)> _subscribers = [];
  js.JsObject? _superAppChannelWebView;
  html.WindowBase? _parentSuperAppWindow;
  var _didInit = false;

  @override
  void init() {
    if (_didInit) {
      return;
    }

    _superAppChannelWebView = js.context[superappMiniappChannel] as js.JsObject;
    if (html.window != html.window.parent) {
      _parentSuperAppWindow = html.window.parent;
    }
    html.window.onMessage.listen(_messageEventListener);

    _didInit = true;
  }

  @override
  void subscribe(void Function(dynamic event) handler) {
    html.window.console.log('subscribe');
    _subscribers.add(handler);
  }

  @override
  bool unsubscribe(void Function(dynamic event) handler) {
    html.window.console.log('unsubscribe');
    return _subscribers.remove(handler);
  }

  @override
  Future<Object> sendTestMessage() {
    final completer = Completer<Object>();
    final requestId = _requestResolver.add(completer);
    _send(BridgeRequest({
      'request_id': requestId,
      'hello': 'world',
    }));
    return completer.future;
  }

  void _messageEventListener(html.Event event) {
    final handlers = [_futureCompleterSubscriber, ..._subscribers];
    html.window.console.log(
      '_messageEventListener handlers count = ${handlers.length}',
    );

    for (final handler in handlers) {
      try {
        handler(event as html.MessageEvent);
      } catch (e) {
        html.window.console.log('_messageEventListener error ${e.toString()}');
      }
    }
  }

  void _futureCompleterSubscriber(html.MessageEvent event) {
    html.window.console.log(
      '_futureCompleterSubscriber start ${event.data}',
    );

    // Этот необходимо т.к. обычные методы приведения типа вызывают ошибку в JS
    final data = Map<String, dynamic>.from(event.data as Map);
    final response = BridgeResponse(data);

    // _requestResolver.complete(
    //   response.data['request_id'],
    //   response,
    //   isSuccess: true,
    // );

    _requestResolver.complete(
      response.data['request_id'],
      json.encode(response.data),
      isSuccess: true,
    );
  }

  void _postMessage(String arg) {
    html.window.console.log('_postMessage $arg');
    _superAppChannelWebView?.callMethod(
      'postMessage',
      <String>[arg],
    );
  }

  void _send(BridgeRequest request) {
    final data = json.encode(request.data);
    html.window.console.log('_send $data');
    _postMessage(data);
  }
}

class _RequestCompleter {
  /// Для уникальности событий в хранилище
  final _Counter _counter = _Counter();

  /// Хранилище для id события и resolve/reject колбеков к нему
  final Map<int, Completer> _futureControllers = {};

  /// Добавление нового события в хранилище
  int add(
    Completer controller, {
    int? customId,
  }) {
    final id = customId ?? _counter.next();
    _futureControllers[id] = controller;
    return id;
  }

  void complete(
    int requestId,
    Object data, {
    required bool isSuccess,
  }) {
    final requestController = _futureControllers[requestId];
    html.window.console.log('complete ${requestController != null} data=$data');

    if (requestController != null) {
      if (isSuccess) {
        requestController.complete(data);
      } else {
        requestController.completeError(data);
      }

      _futureControllers.remove(requestId);
    }
  }
}

class _Counter {
  int _id = 0;

  int next() {
    return ++_id;
  }
}
