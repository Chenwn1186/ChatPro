// import 'package:chat_pro/chat_controller.dart';
// import 'package:chat_pro/chat_page.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class ChatList extends StatelessWidget {
//   const ChatList({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Selector<ChatController, List<String>>(
//       selector: (_, myType) => myType.chatTitles,
//       builder: (context, titles, child) {
//         return Scaffold(
//           body: ListView.builder(
//             itemCount: titles.length,
//             itemBuilder: (context, index) {
//               final title = titles[index];
//               return Card(
//                 elevation: 4,
//                 margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//                 child: ListTile(
//                   title: Text(title),
//                   onTap: () {
//                     ChatController().selectedImgs = [];
//                     Navigator.of(context).push(MaterialPageRoute(
//                       builder: (_) => ChatPage(
//                         chatRecord: ChatController().getChat(title),
//                       ),
//                     ));
//                   },
//                   trailing: IconButton(
//                     icon: const Icon(Icons.delete),
//                     onPressed: () async {
//                       await ChatController().deleteChatRecord(title);
//                     },
//                   ),
//                 ),
//               );
//             },
//           ),
//           floatingActionButton: FloatingActionButton(
//             child: const Icon(Icons.add),
//             onPressed: () async {
//               final TextEditingController titleController = TextEditingController();
//               await showDialog(
//                 context: context,
//                 builder: (context) {
//                   return AlertDialog(
//                     title: const Text('请输入标题'),
//                     content: TextField(
//                       controller: titleController,
//                     ),
//                     actions: [
//                       TextButton(
//                         onPressed: () async {
//                           String title = titleController.text.trim();
//                           if (title.isEmpty) {
//                             titleController.clear();
//                           } else {
//                             ChatController().createChat(title);

//                           }
//                           Navigator.of(context).pop();
//                         },
//                         child: const Text('确定'),
//                       ),
//                     ],
//                   );
//                 },
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }

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
        if (titles.isEmpty) {
          return const Center(child: Text('暂无聊天记录'));
        }
        return Scaffold(
          body: ListView.builder(
            itemCount: titles.length,
            itemBuilder: (context, index) {
              final title = titles[index];
              if (title.isEmpty) {
                Logger.logError('ChatList: 发现空的聊天标题 at index $index');
                return const SizedBox.shrink();
              }
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  title: Text(title),
                  onTap: () {
                    try {
                      ChatController().selectedImgs = [];
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ChatPage(title: title), // 只传递 title
                      ));
                    } catch (e, stackTrace) {
                      Logger.logError(
                          'ChatList: 导航到 ChatPage 失败，title: "$title", 错误: $e',
                          stackTrace);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('无法打开聊天: $e')),
                      );
                    }
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
              final TextEditingController titleController =
                  TextEditingController();
              await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('请输入标题'),
                    content: TextField(controller: titleController),
                    actions: [
                      TextButton(
                        onPressed: () {
                          String title = titleController.text.trim();
                          if (title.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('标题不能为空')),
                            );
                          } else {
                            try {
                              ChatController().createChat(title);
                              Navigator.of(context).pop();
                            } catch (e, stackTrace) {
                              Logger.logError(
                                  'ChatList: 创建聊天失败，title: "$title", 错误: $e',
                                  stackTrace);
                            }
                          }
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
