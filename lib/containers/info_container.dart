import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:simple_html_css/simple_html_css.dart';

import '../models.dart';
import '../common/tools.dart';
import '../widgets/dialogs.dart';
import '../widgets/workloader.dart';

typedef NeedSearchCallback = void Function(String needSearch);

/// A widget to show work info.
class WorkInfoContainer extends StatelessWidget {
  const WorkInfoContainer({
    super.key,
    required this.workInfo,
    required this.onTapUser,
    required this.onTapTag,
  });
  final WorkInfo workInfo;
  final OpenTabCallback onTapUser;
  final NeedSearchCallback onTapTag;
  @override
  Widget build(BuildContext context) {
    final List<Widget> tags = [];
    workInfo.tags.forEach((key, value) {
      tags.add(
          /*SelectableText.rich(
          TextSpan(
              text: '$key ($value)',
              recognizer: (TapGestureRecognizer()
                ..onTap = () => onTapTag(key)
              )
              )
          )*/
          TextButton(
        onPressed: () => onTapTag(key),
        child: Text('#$key $value'),
      ));
    });
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(workInfo.title,
                style: Theme.of(context).textTheme.titleMedium),
            RichText(
              text: HTML.toTextSpan(
                context,
                workInfo.description,
                defaultTextStyle: Theme.of(context).textTheme.bodyMedium,
                linksCallback: (orginalLink) {
                  // TODO flutter_inappwebview
                  String link = linkConverter(orginalLink);
                  openLinkDialog(context, Uri.parse(link));
                },
              ),
            ),
            Divider(),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: tags,
            ),
            Divider(),
            Text(workInfo.uploadDate),
            Divider(),
            Text.rich(
              TextSpan(
                  text: '${workInfo.userName} ${workInfo.userId}\n',
                  style: Theme.of(context).textTheme.titleSmall,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => onTapUser(workInfo.userName)),
            ),
          ]),
    ));
  }
}

/// /// A widget to show user info.
class UserInfoContainer extends StatelessWidget {
  const UserInfoContainer({
    super.key,
    required this.userInfo,
    required this.hostPath,
    required this.imageCacheRate,
  });
  final UserInfo userInfo;
  final String hostPath;
  final double imageCacheRate;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 30,
      children: [
        Expanded(
          child: ImageLoader(
            path: '$hostPath${userInfo.profileImage}',
            width: 240,
            height: 240,
            cacheRate: imageCacheRate,
          ),
        ),
        Expanded(
            child: SelectableText(
          userInfo.userName,
          style: Theme.of(context).textTheme.titleMedium,
        )),
        Expanded(
            flex: 4,
            child: SelectableText(
              userInfo.userComment,
            )),
      ],
    );
  }
}
