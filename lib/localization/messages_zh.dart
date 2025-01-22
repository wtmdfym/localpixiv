// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
// messages from the main program should be duplicated here with the same
// function name.
// @dart=2.12
// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();

typedef String? MessageIfAbsent(
    String? messageStr, List<Object>? args);

class MessageLookup extends MessageLookupByLibrary {
  @override
  String get localeName => 'zh';

  static m0(choice) => "${Intl.select(choice, {'ne': '账户名称或邮箱', 'c': '账户Cookie', 'i': '账户信息', 'other': '', })}";

  static m1(action) => "${Intl.select(action, {'y': '是', 'n': '否', 'a': '应用', 'c': '取消', 'other': '', })}";

  static m2(choice) => "${Intl.select(choice, {'ef': '( ･ω･)☞   (:3 」∠)', 'ew': '输入作品ID', 'eu': '输入用户ID', 'ek': '输入关键词', 'er': '٩( ᐛ )و', 'ce': '连接错误：\n代理不可访问', 'ped': '请检查代理设置。', 'b': '开始', 's': '停止', 'c': '清除', 'cf': '关注', 'ci': 'ID', 'cu': '用户', 'ct': '标签', 'cr': '排名', 'other': '', })}";

  static m3(hintText) => "请输入 ${hintText}";

  static m4(text) => "${text} 格式无效";

  static m5(isLiked) => "${Intl.select(isLiked, {'y': '取消收藏', 'n': '收藏', 'other': '', })}";

  static m6(choice) => "${Intl.select(choice, {'ii': '无效的图像数据！图像文件可能已损坏。它将被自动删除。', 'ei': '图像加载错误', 'other': '', })}";

  static m7(operation) => "${Intl.select(operation, {'p': '上一页', 'j': '跳转', 'n': '下一页', 'i': '页码', 'other': '', })}";

  static m8(choice) => "${Intl.select(choice, {'hostPath': '主机路径', 'chooseColor': '点击选择要更改的颜色', 'enable': '启用', 'proxy': '代理', 'resverseProxy': '反向代理', 'resverseProxyExample': '反向代理 (例如 i.pximg.net)', 'downloadstyle': '下载样式', 'concurrency': '并发数', 'largerThanOne': '并发数必须大于1', 'clientPool': '客户端池', 'add': '添加', 'other': '选��键错误', })}";

  static m9(choice) => "${Intl.select(choice, {'basic': '基本设置', 'theme': '主题设置', 'search': '搜索设置', 'performance': '性能设置', 'webCrawler': '网络爬虫设置', 'other': '其他设置', 'about': '关于', })}";

  static m10(choice) => "${Intl.select(choice, {'system': '系统主题', 'light': '浅色主题', 'dark': '深色主题', 'other': '选择键错误', })}";

  static m11(choice) => "${Intl.select(choice, {'s': '搜索', 'as': '高级搜索', 'l': '加载中……', 'other': '', })}";

  @override
  final Map<String, dynamic> messages = _notInlinedMessages(_notInlinedMessages);

  static Map<String, dynamic> _notInlinedMessages(_) => {
      'account': m0,
    'actions': m1,
    'appTitle': MessageLookupByLibrary.simpleMessage('Localixiv'),
    'homePage': m2,
    'inputHintText': m3,
    'invalidFormat': m4,
    'like': m5,
    'loader': m6,
    'noMoreData': MessageLookupByLibrary.simpleMessage('没有更多数据'),
    'notFollowingWarn': MessageLookupByLibrary.simpleMessage('未关注！'),
    'openLink': MessageLookupByLibrary.simpleMessage('打开链接？'),
    'pageController': m7,
    'setFontSize': MessageLookupByLibrary.simpleMessage('字体大小 (这是一个示例)'),
    'settingsContain': m8,
    'settingsTitle': m9,
    'theme': m10,
    'viewerPage': m11
  };
}
