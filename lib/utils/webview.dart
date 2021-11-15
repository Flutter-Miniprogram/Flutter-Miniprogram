import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FmWebview extends StatelessWidget {
  String initialUrl;

  FmWebview({
    required this.initialUrl,
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
      onPageFinished: (url) => {},
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
