import 'package:flutter/material.dart';
import 'package:localpixiv/common/customnotifier.dart';
import 'package:provider/provider.dart';

class Mytabbar extends StatefulWidget implements PreferredSizeWidget {
  const Mytabbar({
    super.key,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight); // 假设AppBar高度为kToolbarHeight
  @override
  State<StatefulWidget> createState() {
    return MytabbarState();
  }
}

class MytabbarState extends State<Mytabbar> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Selector<StackChangeNotifier, List<String>>(
        selector: (context, stackData) {
      return List.unmodifiable(stackData.titles);
    }, builder: (context, titles, child) {
      return TabBar(
          isScrollable: true,
          controller: TabController(
            vsync: this,
            length: titles.length,
            initialIndex: titles.isEmpty ? titles.length : titles.length - 1,
          ),
          onTap: (value) =>
              context.read<StackChangeNotifier>().changeIndex(value, false),
          tabs: [
            for (int index = 0; index < titles.length; index++)
              SizedBox(
                  width: 300,
                  child: ListTile(
                    title: Text(titles[index],
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 12,
                        )),
                    trailing: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Provider.of<StackChangeNotifier>(context, listen: false)
                            .removeAt(
                          index,
                        );
                      },
                    ),
                  ))
          ]);
    });
  }
}
