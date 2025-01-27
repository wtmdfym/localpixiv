import 'package:flutter/material.dart';

import '../models.dart';

typedef NeedSearchCallback = void Function(String needSearch);

/// A widget to show tag infoa.
class TagContainer extends StatelessWidget {
  const TagContainer({
    super.key,
    required this.tagInfo,
    required this.onTap,
    this.trailing,
  });
  final TagInfo tagInfo;
  final NeedSearchCallback onTap;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    return Draggable<TagInfo>(
      data: tagInfo,
      dragAnchorStrategy: (draggable, context, position) => Offset(0, 50),
      feedback: Material(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(mainAxisSize: MainAxisSize.min, spacing: 10, children: [
              Text(tagInfo.name),
              Text(tagInfo.translation),
              Text(tagInfo.workCount.toString()),
            ]),
          ),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () => onTap(tagInfo.name),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Expanded(flex: 5, child: Text(tagInfo.name)),
            Expanded(flex: 5, child: Text(tagInfo.translation)),
            Expanded(child: Text(tagInfo.workCount.toString())),
            if (trailing != null) trailing!,
          ]),
        ),
      ),
    );
  }
}
