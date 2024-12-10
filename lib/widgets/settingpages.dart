import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import 'package:localpixiv/common/customnotifier.dart';
import 'package:localpixiv/common/tools.dart';
import 'package:localpixiv/widgets/dialogs.dart';
import 'package:localpixiv/models.dart';

class BasicSettingsPage extends StatefulWidget {
  const BasicSettingsPage({super.key, required this.configs});
  final Configs configs;
  @override
  State<StatefulWidget> createState() => _BasicSettingsPageState();
}

class _BasicSettingsPageState extends State<BasicSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, spacing: 20, children: [
      // 基本设置
      Text(
        'Basic Settings',
        style: TextStyle(
          fontSize: 20,
        ),
      ),
      TextFormField(
        initialValue: widget.configs.basicConfigs.savePath,
        maxLength: 100,
        style: TextStyle(
          fontSize: 20,
        ),
        decoration: getInputDecoration('Save Path'),
        validator: (value) {
          var pathre = RegExp(r'^[C-Z]\:[\\,\/].*');
          if (value == null || value.isEmpty) {
            return '请输入Save Path';
          } else if (pathre.hasMatch(value)) {
            return null;
          } else {
            return 'Path 格式错误';
          }
        },
        onSaved: (newValue) => widget.configs.basicConfigs.savePath = newValue!,
      ),
    ]);
  }
}

class WebCrawlerSettingsPage extends StatefulWidget {
  const WebCrawlerSettingsPage({super.key, required this.configs});
  final Configs configs;
  @override
  State<StatefulWidget> createState() => _WebCrawlerSettingsPageState();
}

class _WebCrawlerSettingsPageState extends State<WebCrawlerSettingsPage> {
  // cookie
  late final TextEditingController _cookiecontroller;
  // 删除Client
  void _removeClient(int index) {
    setState(() {
      widget.configs.webCrawlerConfigs.clientPool.removeAt(index);
    });
  }

  @override
  void initState() {
    _cookiecontroller = TextEditingController(
        text: widget.configs.webCrawlerConfigs.cookies.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 20,
      children: [
        // pixiv爬虫相关设置
        Text(
          'Web Crawler Settings',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        TextFormField(
          controller: _cookiecontroller,
          minLines: 5,
          maxLines: 5,
          style: TextStyle(
            fontSize: 20,
          ),
          decoration: InputDecoration(
            labelStyle: TextStyle(fontSize: 24),
            labelText: 'Cookies',
            hintText: '请输入你要爬取的账号的Cookies',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入Cookies';
            } else if (value !=
                widget.configs.webCrawlerConfigs.cookies.toString()) {
              Map<String, String> formatted = cookiesFormater(value);
              if (formatted['PHPSESSID'] == null) {
                return 'Cookies值错误';
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
                widget.configs.webCrawlerConfigs.cookies.toString()) {
              widget.configs.webCrawlerConfigs.cookies =
                  Cookies.fromJson(cookiesFormater(newValue!));
            }
          },
        ),
        SwitchListTile(
          title: Text(
            'Enable Proxy',
            style: TextStyle(fontSize: 20),
          ),
          value: widget.configs.webCrawlerConfigs.enableProxy,
          onChanged: (value) {
            setState(() {
              widget.configs.webCrawlerConfigs.enableProxy = value;
            });
          },
        ),
        TextFormField(
          initialValue: widget.configs.webCrawlerConfigs.httpProxies,
          maxLength: 30,
          style: TextStyle(
            fontSize: 20,
          ),
          decoration: getInputDecoration('Http Proxy'),
          enabled: widget.configs.webCrawlerConfigs.enableProxy,
          onChanged: (value) {
            // 处理文本变化
          },
          validator: (value) {
            if (widget.configs.webCrawlerConfigs.enableProxy) {
              if (value == null || value.isEmpty) {
                return '请输入Http Proxy';
              } else {
                var ipv4re = RegExp(
                    r'http://((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})(\.((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})){3}:\d{1,5}');
                var localhostre = RegExp(r'http://localhost:\d{1,5}');
                // TODO ipv6 (?<=]:).*\w+
                if (value.replaceAll(ipv4re, '').isNotEmpty &&
                    value.replaceAll(localhostre, '').isNotEmpty) {
                  return 'Http Proxy 格式错误';
                }
              }
            }
            return null;
          },
          onSaved: (newValue) {
            if (widget.configs.webCrawlerConfigs.enableProxy) {
              widget.configs.webCrawlerConfigs.httpProxies = newValue!;
            }
          },
        ),
        TextFormField(
          initialValue: widget.configs.webCrawlerConfigs.httpsProxies,
          maxLength: 30,
          style: TextStyle(
            fontSize: 20,
          ),
          decoration: getInputDecoration('Https Proxy'),
          enabled: widget.configs.webCrawlerConfigs.enableProxy,
          onChanged: (value) {
            // 处理文本变化
          },
          validator: (value) {
            if (widget.configs.webCrawlerConfigs.enableProxy) {
              if (value == null || value.isEmpty) {
                return '请输入Https Proxy';
              } else {
                var regExp1 = RegExp(
                    r'http://((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})(\.((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})){3}:\d{1,5}');
                var localhostre = RegExp(r'http://localhost:\d{1,5}');
                if (value.replaceAll(regExp1, '').isNotEmpty &&
                    value.replaceAll(localhostre, '').isNotEmpty) {
                  return 'Https Proxy 格式错误';
                }
              }
            }
            return null;
          },
          onSaved: (newValue) {
            if (widget.configs.webCrawlerConfigs.enableProxy) {
              widget.configs.webCrawlerConfigs.httpsProxies = newValue!;
            }
          },
        ),
        SwitchListTile(
          title: Text(
            'Enable Pixiv Resverse Proxy',
            style: TextStyle(fontSize: 20),
          ),
          value: widget.configs.webCrawlerConfigs.enableIPixiv,
          onChanged: (value) {
            setState(() {
              widget.configs.webCrawlerConfigs.enableIPixiv = value;
            });
          },
        ),
        TextFormField(
          initialValue: widget.configs.webCrawlerConfigs.ipixivHostPath,
          maxLength: 30,
          style: TextStyle(
            fontSize: 20,
          ),
          decoration: getInputDecoration('Resverse Proxy (eg i.pximg.net)'),
          enabled: widget.configs.webCrawlerConfigs.enableIPixiv,
          onChanged: (value) {
            // 处理文本变化
          },
          validator: (value) {
            if (widget.configs.webCrawlerConfigs.enableIPixiv) {
              if (value == null || value.isEmpty) {
                return '请输入Resverse Proxy';
              } else {
                return null;
              }
            }
            return null;
          },
          onSaved: (newValue) {
            if (widget.configs.webCrawlerConfigs.enableIPixiv) {
              widget.configs.webCrawlerConfigs.ipixivHostPath = newValue!;
            }
          },
        ),
        Text(
          'Download Style',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        CheckboxListTile(
          title: Text(
            'Illust',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          value: widget.configs.webCrawlerConfigs.downloadType.illust,
          onChanged: (value) {
            setState(() {
              widget.configs.webCrawlerConfigs.downloadType.illust = value!;
            });
          },
        ),
        CheckboxListTile(
          title: Text(
            'Manga',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          value: widget.configs.webCrawlerConfigs.downloadType.manga,
          onChanged: (value) {
            setState(() {
              widget.configs.webCrawlerConfigs.downloadType.manga = value!;
            });
          },
        ),
        CheckboxListTile(
          title: Text(
            'Novel',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          value: widget.configs.webCrawlerConfigs.downloadType.novel,
          onChanged: (value) {
            setState(() {
              widget.configs.webCrawlerConfigs.downloadType.novel = value!;
            });
          },
        ),
        CheckboxListTile(
          title: Text(
            'Ugoira',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          value: widget.configs.webCrawlerConfigs.downloadType.ugoira,
          onChanged: (value) {
            setState(() {
              widget.configs.webCrawlerConfigs.downloadType.ugoira = value!;
            });
          },
        ),
        CheckboxListTile(
          title: Text(
            'Series',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          value: widget.configs.webCrawlerConfigs.downloadType.series,
          onChanged: (value) {
            setState(() {
              widget.configs.webCrawlerConfigs.downloadType.series = value!;
            });
          },
        ),
        TextFormField(
          initialValue: '2',
          maxLength: 2,
          style: TextStyle(
            fontSize: 20,
          ),
          decoration: getInputDecoration('Concurrency'),
          onChanged: (value) {
            // 处理文本变化
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入并发数';
            } else {
              if (RegExp(r'\d{1,2}').matchAsPrefix(value) == null) {
                return '请输入数字';
              } else {
                if (int.parse(value) < 1) {
                  return '并发数不能小于1';
                }
              }
            }
            return null;
          },
          onSaved: (newValue) =>
              widget.configs.webCrawlerConfigs.semaphore = int.parse(newValue!),
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 200,
            children: [
              Expanded(
                  child: SwitchListTile(
                title: Text(
                  'Enable Client Pool',
                  style: TextStyle(fontSize: 20),
                ),
                value: widget.configs.webCrawlerConfigs.enableClientPool,
                onChanged: (value) {
                  // 重新构建页面
                  setState(() {
                    widget.configs.webCrawlerConfigs.enableClientPool = value;
                  });
                },
              )),
              // 添加按钮
              ElevatedButton(
                onPressed: () => widget
                        .configs.webCrawlerConfigs.enableClientPool
                    ? addClient(context).then((value) {
                        setState(() {
                          //print(value);
                          String clientInfo = value;
                          if (clientInfo.isNotEmpty) {
                            widget.configs.webCrawlerConfigs.clientPool.add(
                                ClientPool.fromJson(jsonDecode(clientInfo)));
                          }
                        });
                      })
                    : {},
                child: Text('Add Client',
                    style: TextStyle(
                      fontSize: 20,
                    )),
              ),
            ]),
        Offstage(
            offstage: !widget.configs.webCrawlerConfigs.enableClientPool,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 200,
                  // 使用 ListView.builder 来构建列表
                  child: ListView.builder(
                    itemExtent: 60,
                    itemCount:
                        widget.configs.webCrawlerConfigs.clientPool.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                            'Email: ${widget.configs.webCrawlerConfigs.clientPool[index]!.email}  ||  Cookies: ${widget.configs.webCrawlerConfigs.clientPool[index]!.cookies.toString()}',
                            style: TextStyle(
                              fontSize: 16,
                            )),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _removeClient(index);
                            widget.configs.webCrawlerConfigs.clientPool
                                .removeAt(index);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            )),
        // 保存
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () {
              // 使用 Form.of(context) 来验证表单
              if (Form.of(context).validate()) {
                setState(() {
                  // 保存表单数据
                  Form.of(context).save();
                  // 写入配置文件
                  configWriter(
                    'jsons/config.json',
                    widget.configs,
                  ).then((success) => context.mounted
                      ? success
                          ? resultDialog(context, 'Save configs', true)
                          : resultDialog(context, 'Save configs', false)
                      : {});
                });
              }
            },
            child: Text(
              'Save',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          );
        }),
      ],
    );
  }
}

class UISettingsPage extends StatefulWidget {
  const UISettingsPage({super.key, required this.configs});
  final Configs configs;
  @override
  State<StatefulWidget> createState() => _UISettingsPageState();
}

class _UISettingsPageState extends State<UISettingsPage> {
  double cacheRate = 1.0;
  // 自动保存
  void autoSaveUIConfigs() {
    configWriter('jsons/config.json', widget.configs).then((success) => success
        ? {}
        : resultDialog(
            context.mounted ? context : null, 'Save configs', false));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 20,
      children: [
        // UI 相关设置
        // 自动保存
        Text(
          'UI Settings',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        SwitchListTile(
          title: Text(
            'Auto open user detial page when click user infos',
            style: TextStyle(fontSize: 20),
          ),
          value: context.read<UIConfigUpdateNotifier>().uiConfigs.autoOpen,
          onChanged: (value) {
            // 重新构建页面
            setState(() {
              // 通知UI更新
              context
                  .read<UIConfigUpdateNotifier>()
                  .updateUiConfigs('autoOpen', value);
              autoSaveUIConfigs();
            });
          },
        ),
        SwitchListTile(
          title: Text(
            'Auto search when click tag',
            style: TextStyle(fontSize: 20),
          ),
          value: context.read<UIConfigUpdateNotifier>().uiConfigs.autoSearch,
          onChanged: (value) {
            // 重新构建页面
            setState(() {
              // 通知UI更新
              context
                  .read<UIConfigUpdateNotifier>()
                  .updateUiConfigs('autoSearch', value);
              autoSaveUIConfigs();
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '  ImageCacheRate',
              style: TextStyle(fontSize: 20),
            ),
            Expanded(
                child: Slider(
              max: 4,
              divisions: 8,
              label: cacheRate == 0 ? 'Not limited' : '$cacheRate',
              value: cacheRate,
              onChanged: (value) {
                setState(() {
                  cacheRate = value;
                });
              },
              onChangeEnd: (value) {
                // 重新构建页面
                setState(() {
                  // 通知UI更新
                  context
                      .read<UIConfigUpdateNotifier>()
                      .updateUiConfigs('imageCacheRate', value);
                  autoSaveUIConfigs();
                });
              },
            )),
          ],
        ),
        Divider(
          height: 400,
          color: Color.fromARGB(0, 0, 0, 0),
        )
      ],
    );
  }
}

InputDecoration getInputDecoration(String tip) {
  return InputDecoration(
    labelStyle: TextStyle(fontSize: 24),
    labelText: tip,
    hintText: '请输入$tip',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(5)),
    ),
  );
}
