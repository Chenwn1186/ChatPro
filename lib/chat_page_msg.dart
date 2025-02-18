import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// class ChatMsg {
//   static Widget build(
//       {required String mdMsg, required bool left}) {
//     if (left) {
//       return ChatPageMsg(
//         left: left,
//         mdMsg: mdMsg,
//         imgText: '666',
//         headBGColor: const Color.fromARGB(255, 166, 51, 243),
//         headTextColor: Colors.white,
//         bgColor: const Color.fromARGB(255, 255, 204, 255),
//         textColor: const Color.fromARGB(255, 166, 51, 243),
//       );
//     } else {
//       return ChatPageMsg(
//         left: left,
//         mdMsg: mdMsg,
//         imgText: '奶龙',
//         headBGColor: const Color.fromARGB(255, 6, 94, 166),
//         headTextColor: Colors.white,
//         bgColor: const Color.fromARGB(255, 185, 225, 255),
//         textColor: const Color.fromARGB(255, 6, 94, 166),
//       );
//     }
//   }
// }

class ChatPageMsg extends StatelessWidget {
  const ChatPageMsg(
      {super.key,
      required this.left,
      required this.mdMsg,
      required this.imgText,
      required this.headBGColor,
      required this.headTextColor,
      required this.bgColor,
      required this.textColor});

  ///markdown message
  final String mdMsg;
  final String imgText;
  final bool left;
  final Color headBGColor;
  final Color headTextColor;
  final Color bgColor;
  final Color textColor;
  @override
  Widget build(BuildContext context) {
    return Row(
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
            elevation: 4,
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: bgColor,
            child: Markdown(
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
