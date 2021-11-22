/// HTML/parser
/// html文件解析DEMO
/// pageFrame模版模块必备方法
/// 如果想体验可以放在hall_page入口进行体验

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool showWebview = false;
  bool foundFile = false;

  @override
  void initState() {
    _initHttpServer();
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
        case '/style.css': {
            String filePath = 'miniprogram/style.css';
            String fileHtmlContents = await rootBundle.loadString(filePath);

            body.request.response.statusCode = 200;
            body.request.response.headers.set("Content-Type", "text/css; charset=utf-8");
            body.request.response.write(fileHtmlContents);
            body.request.response.close();
            break;
        }
        case '/':
          {
            String filePath = 'miniprogram/index.html';
            String fileHtmlContents = await rootBundle.loadString(filePath);

            /// [analyze html]💥
            /// 解析HTML为document树，满足基本增删查改需求
            /// 后期pageFrame模板生成新页面的时候可以使用此方法进行节点插入，修改。
            /// 两种方式
            /// [1] 通过document类进行操作
            /// [2] 通过replace方法替换指定html备注（例如: <!-- remark -->）
            DOM.Document document = parse(fileHtmlContents);

            String scriptStr = '''
              <script>
                var dom = document.querySelector('.unique');
                dom.innerHTML = '注入脚本修改DOM标题';
              </script>
            ''';

            document.body?.nodes.addLast(parseFragment(scriptStr));
            document.body?.nodes.insert(1, parseFragment("<p>这句话是parser后插入的</p>"));

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Server Page'),
      ),
      body: WebView(
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: 'http://0.0.0.0:8000',
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
