import 'package:flutter/material.dart';

Future<String> inputDialog(BuildContext context, String title,
    {String? initialValue,
    InputDecoration? decoration,
    String? Function(String?)? validator}) async {
  final String result = initialValue ?? '';
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: TextFormField(
          initialValue: initialValue,
          decoration: decoration,
          validator: validator,
          onSaved: (newValue) => result,
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            'Apply',
          ),
          onPressed: () {
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
            }
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(
            'Cancel',
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
  return result;
}
