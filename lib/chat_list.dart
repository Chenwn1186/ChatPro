// import 'dart:ui';

import 'package:chat_pro/chat_controller.dart';
import 'package:chat_pro/chat_page.dart';
// import 'package:chat_pro/ui/pura_multiple_radial_gradients.dart';
import 'package:chat_pro/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_canvas/simple_canvas.dart';

class ChatList extends StatelessWidget {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ChatController, List<String>>(
      selector: (_, myType) => myType.chatTitles,
      shouldRebuild: (previous, next) => true,
      builder: (context, titles, child) {
        var width = MediaQuery.sizeOf(context).width * 0.5;
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: GridView.builder(
            itemCount: titles.length,
            itemBuilder: (context, index) {
              final title = titles[index];
              final lastMsg = ChatController().getChat(title).getLastMsg();
              // print('lastMsg: $lastMsg');
              final userMsg =
                  ChatController().getChat(title).getLastMsg(index: 1);
              return Card(
                color: const Color.fromARGB(144, 255, 255, 255),
                elevation: 0,
                margin:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  title: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                        ),
                        Card(
                          elevation: 0,
                          color: ChatThemes().getColors()[6],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              userMsg,
                              maxLines: 7,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: ChatThemes().getColors()[7],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        Card(
                          elevation: 0,
                          color: ChatThemes().getColors()[2],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              lastMsg,
                              maxLines: 7,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: ChatThemes().getColors()[3],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    ChatController().selectedImgs = [];
                    ChatController().chatListScrollController.dispose();
                    ChatController().chatListScrollController =
                        ScrollController();
                    ChatController().currentTitle = title;
                    ChatController().isParsed = [];
                    ImagesBoardManager().autoAddLabels = false;
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ChatPage(
                        chatRecord: ChatController().getChat(title),
                      ),
                    ));
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await ChatController().deleteChatRecord(title);
                    },
                  ),
                ),
              );
            },
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: width.toInt() ~/ 300,
              childAspectRatio: 1.5,
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.white,
            elevation: 0,
            child: const Icon(Icons.add),
            onPressed: () async {
              final TextEditingController titleController =
                  TextEditingController();
              await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('请输入对话标题'),
                    content: TextField(
                      controller: titleController,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          String title = titleController.text.trim();
                          if (title.isEmpty) {
                            titleController.clear();
                          } else {
                            ChatController().createChat(title);
                          }
                          Navigator.of(context).pop();
                        },
                        child: const Text('确定'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
