// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static m0(choice) => "${Intl.select(choice, {'ne': 'Account Name or E-mail', 'c': 'Account Cookie', 'i': 'Account Info', 'other': '', })}";

  static m1(action) => "${Intl.select(action, {'y': 'Yes', 'n': 'No', 'a': 'Apply', 'c': 'Cancel', 'other': '', })}";

  static m2(hintText) => "Please input ${hintText}";

  static m3(text) => "Invalid format of ${text}";

  static m4(isLiked) => "${Intl.select(isLiked, {'y': 'Cancel Bookmark', 'n': 'Bookmark', 'other': '', })}";

  static m5(operation) => "${Intl.select(operation, {'p': 'Prev', 'j': 'Jump', 'n': 'Next', 'i': 'Page', 'other': '', })}";

  static m6(choice) => "${Intl.select(choice, {'hostPath': 'Host Path', 'chooseColor': 'Click to select color you want to change', 'enable': 'Enable', 'proxy': 'Proxy', 'resverseProxy': 'Resverse Proxy', 'resverseProxyExample': 'Resverse Proxy (eg i.pximg.net)', 'downloadstyle': 'Download Style', 'concurrency': 'Concurrency', 'largerThanOne': 'Concurrency must large than 1', 'clientPool': 'ClientPool', 'add': 'Add', 'other': 'Select key error', })}";

  static m7(choice) => "${Intl.select(choice, {'basic': 'Basic Settings', 'theme': 'Theme Settings', 'search': 'Search Settings', 'performance': 'Performance Settings', 'webCrawler': 'WebCrawler Settings', 'other': 'Other Settings', 'about': 'About', })}";

  static m8(choice) => "${Intl.select(choice, {'system': 'System Theme', 'light': 'Light Theme', 'dark': 'Dark Theme', 'other': 'Select key error', })}";

  @override
  final Map<String, dynamic> messages = _notInlinedMessages(_notInlinedMessages);

  static Map<String, dynamic> _notInlinedMessages(_) => {
      'account': m0,
    'actions': m1,
    'appTitle': MessageLookupByLibrary.simpleMessage('Local Pixiv'),
    'inputHintText': m2,
    'invalidFormat': m3,
    'like': m4,
    'notFollowingWarn': MessageLookupByLibrary.simpleMessage('NOT FOLLOWING NOW!'),
    'openLink': MessageLookupByLibrary.simpleMessage('Open Link ?'),
    'page': m5,
    'setFontSize': MessageLookupByLibrary.simpleMessage('FontSize (This is an example.)'),
    'settingsContain': m6,
    'settingsTitle': m7,
    'theme': m8
  };
}
