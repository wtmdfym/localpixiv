# localpixiv

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## 路线图
 - [x] 自动启动pythonapp
 - [ ] 实现不同数据需求的支持（id, tag......）
 - [x] image viewer
 - [ ] novel viewer
 - [x] following viewer
 - [ ] tag viewer
 - [x] settings
 - [x] 自定义图片缓存大小
 - [x] 自定义字体大小
 - [x] 多主题，暗色模式
 - [x] 多语言支持
 - [ ] 完整的高级搜索功能
 - [x] pixivcat代理
 - [ ] 数据分块加载
 - [x] 支持不使用mongoDB

## Update History
 - Version 1.1.3

    - 修复了bug。
    - 更换了多语言支持的方式，放弃使用Intl，改为使用Map。
    - 支持不使用mongoDb（仅有本地图片浏览功能）
 - Version 1.1.2

    - 移除了不必要的provider。
    - 修改了pageController。
    - 修改了控制整个tab显示的widget，修改了传递addtab信息的方式。
    - 实现了除了dialogs的组件的国际化。
 - Version 1.1.1

    - 修改了部分widget的颜色控制，以便适应自动的主题更改。
    - 调整了user信息的显示，添加InkWell效果，修复了一些bug。
    - 移除了不必要的动画。
    - 实现了TabHideStack。
    - 为LeftRightStack增加了折叠组件的功能，修复了鼠标指针显示错误的bug。
 - Version 1.1.0

    - 对设置界面和设置更新进行了调整。
    - 实现自定义主题，更改主题模式。
    - 实现了部分的国际化。
    - 修改了配置文件的结构。
    - 修改了项目结构。
    - 意外收获=>将LazyLoadIndexedStack改为StatefulWidget实现在更换主题等操作时保持State
 - Version 1.0.10

    - 实现了选择性rebulid（From https://github.com/fantasy525/should_rebuild）
    - 实现了LazyLoadIndexedStack，使用uniquekey解决了组件state丢失的问题。
    - 解决了画面溢出的问题。
 - Version 1.0.9

    - 为workContainer添加了InkWell效果。
    - 实现了可调整左右或上下比例的Stack组件，并封装为StatefulWidget。
    - 把翻页部件封装为StatefulWidget。
    - 实现了字体大小控制，使用全局设置。
    - 增强了UI的响应性。
    - 修复了一些bug
 - Version 1.0.8

    - 修改了Config的结构。
    - 修改了settings的结构。
    - 优化了settings的显示和交互。
    - 使用拖拽的方式取代双击打开作品详情页，交互更加流畅。
    - 删除了一些不必要的动画。
    - 为tabbar增加了向前和向后的按钮。
 - Version 1.0.7

    - 细节和bug修正。
    - 优化了userinfo的载入方法，减少卡顿和性能消耗。
    - 使用provider提供UI设置的更新和传递。
    - 实现了UIConfig的自动保存
    - 开始编写小说显示器的雏形（仅能显示简陋的信息）。
    - 实现了自定义图片缓存大小。
 - Version 1.0.6

    - 修复了控制台输出过多时程序卡死的问题。
    - 将图片异步加载显示的部件封装为单个widget。
    - 使用回调函数取代了部分Notification，同时减少了不必要的参数传递。
    - 实现了点击作者名字自动打开作者详情页。
    - 增加了对已取消关注的作者的标识。
    - 将默认数据移至单独的文件，方便管理和使用。
    - 使用了新的加载动画，整体更加流畅。
 - Version 1.0.5

    更换了组件的更新逻辑，修复了已知bug，修改了文件结构。
 - Version 1.0.4

    Implemented a tablike view with a cache function , and can be dynamically added and deleted , support for lazy loading .But the method is still need to be improved.
    Fixed bugs. Use Provider to replace Notification in stackChange and bookmark.
 - Version 1.0.3

    Optimised the project structure, fixed bugs, improved the followings state, added the test drag and drop function state
 - Version 1.0.2

    Implemented running pyapp in cmd, smooth search function (but advanced search is not completed), home, viewer interface is basically perfect, setting interface and configuration file is completed.
    Add auto search when click tag in infoshower and can manually close this function.
 - Version 1.0.1

    Optimised the project structure, improved the setting, added a homepage, implemented the ability to run python files and display console output.