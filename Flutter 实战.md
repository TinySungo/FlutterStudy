



## Flutter 实战小记

[官方实践](https://book.flutterchina.club/chapter2/flutter_router.html)

[很棒的资源列表](http://www.devio.org/2018/09/09/awesome-flutter/)

可在App Store下载Fluttergo学习常用Widget。源码地址： [阿里拍卖Fluttergo](https://github.com/alibaba/flutter-go)

###pageController > PageView / TabbarView

###抽屉 > Drawer / EndDrawer

###tabbarController > BottomNavigationBar (BottomNavigationBarItem)

[防止切换时重绘](https://www.jianshu.com/p/5077a1f86154)  使用IndexedStack组件



###路由 和 Navigator(push/pop)

[Dart异步编程详解](https://juejin.im/post/5cdbf2e3f265da035632570e)

`注意：在写pop时注意确保context是要关闭的页面`

```
路由定义：
final Map<String, WidgetBuilder> routes;
typedef WidgetBuilder = Widget Function(BuildContext context);
```

路由钩子：作用类似，可用于一些条件的拦截以及判断




### 包管理 (cocoapods) 

`pubspec.yaml`

`dependencies `中添加依赖库保存，VSCode会自动运行 `flutter package get`



###项目搭建Package

网络请求 ： `dio: ^2.1.16` [超级详细关于Dio的使用说明](https://segmentfault.com/a/1190000015853959)

json解析：`json_annotation: ^3.0.0`

1. json => model: https://caijinglong.github.io/json2dart/index_ch.html (这个工具记得类名小写)项目根目录 
2. `flutter packages pub run build_runner build` （注意文件名的大小写一致）

加载提示HUD :  `flutter_spinkit: "^4.0.0"`

网络图片缓存：`cached_network_image: ^1.1.1`

Toast：`fluttertoast: ^3.1.2`

Refresh:  `flutter_easyrefresh: ^2.0.4`





## 布局

#### Row & Column

以Row为例：（Column的主轴为Y，纵轴是X。都是继承自Flex）

- mainAxisSize: 决定row的水平占用空间（max: 可以理解为一屏， min:可以理解为子组件的合计）
- textDirection：排列开始方向（rtl: 从右侧开始， ltr:从左侧开始）
- mainAxisAlignment： mainAxisSize.max有效，(start, center, end 对应textDirection的方向)
- verticalDirection：纵轴对齐方式（down, up）
- crossAxisAlignment：纵轴子组件对齐方式，Row高度是子组件中最高元素的高度（start, center, end）

```
textDirection 是 mainAxisAlignment的参考系
verticalDirection 是 crossAxisAlignment 的参考系
Row/Column 嵌套时，mainAxisSize=max 只有最外层有效
```



#### Flex & Expanded

- Flex - direction：弹性布局方向， Row=水平， Column=垂直， 其他参数与Row/Column一致
- Expand：按比例拉伸Flex



#### Wrap 

流式布局：超出屏幕部分自动折行

- spacing : 主轴方向的间距

-  runSpacing : 纵轴方向的间距

- alignment : 主轴方向的对齐方式

- runAlignment : 纵轴方向的对齐方式

  

#### FLow

较为复杂，优先考虑Wrap实现

- FlowDelegate 中 paintChildren() 方法

### 

#### 数据共享

- 保存共享数据： `InheritedWidget`（能够绑定与子孙组件的依赖关系） 
- 数据发生变化时，发送通知：`ChangeNotifier`（需要共享的数据放到Model中，继承自ChangeNotifier）
- 订阅者来重构，一般定义 `of() `方法方便子树widget获取共享数据



###Provider  

- [Provider ](https://juejin.im/post/5d00a84fe51d455a2f22023f)

**StatefulWidget** 是Flutter 提供的状态管理方式





#### 基本概念

- **https://juejin.im/post/5c768ad2f265da2dce1f535c**





[从0到1开发掘金APP](https://juejin.im/post/5c910bd55188252da05f3f05)

瀑布流：pub => flutter_staggered_grid_view

List headerView 缩放：https://juejin.im/post/5bebcc44f265da61682aedb8