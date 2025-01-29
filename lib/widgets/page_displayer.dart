import 'package:flutter/material.dart';

import '../localization/localization.dart';

typedef ChangePageCallback = void Function(int page);

/// The widget supports building flexible and scrollable page-like views.
class PageDisplayer extends StatefulWidget {
  PageDisplayer({
    super.key,
    required this.maxPage,
    required this.pageSize,
    this.columnCount,
    this.childAspectRatio,
    required this.onPageChange,
    this.padding,
    this.rowSpace = 0.0,
    this.columnSpace = 0.0,
    required this.scrollable,
    required this.children,
  }) {
    assert(children.length == pageSize);
    if (columnCount == null) {
      assert(childAspectRatio != null);
      return;
    }
    assert(childAspectRatio == null);
    assert(children.length > columnCount!);
  }

  /// The maximum number of pages that can be changed.
  final int maxPage;

  /// The count of child to display per page. Must be equal to `children.length`.
  final int pageSize;

  /// If not null, the count of child display in a row is fixed.
  /// This value must be less than or equal to `children.length`.
  /// `columnCount` and `childAspectRatio` must have one and only one defined.
  final int? columnCount;

  /// If not null, the count of child display in a row will change with the size of the window.
  /// `columnCount` and `childAspectRatio` must have one and only one defined.
  final double? childAspectRatio;

  /// Called when the user changes the displayed page.
  final ChangePageCallback onPageChange;

  final EdgeInsetsGeometry? padding;
  final double rowSpace;
  final double columnSpace;

  /// If true, use [ListView] to build page, otherwise use [Column] and [Row] instead.
  final bool scrollable;
  final List<Widget> children;

  @override
  State<StatefulWidget> createState() {
    return _PageDisplayerState();
  }
}

class _PageDisplayerState extends State<PageDisplayer> {
  // localized text
  late String Function(String) localizationMap;
  final TextEditingController _pageTextEditingController =
      TextEditingController(text: '1/1');
  int page = 1;
  late int columnCount;

  @override
  void initState() {
    columnCount = widget.columnCount ?? 1;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    localizationMap = MyLocalizations.of(context).pageController;
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant PageDisplayer oldWidget) {
    if (oldWidget.maxPage.hashCode != widget.maxPage.hashCode) {
      page = 1;
    }
    _pageTextEditingController.text = '$page/${widget.maxPage}';
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _pageTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget current;
    if (widget.scrollable) {
      current = ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.only(right: 12),
        itemCount: (widget.pageSize / columnCount).ceil(),
        itemBuilder: (context, index) {
          final List<Widget> rowWidgets;
          if ((index + 1) * columnCount <= widget.children.length) {
            rowWidgets = widget.children
                .sublist(index * columnCount, (index + 1) * columnCount);
          } else {
            rowWidgets = widget.children.sublist(index * columnCount);
          }
          final int lake = columnCount - rowWidgets.length;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: widget.rowSpace,
            children: [
              for (Widget child in rowWidgets) Expanded(child: child),
              for (int i = 0; i < lake; i++)
                Expanded(
                  child: SizedBox(),
                )
            ],
          );
        },
        separatorBuilder: (context, index) =>
            SizedBox(height: widget.columnSpace),
      );
    } else {
      current = LayoutBuilder(
        builder: (context, constraints) {
          if (widget.childAspectRatio != null) {
            final double aspectRatio =
                constraints.maxWidth / constraints.maxHeight;
            columnCount = (aspectRatio / widget.childAspectRatio!).round();
          }
          return Column(
            spacing: widget.columnSpace,
            children: [
              for (int j = 0; j < widget.pageSize / columnCount; j++)
                Expanded(
                    child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: widget.columnSpace,
                  children: [
                    for (int i = j * columnCount;
                        i < widget.pageSize - (1 - j) * columnCount;
                        i++)
                      Expanded(child: widget.children[i]),
                  ],
                )),
            ],
          );
        },
      );
    }
    current = Column(children: [
      Expanded(child: current),
      RepaintBoundary(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton.icon(
            onPressed: prevPage,
            icon: Icon(
              Icons.navigate_before,
              size: Theme.of(context).iconTheme.size,
            ),
            label: Text(
              localizationMap('prev'),
            ),
          ),
          ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300),
              child: Row(
                spacing: 20,
                children: [
                  Text(localizationMap('input')),
                  Expanded(
                      child: TextField(
                    controller: _pageTextEditingController,
                    maxLines: 1,
                    onTapOutside: (_) {
                      if (int.tryParse(_pageTextEditingController.text) ==
                          null) {
                        _pageTextEditingController.text =
                            '$page/${widget.maxPage}';
                      }
                    },
                  ))
                ],
              )),
          TextButton(
              onPressed: jumpToPage,
              child: Text(
                localizationMap('jump'),
              )),
          TextButton.icon(
              onPressed: nextPage,
              icon: Icon(
                Icons.navigate_next,
                size: Theme.of(context).iconTheme.size,
              ),
              iconAlignment: IconAlignment.end,
              label: Text(
                localizationMap('next'),
              )),
        ],
      ))
    ]);
    if (widget.padding != null) {
      return Padding(padding: widget.padding!, child: current);
    } else {
      return current;
    }
  }

  void prevPage() {
    if (page > 1) {
      page -= 1;
      widget.onPageChange(page);
    }
    _pageTextEditingController.text = '$page/${widget.maxPage}';
  }

  void jumpToPage() {
    int? newpage = int.tryParse(
        _pageTextEditingController.text.replaceFirst(RegExp('/.+'), ''));
    if (newpage == null) {
      return;
    }
    if (page == newpage) {
      return;
    }
    if ((0 < newpage) && (newpage <= widget.maxPage)) {
      page = newpage;
      widget.onPageChange(page);
    }
    _pageTextEditingController.text = '$page/${widget.maxPage}';
  }

  void nextPage() {
    if (page < widget.maxPage) {
      page += 1;
      widget.onPageChange(page);
    }
    _pageTextEditingController.text = '$page/${widget.maxPage}';
  }
}
