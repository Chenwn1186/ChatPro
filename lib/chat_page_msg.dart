// import 'package:flutter/material.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';

// class ChatPageMsg extends StatelessWidget {
//   const ChatPageMsg(
//       {super.key,
//       required this.left,
//       required this.mdMsg,
//       required this.imgText,
//       required this.headBGColor,
//       required this.headTextColor,
//       required this.bgColor,
//       required this.textColor});

//   ///markdown message
//   final String mdMsg;
//   final String imgText;
//   final bool left;
//   final Color headBGColor;
//   final Color headTextColor;
//   final Color bgColor;
//   final Color textColor;
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (left)
//           HeadImg(
//             imgText: imgText,
//             bgColor: headBGColor,
//             textColor: headTextColor,
//           ),
//         if (!left) const SizedBox(width: 58),
//         const SizedBox(width: 3),
//         Expanded(
//           child: Card(
//             elevation: 4,
//             shape: ContinuousRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             color: bgColor,
//             child: Markdown(
//               selectable: true,
//               data: mdMsg,
//               shrinkWrap: true,
//               styleSheet: MarkdownStyleSheet(
//                 p: TextStyle(color: textColor), // 修改段落文字颜色
//                 h1: TextStyle(color: textColor), // 修改一级标题文字颜色
//                 h2: TextStyle(color: textColor), // 修改二级标题文字颜色
//                 h3: TextStyle(color: textColor), // 修改三级标题文字颜色
//                 h4: TextStyle(color: textColor), // 修改四级标题文字颜色
//                 h5: TextStyle(color: textColor), // 修改五级标题文字颜色
//                 h6: TextStyle(color: textColor), // 修改六级标题文字颜色
//                 blockquote: TextStyle(color: textColor), // 修改引用文字颜色
//                 codeblockDecoration: BoxDecoration(
//                   color: Colors.black, // 修改代码块背景颜色
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 code: const TextStyle(color: Colors.white70), // 修改代码文字颜色
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 3),
//         if (!left)
//           HeadImg(
//             imgText: imgText,
//             bgColor: headBGColor,
//             textColor: headTextColor,
//           ),
//         if (left) const SizedBox(width: 58),
//       ],
//     );
//   }
// }

// class HeadImg extends StatelessWidget {
//   const HeadImg(
//       {super.key,
//       required this.imgText,
//       required this.bgColor,
//       required this.textColor});
//   final String imgText;
//   final Color bgColor;
//   final Color textColor;
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       shape: const CircleBorder(),
//       clipBehavior: Clip.antiAlias,
//       color: bgColor,
//       child: SizedBox(
//           width: 50,
//           height: 50,
//           child: Center(
//             child: Text(
//               imgText,
//               style: TextStyle(
//                   fontSize: 10, overflow: TextOverflow.fade, color: textColor),
//             ),
//           )),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:chat_pro/chat_controller.dart';

class ChatPageMsg extends StatelessWidget {
  const ChatPageMsg({
    super.key,
    required this.left,
    required this.mdMsg,
    required this.imgText,
    required this.headBGColor,
    required this.headTextColor,
    required this.bgColor,
    required this.textColor,
    required this.title,
    required this.index,
  });

  final String mdMsg;
  final String imgText;
  final bool left;
  final Color headBGColor;
  final Color headTextColor;
  final Color bgColor;
  final Color textColor;
  final String title;
  final int index;

  @override
  Widget build(BuildContext context) {
    final chatController = ChatController();
    Map<String, dynamic> metadata = {'liked': false, 'disliked': false};
    bool isLiked = false;
    bool isDisliked = false;

    if (title.isNotEmpty) {
      try {
        final chat = chatController.getChat(title);
        if (index >= 0 && index < chat.messages.length) {
          metadata = chat.messages[index]['metadata'];
          isLiked = metadata['liked'] as bool;
          isDisliked = metadata['disliked'] as bool;
        } else {
          Logger.logError('ChatPageMsg: 索引 $index 超出范围，title: "$title"');
        }
      } catch (e, stackTrace) {
        Logger.logError(
            'ChatPageMsg: 获取 metadata 失败，title: "$title", 错误: $e', stackTrace);
      }
    } else {
      Logger.logError('ChatPageMsg: title 为空，无法获取 metadata');
    }

    return Column(
      crossAxisAlignment:
          left ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Row(
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
            Flexible(
              child: Card(
                elevation: 4,
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: bgColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MarkdownBody(
                    selectable: true,
                    data: mdMsg,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(color: textColor),
                      h1: TextStyle(color: textColor),
                      h2: TextStyle(color: textColor),
                      h3: TextStyle(color: textColor),
                      h4: TextStyle(color: textColor),
                      h5: TextStyle(color: textColor),
                      h6: TextStyle(color: textColor),
                      blockquote: TextStyle(color: textColor),
                      codeblockDecoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      code: const TextStyle(color: Colors.white70),
                    ),
                  ),
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
        if (left)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.thumb_up,
                    color: isLiked ? Colors.green : Colors.grey,
                    size: 20,
                  ),
                  onPressed: () {
                    if (title.isNotEmpty)
                      chatController.likeMessage(title, index);
                  },
                  tooltip: '赞',
                ),
                IconButton(
                  icon: Icon(
                    Icons.thumb_down,
                    color: isDisliked ? Colors.red : Colors.grey,
                    size: 20,
                  ),
                  onPressed: () {
                    if (title.isNotEmpty)
                      chatController.dislikeMessage(title, index);
                  },
                  tooltip: '踩',
                ),
                IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: () {
                    if (title.isNotEmpty)
                      chatController.regenerateMessage(title, index);
                  },
                  tooltip: '重新生成',
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class HeadImg extends StatelessWidget {
  const HeadImg({
    super.key,
    required this.imgText,
    required this.bgColor,
    required this.textColor,
  });
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
              fontSize: 10,
              overflow: TextOverflow.fade,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
