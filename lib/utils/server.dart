import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http_server/http_server.dart';

class FmServer {
  late HttpServer _server;

  FmServer.createServer({
    required int port,
    required List<ServerSource> sourceList,
  }) {
    HttpServer.bind('0.0.0.0', port, shared: true).then((server) {

      this._server = server;

      print('Server running at: ${server.address.address}:${server.address.host}');
      server.transform(HttpBodyHandler()).listen((HttpRequestBody body) async {

      /// [request] uri
      print('Request URI'); 

      /// [response] rule

      String _sourcePath = body.request.uri.toString();

      List _sourceMap = sourceList;
      int index = _sourceMap.indexWhere((element) => element.path == _sourcePath);

      if (index > -1) {
        ServerSource _source = sourceList[index];
        String filePath = _source.rootPath ?? '';
        String fileHtmlContents = await rootBundle.loadString(filePath);

        body.request.response.statusCode = 200;
        body.request.response.headers.set("Content-Type", _source.header?.contentType ?? "text/html; charset=utf-8");
        body.request.response.write(fileHtmlContents);
        body.request.response.close();
      } else {
        body.request.response.statusCode = 404;
        body.request.response.write('Not found');
        body.request.response.close();
      }
      });
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

///@author: xxx
class ServerSourceHeader {
  String ? contentType;

  ServerSourceHeader({
    this.contentType,
  });
  ServerSourceHeader.fromJson(Map < String, dynamic > json) {
    contentType = json["content-type"]?.toString();
  }
  Map < String, dynamic > toJson() {
    final Map < String, dynamic > data = Map < String, dynamic > ();
    data["content-type"] = contentType;
    return data;
  }
}

class ServerSource {
  String ? path;
  String ? rootPath;
  ServerSourceHeader ? header;

  ServerSource({
    this.path,
    this.rootPath,
    this.header,
  });
  ServerSource.fromJson(Map < String, dynamic > json) {
    path = json["path"]?.toString();
    rootPath = json["rootPath"]?.toString();
    header = (json["header"] != null) ? ServerSourceHeader.fromJson(json["header"]) : null;
  }
  Map < String, dynamic > toJson() {
    final Map < String, dynamic > data = Map < String, dynamic > ();
    data["path"] = path;
    data["rootPath"] = rootPath;
    if (header != null) {
      data["header"] = header?.toJson();
    }
    return data;
  }
}