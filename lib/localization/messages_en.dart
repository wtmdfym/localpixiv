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

  static m0(hintText) => "Please input ${hintText}";

  static m1(text) => "Invalid format of ${text}";

  static m2(choice) => "${Intl.select(choice, {'hostPath': 'Host Path', 'chooseColor': 'Click to select color you want to change', 'enable': 'Enable', 'proxy': 'Proxy', 'resverseProxy': 'Resverse Proxy', 'resverseProxyExample': 'Resverse Proxy (eg i.pximg.net)', 'downloadstyle': 'Download Style', 'concurrency': 'Concurrency', 'largerThanOne': 'Concurrency must large than 1', 'clientPool': 'ClientPool', 'add': 'Add', 'other': 'Select key error', })}";

  static m3(choice) => "${Intl.select(choice, {'basic': 'Basic Settings', 'theme': 'Theme Settings', 'search': 'Search Settings', 'performance': 'Performance Settings', 'webCrawler': 'WebCrawler Settings', 'other': 'Other Settings', })}";

  static m4(choice) => "${Intl.select(choice, {'system': 'System Theme', 'light': 'Light Theme', 'dark': 'Dark Theme', 'other': '', })}";

  @override
  final Map<String, dynamic> messages = _notInlinedMessages(_notInlinedMessages);

  static Map<String, dynamic> _notInlinedMessages(_) => {
      'appTitle': MessageLookupByLibrary.simpleMessage('Local Pixiv'),
    'inputHintText': m0,
    'invalidFormat': m1,
    'setFontSize': MessageLookupByLibrary.simpleMessage('FontSize (This is an example.)'),
    'settingsContain': m2,
    'settingsTitle': m3,
    'theme': m4
  };
}
