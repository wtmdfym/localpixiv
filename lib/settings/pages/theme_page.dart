import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

import '../../localization/localization_intl.dart';
import '../back_appbar.dart';
import '../settings_controller.dart';

/// Theme

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key, required this.controller});
  final SettingsController controller;
  static const routeName = '/theme';
  @override
  State<StatefulWidget> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  // The color which is using now.
  late Color _color;

  @override
  void initState() {
    super.initState();
    _color = widget.controller.color;
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> colorPickerDialog() async {
      return ColorPicker(
        // Use the dialogPickerColor as start and active color.
        color: _color,
        // Update the dialogPickerColor using the callback.
        onColorChanged: (Color color) => setState(() => _color = color),
        width: 40,
        height: 40,
        borderRadius: 4,
        spacing: 5,
        runSpacing: 5,
        wheelDiameter: 155,
        heading: Text(
          'Select color',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subheading: Text(
          'Select color shade',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        wheelSubheading: Text(
          'Selected color and its shades',
          style: Theme.of(context).textTheme.titleSmall,
        ),

        showMaterialName: true,
        showColorName: true,
        showColorCode: true,
        copyPasteBehavior: const ColorPickerCopyPasteBehavior(
          longPressMenu: true,
        ),
        materialNameTextStyle: Theme.of(context).textTheme.bodySmall,
        colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
        colorCodeTextStyle: Theme.of(context).textTheme.bodySmall,
        pickersEnabled: const <ColorPickerType, bool>{
          ColorPickerType.both: false,
          ColorPickerType.primary: true,
          ColorPickerType.accent: true,
          ColorPickerType.bw: true,
          ColorPickerType.custom: false,
          ColorPickerType.wheel: true,
        },
        enableShadesSelection: true,
        enableOpacity: true,
      ).showPickerDialog(
        context,
        // New in version 3.0.0 custom transitions support.
        /*transitionBuilder: (BuildContext context, Animation<double> a1,
            Animation<double> a2, Widget widget) {
          final double curvedValue =
              Curves.easeInOutBack.transform(a1.value) - 1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Opacity(
              opacity: a1.value,
              child: widget,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
        constraints:
            const BoxConstraints(minHeight: 460, minWidth: 300, maxWidth: 320),*/
      );
    }

    return Scaffold(
        appBar: BackAppBar(
          title: MyLocalizations.of(context).settingsTitle('theme'),
          backgroundColor: _color,
        ),
        body: Padding(
            padding: const EdgeInsets.all(8),
            child:
                Column(mainAxisSize: MainAxisSize.min, spacing: 20, children: [
              DropdownButton<ThemeMode>(
                isExpanded: true,
                // Read the selected themeMode from the controller
                value: widget.controller.themeMode,
                // Call the updateThemeMode method any time the user selects a theme.
                onChanged: (value) =>
                    {widget.controller.updateThemeMode(value), setState(() {})},
                items: [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text(MyLocalizations.of(context).theme('system')),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text(MyLocalizations.of(context).theme('light')),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text(MyLocalizations.of(context).theme('dark')),
                  )
                ],
              ),
              ListTile(
                title: Text(
                    MyLocalizations.of(context).settingsContain('chooseColor')),
                onTap: () async {
                  // Store current color before we open the dialog.
                  final Color colorBeforeDialog = _color;
                  // Wait for the picker to close, if dialog was dismissed,
                  // then restore the color we had before it was opened.
                  if (!(await colorPickerDialog())) {
                    setState(() {
                      _color = colorBeforeDialog;
                    });
                  } else {
                    // Update the color of whole app.
                    widget.controller.updateColorScheme(_color);
                  }
                },
                trailing: ColorIndicator(
                    width: 44,
                    height: 44,
                    borderRadius: 4,
                    color: _color,
                    onSelectFocus: false),
              ), // Show the color picker in sized box in a raised card.
            ])));
  }
}
