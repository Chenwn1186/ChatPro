import 'package:chat_pro/chat_controller.dart';
import 'package:chat_pro/chat_page_msg.dart';
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
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    var width = size.width;
    var height = size.height;
    return Scaffold(
      appBar: AppBar(
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
                return Expanded(
                  child: ListView.builder(
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

  @override
  void dispose() {
    _textEditingController.dispose();
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
              child: TextField(
                controller: _textEditingController,
                decoration: const InputDecoration(
                  hintText: '输入消息...',
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.photo),
              onPressed: () {
                // 处理上传图片的逻辑
              },
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                if (_textEditingController.text.isNotEmpty) {
                  // 处理发送消息的逻辑
                  ChatController().sendMessage(widget.title, _textEditingController.text, false);
                  print('发送消息: ${_textEditingController.text}');
                  _textEditingController.clear();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
