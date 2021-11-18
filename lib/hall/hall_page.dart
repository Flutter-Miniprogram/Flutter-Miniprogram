import 'package:flutter/material.dart';
import 'package:flutterminiprogram/hall/route/route.dart';
import 'package:flutterminiprogram/hall/server/server.dart';
import 'package:flutterminiprogram/hall/serverAndView/server_and_view.dart';
import 'package:flutterminiprogram/hall/temporary/temporary.dart';
import 'package:flutterminiprogram/hall/view/binding_page.dart';
import 'package:flutterminiprogram/hall/webview/webview_page.dart';

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
          subtitle: Text('结合server和view，配合html+css+js模型'),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return ServerAndView();
            }));
          },
        ),
        ListTile(
          title: Text('Server Page'),
          subtitle: Text('create a port server'),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return Server();
            }));
          },
        ),
        ListTile(
          title: Text('Webview Page'),
          subtitle: Text('route to webview page'),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return WebviewPage();
            }));
          },
        ),
        ListTile(
          title: Text('Bindings page'),
          subtitle: Text('Dart binding C'),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return BindingsPage();
            }));
          },
        ),
        ListTile(
          title: Text('Temporary page'),
          subtitle: Text('Temporary page'),
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
