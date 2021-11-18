import 'package:flutter/material.dart';
import 'package:flutterminiprogram/utils/jsEnv.dart';
import 'package:flutterminiprogram/utils/server.dart';
import 'package:flutterminiprogram/utils/webview.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HallRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HallRouteState();
  }
}

class HallRouteState extends State<HallRoute> {
  late WebViewController _webViewController;

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  void dispose() {
    FmServer.closeServer();
    super.dispose();
  }

  void _init () async {
    FmServer.createServer(
      port: 8000,
      sourceList: [
        ServerSource(path: '/', rootPath: 'miniprogram/index.html'),
        ServerSource(path: '/style.css', rootPath: 'miniprogram/style.css', header: ServerSourceHeader(contentType: 'text/css; charset=utf-8'))
      ]
    );

    FmServer.createServer(
      port: 8001,
      sourceList: [
        ServerSource(path: '/', rootPath: 'miniprogram/second.html'),
      ]
    );

    JsEnv.create(
      /// 监听JS传递过来的信息
      subscribeEvent: ((message) {
        String commend = 'callJS("$message")';
        _webViewController.evaluateJavascript(commend);
      })
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Server Page'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: double.infinity,
                height: 500,
                child: FmWebview(
                  initialUrl: 'http://localhost:8000',
                  onWebviewChange: (WebViewController webviewController) {
                    _webViewController = webviewController;
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: double.infinity,
                height: 500,
                margin: EdgeInsets.only(left: 100),
                child: FmWebview(
                  initialUrl: 'http://localhost:8001',
                  onWebviewChange: (WebViewController webviewController) {
                    _webViewController = webviewController;
                  },
                ),
              ),
            ),
          ]
        ),
      )
    );
  }
}
