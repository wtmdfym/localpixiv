import 'package:flutter/material.dart';
import '../localization/localization_intl.dart';

typedef ChangePageCallback = void Function(int index);

class PageControllerRow extends StatefulWidget {
  const PageControllerRow({
    super.key,
    required this.maxpage,
    required this.pagesize,
    required this.onPageChange,
  });
  final ValueNotifier<int> maxpage;
  final int pagesize;
  final ChangePageCallback onPageChange;

  @override
  State<StatefulWidget> createState() => _PageControllerRowState();
}

class _PageControllerRowState extends State<PageControllerRow> {
  // 初始化
  int _page = 1;

  final TextEditingController _pageController =
      TextEditingController(text: '1/1');

  // 翻页控制
  void prevPage() {
    if (_page > 1) {
      _page -= 1;
      _pageController.text = '$_page/${widget.maxpage.value}';
      widget.onPageChange(_page);
    }
  }

  void jumpToPage() {
    int newpage =
        int.parse(_pageController.text.replaceFirst(RegExp('/.+'), ''));
    if (_page == newpage) {
    } else if ((0 < newpage) && (newpage <= widget.maxpage.value)) {
      _page = newpage;
      _pageController.text = '$_page/${widget.maxpage.value}';
      widget.onPageChange(_page);
    } else {
      _pageController.text = '$_page/${widget.maxpage.value}';
    }
  }

  void nextPage() {
    if (_page < widget.maxpage.value) {
      _page += 1;
      _pageController.text = '$_page/${widget.maxpage.value}';
      widget.onPageChange(_page);
    }
  }

  @override
  void initState() {
    _pageController.text = '$_page/${widget.maxpage.value}';
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
        child: ValueListenableBuilder(
            valueListenable: widget.maxpage,
            builder: (context, value, child) {
              _page = 1;
              _pageController.text = '$_page/${widget.maxpage.value}';
              return child!;
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: prevPage,
                  icon: Icon(
                    Icons.navigate_before,
                    size: Theme.of(context).iconTheme.size,
                  ),
                  label: Text(
                    MyLocalizations.of(context).page('p'),
                  ),
                ),
                ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 300),
                    child: Row(
                      spacing: 20,
                      children: [
                        Text(MyLocalizations.of(context).page('i')),
                        Expanded(
                            child: TextField(
                          controller: _pageController,
                          maxLines: 1,
                          onTapOutside: (_) {
                            if (int.tryParse(_pageController.text) == null) {
                              _pageController.text =
                                  '$_page/${widget.maxpage.value}';
                            }
                          },
                        ))
                      ],
                    )),
                ElevatedButton(
                    onPressed: jumpToPage,
                    child: Text(
                      MyLocalizations.of(context).page('j'),
                    )),
                ElevatedButton.icon(
                    onPressed: nextPage,
                    icon: Icon(
                      Icons.navigate_next,
                      size: Theme.of(context).iconTheme.size,
                    ),
                    iconAlignment: IconAlignment.end,
                    label: Text(
                      MyLocalizations.of(context).page('n'),
                    )),
              ],
            )));
  }
}

class PageControllerRow2 extends StatelessWidget {
  PageControllerRow2({
    super.key,
    required this.maxpage,
    required this.pagesize,
    required this.onPageChange,
  });
  final int maxpage;
  final int pagesize;
  final ChangePageCallback onPageChange;
  final TextEditingController _pageController =
      TextEditingController(text: '1/1');

  @override
  Widget build(BuildContext context) {
    int page = 1;
    _pageController.text = '$page/$maxpage';

    // 翻页控制
    void prevPage() {
      if (page > 1) {
        page -= 1;
        _pageController.text = '$page/$maxpage';
        onPageChange(page);
      }
    }

    void jumpToPage() {
      int newpage =
          int.parse(_pageController.text.replaceFirst(RegExp('/.+'), ''));
      if (page == newpage) {
      } else if ((0 < newpage) && (newpage <= maxpage)) {
        page = newpage;
        _pageController.text = '$page/$maxpage';
        onPageChange(page);
      } else {
        _pageController.text = '$page/$maxpage';
      }
    }

    void nextPage() {
      if (page < maxpage) {
        page += 1;
        _pageController.text = '$page/$maxpage';
        onPageChange(page);
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: prevPage,
          icon: Icon(
            Icons.navigate_before,
          ),
          label: Text(
            'Prev',
          ),
        ),
        ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 200),
            child: TextField(
              controller: _pageController,
              decoration: InputDecoration(label: Text('Page')),
              maxLength: 10,
              onTapOutside: (_) {
                if (int.tryParse(_pageController.text) == null) {
                  _pageController.text = '$page/$maxpage';
                }
              },
            )),
        ElevatedButton.icon(
            onPressed: jumpToPage,
            icon: Icon(
              Icons.next_plan_outlined,
            ),
            label: Text(
              "Jump",
            )),
        ElevatedButton.icon(
            onPressed: nextPage,
            icon: Icon(
              Icons.navigate_next,
            ),
            iconAlignment: IconAlignment.end,
            label: Text(
              "Next",
            )),
      ],
    );
  }
}
