import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http_server/http_server.dart';

int port = 8000;
List<HttpServer> _serverList = [];

class FmServer {
  FmServer.createServer({
    required List<ServerSource> sourceList,
    Function? onSuccess
  }) {
    HttpServer.bind('0.0.0.0', port, shared: true).then((server) {
      /// 推入队列
      _serverList.add(server);

      /// port自增
      port += 1;

      /// 成功回调函数
      Function callBackSuccess = onSuccess ?? () {};
      callBackSuccess(server);
      
      /// log日志
      print('Server running at: ${server.address.address}:${server.address.host}');

      /// 监听资源请求
      server.transform(HttpBodyHandler()).listen((HttpRequestBody body) async {
        /// [request] uri
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

   static void closeAllServer() {
    try {
      _serverList.forEach((element) {
        element.close();
      });
    } catch(e) {
      print(e);
    }
  }

  static void cancelLastServer({ Function? onSuccess }) {
    HttpServer lastServer = _serverList[_serverList.length - 1];

    int removePort = lastServer.port;

    lastServer.close();

    /// 移除serverList列表最后server
    _serverList.removeLast();
    
    Function _onSuccessCallback = onSuccess ?? () {};
    _onSuccessCallback(removePort);
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

/// Server的实体类
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