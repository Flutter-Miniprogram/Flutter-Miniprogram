import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:flutter/material.dart';

class WebviewPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WebviewPageState();
  }
}

class WebviewPageState extends State<WebviewPage> {
  @override
   void initState() {
     super.initState();
         // Enable hybrid composition.
      if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebviewPage'),
      ),
      body: WebView(
        javascriptMode: JavascriptMode.unrestricted,
        // javascriptChannels
        initialUrl: 'https://www.baidu.com/',
        navigationDelegate: (NavigationRequest request) {
          if (request.url.startsWith('zhixing://')) {
            // do something
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onPageFinished: (url) => {},
        onWebResourceError: (error) => {},
      )
    );
  }
}
