import 'package:flutter/material.dart';
import 'package:localpixiv/models.dart';

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
  int page = 1;

  final TextEditingController _pageController =
      TextEditingController(text: '1/1');

  // 翻页控制
  void prevPage() {
    if (page > 1) {
      page -= 1;
      _pageController.text = '$page/${widget.maxpage.value}';
      widget.onPageChange(page);
    }
  }

  void jumpToPage() {
    int newpage =
        int.parse(_pageController.text.replaceFirst(RegExp('/.+'), ''));
    if (page == newpage) {
    } else if ((0 < newpage) && (newpage <= widget.maxpage.value)) {
      page = newpage;
      _pageController.text = '$page/${widget.maxpage.value}';
      widget.onPageChange(page);
    } else {
      _pageController.text = '$page/${widget.maxpage.value}';
    }
  }

  void nextPage() {
    if (page < widget.maxpage.value) {
      page += 1;
      _pageController.text = '$page/${widget.maxpage.value}';
      widget.onPageChange(page);
    }
  }

  @override
  void initState() {
    _pageController.text = '$page/${widget.maxpage.value}';
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
              page = 1;
              _pageController.text = '$page/${widget.maxpage.value}';
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
                            _pageController.text = '$page/$value';
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
            }));
  }
}
