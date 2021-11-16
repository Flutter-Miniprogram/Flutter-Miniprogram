import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_jscore/jscore_bindings.dart';
import 'package:ffi/ffi.dart';

class JsEnv {
  static JSObjectCallAsFunctionCallbackDart? _alertDartFunc;
  // Jsc上下文
  late Pointer contextGroup;
  late Pointer globalContext;
  late Pointer globalObject;

  ///内部成员
  bool hasInstall = false;
  // 事件监听
  late Function _subscribeEvent;

  JsEnv.create({ Function? subscribeEvent }) {
    // 初始化内部成员
    _subscribeEvent = subscribeEvent ?? () {};

    // 创建js上下文
    if (!hasInstall) {
      contextGroup = jSContextGroupCreate();
      globalContext = jSGlobalContextCreateInGroup(contextGroup, nullptr);
      globalObject = jSContextGetGlobalObject(globalContext);

      hasInstall = true;

      _registerMethod();
    }

    _getJsFile();
  }

  _getJsFile() async {
    /// 读取本地js文件
    String filePath = 'miniprogram/index.js';
    String script = await rootBundle.loadString(filePath);

    _runJs(script);
  }

  _runJs(String script) {
    Pointer<Utf8> scriptCString = script.toNativeUtf8();
    var jsValueRef = jSEvaluateScript(
      globalContext,
      jSStringCreateWithUTF8CString(scriptCString),
      nullptr,
      nullptr,
      1,
      nullptr
    );
    malloc.free(scriptCString);
    /// 获取返回结果
    String result = _getJsValue(jsValueRef);

    print('result: $result');
  }

  /// 绑定JavaScript alert()函数
  static Pointer alert(
      Pointer ctx,
      Pointer function,
      Pointer thisObject,
      int argumentCount,
      Pointer<Pointer> arguments,
      Pointer<Pointer> exception) {
    if (_alertDartFunc != null) {
      _alertDartFunc!(
          ctx, function, thisObject, argumentCount, arguments, exception);
    }
    return nullptr;
  }

  _registerMethod() {
    // 注册alert方法
    _alertDartFunc = _alert;
    Pointer<Utf8> funcNameCString = 'alert'.toNativeUtf8();

    // [binding diy callback function]
    var functionObject = jSObjectMakeFunctionWithCallback(
      globalContext,
      jSStringCreateWithUTF8CString(funcNameCString),
      Pointer.fromFunction(alert)
    );

    jSObjectSetProperty(
      globalContext,
      globalObject,
      jSStringCreateWithUTF8CString(funcNameCString),
      functionObject,
      JSPropertyAttributes.kJSPropertyAttributeNone,
      nullptr
    );

    malloc.free(funcNameCString);

    // 注册flutter.print静态方法
    _printDartFunc = _print;
    var staticFunctions = JSStaticFunctionPointer.allocateArray([
      JSStaticFunctionStruct(
        name: 'print'.toNativeUtf8(),
        callAsFunction: Pointer.fromFunction(flutterPrint),
        attributes: JSPropertyAttributes.kJSPropertyAttributeNone,
      ),
    ]);
    var definition = JSClassDefinitionPointer.allocate(
      version: 0,
      attributes: JSClassAttributes.kJSClassAttributeNone,
      className: 'flutter'.toNativeUtf8(),
      parentClass: null,
      staticValues: null,
      staticFunctions: staticFunctions,
      initialize: null,
      finalize: null,
      hasProperty: null,
      getProperty: null,
      setProperty: null,
      deleteProperty: null,
      getPropertyNames: null,
      callAsFunction: null,
      callAsConstructor: null,
      hasInstance: null,
      convertToType: null,
    );
    var flutterJSClass = jSClassCreate(definition);
    var flutterJSObject = jSObjectMake(globalContext, flutterJSClass, nullptr);

    Pointer<Utf8> flutterCString = 'flutter'.toNativeUtf8();

    jSObjectSetProperty(
      globalContext,
      globalObject,
      jSStringCreateWithUTF8CString(flutterCString),
      flutterJSObject,
      JSPropertyAttributes.kJSPropertyAttributeDontDelete,
      nullptr
    );

    malloc.free(flutterCString);
  }

  // 获取JsValue的值
  String _getJsValue(Pointer jsValueRef) {
    if (jSValueIsNull(globalContext, jsValueRef) == 1) {
      return 'null';
    } else if (jSValueIsUndefined(globalContext, jsValueRef) == 1) {
      return 'undefined';
    }
    var resultJsString =
        jSValueToStringCopy(globalContext, jsValueRef, nullptr);
    var resultCString = jSStringGetCharactersPtr(resultJsString);
    int resultCStringLength = jSStringGetLength(resultJsString);
    if (resultCString == nullptr) {
      return 'null';
    }
    String result = String.fromCharCodes(Uint16List.view(
      resultCString.cast<Uint16>().asTypedList(resultCStringLength).buffer,
      0,
      resultCStringLength)
    );
    jSStringRelease(resultJsString);
    return result;
  }

  Pointer _alert(
    Pointer ctx,
    Pointer function,
    Pointer thisObject,
    int argumentCount,
    Pointer<Pointer> arguments,
    Pointer<Pointer> exception
  ) {
    String msg = 'No Message';
    if (argumentCount != 0) {
      msg = '';
      for (int i = 0; i < argumentCount; i++) {
        var jsValueRef = arguments[i];
        msg += _getJsValue(jsValueRef);
      }
    }
    
    Future.delayed(Duration(milliseconds: 2000), () {
      _subscribeEvent(msg);
    });

    return nullptr;
  }

  /// 绑定flutter.print()函数
  static Pointer flutterPrint(
    Pointer ctx,
    Pointer function,
    Pointer thisObject,
    int argumentCount,
    Pointer<Pointer> arguments,
    Pointer<Pointer> exception
  ) {
    if (_printDartFunc != null) {
      _printDartFunc!(
          ctx, function, thisObject, argumentCount, arguments, exception);
    }
    return nullptr;
  }

  static JSObjectCallAsFunctionCallbackDart? _printDartFunc;

  Pointer _print(
    Pointer ctx,
    Pointer function,
    Pointer thisObject,
    int argumentCount,
    Pointer<Pointer> arguments,
    Pointer<Pointer> exception
  ) {
    if (argumentCount > 0) {
      print(_getJsValue(arguments[0]));
    }
    return nullptr;
  }
}