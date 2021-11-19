import 'dart:convert';

import 'package:flutterminiprogram/jsBridge/jsBridgeEntity.dart';
import 'package:webview_flutter/webview_flutter.dart';

class JavascriptChannelSingle {
  static JavascriptChannel instance = JavascriptChannel(
    name: 'Native',
    onMessageReceived: (JavascriptMessage message) {
      JsBridge _bridge = JsBridge.fromJson(jsonDecode(message.message));
      print(_bridge);
    }
  );
  
  static JavascriptChannel createChannel ({ Function? onMessageReceived }) {
    Function _onMessageReceived = onMessageReceived ?? () {};

    return JavascriptChannel(
      name: 'Native',
      onMessageReceived: (JavascriptMessage message) {
        JsBridge _bridge = JsBridge.fromJson(jsonDecode(message.message));
        _onMessageReceived(_bridge);
      }
    );
  }
}