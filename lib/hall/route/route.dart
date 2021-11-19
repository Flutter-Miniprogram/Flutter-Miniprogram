import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterminiprogram/utils/history.dart';
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
  // late WebViewController _webViewController;
  List history = [];

  @override
  void initState() {
    _init();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.initState();
  }

  @override
  void dispose() {
    FmServer.closeServer();
    super.dispose();
  }

  void _createNewServer(List<ServerSource> sourceList) {
    FmServer.createServer(
      sourceList: sourceList,
      onSuccess: (HttpServer server) {
        history.add('http://localhost:${server.port}');
        setState(() {
          history = history;
        });
      }
    );
  }

  void _init () async {
    _createNewServer([
      ServerSource(path: '/', rootPath: 'miniprogram/index.html'),
      ServerSource(path: '/style.css', rootPath: 'miniprogram/style.css', header: ServerSourceHeader(contentType: 'text/css; charset=utf-8'))
    ]);

    JsEnv.create(
      /// 监听JS传递过来的信息
      subscribeEvent: ((message) {
        String commend = 'callJS("$message")';
        // _webViewController.evaluateJavascript(commend);
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
          children: history.map((address) {
            return Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: FmWebview(
                  // initialUrl: address,
                  initialUrl: 'https://kefu.ikbase.cn/feedback/index.html?uid=16264075323754&appid=10027&color=EEB872#home?uid=16264075323754&notanimation=1',
                  onWebviewChange: (WebViewController webviewController) {
                    // _webViewController = webviewController;
                  },
                ),
              ),
            );
          }).toList(),
        ),
      )
    );
  }
}
