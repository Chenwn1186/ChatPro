import 'dart:io';

import 'package:chat_pro/chat_controller.dart';
import 'package:chat_pro/util/file_utils.dart';
import 'package:dart_openai/dart_openai.dart';
// import 'package:chat_pro/chat_page_msg.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

// 将 ChatPage 改为 StatefulWidget
class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.chatRecord});
  // final ChatRecord chatRecord;
  final Chat chatRecord;

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
    // var height = size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 4,
        scrolledUnderElevation: 4,
        backgroundColor: const Color.fromARGB(255, 139, 211, 253),
        title: Text(widget.chatRecord.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Row(
        children: [
          SizedBox(
            width: width * 0.25,
          ),
          Expanded(
            child: Column(
              children: [
                Selector<ChatController,
                    List<OpenAIChatCompletionChoiceMessageModel>>(
                  // 修改为调用新的方法
                  selector: (_, myType) =>
                      myType.getChat(widget.chatRecord.title).content,
                  shouldRebuild: (previous, next) => true,
                  builder: (context, messages, child) {
                    // 当消息列表更新时，滚动到最底部
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController
                            .jumpTo(_scrollController.position.maxScrollExtent);
                      }
                    });
                    return Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: messages.length,
                        itemBuilder: (BuildContext context, int index) {
                          return widget.chatRecord.buildWidget(index);
                        },
                      ),
                    );
                  },
                ),
                Stack(children: [
                  ChatInputField(title: widget.chatRecord.title),
                ])
              ],
            ),
          ),
          SizedBox(
            width: width * 0.25,
            child: Selector<ChatController, (String, List<int>)>(
              selector: (_, myType) =>
                  (myType.getImgsText(widget.chatRecord.title), myType.selectedImgs),
                  shouldRebuild: (previous, next) => true,
              builder: (context, data, child) {
                var imgs = data.$1.split('\n');

                return Card(
                    elevation: 4,
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                        itemCount: imgs.length + 1,
                        itemBuilder: (BuildContext context, int index) {
                          if (index == 0) {
                            return const Text(
                              '图片',
                              style: TextStyle(fontSize: 22),
                            );
                          }
                          if (imgs[index - 1].isEmpty) {
                            return const SizedBox();
                          }
                          return InkWell(
                            onTap: () {
                              // 处理点击事件
                              // print('点击了图片 ${imgs[index]}');
                              if (ChatController()
                                  .selectedImgs
                                  .contains(index)) {
                                ChatController().selectedImgs.remove(index);
                              } else {
                                ChatController().selectedImgs.add(index);
                              }
                              ChatController().update();
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 4.0, top: 4.0),
                              child: Material(
                                color: const Color.fromARGB(255, 59, 173, 255),
                                  shape: ContinuousRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Padding(
                                    padding: !ChatController().selectedImgs.contains(index)?const EdgeInsets.all(0.0): const EdgeInsets.all(8.0),
                                    child: Image.file(File(imgs[index - 1])),
                                  )),
                            ),
                          );
                        },
                      ),
                    ));
              },
            ),
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
    _focusNode.requestFocus(); // 初始化时请求焦点
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
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 120, // 设置输入框的最大高度
                ),
                child: SingleChildScrollView(
                  child: TextField(
                    controller: _textEditingController,
                    focusNode: _focusNode,
                    decoration: const InputDecoration(
                      hintText: '输入消息...',
                      border: InputBorder.none,
                    ),
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
              icon: const Icon(Icons.photo),
              onPressed: () async {
                // 处理上传图片的逻辑
                List<String>? filePaths = await FileUtils.pickFile(context);
                if (filePaths != null && filePaths.isNotEmpty) {
                  String chatDir = 'chats/${widget.title}';
                  await FileUtils.createDirectoryIfNotExists(chatDir);
                  String imgMDText = '';
                  for (String filePath in filePaths) {
                    String newPath =
                        await FileUtils.copyFileToDirectory(filePath, chatDir);
                    newPath = newPath.replaceAll('\\', '/');

                    if (newPath.isNotEmpty) {
                      // String relativePath = newPath.split('chats/').last;
                      imgMDText += '$newPath\n';
                      // setState(() {
                      //   _textEditingController.text += '\n$markdown';
                      //   _textEditingController.selection = TextSelection.fromPosition(
                      //     TextPosition(offset: _textEditingController.text.length),
                      //   );
                      // }
                      // );
                    }
                  }

                  ChatController().updateImgs(widget.title, imgMDText);

                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                if (_textEditingController.text.isNotEmpty) {
                  // 处理发送消息的逻辑
                  ChatController().sendMessage(
                      widget.title, _textEditingController.text, false);
                  // print('发送消息: ${_textEditingController.text}');
                  //todo: 发送信息到服务器
                  _textEditingController.clear();
                  // 发送消息后重新请求焦点
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
