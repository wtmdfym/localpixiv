import 'dart:convert';

import 'package:flutter/material.dart';

import '../../common/tools.dart';
import '../../localization/localization_intl.dart';
import '../../models.dart';
import '../../widgets/dialogs.dart';
import '../back_appbar.dart';
import '../settings_controller.dart';
import '../tools.dart';

/// Pixiv webCrawler settings.
class WebCrawlerSettingsPage extends StatefulWidget {
  const WebCrawlerSettingsPage({super.key, required this.controller});
  static const routeName = '/webCrawler';
  final SettingsController controller;
  @override
  State<StatefulWidget> createState() => _WebCrawlerSettingsPageState();
}

class _WebCrawlerSettingsPageState extends State<WebCrawlerSettingsPage> {
  // cookie
  final TextEditingController _cookiecontroller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // 删除Client
  void _removeClient(int index) {
    setState(() {
      widget.controller.webCrawlerSettings.clientPool.removeAt(index);
    });
  }

  @override
  void dispose() {
    _cookiecontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final WebCrawlerSettings webCrawlerSettings =
        widget.controller.webCrawlerSettings;
    _cookiecontroller.text = webCrawlerSettings.cookies.toString();
    String Function(String hintText) getinputHintText =
        MyLocalizations.of(context).inputHintText;
    String Function(String hintText) getiinvalidFormatText =
        MyLocalizations.of(context).invalidFormat;
    String Function(String choice) getText =
        MyLocalizations.of(context).settingsContain;
    return Scaffold(
        appBar: BackAppBar(
          title: MyLocalizations.of(context).settingsTitle('webCrawler'),
        ),
        body: Form(
            key: _formKey,
            canPop: true,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop = true) {
                // 验证表单
                if (_formKey.currentState!.validate()) {
                  // 保存表单数据
                  _formKey.currentState!.save();
                  //widget.controller.updateWebCrawlerSettings(newWebCrawlerSettings);
                }
              }
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: SingleChildScrollView(
                child: Padding(
                    padding:const EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 20,
                      children: [
                        TextFormField(
                          controller: _cookiecontroller,
                          minLines: 5,
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: 'Cookies',
                            hintText: getinputHintText('Cookies'),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return getinputHintText('Cookies');
                            } else if (value !=
                                webCrawlerSettings.cookies.toString()) {
                              Map<String, String> formatted =
                                  cookiesFormater(value);
                              if (formatted['PHPSESSID'] == null) {
                                return getiinvalidFormatText('Cookies');
                              } else {
                                _cookiecontroller.text = formatted.toString();
                                return null;
                              }
                            } else {
                              return null;
                            }
                          },
                          onSaved: (newValue) {
                            if (newValue !=
                                webCrawlerSettings.cookies.toString()) {
                              webCrawlerSettings.cookies =
                                  Cookies.fromJson(cookiesFormater(newValue!));
                            }
                          },
                        ),
                        SwitchListTile(
                          title: Text(
                            '${getText('enable')} ${getText('proxy')}',
                          ),
                          value: webCrawlerSettings.enableProxy,
                          onChanged: (value) {
                            setState(() {
                              webCrawlerSettings.enableProxy = value;
                            });
                          },
                        ),
                        TextFormField(
                          initialValue: webCrawlerSettings.httpProxies,
                          maxLength: 30,
                          decoration: getInputDecoration(
                              'Http ${getText('proxy')}',
                              getinputHintText('Http ${getText('proxy')}')),
                          enabled: webCrawlerSettings.enableProxy,
                          onChanged: (value) {
                            // 处理文本变化
                          },
                          validator: (value) {
                            if (webCrawlerSettings.enableProxy) {
                              if (value == null || value.isEmpty) {
                                return getinputHintText(
                                    'Http ${getText('proxy')}');
                              } else {
                                var ipv4re = RegExp(
                                    r'http://((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})(\.((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})){3}:\d{1,5}');
                                var localhostre =
                                    RegExp(r'http://localhost:\d{1,5}');
                                // TODO ipv6 (?<=]:).*\w+
                                if (value.replaceAll(ipv4re, '').isNotEmpty &&
                                    value
                                        .replaceAll(localhostre, '')
                                        .isNotEmpty) {
                                  return getiinvalidFormatText(
                                      'Http ${getText('proxy')}');
                                }
                              }
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            if (webCrawlerSettings.enableProxy) {
                              webCrawlerSettings.httpProxies = newValue!;
                            }
                          },
                        ),
                        TextFormField(
                          initialValue: webCrawlerSettings.httpsProxies,
                          maxLength: 30,
                          decoration: getInputDecoration(
                              'Https ${getText('proxy')}',
                              getinputHintText(getText('proxy'))),
                          enabled: webCrawlerSettings.enableProxy,
                          onChanged: (value) {
                            // 处理文本变化
                          },
                          validator: (value) {
                            if (webCrawlerSettings.enableProxy) {
                              if (value == null || value.isEmpty) {
                                return getinputHintText(
                                    'Https ${getText('proxy')}');
                              } else {
                                var regExp1 = RegExp(
                                    r'http://((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})(\.((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})){3}:\d{1,5}');
                                var localhostre =
                                    RegExp(r'http://localhost:\d{1,5}');
                                if (value.replaceAll(regExp1, '').isNotEmpty &&
                                    value
                                        .replaceAll(localhostre, '')
                                        .isNotEmpty) {
                                  return getiinvalidFormatText(
                                      'Https ${getText('proxy')}');
                                }
                              }
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            if (webCrawlerSettings.enableProxy) {
                              webCrawlerSettings.httpsProxies = newValue!;
                            }
                          },
                        ),
                        SwitchListTile(
                          title: Text(
                            '${getText('enable')} ${getText('resverseProxy')}',
                          ),
                          value: webCrawlerSettings.enableIPixiv,
                          onChanged: (value) {
                            setState(() {
                              webCrawlerSettings.enableIPixiv = value;
                            });
                          },
                        ),
                        TextFormField(
                          initialValue: webCrawlerSettings.ipixivHostPath,
                          maxLength: 30,
                          decoration: getInputDecoration(
                              getText('resverseProxyExample'),
                              getinputHintText(getText('resverseProxy'))),
                          enabled: webCrawlerSettings.enableIPixiv,
                          onChanged: (value) {
                            // 处理文本变化
                          },
                          validator: (value) {
                            if (webCrawlerSettings.enableIPixiv) {
                              if (value == null || value.isEmpty) {
                                return getinputHintText(
                                    getText('resverseProxy'));
                              } else {
                                return null;
                              }
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            if (webCrawlerSettings.enableIPixiv) {
                              webCrawlerSettings.ipixivHostPath = newValue!;
                            }
                          },
                        ),
                        Text(
                          getText('downloadstyle'),
                        ),
                        CheckboxListTile(
                          title: Text(
                            'Illust',
                          ),
                          value: webCrawlerSettings.downloadType.illust,
                          onChanged: (value) {
                            setState(() {
                              webCrawlerSettings.downloadType.illust = value!;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text(
                            'Manga',
                          ),
                          value: webCrawlerSettings.downloadType.manga,
                          onChanged: (value) {
                            setState(() {
                              webCrawlerSettings.downloadType.manga = value!;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text(
                            'Novel',
                          ),
                          value: webCrawlerSettings.downloadType.novel,
                          onChanged: (value) {
                            setState(() {
                              webCrawlerSettings.downloadType.novel = value!;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text(
                            'Ugoira',
                          ),
                          value: webCrawlerSettings.downloadType.ugoira,
                          onChanged: (value) {
                            setState(() {
                              webCrawlerSettings.downloadType.ugoira = value!;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text(
                            'Series',
                          ),
                          value: webCrawlerSettings.downloadType.series,
                          onChanged: (value) {
                            setState(() {
                              webCrawlerSettings.downloadType.series = value!;
                            });
                          },
                        ),
                        TextFormField(
                          initialValue: '2',
                          maxLength: 2,
                          decoration: getInputDecoration(getText('concurrency'),
                              getinputHintText(getText('concurrency'))),
                          onChanged: (value) {
                            // 处理文本变化
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return getinputHintText(getText('concurrency'));
                            } else {
                              if (RegExp(r'\d{1,2}').matchAsPrefix(value) ==
                                  null) {
                                return getinputHintText(getText('number'));
                              } else {
                                if (int.parse(value) < 1) {
                                  return getText('largerThanOne');
                                }
                              }
                            }
                            return null;
                          },
                          onSaved: (newValue) => webCrawlerSettings.semaphore =
                              int.parse(newValue!),
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 200,
                            children: [
                              Expanded(
                                  child: SwitchListTile(
                                title: Text(
                                  '${getText('enable')} ${getText('clientPool')}',
                                ),
                                value: webCrawlerSettings.enableClientPool,
                                onChanged: (value) {
                                  // 重新构建页面
                                  setState(() {
                                    webCrawlerSettings.enableClientPool = value;
                                  });
                                },
                              )),
                              // 添加按钮
                              ElevatedButton(
                                onPressed: () => webCrawlerSettings
                                        .enableClientPool
                                    ? addClient(context).then((value) {
                                        setState(() {
                                          //print(value);
                                          String clientInfo = value;
                                          if (clientInfo.isNotEmpty) {
                                            webCrawlerSettings.clientPool.add(
                                                ClientPool.fromJson(
                                                    jsonDecode(clientInfo)));
                                          }
                                        });
                                      })
                                    : {},
                                child: Text(
                                  getText('add'),
                                ),
                              ),
                            ]),
                        Offstage(
                            offstage: !webCrawlerSettings.enableClientPool,
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 200,
                                  // 使用 ListView.builder 来构建列表
                                  child: ListView.builder(
                                    itemExtent: 60,
                                    itemCount:
                                        webCrawlerSettings.clientPool.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        title: Text(
                                          'Email: ${webCrawlerSettings.clientPool[index]!.email}  ||  Cookies: ${webCrawlerSettings.clientPool[index]!.cookies.toString()}',
                                        ),
                                        trailing: IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            _removeClient(index);
                                            webCrawlerSettings.clientPool
                                                .removeAt(index);
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            )),
                      ],
                    )))));
  }
}
