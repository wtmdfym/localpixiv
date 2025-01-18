import 'package:flutter/material.dart';

class BackAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BackAppBar({
    super.key,
    this.toolbarHeight,
    required this.title,
    this.onPop,
    this.backgroundColor,
  });
  final double? toolbarHeight;
  final String title;
  final VoidCallback? onPop;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return AppBar(
        toolbarHeight: preferredSize.height,
        backgroundColor: backgroundColor,
        leading: Tooltip(
            message: 'Back',
            child: IconButton(
                onPressed: () {
                  if (onPop != null) {
                    onPop!();
                  }
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_outlined))),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ));
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight ?? kToolbarHeight);
}
