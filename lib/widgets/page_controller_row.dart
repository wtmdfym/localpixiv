import 'package:flutter/material.dart';
import '../localization/localization.dart';

typedef ChangePageCallback = void Function(int index);

class PageControllerRow extends StatelessWidget {
  PageControllerRow({
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
    // localized text
    late final String Function(String) localizationMap =
        MyLocalizations.of(context).pageController;
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

    return RepaintBoundary(
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
                  controller: _pageController,
                  maxLines: 1,
                  onTapOutside: (_) {
                    if (int.tryParse(_pageController.text) == null) {
                      _pageController.text = '$page/$maxpage';
                    }
                  },
                ))
              ],
            )),
        ElevatedButton(
            onPressed: jumpToPage,
            child: Text(
              localizationMap('jump'),
            )),
        ElevatedButton.icon(
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
    ));
  }
}
