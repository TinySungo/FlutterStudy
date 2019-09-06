## Flutter小记

[中文教程](https://flutterchina.club/tutorials/)



### 配置Flutter

#### 1. 克隆SDK到指定目录

`git clone -b stable https://github.com/flutter/flutter.git`

加速git clone的配置：

① Finder 前往文件夹（shift+command+G）输入 `/etc`

② etc目录下找到hosts文件，添加一下两行（若没有文件权限，自行更改）

```
151.101.72.249 github.global.ssl.fastly.net  
192.30.253.112 github.com
```

####2. 配置文件

不要用export命令，直接全局配置，不然之后会出现bash错误（直接配置.bash_profile）

1. 创建(若已经存在该文件，跳过这一步)：`cd ~/`      `touch .bash_profile`  
2. 打开文件：`open -e .bash_profile`
3. 修改文件末尾添加export(路径是你解压的SDK路径)：`export PATH=${PATH}:/Users/shen/flutter-1.9.6/bin`
4. 更新.bash_profile文件：`source .bash_profile`



#### 3. 运行

能正常运行 `flutter doctor` 则flutter安装完毕



### Xcode + VSCode

#### 1. VSCode 配置

####  https://flutterchina.club/get-started/editor/#vscode



推荐插件(左侧工具栏，🐞按钮下面)：

- Dart
- Flutter
- Flutter Widget Snippets（提供Widget代码片段）
- Awesome Flutter Snippets （提供常用函数代码片段）
- Bracket Pair Colorizer （代码高亮，嵌套较多时代码更清晰）
- GitLens （代码Git管理工具）





####2. 打开模拟器

`open -a Simulator`

### 新建应用

https://flutterchina.club/get-started/test-drive/#vscode （快捷键：shift + command + P）



------

至此  Flutter SDK下载安装，VSCode使用，新建项目并运行到模拟器结束

------



### 学习链接

[第三方组件库](https://pub.dev/)

Dart: [ 入门视频](https://www.imooc.com/learn/1035) [Dart2 中文文档](https://www.kancloud.cn/marswill/dark2_document/709091) [Dart2.3 版本发布](https://juejin.im/post/5cf352c1f265da1b904bca56)

[Flutter核心概念](https://juejin.im/post/5c768ad2f265da2dce1f535c)

[从零搭建 iOS Native Flutter 混合工程](https://juejin.im/post/5c3ae5ef518825242165c5ca)



###从项目中学习项目结构

[这里有超级多的demo](https://github.com/iampawan/FlutterExampleApps )

举例下载demo：[whatsApp](https://github.com/iampawan/FlutterWhatsAppClone.git) 注意：

1. 工程download/clone 之后，cd到工程目录，`flutter build ios` [编译错误导致原因](https://blog.csdn.net/u013560890/article/details/96476861)

    解决方案：打开ios目录下`Runner.xcworkspace` > `Build Phases` > `Embed Frameworks` 将App.framework和Flutter.framework 对应的 `Code Sign On Copy` 去掉勾选

   ```
   
   Showing Recent Messages
   :-1: Multiple commands produce '/Users/shen/Library/Developer/Xcode/DerivedData/Runner-fximlvsvxzauepfcfritpfreivqq/Build/Products/Debug-iphonesimulator/Runner.app/Frameworks/Flutter.framework':
   1) Target 'Runner' has copy command from '/Users/shen/Desktop/GitHub demo/FlutterWhatsAppClone/ios/Flutter/Flutter.framework' to '/Users/shen/Library/Developer/Xcode/DerivedData/Runner-fximlvsvxzauepfcfritpfreivqq/Build/Products/Debug-iphonesimulator/Runner.app/Frameworks/Flutter.framework'
   2) That command depends on command in Target 'Runner': script phase “[CP] Embed Pods Frameworks”
   ```

2. 直接 `flutter run` 会报错。查看错误信息明确需要在`cameras = await availableCameras();`之前添加`WidgetsFlutterBinding.ensureInitialized();`

   ```
   注意：如果在调用runApp()之前需要初始化插件，需要显示的调用WidgetsFlutterBinding.ensureInitialized(); // 此方法是对flutter的框架做一些必要的初始化
   ```

3. 真机运行时，常出现 `Lost connection to device.` 导致连接断掉

   解决方案：`brew install --HEAD usbmuxd`

4. 注意项目中使用到了相机，记得在ios工程 `info.plist` 中添加 `Privacy - Camera Usage Description`

