import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http_server/http_server.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Server extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ServerState();
  }
}

class ServerState extends State<Server> {
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

  /// [remark]
  /// 这里可以摸索目录，根据文件类型定制content-type类型（估计这个东西有现成的）
  /// 封装的事情可以往后放一放，功能点先铺开
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

            body.request.response.statusCode = 200;
            body.request.response.headers.set("Content-Type", "text/html; charset=utf-8");
            body.request.response.write(fileHtmlContents);
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
        // javascriptChannels
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
