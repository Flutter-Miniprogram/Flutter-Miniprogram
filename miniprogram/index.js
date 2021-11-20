function test() {
  // js中的一些计算
  var years = 2000 + 21;

  // 目前尝试alert方法传送信息到html
  alert(`js alert message`);

  // js触发Native方法
  flutter.print('触发Navie方法');

  // jscore解析返回值
  return 'years' + (2000 + 21);
}
test();