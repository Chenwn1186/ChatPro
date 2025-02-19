import 'package:chat_pro/chat_controller.dart';
import 'package:chat_pro/util/file_utils.dart';
// import 'package:chat_pro/chat_page_msg.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 将 ChatPage 改为 StatefulWidget
class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.chatRecord});
  final ChatRecord chatRecord;

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
        title: Text(widget.chatRecord.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: width * 0.2, right: width * 0.2),
        child: Column(
          children: [
            Selector<ChatController, List<ChatMsg>>(
              // 修改为调用新的方法
              selector: (_, myType) => myType.getChatRecordMessages(widget.chatRecord.title),
              builder: (context, messages, child) {
                // 当消息列表更新时，滚动到最底部
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });
                return Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      return messages[index].buildWidget();
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
                  for (String filePath in filePaths) {
                    String newPath = await FileUtils.copyFileToDirectory(filePath, chatDir);
                    newPath = newPath.replaceAll('\\', '/');
                    if (newPath.isNotEmpty) {
                      // String relativePath = newPath.split('chats/').last;
                      String markdown = '![图片]($newPath)';
                      setState(() {
                        _textEditingController.text += '\n$markdown';
                        _textEditingController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _textEditingController.text.length),
                        );
                      });
                    }
                  }
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                if (_textEditingController.text.isNotEmpty) {
                  // 处理发送消息的逻辑
                  ChatController().sendMessage(widget.title, _textEditingController.text, false);
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
