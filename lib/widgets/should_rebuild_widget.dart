import 'package:flutter/material.dart';

typedef ShouldRebuildFunction<T> = bool Function(T oldWidget, T newWidget);

/// Copy from https://github.com/fantasy525/should_rebuild
class ShouldRebuildWidget<T extends Widget> extends StatefulWidget {
  final T child;
  final ShouldRebuildFunction<T>? shouldRebuild;
  const ShouldRebuildWidget(
      {super.key, required this.child, this.shouldRebuild});
  @override
  State createState() => _ShouldRebuildWidgetState<T>();
}

class _ShouldRebuildWidgetState<T extends Widget>
    extends State<ShouldRebuildWidget> {
  @override
  ShouldRebuildWidget<T> get widget => super.widget as ShouldRebuildWidget<T>;
  T? oldWidget;
  @override
  Widget build(BuildContext context) {
    final T newWidget = widget.child;
    if (this.oldWidget == null ||
        (widget.shouldRebuild == null
            ? true
            : widget.shouldRebuild!(oldWidget!, newWidget))) {
      this.oldWidget = newWidget;
    }
    return oldWidget as T;
  }
}
