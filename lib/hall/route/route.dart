import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterminiprogram/jsBridge/jsBridgeEntity.dart';
import 'package:flutterminiprogram/utils/javascriptChannel.dart';
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

  /// channel
  late JavascriptChannel channel;

  @override
  void initState() {
    /// 初始化一级页面
    _init();
    super.initState();
  }

  @override
  void dispose() {
    FmServer.closeAllServer();
    super.dispose();
  }

  /// 初始化一级页面
  void _init () async {
    /// 创建channel
    channel = JavascriptChannelSingle.createChannel(
      onMessageReceived: (JsBridge bridge) {
        if (bridge.method == 'routePush') {
          /// 创建第二个页面server
          _createNewServer([
            ServerSource(path: '/', rootPath: bridge.data),
          ]);
        } else if (bridge.method == 'routeBack') {
          _cancelLastServer();
        }
      }
    );

    /// 创建第一个页面Server
    _createNewServer([
      ServerSource(path: '/', rootPath: 'miniprogram/index.html'),
      ServerSource(path: '/style.css', rootPath: 'miniprogram/style.css', header: ServerSourceHeader(contentType: 'text/css; charset=utf-8'))
    ]);

    JsEnv.create(
      /// 监听JS传递过来的信息
      /// 可通过evaluateJavascript触发html中的方法
      /// 此方法暂时用不到
      /// 后面通过两端注入通讯模块实现
      /// 这里只是一种通讯的可能行
      subscribeEvent: ((message) {
        String commend = 'callJS("$message")';
        print('commend:$commend');
        // _webViewController.evaluateJavascript(commend);
      })
    );
  }

  /// 创建一个新端口并讲地址推入history
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

  /// 销毁最后一个server并弹出history
  /// 完成路由回退功能
  /// 这里目前暂时只实现移除history最后一项
  /// 已完成返回remove 具体端口
  _cancelLastServer() {
    FmServer.cancelLastServer(
      onSuccess: (int removePort) {
        List _history = history;
        _history.removeLast();
        setState(() {
          history = _history;
        });
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route Page'),
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
                  initialUrl: address,
                  onWebviewChange: (WebViewController webviewController) {
                    // _webViewController = webviewController;
                  },
                  channel: channel,
                ),
              ),
            );
          }).toList(),
        ),
      )
    );
  }
}
