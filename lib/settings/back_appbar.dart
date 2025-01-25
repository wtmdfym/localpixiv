import 'package:flutter/material.dart';

/// Called before pop the route. Call [Navigator.pop] if return `true`.
typedef OnWillPopCallback = bool Function();

class BackAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BackAppBar({
    super.key,
    this.toolbarHeight,
    required this.title,
    this.onWillPop,
    this.backgroundColor,
  });
  final double? toolbarHeight;
  final String title;
  final OnWillPopCallback? onWillPop;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return AppBar(
        toolbarHeight: preferredSize.height,
        backgroundColor: backgroundColor,
        leading: IconButton(
          onPressed: () {
            if (onWillPop != null) {
              final bool needPop = onWillPop!();
              if (!needPop) {
                return;
              }
            }
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_outlined),
          tooltip: 'Back',
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ));
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight ?? kToolbarHeight);
}
