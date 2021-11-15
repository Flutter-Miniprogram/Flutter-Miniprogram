import 'package:flutter/services.dart';

class Utils {
  /// 获取静态资源方法，文件内容UTF-8 String
  static getStaticFileString(String filePath) async {
    return await rootBundle.loadString(filePath);
  }
}