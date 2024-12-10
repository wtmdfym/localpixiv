import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart'
    show Db, DbCollection, SelectorBuilder, where;
import 'package:provider/provider.dart';

import 'package:localpixiv/common/defaultdatas.dart';
import 'package:localpixiv/widgets/userdisplayer.dart';
import 'package:localpixiv/widgets/workcontainer.dart';
import 'package:localpixiv/widgets/dialogs.dart';
import 'package:localpixiv/common/customnotifier.dart';
import 'package:localpixiv/models.dart';

class Viewer extends StatefulWidget {
  const Viewer({
    super.key,
    required this.pixivDb,
    required this.backupcollection,
    required this.basicConfigs,
  });
  final Db pixivDb;
  final DbCollection backupcollection;
  final BasicConfigs basicConfigs;

  @override
  State<StatefulWidget> createState() {
    return _ViewerState();
  }
}

class _ViewerState extends State<Viewer> {
  // 初始化
  int page = 1;
  int maxpage = 1;
  final int pagesize = 8;
  bool cancelevent = false;
  final List<dynamic> searchedInfos = [];
  final InfosNotifier<WorkInfo> workInfosNotifer = InfosNotifier([
    defaultWorkInfo,
    defaultWorkInfo,
    defaultWorkInfo,
    defaultWorkInfo,
    defaultWorkInfo,
    defaultWorkInfo,
    defaultWorkInfo,
    defaultWorkInfo,
  ]);
  final List<dynamic> searchResults = [];
  final WorkInfoNotifier showingInfo = WorkInfoNotifier(defaultWorkInfo);
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _pageController =
      TextEditingController(text: '1/1');
  /*ValueNotifier<List<bool>> searchType =
      ValueNotifier([true, false, false]); //id  uid tag*/
  int reslength = 0;
  final int buffer = 200;
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  bool onsearching = false;

  // 搜索控制
  void searchAnalyzer(
      {Map<String, dynamic>? advancedtext, SelectorBuilder? finishedselector}) {
    if (onsearching) {
      resultDialog(context, 'Search', false,
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
        resultDialog(context.mounted ? context : null, 'Search', true,
            description: 'Found $reslength results!');
        maxpage = (reslength / pagesize).ceil();
        Timer.periodic(Durations.short2, (timer) {
          if ((searchResults.length >= 8) ||
              (searchResults.length == reslength)) {
            _isLoading.value = false;
            changePage();
            timer.cancel();
          }
        });
      } else {
        resultDialog(context.mounted ? context : null, 'Search', false,
            description: 'No matching results found!');
      }
    });
  }

  Future<bool> searchWork(SelectorBuilder selector) async {
    onsearching = true;
    reslength = await widget.backupcollection.count(selector);
    if (reslength == 0) {
      _isLoading.value = false;
      onsearching = false;
      return false;
    } else {
      searchResults.clear();
      page = 1;
      widget.backupcollection
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

  // 通信信息处理
  void dataHander(data) {}

  // 翻页控制
  void prevPage() {
    if (page > 1) {
      page -= 1;
      changePage();
    }
  }

  void jumpToPage() {
    int newpage =
        int.parse(_pageController.text.replaceFirst(RegExp('/.+'), ''));
    if (page == newpage) {
    } else if ((0 < newpage) && (newpage <= maxpage)) {
      page = newpage;
      changePage();
    } else {
      _pageController.text = '$page/$maxpage';
    }
  }

  void nextPage() {
    if (page < maxpage) {
      page += 1;
      changePage();
    }
  }

  void changePage() async {
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
    workInfosNotifer.setInfos(workInfos);
    _pageController.text = '$page/$maxpage';
  }

  // 构造界面
  @override
  Widget build(BuildContext context) {
    return FittedBox(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Stack(children: [
              NotificationListener<ShowInfoNotification>(
                  // showinfo信号监听
                  onNotification: (notification) {
                    showingInfo.setInfo(notification.msg);
                    return true;
                  },
                  child: Row(spacing: 20, children: [
                    SizedBox(
                        width: 400,
                        height: 1080,
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            // 搜索控件
                            TextField(
                              controller: _searchController,
                              maxLength: 100,
                              decoration: InputDecoration(
                                labelText: "Ciallo~(∠・ω< )⌒☆",
                                icon: Icon(Icons.search),
                              ),
                            ),
                            /*Divider(),
                            ValueListenableBuilder(
                                valueListenable: searchType,
                                builder: (context, _searchType, child) => Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(
                                              child: CheckboxListTile(
                                            title: Text('Id'),
                                            value: _searchType[0],
                                            onChanged: (value) {
                                              List<bool> temp =
                                                  searchType.value;
                                              temp[0] = value!;
                                              searchType.value = temp;
                                            },
                                          )),
                                          Expanded(
                                              child: CheckboxListTile(
                                            title: Text('Uid'),
                                            value: _searchType[1],
                                            onChanged: (value) {
                                              List<bool> temp =
                                                  searchType.value;
                                              temp[0] = value!;
                                              searchType.value = temp;
                                            },
                                          )),
                                          Expanded(
                                              child: CheckboxListTile(
                                            title: Text('Tag'),
                                            value: _searchType[2],
                                            onChanged: (value) {
                                              List<bool> temp =
                                                  searchType.value;
                                              temp[0] = value!;
                                              searchType.value = temp;
                                            },
                                          )),
                                        ])),*/
                            Divider(),
                            ElevatedButton.icon(
                              onPressed: searchAnalyzer,
                              icon: Icon(
                                Icons.search,
                                size: 30,
                              ),
                              label: Text('Search',
                                  style: TextStyle(fontSize: 20)),
                            ),
                            Divider(),
                            ElevatedButton(
                                onPressed: () {
                                  advancedSearch(context).then((advancedtext) {
                                    // TODO 高级搜索
                                    searchAnalyzer(advancedtext: advancedtext);
                                  });
                                },
                                child: Text('Advanced Search',
                                    style: TextStyle(fontSize: 20))),
                            Divider(),
                            // 信息显示部件
                            ValueListenableBuilder(
                                valueListenable: showingInfo,
                                builder: (context, workInfo, child) => Consumer<
                                        UIConfigUpdateNotifier>(
                                    builder: (context, value, child) =>
                                        InfoContainer(
                                          workInfo: workInfo,
                                          onTapUser: (userName) {
                                            value.uiConfigs.autoOpen
                                                ? context
                                                    .read<StackChangeNotifier>()
                                                    .addStack(
                                                        userName,
                                                        UserDetailsDisplayer(
                                                          hostPath: widget
                                                              .basicConfigs
                                                              .savePath,
                                                          /*cacheRate:
                                                            configNotifier
                                                                .uiConfigs
                                                                .imageCacheRate,*/
                                                          userName: userName,
                                                          pixivDb:
                                                              widget.pixivDb,
                                                          // TODO 同步信息
                                                          onWorkBookmarked: (isLiked,
                                                                  workId,
                                                                  userName) =>
                                                              Provider.of<WorkBookmarkModel>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .changebookmark(
                                                            isLiked,
                                                            workId,
                                                            userName,
                                                          ),
                                                        ))
                                                : {};
                                          },
                                          onTapTag: (tag) {
                                            value.uiConfigs.autoSearch
                                                ? searchAnalyzer(
                                                    advancedtext: null,
                                                    finishedselector: where
                                                        .exists('tags.$tag'))
                                                : {};
                                          },
                                        )))
                          ],
                        )),
                    // 作品展示网格
                    Column(
                        spacing: 8,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 1920,
                                // maxHeight: 1080,
                              ),
                              child: ValueListenableBuilder(
                                  valueListenable: workInfosNotifer,
                                  builder: (context, workInfos, child) =>
                                      GridView.count(
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        crossAxisCount: 4,
                                        childAspectRatio: 10 / 12, //宽比高
                                        mainAxisSpacing: 16,
                                        crossAxisSpacing: 16,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        children: <Widget>[
                                          for (int i = 0; i < pagesize; i++)
                                            WorkContainer(
                                              hostPath:
                                                  widget.basicConfigs.savePath,
                                              workInfo: workInfos[i],
                                              //cacheRate: widget.uiConfigs.imageCacheRate,
                                              onBookmarked: (isLiked, workId,
                                                      userName) =>
                                                  Provider.of<WorkBookmarkModel>(
                                                          context,
                                                          listen: false)
                                                      .changebookmark(
                                                isLiked,
                                                workId,
                                                userName,
                                              ),
                                            ),
                                        ],
                                      ))),
                          // 翻页控件
                          Row(
                            spacing: 300,
                            children: [
                              ElevatedButton.icon(
                                onPressed: prevPage,
                                icon: Icon(
                                  Icons.navigate_before,
                                  size: 30,
                                ),
                                label: Text('Prev',
                                    style: TextStyle(fontSize: 20)),
                              ),
                              SizedBox(
                                  width: 300,
                                  child: TextField(
                                    controller: _pageController,
                                    maxLength: 10,
                                    decoration: InputDecoration(
                                      labelText: "Page",
                                    ),
                                  )),
                              ElevatedButton.icon(
                                  onPressed: jumpToPage,
                                  icon: Icon(
                                    Icons.next_plan_outlined,
                                    size: 30,
                                  ),
                                  label: Text("Jump",
                                      style: TextStyle(fontSize: 20))),
                              ElevatedButton.icon(
                                  onPressed: nextPage,
                                  icon: Icon(
                                    Icons.navigate_next,
                                    size: 30,
                                  ),
                                  iconAlignment: IconAlignment.end,
                                  label: Text("Next",
                                      style: TextStyle(fontSize: 20))),
                            ],
                          )
                        ])
                  ])),

              // 加载指示器
              ValueListenableBuilder(
                  valueListenable: _isLoading,
                  builder: (context, value, child) {
                    return Positioned.fill(
                      child:
                          // 当不加载时不显示
                          Offstage(
                              offstage: !value,
                              child: Stack(children: [
                                ModalBarrier(
                                  color:
                                      const Color.fromARGB(150, 160, 160, 160),
                                  dismissible: true,
                                  onDismiss: () => {
                                    cancelevent = true,
                                    _isLoading.value = false
                                  },
                                ),
                                Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.blueAccent,
                                    strokeWidth: 6,
                                    semanticsLabel: 'Loading......',
                                  ),
                                ),
                              ])),
                    );
                  }),
            ])));
  }
}

/*
class _ImageContainerState extends State<ImageContainer>{
  /*
  List<String> imagePath = [];
  var imageInfo = {'imagecount':1};
  // include: id,type,title,description,count,uploadDate,isOriginal
  var autherInfo = {};
  // include: userId,username
  var userInfo = [];
  // include: islike
  var tags = {};
  // tags of this work
  var image = FileImage(File('images/default\.png'));
  void updateImage(List infos){
    imagePath = infos[0];
    imageInfo = infos[1];
    autherInfo = infos[2];
    userInfo = infos[3];
    tags = infos[4];
  }*/
  //var imagePath;
  //var imageInfo;
  /*@override
  void initState() {
    super.initState();
    imagePath = widget.workinfos.imagePath;
    //imagePath = widget.workinfos['imagePath'];
    imageInfo = widget.workinfos.imageInfo;
    //imageInfo = widget.workinfos['imageInfo'];
    // include: id,type,title,description,count,uploadDate,isOriginal
    /*
    var autherInfo = widget.workinfos[''];
    // include: userId,username
    var userInfo = widget.workinfos[''];
    // include: islike
    var tags = widget.workinfos[''];
    // tags of this work*/
  }
  void loadImage(String imagePath) async {
    var file = File(imagePath);
    var imfage = await file.readAsBytes();
    setState((){var _imfage = Image.memory(imfage);});
  }*/
  Future<File> _getImageFile() async {
    List<String> imagePath = widget.workinfos.imagePath;
    if (imagePath.isNotEmpty){
      return File(imagePath[0]);
    }
    else{
      // 若图片不存在就加载默认图片
      return File('images\\test.png');
    }
  }
  //var image = Image.asset('images\\test.png');
  @override
  Widget build(BuildContext context){
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey, // 边框颜色
          width: 2, // 边框宽度
        ),
      ),
      width: (widget.width+5)*widget.scale,
      height: (widget.height+5)*widget.scale,
      // 异步加载图片
      child: Stack(
        alignment: Alignment.center,
        children: [
          FutureBuilder<File>(
              future: _getImageFile(),
              builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      return Image.file(
                        snapshot.data!,
                        width: widget.width*widget.scale,
                        height: widget.height*widget.scale
                        ).animate().fade(duration: 500.ms);
                    }
                    else {return const Center(child: Text('Error loading image'));}
                  }
                  else {return const Center(child: CircularProgressIndicator());}
                }
              ),
          Positioned(
            top: 5,
            right: 5,
            width: 30,
            height: 20,
            child: Text(widget.workinfos.imageInfo['imagecount'].toString()),
          )
        ],
      )
    );
  }
}

     FutureBuilder<File>(
      future: _getImageFile(),
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return Image.file(snapshot.data!);
          } else {
            return Center(child: Text('Error loading image'));
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }  
        
          Widget build(BuildContext context){
    if (imagePath[0] != null){
      image  = FileImage(File(imagePath[0]));
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black, // 边框颜色
              width: 2, // 边框宽度
            ),
          ),
          child: Image(
            image: image,
            width: widget.width*widget.scale,
            height: widget.height*widget.scale,
            alignment: Alignment.center
          )
        ),
        Positioned(
          top: 5,
          right: 5,
          width: 30,
          height: 20,
          child: Text(imageInfo['imagecount'].toString()),
        )
      ],
    );
  }
} */
