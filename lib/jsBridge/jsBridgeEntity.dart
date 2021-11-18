///@author: xxx
class JsBridge {
  String ? method;
  String ? data;

  JsBridge({
    this.method,
    this.data,
  });
  JsBridge.fromJson(Map < String, dynamic > json) {
    method = json["method"]?.toString();
    data = json["data"]?.toString();
  }
  Map < String, dynamic > toJson() {
    final Map < String, dynamic > data = Map < String, dynamic > ();
    data["method"] = method;
    data["data"] = this.data;
    return data;
  }
}