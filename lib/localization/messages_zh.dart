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

  static m0(index) => "${Intl.select(index, {'a': '优', 'b': '良', 'c': '中', 'd': '及格', 'e': '不及格', 'other': '', })}";

  static m1(index) => "${Intl.select(index, {'a': '百分制成绩', 'b': '五级制成绩', 'c': '两级制成绩', 'd': '补考、重修', 'other': '', })}";

  static m2(choice) => "${Intl.select(choice, {'auto': '跟随系统', 'light': '亮色主题', 'dark': '暗色主题', 'other': '', })}";

  static m3(index) => "${Intl.select(index, {'p': '合格', 'f': '不合格', 'other': '', })}";

  @override
  final Map<String, dynamic> messages = _notInlinedMessages(_notInlinedMessages);

  static Map<String, dynamic> _notInlinedMessages(_) => {
      'appBarTitle': MessageLookupByLibrary.simpleMessage('重庆大学平均绩点计算器'),
    'appTitle': MessageLookupByLibrary.simpleMessage('Flutter APP'),
    'creditGradePoint': MessageLookupByLibrary.simpleMessage('学分绩点'),
    'creditInput': MessageLookupByLibrary.simpleMessage('学分'),
    'fivePoint': m0,
    'gradePoint': MessageLookupByLibrary.simpleMessage('绩点'),
    'scoreInput': MessageLookupByLibrary.simpleMessage('分数'),
    'scoreType': m1,
    'theme': m2,
    'twoLevel': m3
  };
}
