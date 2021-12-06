/// HTML/parser
/// html文件解析DEMO
/// pageFrame模版模块必备方法
/// 如果想体验可以放在hall_page入口进行体验

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterminiprogram/jsBridge/jsBridgeEntity.dart';
import 'package:flutterminiprogram/utils/javascriptChannel.dart';
import 'package:flutterminiprogram/utils/webview.dart';
import 'package:http_server/http_server.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:html/dom.dart' as DOM;
import 'package:html/parser.dart' show parse, parseFragment;

class HtmlParser extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HtmlParserState();
  }
}

class HtmlParserState extends State<HtmlParser> {
  late HttpServer server;
  /// channel
  late JavascriptChannel channel;
  /// webview controller
  late WebViewController _webViewController;

  @override
  void initState() {
    _initHttpServer();
    _initChannel();

    super.initState();
  }

  @override
  void dispose() {
    this.server.close();

    super.dispose();
  }

  void _initHttpServer() async {
    HttpServer.bind('0.0.0.0', 8000).then((server) {
      this.server = server;

      print('Server running at: ${server.address.address}:${server.address.host}');
      server.transform(HttpBodyHandler()).listen((HttpRequestBody body) async {

      /// [request] uri
      print('Request URI'); 

      /// [response] rule
      switch (body.request.uri.toString()) {
        case '/':
          {
            String filePath = 'miniprogram/parser.html';
            String fileHtmlContents = await rootBundle.loadString(filePath);

            /// [analyze html]💥
            /// 解析HTML为document树，满足基本增删查改需求
            /// 后期pageFrame模板生成新页面的时候可以使用此方法进行节点插入，修改。
            /// 两种方式
            /// [1] 通过document类进行操作
            /// [2] 通过replace方法替换指定html备注（例如: <!-- remark -->）
            DOM.Document document = parse(fileHtmlContents);

            // 创建generateFuncReady监听
            String generateFuncReadyScript = '''
              <script>
                (function() {
                  if (document.readyState === 'complete') {
                    Native.postMessage(JSON.stringify({
                      method: 'DOCUMENT_READY',
                    }))
                  } else {
                    const fn = () => {
                      Native.postMessage(JSON.stringify({
                        method: 'DOCUMENT_READY',
                      }))
                      window.removeEventListener('load', fn)
                    }
                    window.addEventListener('load', fn)
                  }
                })()
            ''';

            document.body?.nodes.add(parseFragment(generateFuncReadyScript));

            String changeFileContents = document.outerHtml;

            body.request.response.statusCode = 200;
            body.request.response.headers.set("Content-Type", "text/html; charset=utf-8");
            body.request.response.write(changeFileContents);
            body.request.response.close();
            break;
          }
        default: {
          body.request.response.statusCode = 404;
          body.request.response.write('Not found');
          body.request.response.close();
        }
      }});
    });
  }

  void _initChannel() {
    /// 创建channel
    channel = JavascriptChannelSingle.createChannel(
      onMessageReceived: (JsBridge bridge) {
        /// [bridge] DOCUMENT_READY
        /// 传递动态数据
        print('bridge.method: ${bridge.method}');
        if (bridge.method == 'DOCUMENT_READY') {
          String command = 'window.exparser.createVirtualNode()';
          Future.delayed(Duration(milliseconds: 300), () {
            _webViewController.evaluateJavascript(command);
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
      body: FmWebview(
        initialUrl: 'http://localhost:8000',
        onWebviewChange: (WebViewController webviewController) {
          _webViewController = webviewController;
        },
        channel: channel,
      )
    );
  }
}
