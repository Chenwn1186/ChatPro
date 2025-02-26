import 'package:chat_pro/chat_controller.dart';
import 'package:chat_pro/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatList extends StatelessWidget {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ChatController, List<String>>(
      selector: (_, myType) => myType.chatTitles,
      builder: (context, titles, child) {
        return Scaffold(
          body: ListView.builder(
            itemCount: titles.length,
            itemBuilder: (context, index) {
              final title = titles[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  title: Text(title),
                  onTap: () {
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
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () async {
              final TextEditingController titleController = TextEditingController();
              await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('请输入标题'),
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
