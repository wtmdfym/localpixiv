import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:localpixiv/common/tools.dart';
import 'package:toastification/toastification.dart';

//高级搜索输入框
void advancedSearch(BuildContext context) {
  Map<String, dynamic> submitContent = {};
  final andkeywords = TextEditingController();
  final notkeywords = TextEditingController();
  final orkeywords = TextEditingController();
  ValueNotifier<String> searchType = ValueNotifier('illust,manga,ugiroa');
  ValueNotifier<String> searchRange = ValueNotifier('tag(partly)');
  ValueNotifier<bool> originalOnly = ValueNotifier(false);
  ValueNotifier<bool> r18 = ValueNotifier(false);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Advanced Search'),
        content: SizedBox(
            height: 640,
            width: 1080,
            child: Column(spacing: 30, children: [
              TextField(
                controller: andkeywords,
                style: TextStyle(
                  fontSize: 25,
                ),
                decoration: InputDecoration(
                  hintText: '必须含有的关键词(使用空格分开)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
              TextField(
                controller: notkeywords,
                style: TextStyle(
                  fontSize: 25,
                ),
                decoration: InputDecoration(
                  hintText: '不含有的关键词(使用空格分开)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
              TextField(
                controller: orkeywords,
                style: TextStyle(
                  fontSize: 25,
                ),
                decoration: InputDecoration(
                  hintText: '可含有的关键词(使用空格分开)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 155,
                  children: [
                    Text(
                      'Search Range',
                      style: TextStyle(fontSize: 25),
                    ),
                    ValueListenableBuilder(
                        valueListenable: searchType,
                        builder: (context, value, child) =>
                            DropdownButton<String>(
                              value: value,
                              onChanged: (value) => searchType.value = value!,
                              items: <String>[
                                /*'插画、漫画、动图（动态插画）',
                                  '插画、动图',
                                  '插画',
                                  '漫画',
                                  '动图'*/
                                'illust,manga,ugiroa',
                                'illust,manga',
                                'illust',
                                'manga',
                                'ugiroa',
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(fontSize: 25),
                                  ),
                                );
                              }).toList(),
                            )),
                    ValueListenableBuilder(
                        valueListenable: searchRange,
                        builder: (context, value, child) =>
                            DropdownButton<String>(
                              value: value,
                              onChanged: (value) => searchRange.value = value!,
                              items: <String>[
                                /*'标签（部分一致）',
                                  '标签（完全一致）',
                                  '标题、说明文字',*/
                                'tag(partly)',
                                'tag(absolutely)',
                                'title,description',
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(fontSize: 25),
                                  ),
                                );
                              }).toList(),
                            )),
                  ]),
              ValueListenableBuilder(
                  valueListenable: originalOnly,
                  builder: (context, value, child) => SwitchListTile(
                        title: Text(
                          'original only',
                          style: TextStyle(fontSize: 25),
                        ),
                        value: value, //当前状态
                        onChanged: (value) {
                          originalOnly.value = value;
                        },
                      )),
              ValueListenableBuilder(
                  valueListenable: r18,
                  builder: (context, value, child) => SwitchListTile(
                        title: Text(
                          'R-18',
                          style: TextStyle(fontSize: 25),
                        ),
                        value: value, //当前状态
                        onChanged: (value) {
                          r18.value = value;
                        },
                      )),
            ])),
        actions: <Widget>[
          TextButton(
            child: Text('apply',
                style: TextStyle(
                  fontSize: 25,
                )),
            onPressed: () {
              submitContent.addAll({
                'AND': andkeywords.text.split(RegExp(r'\s+')),
                'NOT': notkeywords.text.split(RegExp(r'\s+')),
                'OR': orkeywords.text.split(RegExp(r'\s+')),
                'searchType': searchType.value,
                'searchRange': searchRange.value,
                'originalOnly': originalOnly.value,
                'R-18': r18.value,
              });
              print('输入的文本是: $submitContent');
              Navigator.of(context).pop(); // 关闭对话框
            },
          ),
          TextButton(
            child: Text('cancel',
                style: TextStyle(
                  fontSize: 25,
                )),
            onPressed: () {
              Navigator.of(context).pop(); // 关闭对话框
            },
          ),
        ],
      );
    },
  );
}
/*
可不要
//日期选择框
void _selectDate(BuildContext context) {
  showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1900),
    lastDate: DateTime(2100),
  ).then((DateTime? pickedDate) {
    if (pickedDate != null) {

    }
  });
}*/

// 添加Client
Future<String> addClient(
  BuildContext context,
) async {
  Map<String, dynamic> clientInfo = {};
  final accountNameController = TextEditingController();
  final accountCookieController = TextEditingController();
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Account Info'),
        content: SizedBox(
            height: 640,
            width: 1080,
            child: Column(spacing: 30, children: [
              TextField(
                controller: accountNameController,
                style: TextStyle(
                  fontSize: 25,
                ),
                decoration: InputDecoration(
                  hintText: '输入账号名或E-mail地址',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
                onSubmitted: (value) {
                  // 处理输入的文本
                  // print('输入的文本是: $value');
                  Navigator.of(context).pop(); // 关闭对话框
                },
              ),
              TextField(
                controller: accountCookieController,
                minLines: 10,
                maxLines: 10,
                style: TextStyle(
                  fontSize: 25,
                ),
                decoration: InputDecoration(
                  hintText: '输入账号的Cookies',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
                onSubmitted: (value) {
                  // 处理输入的文本
                  //print('输入的文本是: $value');
                  Navigator.of(context).pop(); // 关闭对话框
                },
              ),
            ])),
        actions: <Widget>[
          TextButton(
            child: Text('确定',
                style: TextStyle(
                  fontSize: 25,
                )),
            onPressed: () {
              Map<String, String> cookies =
                  cookiesFormater(accountCookieController.text);
              if (accountNameController.text.isNotEmpty && cookies.isNotEmpty) {
                clientInfo = {
                  'email': accountNameController.text,
                  'cookies': cookies
                };
              }
              Navigator.of(context).pop(); // 关闭对话框
            },
          ),
          TextButton(
            child: Text('取消',
                style: TextStyle(
                  fontSize: 25,
                )),
            onPressed: () {
              Navigator.of(context).pop(); // 关闭对话框
            },
          ),
        ],
      );
    },
  );
  //TODO 检查是否可用
  if (clientInfo.isNotEmpty) {
    return jsonEncode(clientInfo);
  } else {
    return '';
  }
}

void resultDialog(BuildContext context, String operation, bool success) {
  toastification.show(
      context: context,
      type: success ? ToastificationType.success : ToastificationType.error,
      style: ToastificationStyle.flatColored,
      alignment: Alignment.bottomLeft,
      autoCloseDuration: Duration(seconds: 3),
      title: Text(
        success ? '$operation successful' : '$operation failed',
      ));
  /*
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(
              success ? '$operation successful' : '$operation failed',
              textAlign: TextAlign.center,
            ),
            titleTextStyle: TextStyle(
                color: success ? Colors.black : Colors.redAccent, fontSize: 20),
          ));*/
}
