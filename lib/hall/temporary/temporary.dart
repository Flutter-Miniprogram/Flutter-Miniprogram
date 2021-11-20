/// [describe]临时目录用于任意代码调试

import 'package:flutter/material.dart';

class Temporary extends StatelessWidget {

  Temporary();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Temporary'),
      ),
      body: Column(
        children: [
          Text('Top Fixed'),
          Expanded(
            child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Container(
                    width: 300,
                    height: 100.0,
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    child: Text('Nested Top')
                  )
                ),
              ];
            },
            body: Text('Nested Content'),
          ))
        ],
      ),
    );
  }
}
