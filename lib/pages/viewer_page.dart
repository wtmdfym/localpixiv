import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart'
    show DbCollection, SelectorBuilder, where;
import 'package:provider/provider.dart';
import 'package:filepicker_windows/filepicker_windows.dart';

import '../localization/localization.dart';
import '../common/defaultdatas.dart';
import '../common/customnotifier.dart';
import '../models.dart';
import '../settings/settings_controller.dart';
import '../widgets/divided_stack.dart';
import '../widgets/page_controller_row.dart';
import '../widgets/dialogs.dart';
import '../containers/info_container.dart';
import '../containers/work_container.dart';
import 'user_detail_page.dart';

class ViewerPage extends StatefulWidget {
  ViewerPage({
    super.key,
    required this.controller,
    this.backupcollection,
    required this.useMongoDB,
    required this.onBookmarked,
  }) {
    if (useMongoDB) {
      assert(backupcollection != null);
    }
  }
  final SettingsController controller;
  final DbCollection? backupcollection;
  final bool useMongoDB;
  final WorkBookmarkCallback onBookmarked;

  @override
  State<StatefulWidget> createState() {
    return _ViewerPageState();
  }
}

class _ViewerPageState extends State<ViewerPage> {
  // 初始化
  // localized text
  late String Function(String) _localizationMap;
  final ValueNotifier<bool> pageControllerUpdater = ValueNotifier(false);
  final int pagesize = 8;
  bool cancelevent = false;
  final ListNotifier<WorkInfo> workInfosNotifer =
      ListNotifier([for (int i = 0; i < 8; i++) defaultWorkInfo]);
  final List<dynamic> searchResults = [];
  final TextEditingController _searchController = TextEditingController();
  /*ValueNotifier<List<bool>> searchType =
      ValueNotifier([true, false, false]); //id  uid tag*/
  int reslength = 0;
  int maxpage = 1;
  final int buffer = 200;
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<WorkInfo> showingInfo = ValueNotifier(defaultWorkInfo);
  bool onsearching = false;

  @override
  void didChangeDependencies() {
    _localizationMap = MyLocalizations.of(context).viewerPage;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return DividedStack(
      padding: const EdgeInsets.all(8),
      leftWidget: widget.useMongoDB
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 搜索控件
                TextField(
                  controller: _searchController,
                  maxLength: 100,
                  decoration: InputDecoration(
                    labelText: "Ciallo~(∠・ω< )⌒☆",
                    icon: Icon(
                      Icons.search,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: searchAnalyzer,
                  icon: Icon(
                    Icons.search,
                  ),
                  label: Text(
                    _localizationMap('search'),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextButton(
                    onPressed: () {
                      advancedSearch(context).then((advancedtext) {
                        // TODO 高级搜索
                        searchAnalyzer(advancedtext: advancedtext);
                      });
                    },
                    child: Text(_localizationMap('advanced_search'))),
                Divider(),
                // 信息显示部件
                ValueListenableBuilder(
                    valueListenable: showingInfo,
                    builder: (context, workInfo, child) => Expanded(
                            child: WorkInfoContainer(
                          workInfo: workInfo,
                          onTapUser: (userName) => widget.controller.autoOpen
                              ? context
                                  .read<AddStackNotifier>()
                                  .addStack<UserDetailPage>(
                                      userName, {'userName': userName})
                              : {},
                          onTapTag: (tag) => widget.controller.autoSearch
                              ? searchAnalyzer(
                                  advancedtext: null,
                                  finishedselector: where.exists('tags.$tag'))
                              : {},
                        ))),
              ],
            )
          : ElevatedButton(
              onPressed: dirWalker,
              child: Text('Select a directory'),
            ),
      rightWidget:
          // Grid like view to show works.
          Column(children: [
        for (int j = 0; j < pagesize / 4; j++)
          Expanded(
              child: Padding(
            padding:
                EdgeInsets.only(top: j == 0 ? 0 : 6, bottom: j == 1 ? 0 : 6),
            child: ValueListenableBuilder(
                valueListenable: workInfosNotifer,
                builder: (context, workInfos, child) => Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 12,
                      children: [
                        for (int i = j * 4; i < pagesize - (1 - j) * 4; i++)
                          Expanded(
                            child: WorkContainer(
                                hostPath: widget.useMongoDB
                                    ? widget.controller.hostPath
                                    : '',
                                workInfo: workInfos[i],
                                cacheRate: widget.controller.imageCacheRate,
                                onTab: () => showingInfo.value = workInfos[i],
                                onBookmarked: widget.onBookmarked),
                          ),
                      ],
                    )),
          )),
        ValueListenableBuilder(
          valueListenable: pageControllerUpdater,
          builder: (context, value, child) => PageControllerRow(
            maxpage: maxpage,
            pagesize: pagesize,
            onPageChange: (page) => changePage(page),
          ),
        )
      ]),
      additionalWidgets: [
        // Loading indicator
        Positioned.fill(
            child: ValueListenableBuilder(
                valueListenable: _isLoading,
                builder: (context, value, child) {
                  return Offstage(
                      offstage: !value,
                      child: Stack(children: [
                        ModalBarrier(
                          color: const Color.fromARGB(150, 160, 160, 160),
                          dismissible: true,
                          onDismiss: () =>
                              {cancelevent = true, _isLoading.value = false},
                        ),
                        Center(
                          child: CircularProgressIndicator(
                            color: Colors.blueAccent,
                            strokeWidth: 6,
                            semanticsLabel: _localizationMap('loading'),
                          ),
                        ),
                      ]));
                })),
      ],
      /*ValueListenableBuilder(
              valueListenable: searchType,
              builder: (context, _searchType, child) =>
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Expanded(
                        child: CheckboxListTile(
                      title: Text('Id'),
                      value: _searchType[0],
                      onChanged: (value) {
                        List<bool> temp = searchType.value;
                        temp[0] = value!;
                        searchType.value = temp;
                      },
                    )),
                    Expanded(
                        child: CheckboxListTile(
                      title: Text('Uid'),
                      value: _searchType[1],
                      onChanged: (value) {
                        List<bool> temp = searchType.value;
                        temp[0] = value!;
                        searchType.value = temp;
                      },
                    )),
                    Expanded(
                        child: CheckboxListTile(
                      title: Text('Tag'),
                      value: _searchType[2],
                      onChanged: (value) {
                        List<bool> temp = searchType.value;
                        temp[0] = value!;
                        searchType.value = temp;
                      },
                    )),
                  ])),*/
    );
  }

  // 搜索控制
  void searchAnalyzer(
      {Map<String, dynamic>? advancedtext, SelectorBuilder? finishedselector}) {
    if (onsearching) {
      resultDialog('Search', false,
          description: 'Searching operation not complete!\nPlease wait.');
      return;
    }
    _isLoading.value = true;
    SelectorBuilder selector = SelectorBuilder().exists('id');
    if (advancedtext != null) {
      if (advancedtext.isNotEmpty) {
        bool searchtag = true;
        bool partly = true;
        if (advancedtext['searchRange'] == 'tag(partly)') {
        } else if (advancedtext['searchRange'] == 'tag(absolutely)') {
          partly = false;
        } else {
          searchtag = false;
        }
        //tag search
        if (searchtag) {
          //匹配tag
          if (!partly) {
            for (String keyword in advancedtext['AND']) {
              if (keyword.isNotEmpty) {
                selector.and(where.exists('tags.$keyword'));
              }
            }
            for (String keyword in advancedtext['NOT']) {
              if (keyword.isNotEmpty) {
                selector.and(where.notExists('tags.$keyword'));
              }
            }
            for (String keyword in advancedtext['OR']) {
              if (keyword.isNotEmpty) {
                selector.or(where.exists('tags.$keyword'));
              }
            }
          }
          //匹配tag和翻译
          else {
            for (String keyword in advancedtext['AND']) {
              if (keyword.isNotEmpty) {
                selector.match('tags', keyword, multiLine: true);
              }
            }
            for (String keyword in advancedtext['NOT']) {
              if (keyword.isNotEmpty) {
                selector.raw({
                  'tags': {'\$not': RegExp(keyword, multiLine: true)}
                });
              }
            }

            for (String keyword in advancedtext['OR']) {
              if (keyword.isNotEmpty) {
                selector.or(where.match('tags', keyword, multiLine: true));
              }
            }
          }
        }
        //title and description search
        else {
          /*
          TODO 聚合查询
          var title = mongo.SelectorBuilder();
          var description = mongo.SelectorBuilder();
          for (String keyword in advancedtext['AND']) {
            if (keyword.isNotEmpty) {
              title.match('title', keyword, multiLine: true);
              description.match('description', keyword, multiLine: true);
            }
          }
          title.or(description);
          selector.and(title);
          
          for (String keyword in advancedtext['NOT']) {
            if (keyword.isNotEmpty) {
              selector.match('title', keyword, multiLine: true);
              selector.match('description', keyword, multiLine: true);
            }
          }

          for (String keyword in advancedtext['OR']) {
            if (keyword.isNotEmpty) {
              selector.or(mongo.where.match('title', keyword, multiLine: true));
              selector.or(
                  mongo.where..match('description', keyword, multiLine: true));
            }
          }*/
        }
        /*var macth = {
        {'\$all': advancedtext['AND']},
        {'\$all': 'values'},
        {'\$in': advancedtext['OR']}
      };*/

        selector.oneFrom('type', advancedtext['searchType']);
        advancedtext['originalOnly'] ? selector.eq('isOriginal', true) : {};
        advancedtext['R-18'] ? {} : selector.notExists("tags.R-18");
        advancedtext['likedOnly'] ? selector.eq('likeData', true) : {};
      } else {
        _isLoading.value = false;
        return;
      }
    } else if (finishedselector != null) {
      selector = finishedselector;
    } else {
      if (_searchController.text.isNotEmpty) {
        selector.eq('id', int.parse(_searchController.text));
      }
    }
    if (cancelevent) {
      cancelevent = false;
      return;
    }
    searchWork(selector).then((success) {
      if (success) {
        resultDialog('Search', true, description: 'Find $reslength results!');
        maxpage = (reslength / pagesize).ceil();
        pageControllerUpdater.value = !pageControllerUpdater.value;
        Timer.periodic(Durations.short2, (timer) {
          if ((searchResults.length >= 8) ||
              (searchResults.length == reslength)) {
            _isLoading.value = false;
            changePage(1);
            timer.cancel();
          }
        });
      } else {
        resultDialog('Search', false,
            description: 'No matching results found!');
      }
    });
  }

  Future<bool> searchWork(SelectorBuilder selector) async {
    onsearching = true;
    reslength = await widget.backupcollection!.count(selector);
    if (reslength == 0) {
      _isLoading.value = false;
      onsearching = false;
      return false;
    } else {
      searchResults.clear();
      widget.backupcollection!
          .find(selector.sortBy('id', descending: true).excludeFields(['_id']))
          .forEach((info) {
        if (cancelevent) {
          cancelevent = false;
          return;
        }
        searchResults.add(info);
      }).then((_) => onsearching = false);
      return true;
    }
  }

  void changePage(int page) async {
    final List<WorkInfo> workInfos = [];
    if (page < maxpage) {
      List<dynamic> info =
          searchResults.sublist((page - 1) * pagesize, page * pagesize);
      for (int i = 0; i < pagesize; i++) {
        workInfos.add(WorkInfo.fromJson(info[i]));
      }
    } else {
      List<dynamic> info =
          searchResults.sublist((page - 1) * pagesize, reslength);
      for (int i = 0; i < pagesize; i++) {
        try {
          workInfos.add(WorkInfo.fromJson(info[i]));
        } on RangeError {
          workInfos.add(defaultWorkInfo);
        }
      }
    }
    workInfosNotifer.setList(workInfos);
  }

  Future<void> dirWalker() async {
    late final Directory? dir;
    final file = DirectoryPicker()..title = 'Select a directory';
    dir = file.getDirectory();
    if (dir == null) {
      return;
    }
    _isLoading.value = true;
    searchResults.clear();
    dir.list().forEach((action) {
      Map<String, dynamic> info = Map.from(defaultworkdata);
      info["relative_path"] = [action.path];
      searchResults.add(info);
    }).then((_) {
      reslength = searchResults.length;
      maxpage = (reslength / pagesize).ceil();
      pageControllerUpdater.value = !pageControllerUpdater.value;
      _isLoading.value = false;
      resultDialog('Walk dir', true, description: 'Find $reslength results.');
      changePage(1);
    });
  }
}
