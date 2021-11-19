# Flutter Miniprogram

Flutter项目搭建小程序底层架构项目

## Getting Started

- Flutter verison 2.2.2
- Dart version 2.13.3 (null safety)

## Describe

当前项目由0-1正推小程序底层架构搭建演变方式。

```
  |- lib
    |- hall               // 演变主页，阶段性版本新建一个目录，并在 lib/hall/hall_page.dart 中添加一个入口访问
       |- temporary         // 临时目录，用户代码调试使用。
       |- jscore            // 演变一：jscore绑定运行演示
       |- server            // 演变二：启动server演示、演示读取本地文件
       |- serverAndView     // 演变三：结合server和jscore，server读取本地html+css，jscore运行js文件，webview进行展示，添加通讯系统
       |- route             // 演变四：基于演变三、添加路由系统
    |- jsBridget          // jsBridget实体类
    |- utils                // 目前抽离的公共类都在这里
       |- history           // 小程序路由管理（未完成）
       |- javascriptChannel // webview channel
       |- jsEnv             // js-core environment
       |- server            // 启动server公共服务
       |- utils             // 公共方法
       |- webview           // webview 封装
    |- main                 // entry
``` 


## About

- [开发小组文档(语雀)](https://www.yuque.com/tatgr4)