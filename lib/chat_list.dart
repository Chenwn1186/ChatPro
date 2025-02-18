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
            body: Expanded(
                child: ListView.builder(
              shrinkWrap: true,
              itemCount: titles.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(titles[index]),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ChatPage(
                              chatRecord:
                                  ChatController().getChatRecord(titles[index]),
                            )));
                  },
                );
              },
            )),
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () async {
                String title = '_test_';
                await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                          title: const Text('输入标题'),
                          content: TextField(
                            onChanged: (value) {
                              title = value;
                            },
                          ),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  ChatController().createChat(title);
                                  Navigator.of(context).pop();
                                },
                                child: const Text('确定'))
                          ]);
                    });
              },
            ));
      },
    );
  }
}
