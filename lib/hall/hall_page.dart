import 'package:flutter/material.dart';
import 'package:flutterminiprogram/hall/parser/html_parser.dart';
import 'package:flutterminiprogram/hall/route/route.dart';
import 'package:flutterminiprogram/hall/server/server.dart';
import 'package:flutterminiprogram/hall/serverAndView/server_and_view.dart';
import 'package:flutterminiprogram/hall/temporary/temporary.dart';
import 'package:flutterminiprogram/hall/jscore/binding_page.dart';

class HallPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HallPageState();
  }
}

class HallPageState extends State<HallPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Divider(
          height: 0.5,
          thickness: 0.5,
        ),
        ListTile(
          title: Text('Parser'),
          subtitle: Text('Parser实例'),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return HtmlParser();
            }));
          },
        ),
        ListTile(
          title: Text('Route'),
          subtitle: Text('添加路由'),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return HallRoute();
            }));
          },
        ),
        ListTile(
          title: Text('Server & View'),
          subtitle: Text('结合server和jscore，配合html+css+js模型'),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return ServerAndView();
            }));
          },
        ),
        ListTile(
          title: Text('Server Page'),
          subtitle: Text('启动一个端口并读取本地文件Example'),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return Server();
            }));
          },
        ),
        ListTile(
          title: Text('Jscore Bindings Page'),
          subtitle: Text('Jscore运行Example'),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return BindingsPage();
            }));
          },
        ),
        ListTile(
          title: Text('Temporary page'),
          subtitle: Text('临时目录用于任意代码调试'),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return Temporary();
            }));
          },
        ),
      ],
    );
  }
}
