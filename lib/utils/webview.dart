import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FmWebview extends StatelessWidget {
  /// webview地址
  String initialUrl;

  /// controller
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  /// webview加载完成回调
  Function? onWebviewChange = () {};

  /// channel
  JavascriptChannel? channel;

  FmWebview({
    required this.initialUrl,
    this.onWebviewChange,
    this.channel,
  });

  @override
  Widget build(BuildContext context) {
    return WebView(
      javascriptMode: JavascriptMode.unrestricted,
      javascriptChannels: <JavascriptChannel>{
        /// 注入channel 临时给予默认值
        channel ?? JavascriptChannel(
          name: 'Native',
          onMessageReceived: (JavascriptMessage message) {}
        )
      },
      initialUrl: initialUrl,
      navigationDelegate: (NavigationRequest request) {
        /// webview路由拦截相关处理
        if (request.url.startsWith('schema://')) {
          // do something
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      },
      onWebViewCreated: (WebViewController webViewController) {
        /// 当webview创建完后，创建controller
        _controller.complete(webViewController);
      },
      onPageFinished: (url) => {
        /// 当HTML加载完毕之后调用callJS方法
        /// 回调_onWebviewChange返回当前controller
        /// 外部完成controller初始化
        _controller.future.then((controller) {
          Function _onWebviewChange = onWebviewChange ?? () {};
          _onWebviewChange(controller);
        })
      },
      onWebResourceError: (error) => {},
    );
  }
}
