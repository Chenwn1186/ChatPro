// ChatPageMsg
// ├── FadeInParent
// │   └── Row
// │       ├── if (left) HeadImg
// │       ├── if (!left) SizedBox(width: 58)
// │       ├── SizedBox(width: 3)
// │       ├── Expanded
// │       │   └── Card
// │       │       └── Column
// │       │           ├── Markdown
// │       │           ├── if (showRecommendations) Column
// │       │           │   └── ... (recommendations.map(...))
// │       │           └── Row
// │       │               ├── SizedBox(width: 4)
// │       │               ├── if (left) IconButton (thumb up)
// │       │               ├── if (left) IconButton (thumb down)
// │       │               ├── if (left) IconButton (resend)
// │       │               └── if (left && recommendations.isNotEmpty) IconButton (expand/collapse)
// │       ├── SizedBox(width: 3)
// │       ├── if (!left) HeadImg
// │       └── if (left) SizedBox(width: 58)

import 'package:chat_pro/chat_controller.dart';
import 'package:chat_pro/ui/animations.dart';
import 'package:chat_pro/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatPageMsg extends StatelessWidget {
  const ChatPageMsg(
      {super.key,
      required this.left,
      required this.mdMsg,
      required this.imgText,
      required this.headBGColor,
      required this.headTextColor,
      required this.bgColor,
      required this.textColor,
      required this.recommendations,
      required this.index,
      this.thumbUp = '',
      this.showRecommendations = true});

  ///markdown message
  final String mdMsg;
  final String imgText;
  final bool left;
  final Color headBGColor;
  final Color headTextColor;
  final Color bgColor;
  final Color textColor;
  final List<String> recommendations;
  final int index;
  final String thumbUp;
  final bool showRecommendations;
  @override
  Widget build(BuildContext context) {
    return FadeInParent(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (left)
            HeadImg(
              imgText: imgText,
              bgColor: headBGColor,
              textColor: headTextColor,
            ),
          if (!left) const SizedBox(width: 58),
          const SizedBox(width: 3),
          Expanded(
            child: Card(
              elevation: 0,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: bgColor,
              child: Column(
                children: [
                  Markdown(
                    selectable: true,
                    data: mdMsg,
                    shrinkWrap: true,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(color: textColor), // 修改段落文字颜色
                      h1: TextStyle(color: textColor), // 修改一级标题文字颜色
                      h2: TextStyle(color: textColor), // 修改二级标题文字颜色
                      h3: TextStyle(color: textColor), // 修改三级标题文字颜色
                      h4: TextStyle(color: textColor), // 修改四级标题文字颜色
                      h5: TextStyle(color: textColor), // 修改五级标题文字颜色
                      h6: TextStyle(color: textColor), // 修改六级标题文字颜色
                      blockquote: TextStyle(color: textColor), // 修改引用文字颜色
                      codeblockDecoration: BoxDecoration(
                        color: Colors.black, // 修改代码块背景颜色
                        borderRadius: BorderRadius.circular(8),
                      ),
                      code: const TextStyle(color: Colors.white70), // 修改代码文字颜色
                    ),
                  ),
                  // if (showRecommendations)
                  if (false)
                    Column(
                      children: recommendations
                          .map((e) => Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: FadeInParent(
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Card(
                                      elevation: 0,
                                      shape: ContinuousRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: const BorderSide(
                                          color: Color.fromARGB(
                                              255, 216, 216, 216),
                                          width: 1,
                                        ),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          ChatController()
                                              .textEditingController
                                              .text = e;
                                          ChatController().update();
                                        },
                                        child: Padding(
                                            padding: const EdgeInsets.all(3),
                                            child: Text(
                                              e,
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                              textAlign: TextAlign.left,
                                            )),
                                      ),
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 4,
                      ),
                      if (left)
                        IconButton(
                            onPressed: () {
                              if (thumbUp != 'up') {
                                ChatController().setThumbUp(index, 'up');
                              } else {
                                ChatController().setThumbUp(index, '');
                              }
                            },
                            icon: Icon(
                              thumbUp == 'up'
                                  ? Icons.thumb_up_alt
                                  : Icons.thumb_up_alt_outlined,
                              color: ChatThemes().getColors()[3],
                              size: 20,
                            )),
                      if (left)
                        IconButton(
                            onPressed: () {
                              if (thumbUp != 'down') {
                                ChatController().setThumbUp(index, 'down');
                              } else {
                                ChatController().setThumbUp(index, '');
                              }
                            },
                            icon: Icon(
                              thumbUp == 'down'
                                  ? Icons.thumb_down_alt
                                  : Icons.thumb_down_alt_outlined,
                              color: ChatThemes().getColors()[3],
                              size: 20,
                            )),
                      if (left)
                        IconButton(
                            onPressed: () {
                              ChatController().resendMsg();
                            },
                            icon: Icon(
                              Icons.replay_outlined,
                              color: ChatThemes().getColors()[3],
                            )),
                      if (left && recommendations.isNotEmpty)
                        IconButton(
                            onPressed: () {
                              if (showRecommendations) {
                                ChatController()
                                    .setShowRecommendations(false, index);
                              } else {
                                ChatController()
                                    .setShowRecommendations(true, index);
                              }
                            },
                            icon: Icon(
                              showRecommendations
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: ChatThemes().getColors()[3],
                              size: 20,
                            )),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(width: 3),
          if (!left)
            HeadImg(
              imgText: imgText,
              bgColor: headBGColor,
              textColor: headTextColor,
            ),
          if (left) const SizedBox(width: 58),
        ],
      ),
    );
  }
}

class HeadImg extends StatelessWidget {
  const HeadImg(
      {super.key,
      required this.imgText,
      required this.bgColor,
      required this.textColor});
  final String imgText;
  final Color bgColor;
  final Color textColor;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: bgColor,
      child: SizedBox(
          width: 50,
          height: 50,
          child: Center(
            child: Text(
              imgText,
              style: TextStyle(
                  fontSize: 10, overflow: TextOverflow.fade, color: textColor),
            ),
          )),
    );
  }
}
