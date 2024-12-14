import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:localpixiv/common/customnotifier.dart';
import 'package:localpixiv/models.dart';
import 'package:localpixiv/widgets/dialogs.dart';
import 'package:localpixiv/common/tools.dart';
import 'package:localpixiv/widgets/settingpages.dart';
import 'package:localpixiv/widgets/tabbutton.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key, required this.configs});
  final Configs configs;
  @override
  State<StatefulWidget> createState() {
    return _SettingsState();
  }
}

class _SettingsState extends State<Settings> {
  final ScrollController _scrollController = ScrollController();
  late final List<Widget> itemlist;
  final Map<int, double> scrollOffsets = {};
  final double dividerHeight = 30.0;
  final ValueNotifier<int> index = ValueNotifier(0);
  double cacheRate = 1.0;
  @override
  void initState() {
    _scrollController.addListener(() {
      final double offsetnow = _scrollController.offset;
      if (offsetnow < scrollOffsets[0]!) {
        index.value = 0;
      } else if ((scrollOffsets[0]! <= offsetnow) &&
          (offsetnow < (scrollOffsets[0]! + scrollOffsets[1]!))) {
        index.value = 1;
      } else if (((scrollOffsets[0]! + scrollOffsets[1]!) <= offsetnow) &&
          (offsetnow <
              (scrollOffsets[0]! + scrollOffsets[1]! + scrollOffsets[2]!))) {
        index.value = 2;
      } else {
        assert(false, 'Offset error! Check offset setter.');
      }
    });
    cacheRate = context.read<UIConfigUpdateNotifier>().uiConfigs.imageCacheRate;
    /*itemlist = [
      Padding(
          padding: EdgeInsets.only(right: 20),
          child: BasicSettingsPage(configs: widget.configs)),
      Padding(
          padding: EdgeInsets.only(right: 20),
          child: WebCrawlerSettingsPage(configs: widget.configs)),
      UISettingsPage(configs: widget.configs)
    ];*/
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 自动保存
  void autoSaveUIConfigs() {
    configWriter('jsons/config.json', widget.configs).then((success) => success
        ? {}
        : resultDialog(
            context.mounted ? context : null, 'Save configs', false));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 30,
          children: [
            Column(
              spacing: 20,
              children: [
                Tabbutton(
                  text: 'Main',
                  style: Theme.of(context).textTheme.titleMedium,
                  onTap: (_) {
                    index.value = 0;
                    _scrollController.jumpTo(0);
                  },
                  index: 0,
                  indexNotifier: index,
                ),
                Tabbutton(
                  text: 'Web Crawler',
                  style: Theme.of(context).textTheme.titleMedium,
                  onTap: (_) {
                    index.value = 1;
                    _scrollController.jumpTo(scrollOffsets[0]!);
                    //_scrollController.animateTo(scrollOffsets[0]!+1,
                    //    duration: Durations.long1, curve: Curves.easeOut);
                  },
                  index: 1,
                  indexNotifier: index,
                ),
                Tabbutton(
                  text: 'UI',
                  style: Theme.of(context).textTheme.titleMedium,
                  onTap: (_) {
                    index.value = 2;
                    _scrollController
                        .jumpTo(scrollOffsets[0]! + scrollOffsets[1]!);
                  },
                  index: 2,
                  indexNotifier: index,
                ),
              ],
            ),
            /*Expanded(
                child: SizedBox(
                    width: 1980,
                    child: Form(
                        autovalidateMode: AutovalidateMode.onUnfocus,
                        child: ListView.separated(
                            controller: _scrollController,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              // 若组件未构建则会出错
                              return AfterLayout(
                                  callback: (value) {
                                    jumpOffsets[index] = value.rect.height;
                                    // print(jumpOffsets);
                                  },
                                  child: itemlist[index]);
                            },
                            separatorBuilder: (context, index) {
                              return Divider();
                            },
                            itemCount: 3)))),*/
            Expanded(
                child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      AfterLayout(
                          callback: (value) {
                            scrollOffsets[0] =
                                value.rect.height + dividerHeight;
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 20),
                            child: BasicSettingsPage(
                              configs: widget.configs,
                            ),
                          )),
                      Divider(
                        height: dividerHeight,
                      ),
                      AfterLayout(
                          callback: (value) {
                            scrollOffsets[1] =
                                value.rect.height + dividerHeight;
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 20),
                            child: WebCrawlerSettingsPage(
                              configs: widget.configs,
                            ),
                          )),
                      Divider(
                        height: dividerHeight,
                      ),
                      AfterLayout(
                        callback: (value) {
                          scrollOffsets[2] = value.rect.height + dividerHeight;
                        },
                        child: UISettingsPage(
                          configs: widget.configs,
                        ),
                      ),
                      Divider(
                        height: dividerHeight,
                      ),
                    ])))
          ],
        ));
  }
}

class AfterLayout extends SingleChildRenderObjectWidget {
  const AfterLayout({
    super.key,
    required this.callback,
    super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderAfterLayout(callback);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderAfterLayout renderObject) {
    renderObject.callback = callback;
  }

  ///组件树布局结束后会被触发，注意，并不是当前组件布局结束后触发
  final ValueSetter<RenderAfterLayout> callback;
}

class RenderAfterLayout extends RenderProxyBox {
  RenderAfterLayout(this.callback);

  ValueSetter<RenderAfterLayout> callback;

  @override
  void performLayout() {
    super.performLayout();
    // 不能直接回调callback，原因是当前组件布局完成后可能还有其他组件未完成布局
    // 如果callback中又触发了UI更新（比如调用了 setState）则会报错。因此，我们
    // 在 frame 结束的时候再去触发回调。
    SchedulerBinding.instance
        .addPostFrameCallback((timeStamp) => callback(this));
  }

  /// 组件在屏幕坐标中的起始点坐标（偏移）
  Offset get offset => localToGlobal(Offset.zero);

  /// 组件在屏幕上占有的矩形空间区域
  Rect get rect => offset & size;
}
