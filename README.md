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
 - [ ] 与pythonapp的通信
 - [x] image viewer
 - [ ] noval viewer
 - [x] following viewer
 - [x] settings
 - [ ] pixivcat代理
 - [ ] 数据分块加载
 - [ ] 支持不使用mongoDB
## Update History
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