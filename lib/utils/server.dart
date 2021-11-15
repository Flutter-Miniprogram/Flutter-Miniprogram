import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http_server/http_server.dart';

class FmServer {
  late HttpServer _server;

  FmServer.createServer() {
    HttpServer.bind('0.0.0.0', 8000).then((server) {

      this._server = server;

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

  FmServer.closeServer() {
    try {
      this._server.close();
    } catch(e) {
      print(e);
    }
  }
}