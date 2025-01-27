import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart'
    show DbCollection, WriteResult, modify, where;
import 'package:provider/provider.dart';

import '../common/customnotifier.dart';
import '../containers/tag_container.dart';
import '../settings/settings_controller.dart';
import '../models.dart';
import '../localization/localization.dart';
import '../widgets/dialogs.dart';

/// A page to help user find tags.
class TagPage extends StatefulWidget {
  const TagPage({
    super.key,
    required this.controller,
    required this.tagCollection,
  });

  final SettingsController controller;
  final DbCollection tagCollection;

  @override
  State<StatefulWidget> createState() => _TagPageState();
}

class _TagPageState extends State<TagPage> with TickerProviderStateMixin {
  // localized text
  late String Function(String) _localizationMap;
  final TextEditingController controller = TextEditingController();
  late final DbCollection tagCollection;
  final ListNotifier<TagInfo> searchResults = ListNotifier<TagInfo>([]);
  final List<TagInfo> likeTags = [];
  final List<TagInfo> dislikeTags = [];

  void search(String keyword) {
    final List<TagInfo> results = [];
    widget.tagCollection
        .find(where
            .excludeFields(['_id'])
            .match('name', keyword)
            .or(where.match('translate', keyword))
            .sortBy('works_count', descending: true))
        .forEach(
      (data) {
        results.add(TagInfo.fromJson(data));
      },
    ).then((_) => searchResults.setList(results));
  }

  void searchTag(String tag) {
    context.read<SearchNotifier>().searchTag(tag);
    context.read<SuperTabViewNotifier>().changeToMaintainTab(1);
  }

  @override
  void initState() {
    tagCollection = widget.tagCollection;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _localizationMap = MyLocalizations.of(context).tagPage;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        spacing: 12,
        children: [
          // Search
          Expanded(
              child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                    ),
                  ),
                  TextButton(
                      onPressed: () => search(controller.text),
                      child: Text(_localizationMap('search')))
                ],
              ),
              Expanded(
                  child: ValueListenableBuilder(
                valueListenable: searchResults,
                builder: (context, results, child) => ListView.separated(
                  itemBuilder: (context, index) {
                    return TagContainer(
                      tagInfo: results[index],
                      onTap: searchTag,
                    );
                  },
                  separatorBuilder: (context, index) => Divider(
                    height: 0,
                  ),
                  itemCount: results.length,
                ),
              ))
            ],
          )),
          // Like
          Expanded(
              child: _TagList(
                  controller: widget.controller,
                  tagCollection: widget.tagCollection,
                  onTapContain: searchTag,
                  isLiked: true)),
          // Dislike
          Expanded(
              child: _TagList(
                  controller: widget.controller,
                  tagCollection: widget.tagCollection,
                  onTapContain: searchTag,
                  isLiked: false)),
        ],
      ),
    );
  }
}

class _TagList extends StatefulWidget {
  const _TagList({
    required this.controller,
    required this.tagCollection,
    required this.onTapContain,
    required this.isLiked,
  });

  final SettingsController controller;
  final DbCollection tagCollection;
  final NeedSearchCallback onTapContain;
  final bool isLiked;

  @override
  State<StatefulWidget> createState() => _TagListState();
}

class _TagListState extends State<_TagList> {
  // localized text
  late String Function(String) _localizationMap;
  bool _isDragIn = false;
  final List<TagInfo> tagInfos = [];

  void _addTag(TagInfo tagInfo) async {
    // Check for illegal operations.
    if (tagInfos.contains(tagInfo)) {
      /*resultDialog(_localizationMap('add_tag'), false,
          description: _localizationMap('tag_exist'));*/
      return;
    }
    final Map<String, dynamic>? foundInfo =
        await widget.tagCollection.findOne(where.eq('name', tagInfo.name));
    if (foundInfo == null) {
      resultDialog(_localizationMap('add_tag'), false,
          description: _localizationMap('tag_not_find'));
      return;
    }
    if (foundInfo['like'] != null) {
      resultDialog(_localizationMap('add_tag'), false,
          description:
              '${_localizationMap('tag_add_to_other')} ${widget.isLiked ? _localizationMap('dislike') : _localizationMap('like')}.');
      return;
    }
    // Update database
    final WriteResult res = await widget.tagCollection.updateOne(
        where.eq('name', tagInfo.name), modify.set('like', widget.isLiked));
    if (!res.isSuccess) {
      resultDialog(
        _localizationMap('update'),
        false,
      );
    }
    // Update UI
    tagInfos.add(tagInfo);
    setState(() {});
  }

  void _removeTag(TagInfo tagInfo) async {
    // Update database
    final WriteResult res = await widget.tagCollection
        .updateOne(where.eq('name', tagInfo.name), modify.unset('like'));
    if (!res.isSuccess) {
      resultDialog(
        _localizationMap('update'),
        false,
      );
    }
    // Update UI
    tagInfos.remove(tagInfo);
    setState(() {});
  }

  void dataLoader() async {
    await widget.tagCollection
        .find(where
            .excludeFields(['_id'])
            .eq('like', widget.isLiked)
            .sortBy('works_count', descending: true))
        .forEach(
      (data) {
        tagInfos.add(TagInfo.fromJson(data));
      },
    );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    dataLoader();
  }

  @override
  void didChangeDependencies() {
    _localizationMap = MyLocalizations.of(context).tagPage;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<TagInfo>(
        onWillAcceptWithDetails: (details) {
          _isDragIn = true;
          // Always accept add new tag.
          return true;
        },
        onLeave: (data) {
          _isDragIn = false;
        },
        onAcceptWithDetails: (details) {
          _isDragIn = false;
          _addTag(details.data);
        },
        builder: (context, candidateData, rejectedData) => Ink(
              color: _isDragIn ? Theme.of(context).hoverColor : null,
              child: Column(
                children: [
                  Text(widget.isLiked
                      ? _localizationMap('like')
                      : _localizationMap('dislike')),
                  Expanded(
                      child: ListView.separated(
                    padding: const EdgeInsets.only(right: 12),
                    itemBuilder: (context, index) {
                      return TagContainer(
                        tagInfo: tagInfos[index],
                        onTap: widget.onTapContain,
                        trailing: IconButton(
                            onPressed: () => _removeTag(tagInfos[index]),
                            icon: Icon(Icons.delete)),
                      );
                    },
                    separatorBuilder: (context, index) => Divider(
                      height: 0,
                    ),
                    itemCount: tagInfos.length,
                  )),
                ],
              ),
            ));
  }
}
