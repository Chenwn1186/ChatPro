// // import 'dart:io';

// // import 'package:chat_pro/chat_controller.dart';
// // import 'package:chat_pro/ui/pura_multiple_radial_gradients.dart';
// // import 'package:chat_pro/util/chat_image_data.dart';
// // import 'package:chat_pro/util/file_utils.dart';
// // import 'package:dart_openai/dart_openai.dart';
// // // import 'package:chat_pro/chat_page_msg.dart';
// // import 'package:flutter/material.dart';
// // // import 'package:flutter_markdown/flutter_markdown.dart';
// // import 'package:provider/provider.dart';

// // // 将 ChatPage 改为 StatefulWidget
// // class ChatPage extends StatefulWidget {
// //   const ChatPage({super.key, required this.chatRecord});
// //   // final ChatRecord chatRecord;
// //   final Chat chatRecord;

// //   @override
// //   State<ChatPage> createState() => _ChatPageState();
// // }

// // class _ChatPageState extends State<ChatPage> {
// //   final ScrollController _scrollController = ScrollController();

// //   @override
// //   void dispose() {
// //     _scrollController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     var size = MediaQuery.sizeOf(context);
// //     var width = size.width;
// //     // var height = size.height;

// //     return Scaffold(
// //       appBar: AppBar(
// //         centerTitle: true,
// //         elevation: 4,
// //         scrolledUnderElevation: 4,
// //         backgroundColor: const Color.fromARGB(255, 139, 211, 253),
// //         title: Text(widget.chatRecord.title),
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back),
// //           onPressed: () {
// //             Navigator.of(context).pop();
// //           },
// //         ),
// //       ),
// //       backgroundColor: Colors.transparent,
// //       body: Stack(
// //         children: [
// //           PuraMultipleRadialGradients(
// //             inputPoints: [
// //               InputPoint(
// //                 const Offset(0.25, 0.25),
// //                 const Color.fromARGB(255, 54, 70, 244),
// //                 0.19,
// //                 0.25,
// //                 const Duration(seconds: 2),
// //               ),
// //               InputPoint(
// //                 const Offset(0.75, 0.25),
// //                 Colors.blue,
// //                 0.28,
// //                 0.35,
// //                 const Duration(seconds: 3),
// //               ),
// //               InputPoint(
// //                 const Offset(0.6, 0.75),
// //                 const Color.fromARGB(255, 76, 172, 175),
// //                 0.26,
// //                 0.38,
// //                 const Duration(seconds: 4),
// //               ),
// //               InputPoint(
// //                 const Offset(0.4, 0.5),
// //                 const Color.fromARGB(255, 221, 154, 225),
// //                 0.12,
// //                 0.28,
// //                 const Duration(seconds: 2, microseconds: 450),
// //               ),
// //               InputPoint(
// //                 const Offset(0.1, 0.8),
// //                 const Color.fromARGB(255, 0, 250, 129),
// //                 0.12,
// //                 0.18,
// //                 const Duration(seconds: 2, microseconds: 450),
// //               ),
// //             ],
// //             backgroundColor: Colors.white,
// //           ),
// //           Row(
// //             children: [
// //               SizedBox(
// //                 width: width * 0.5,
// //                 child: Selector<ChatController, (String, List<int>)>(
// //                   selector: (_, myType) => (
// //                     myType.getImgsText(widget.chatRecord.title),
// //                     myType.selectedImgs
// //                   ),
// //                   shouldRebuild: (previous, next) => true,
// //                   builder: (context, data, child) {
// //                     var imgs = data.$1.split('\n');

// //                     return Card(
// //                         color: const Color.fromARGB(255, 229, 229, 229),
// //                         elevation: 4,
// //                         shape: ContinuousRectangleBorder(
// //                           borderRadius: BorderRadius.circular(16),
// //                         ),
// //                         child: Padding(
// //                           padding: const EdgeInsets.all(8.0),
// //                           child: ListView.builder(
// //                             itemCount: imgs.length + 1,
// //                             itemBuilder: (BuildContext context, int index) {
// //                               if (index == 0) {
// //                                 return const Text(
// //                                   '  图片',
// //                                   style: TextStyle(fontSize: 22),
// //                                 );
// //                               }
// //                               if (imgs[index - 1].isEmpty) {
// //                                 return const SizedBox();
// //                               }
// //                               return Card(
// //                                 child: Row(
// //                                   children: [
// //                                     SizedBox(
// //                                       width: width * 0.22,
// //                                       height: width * 0.22,
// //                                       child: InkWell(
// //                                         onTap: () {
// //                                           // 处理点击事件
// //                                           // print('点击了图片 ${imgs[index]}');
// //                                           if (ChatController()
// //                                               .selectedImgs
// //                                               .contains(index)) {
// //                                             ChatController()
// //                                                 .selectedImgs
// //                                                 .remove(index);
// //                                           } else {
// //                                             ChatController()
// //                                                 .selectedImgs
// //                                                 .add(index);
// //                                           }
// //                                           ChatController().update();
// //                                         },
// //                                         child: Padding(
// //                                           padding: const EdgeInsets.only(
// //                                               bottom: 4.0, top: 4.0),
// //                                           child: Material(
// //                                               color: const Color.fromARGB(
// //                                                   0, 59, 173, 255),
// //                                               shape: ContinuousRectangleBorder(
// //                                                 borderRadius:
// //                                                     BorderRadius.circular(16),
// //                                               ),
// //                                               clipBehavior: Clip.antiAlias,
// //                                               child: Padding(
// //                                                 padding: !ChatController()
// //                                                         .selectedImgs
// //                                                         .contains(index)
// //                                                     ? const EdgeInsets.all(0.0)
// //                                                     : const EdgeInsets.all(8.0),
// //                                                 child: Container(
// //                                                     clipBehavior:
// //                                                         Clip.antiAlias,
// //                                                     decoration: ShapeDecoration(
// //                                                         shape:
// //                                                             ContinuousRectangleBorder(
// //                                                       side: BorderSide(
// //                                                           width: 3,
// //                                                           color: !ChatController().selectedImgs.contains(index)? Colors.transparent: Colors.blue,
// //                                                       ),
// //                                                       borderRadius:
// //                                                           BorderRadius.circular(
// //                                                               16),
// //                                                     )),
// //                                                     child: Image.file(
// //                                                         File(imgs[index - 1]))),
// //                                               )),
// //                                         ),
// //                                       ),
// //                                     ),
// //                                     SizedBox(
// //                                       width: width * 0.25,
// //                                       child: ChatImageData(index-1, title: widget.chatRecord.title).buildWidget(context),
// //                                     )
// //                                   ],
// //                                 ),
// //                               );
// //                             },
// //                           ),
// //                         ));
// //                   },
// //                 ),
// //               ),
// //               // SizedBox(
// //               //   width: width * 0.25,
// //               // ),
// //               Expanded(
// //                 child: Column(
// //                   children: [
// //                     Selector<ChatController,
// //                         List<OpenAIChatCompletionChoiceMessageModel>>(
// //                       // 修改为调用新的方法
// //                       selector: (_, myType) =>
// //                           myType.getChat(widget.chatRecord.title).content,
// //                       shouldRebuild: (previous, next) => true,
// //                       builder: (context, messages, child) {
// //                         // 当消息列表更新时，滚动到最底部
// //                         WidgetsBinding.instance.addPostFrameCallback((_) {
// //                           if (_scrollController.hasClients) {
// //                             _scrollController.jumpTo(
// //                                 _scrollController.position.maxScrollExtent);
// //                           }
// //                         });
// //                         return Expanded(
// //                           child: ListView.builder(
// //                             controller: _scrollController,
// //                             itemCount: messages.length,
// //                             itemBuilder: (BuildContext context, int index) {
// //                               return widget.chatRecord.buildWidget(index);
// //                             },
// //                           ),
// //                         );
// //                       },
// //                     ),
// //                     Stack(children: [
// //                       ChatInputField(title: widget.chatRecord.title),
// //                     ])
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class ChatInputField extends StatefulWidget {
// //   const ChatInputField({super.key, required this.title});
// //   final String title;

// //   @override
// //   State<ChatInputField> createState() => _ChatInputFieldState();
// // }

// // class _ChatInputFieldState extends State<ChatInputField> {
// //   final TextEditingController _textEditingController = TextEditingController();
// //   final FocusNode _focusNode = FocusNode();

// //   @override
// //   void initState() {
// //     super.initState();
// //     _focusNode.requestFocus(); // 初始化时请求焦点
// //   }

// //   @override
// //   void dispose() {
// //     _textEditingController.dispose();
// //     _focusNode.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Card(
// //       elevation: 4,
// //       shape: const ContinuousRectangleBorder(
// //         borderRadius: BorderRadius.all(Radius.circular(20)),
// //       ),
// //       child: Padding(
// //         padding: const EdgeInsets.symmetric(horizontal: 8),
// //         child: Row(
// //           children: [
// //             Expanded(
// //               child: ConstrainedBox(
// //                 constraints: const BoxConstraints(
// //                   maxHeight: 120, // 设置输入框的最大高度
// //                 ),
// //                 child: SingleChildScrollView(
// //                   child: TextField(
// //                     controller: _textEditingController,
// //                     focusNode: _focusNode,
// //                     decoration: const InputDecoration(
// //                       hintText: '输入消息...',
// //                       border: InputBorder.none,
// //                     ),
// //                     maxLines: null,
// //                     enableInteractiveSelection: true,
// //                     enableIMEPersonalizedLearning: true,
// //                     keyboardType: TextInputType.multiline,
// //                     textInputAction: TextInputAction.newline,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             IconButton(
// //               onPressed: () {
// //                 ChatController().summarize(widget.title);
// //               },
// //               icon: const Icon(Icons.done_all_outlined),
// //               tooltip: "总结",
// //             ),
// //             IconButton(
// //               icon: const Icon(Icons.photo),
// //               tooltip: "上传图片",
// //               onPressed: () async {
// //                 // 处理上传图片的逻辑
// //                 List<String>? filePaths = await FileUtils.pickFile(context);
// //                 if (filePaths != null && filePaths.isNotEmpty) {
// //                   String chatDir = 'chats/${widget.title}';
// //                   await FileUtils.createDirectoryIfNotExists(chatDir);
// //                   String imgMDText = '';
// //                   for (String filePath in filePaths) {
// //                     String newPath =
// //                         await FileUtils.copyFileToDirectory(filePath, chatDir);
// //                     newPath = newPath.replaceAll('\\', '/');

// //                     if (newPath.isNotEmpty) {
// //                       // String relativePath = newPath.split('chats/').last;
// //                       imgMDText += '$newPath\n';
// //                       // setState(() {
// //                       //   _textEditingController.text += '\n$markdown';
// //                       //   _textEditingController.selection = TextSelection.fromPosition(
// //                       //     TextPosition(offset: _textEditingController.text.length),
// //                       //   );
// //                       // }
// //                       // );
// //                     }
// //                   }

// //                   ChatController().updateImgs(widget.title, imgMDText);
// //                 }
// //               },
// //             ),
// //             IconButton(
// //               icon: const Icon(Icons.send),
// //               tooltip: "发送",
// //               onPressed: () {
// //                 if (_textEditingController.text.isNotEmpty) {
// //                   // 处理发送消息的逻辑
// //                   ChatController().sendMessage(
// //                       widget.title, _textEditingController.text, false);
// //                   // print('发送消息: ${_textEditingController.text}');
// //                   //todo: 发送信息到服务器
// //                   _textEditingController.clear();
// //                   // 发送消息后重新请求焦点
// //                   WidgetsBinding.instance.addPostFrameCallback((_) {
// //                     _focusNode.requestFocus();
// //                   });
// //                 }
// //               },
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'dart:io';
// import 'package:chat_pro/chat_controller.dart';
// import 'package:chat_pro/ui/pura_multiple_radial_gradients.dart';
// import 'package:chat_pro/util/chat_image_data.dart';
// import 'package:chat_pro/util/file_utils.dart';
// import 'package:dart_openai/dart_openai.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class ChatPage extends StatefulWidget {
//   const ChatPage({super.key, required this.title});
//   final String title; // 只传递 title

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.sizeOf(context);
//     var width = size.width;

//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         elevation: 4,
//         scrolledUnderElevation: 4,
//         backgroundColor: const Color.fromARGB(255, 139, 211, 253),
//         title: Text(widget.title),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//       ),
//       backgroundColor: Colors.transparent,
//       body: Stack(
//         children: [
//           PuraMultipleRadialGradients(
//             inputPoints: [
//               InputPoint(
//                 const Offset(0.25, 0.25),
//                 const Color.fromARGB(255, 54, 70, 244),
//                 0.19,
//                 0.25,
//                 const Duration(seconds: 2),
//               ),
//               InputPoint(
//                 const Offset(0.75, 0.25),
//                 Colors.blue,
//                 0.28,
//                 0.35,
//                 const Duration(seconds: 3),
//               ),
//               InputPoint(
//                 const Offset(0.6, 0.75),
//                 const Color.fromARGB(255, 76, 172, 175),
//                 0.26,
//                 0.38,
//                 const Duration(seconds: 4),
//               ),
//               InputPoint(
//                 const Offset(0.4, 0.5),
//                 const Color.fromARGB(255, 221, 154, 225),
//                 0.12,
//                 0.28,
//                 const Duration(seconds: 2, microseconds: 450),
//               ),
//               InputPoint(
//                 const Offset(0.1, 0.8),
//                 const Color.fromARGB(255, 0, 250, 129),
//                 0.12,
//                 0.18,
//                 const Duration(seconds: 2, microseconds: 450),
//               ),
//             ],
//             backgroundColor: Colors.white,
//           ),
//           Row(
//             children: [
//               SizedBox(
//                 width: width * 0.5,
//                 child: Selector<ChatController, (String, List<int>)>(
//                   selector: (_, myType) =>
//                       (myType.getImgsText(widget.title), myType.selectedImgs),
//                   shouldRebuild: (previous, next) => true,
//                   builder: (context, data, child) {
//                     var imgs = data.$1.split('\n');
//                     return Card(
//                       color: const Color.fromARGB(255, 229, 229, 229),
//                       elevation: 4,
//                       shape: ContinuousRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: ListView.builder(
//                           itemCount: imgs.length + 1,
//                           itemBuilder: (BuildContext context, int index) {
//                             if (index == 0) {
//                               return const Text(
//                                 '  图片',
//                                 style: TextStyle(fontSize: 22),
//                               );
//                             }
//                             if (imgs[index - 1].isEmpty) {
//                               return const SizedBox();
//                             }
//                             return Card(
//                               child: Row(
//                                 children: [
//                                   SizedBox(
//                                     width: width * 0.22,
//                                     height: width * 0.22,
//                                     child: InkWell(
//                                       onTap: () {
//                                         if (ChatController()
//                                             .selectedImgs
//                                             .contains(index)) {
//                                           ChatController()
//                                               .selectedImgs
//                                               .remove(index);
//                                         } else {
//                                           ChatController()
//                                               .selectedImgs
//                                               .add(index);
//                                         }
//                                         ChatController().update();
//                                       },
//                                       child: Padding(
//                                         padding: const EdgeInsets.only(
//                                             left: 4.0, top: 4.0),
//                                         child: Material(
//                                           color: const Color.fromARGB(
//                                               0, 59, 173, 255),
//                                           shape: ContinuousRectangleBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(16),
//                                           ),
//                                           clipBehavior: Clip.antiAlias,
//                                           child: Padding(
//                                             padding: !ChatController()
//                                                     .selectedImgs
//                                                     .contains(index)
//                                                 ? const EdgeInsets.all(0.0)
//                                                 : const EdgeInsets.all(8.0),
//                                             child: Container(
//                                               clipBehavior: Clip.antiAlias,
//                                               decoration: ShapeDecoration(
//                                                 shape:
//                                                     ContinuousRectangleBorder(
//                                                   side: BorderSide(
//                                                     width: 3,
//                                                     color: !ChatController()
//                                                             .selectedImgs
//                                                             .contains(index)
//                                                         ? Colors.transparent
//                                                         : Colors.blue,
//                                                   ),
//                                                   borderRadius:
//                                                       BorderRadius.circular(16),
//                                                 ),
//                                               ),
//                                               child: Image.file(
//                                                   File(imgs[index - 1])),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: width * 0.25,
//                                     child: ChatImageData(index - 1,
//                                             title: widget.title)
//                                         .buildWidget(context),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               Expanded(
//                 child: Column(
//                   children: [
//                     Expanded(
//                       child: Selector<ChatController,
//                           List<OpenAIChatCompletionChoiceMessageModel>>(
//                         selector: (_, myType) => myType
//                             .getChat(widget.title)
//                             .messages
//                             .map((m) => m['content']
//                                 as OpenAIChatCompletionChoiceMessageModel)
//                             .toList(),
//                         shouldRebuild: (previous, next) => true,
//                         builder: (context, messages, child) {
//                           WidgetsBinding.instance.addPostFrameCallback((_) {
//                             if (_scrollController.hasClients) {
//                               _scrollController.jumpTo(
//                                   _scrollController.position.maxScrollExtent);
//                             }
//                           });
//                           return ListView.builder(
//                             controller: _scrollController,
//                             itemCount: messages.length,
//                             itemBuilder: (BuildContext context, int index) {
//                               return Provider.of<ChatController>(context,
//                                       listen: false)
//                                   .getChat(widget.title)
//                                   .buildWidget(index, widget.title);
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                     ChatInputField(title: widget.title),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ChatInputField extends StatefulWidget {
//   const ChatInputField({super.key, required this.title});
//   final String title;

//   @override
//   State<ChatInputField> createState() => _ChatInputFieldState();
// }

// class _ChatInputFieldState extends State<ChatInputField> {
//   final TextEditingController _textEditingController = TextEditingController();
//   final FocusNode _focusNode = FocusNode();

//   @override
//   void initState() {
//     super.initState();
//     _focusNode.requestFocus();
//   }

//   @override
//   void dispose() {
//     _textEditingController.dispose();
//     _focusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       shape: const ContinuousRectangleBorder(
//         borderRadius: BorderRadius.all(Radius.circular(20)),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8),
//         child: Row(
//           children: [
//             Expanded(
//               child: ConstrainedBox(
//                 constraints: const BoxConstraints(maxHeight: 120),
//                 child: SingleChildScrollView(
//                   child: TextField(
//                     controller: _textEditingController,
//                     focusNode: _focusNode,
//                     decoration: const InputDecoration(
//                       hintText: '输入消息...',
//                       border: InputBorder.none,
//                     ),
//                     maxLines: null,
//                     enableInteractiveSelection: true,
//                     enableIMEPersonalizedLearning: true,
//                     keyboardType: TextInputType.multiline,
//                     textInputAction: TextInputAction.newline,
//                   ),
//                 ),
//               ),
//             ),
//             IconButton(
//               onPressed: () {
//                 ChatController().summarize(widget.title);
//               },
//               icon: const Icon(Icons.done_all_outlined),
//               tooltip: "总结",
//             ),
//             IconButton(
//               icon: const Icon(Icons.photo),
//               tooltip: "上传图片",
//               onPressed: () async {
//                 List<String>? filePaths = await FileUtils.pickFile(context);
//                 if (filePaths != null && filePaths.isNotEmpty) {
//                   String chatDir = 'chats/${widget.title}';
//                   await FileUtils.createDirectoryIfNotExists(chatDir);
//                   String imgMDText = '';
//                   for (String filePath in filePaths) {
//                     String newPath =
//                         await FileUtils.copyFileToDirectory(filePath, chatDir);
//                     newPath = newPath.replaceAll('\\', '/');
//                     if (newPath.isNotEmpty) {
//                       imgMDText += '$newPath\n';
//                     }
//                   }
//                   ChatController().updateImgs(widget.title, imgMDText);
//                 }
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.send),
//               tooltip: "发送",
//               onPressed: () {
//                 if (_textEditingController.text.isNotEmpty) {
//                   ChatController().sendMessage(
//                       widget.title, _textEditingController.text, false);
//                   _textEditingController.clear();
//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     _focusNode.requestFocus();
//                   });
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:chat_pro/chat_controller.dart';
import 'package:chat_pro/ui/pura_multiple_radial_gradients.dart';
import 'package:chat_pro/util/chat_image_data.dart';
import 'package:chat_pro/util/file_utils.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.title});
  final String title;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    var width = size.width;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 4,
        scrolledUnderElevation: 4,
        backgroundColor: const Color.fromARGB(255, 139, 211, 253),
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          PuraMultipleRadialGradients(
            inputPoints: [
              InputPoint(
                  const Offset(0.25, 0.25),
                  const Color.fromARGB(255, 54, 70, 244),
                  0.19,
                  0.25,
                  const Duration(seconds: 2)),
              InputPoint(const Offset(0.75, 0.25), Colors.blue, 0.28, 0.35,
                  const Duration(seconds: 3)),
              InputPoint(
                  const Offset(0.6, 0.75),
                  const Color.fromARGB(255, 76, 172, 175),
                  0.26,
                  0.38,
                  const Duration(seconds: 4)),
              InputPoint(
                  const Offset(0.4, 0.5),
                  const Color.fromARGB(255, 221, 154, 225),
                  0.12,
                  0.28,
                  const Duration(seconds: 2, microseconds: 450)),
              InputPoint(
                  const Offset(0.1, 0.8),
                  const Color.fromARGB(255, 0, 250, 129),
                  0.12,
                  0.18,
                  const Duration(seconds: 2, microseconds: 450)),
            ],
            backgroundColor: Colors.white,
          ),
          Row(
            children: [
              SizedBox(
                width: width * 0.5,
                child: Selector<ChatController, (String, List<int>)>(
                  selector: (_, myType) =>
                      (myType.getImgsText(widget.title), myType.selectedImgs),
                  shouldRebuild: (previous, next) => true,
                  builder: (context, data, child) {
                    var imgs = data.$1.split('\n');
                    return Card(
                      color: const Color.fromARGB(255, 229, 229, 229),
                      elevation: 4,
                      shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: imgs.length + 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == 0) {
                              return const Text('  图片',
                                  style: TextStyle(fontSize: 22));
                            }
                            if (imgs[index - 1].isEmpty)
                              return const SizedBox();
                            return Card(
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: width * 0.22,
                                    height: width * 0.22,
                                    child: InkWell(
                                      onTap: () {
                                        if (ChatController()
                                            .selectedImgs
                                            .contains(index)) {
                                          ChatController()
                                              .selectedImgs
                                              .remove(index);
                                        } else {
                                          ChatController()
                                              .selectedImgs
                                              .add(index);
                                        }
                                        ChatController().update();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 4.0, top: 4.0),
                                        child: Material(
                                          color: const Color.fromARGB(
                                              0, 59, 173, 255),
                                          shape: ContinuousRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16)),
                                          clipBehavior: Clip.antiAlias,
                                          child: Padding(
                                            padding: !ChatController()
                                                    .selectedImgs
                                                    .contains(index)
                                                ? const EdgeInsets.all(0.0)
                                                : const EdgeInsets.all(8.0),
                                            child: Container(
                                              clipBehavior: Clip.antiAlias,
                                              decoration: ShapeDecoration(
                                                shape:
                                                    ContinuousRectangleBorder(
                                                  side: BorderSide(
                                                    width: 3,
                                                    color: !ChatController()
                                                            .selectedImgs
                                                            .contains(index)
                                                        ? Colors.transparent
                                                        : Colors.blue,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                              ),
                                              child: Image.file(
                                                  File(imgs[index - 1])),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: width * 0.25,
                                    child: ChatImageData(index - 1,
                                            title: widget.title)
                                        .buildWidget(context),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Consumer<ChatController>(
                        builder: (context, controller, child) {
                          final messages =
                              controller.getChat(widget.title).messages;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (_scrollController.hasClients) {
                              _scrollController.jumpTo(
                                  _scrollController.position.maxScrollExtent);
                            }
                          });
                          return ListView.builder(
                            controller: _scrollController,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              return controller
                                  .getChat(widget.title)
                                  .buildWidget(index, widget.title);
                            },
                          );
                        },
                      ),
                    ),
                    ChatInputField(title: widget.title),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChatInputField extends StatefulWidget {
  const ChatInputField({super.key, required this.title});
  final String title;

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 120),
                child: SingleChildScrollView(
                  child: TextField(
                    controller: _textEditingController,
                    focusNode: _focusNode,
                    decoration: const InputDecoration(
                        hintText: '输入消息...', border: InputBorder.none),
                    maxLines: null,
                    enableInteractiveSelection: true,
                    enableIMEPersonalizedLearning: true,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () => ChatController().summarize(widget.title),
              icon: const Icon(Icons.done_all_outlined),
              tooltip: "总结",
            ),
            IconButton(
              icon: const Icon(Icons.photo),
              tooltip: "上传图片",
              onPressed: () async {
                List<String>? filePaths = await FileUtils.pickFile(context);
                if (filePaths != null && filePaths.isNotEmpty) {
                  String chatDir = 'chats/${widget.title}';
                  await FileUtils.createDirectoryIfNotExists(chatDir);
                  String imgMDText = '';
                  for (String filePath in filePaths) {
                    String newPath =
                        await FileUtils.copyFileToDirectory(filePath, chatDir);
                    newPath = newPath.replaceAll('\\', '/');
                    if (newPath.isNotEmpty) imgMDText += '$newPath\n';
                  }
                  ChatController().updateImgs(widget.title, imgMDText);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.send),
              tooltip: "发送",
              onPressed: () {
                if (_textEditingController.text.isNotEmpty) {
                  ChatController().sendMessage(
                      widget.title, _textEditingController.text, false);
                  _textEditingController.clear();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _focusNode.requestFocus();
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
