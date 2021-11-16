import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FmWebview extends StatelessWidget {
  String initialUrl;
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  Function? onWebviewChange = () {};

  FmWebview({
    required this.initialUrl,
    this.onWebviewChange,
  });

  @override
  Widget build(BuildContext context) {
    return WebView(
      javascriptMode: JavascriptMode.unrestricted,
      javascriptChannels: <JavascriptChannel>{
        _toasterJavascriptChannel(context),
      },
      initialUrl: initialUrl,
      navigationDelegate: (NavigationRequest request) {
        if (request.url.startsWith('zhixing://')) {
          // do something
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      },
      onWebViewCreated: (WebViewController webViewController) {
        ///当webview创建完后，创建controller
        _controller.complete(webViewController);
      },
      onPageFinished: (url) => {
        ///当HTML加载完毕之后调用callJS方法
        _controller.future.then((controller) {

          Function _onWebviewChange = onWebviewChange ?? () {};
          _onWebviewChange(controller);

          // controller
          //   .evaluateJavascript('callJS("visible")')
          //   .then((result) {});
        })
      },
      onWebResourceError: (error) => {},
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'Native',
      onMessageReceived: (JavascriptMessage message) {
        // ignore: deprecated_member_use
        Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(message.message)),
        );
      });
  }
}
