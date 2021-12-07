/// HTML/parser
/// html文件解析DEMO
/// pageFrame模版模块必备方法
/// 如果想体验可以放在hall_page入口进行体验

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterminiprogram/jsBridge/jsBridgeEntity.dart';
import 'package:flutterminiprogram/utils/javascriptChannel.dart';
import 'package:flutterminiprogram/utils/server.dart';
import 'package:flutterminiprogram/utils/webview.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:html/parser.dart' show parse, parseFragment;

class HtmlParser extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HtmlParserState();
  }
}

class HtmlParserState extends State<HtmlParser> {
  /// channel
  late JavascriptChannel channel;
  /// webview controller
  late WebViewController _webViewController;
  List history = [];

  @override
  void initState() {
    _initChannel();

    _createNewServer([
      ServerSource(path: '/', rootPath: 'miniprogram/pageFrame/pageFrame.html'),
      ServerSource(path: '/WAWebview.js', rootPath: 'miniprogram/pageFrame/WAWebview.js', header: ServerSourceHeader(contentType: 'text/javascript; charset=utf-8')),
      ServerSource(path: '/wxml.js', rootPath: 'miniprogram/pageFrame/wxml.js', header: ServerSourceHeader(contentType: 'text/javascript; charset=utf-8'))
    ]);

    super.initState();
  }

  @override
  void dispose() {
    FmServer.closeAllServer();
    super.dispose();
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

  void _initChannel() {
    /// 创建channel
    channel = JavascriptChannelSingle.createChannel(
      onMessageReceived: (JsBridge bridge) {

        print('log:--------bridge.method:${bridge.method}');

        if (bridge.method == 'DOCUMENT_READY') {
          /// [bridge] DOCUMENT_READY
          /// 获取初始动态数据
          /// 插入wxml.js等 
          String wxml = './wxml.js';
          String scriptType = 'text/javascript';
          String commend = 'window.foundtion.insertDocumentHeadChild("$wxml", "$scriptType")';
          Future.delayed(Duration(milliseconds: 300), () {
            _webViewController.evaluateJavascript(commend);
          });
        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parser Page'),
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
                    _webViewController = webviewController;
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
