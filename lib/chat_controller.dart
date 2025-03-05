// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:chat_pro/chat_page_msg.dart';
// // import 'package:chat_pro/embeddings.dart';
// // import 'package:dart_openai/dart_openai.dart';
// // import 'package:flutter/material.dart';
// // import 'backend.dart';

// // // 日志工具类
// // class Logger {
// //   static const String logFilePath = 'chat_app.log';

// //   static void log(String message) {
// //     final logFile = File(logFilePath);
// //     final logMessage = '${DateTime.now()}: $message\n';
// //     logFile.writeAsStringSync(logMessage, mode: FileMode.append);
// //   }

// //   static void logError(String errorMessage, [StackTrace? stackTrace]) {
// //     var logMessage = '${DateTime.now()}: [ERROR] $errorMessage\n';
// //     if (stackTrace != null) {
// //       logMessage += '$stackTrace\n';
// //     }
// //     final logFile = File(logFilePath);
// //     logFile.writeAsStringSync(logMessage, mode: FileMode.append);
// //   }
// // }

// // class ImgRecord {
// //   final String title;
// //   String imgMDText;
// //   late String lastImgs;
// //   String get lastImgMDText => imgMDText;
// //   ImgRecord({this.imgMDText = '', required this.title}) {
// //     try {
// //       saveRecord();
// //     } catch (e, stackTrace) {
// //       Logger.logError('ImgRecord 构造函数中保存记录出错: $e', stackTrace);
// //     }
// //   }

// //   @override
// //   bool operator ==(Object other) {
// //     return other is ImgRecord && other.imgMDText == imgMDText;
// //   }

// //   @override
// //   int get hashCode => imgMDText.hashCode;

// //   factory ImgRecord.fromPath(String path) {
// //     try {
// //       final File file = File(path);
// //       if (file.existsSync()) {
// //         final fileName = file.uri.pathSegments.last.split('.').first;
// //         var imgMDText = file.readAsStringSync();
// //         return ImgRecord(title: fileName, imgMDText: imgMDText);
// //       }
// //       return ImgRecord(title: '-imgs');
// //     } catch (e, stackTrace) {
// //       Logger.logError('ImgRecord 从路径创建实例出错: $e', stackTrace);
// //       return ImgRecord(title: '-imgs');
// //     }
// //   }

// //   void saveRecord() {
// //     try {
// //       final file = File('chats/$title.txt');
// //       file.writeAsStringSync(imgMDText);
// //     } catch (e, stackTrace) {
// //       Logger.logError('ImgRecord 保存记录出错: $e', stackTrace);
// //     }
// //   }

// //   void updateRecord(String imgMDText) {
// //     try {
// //       this.imgMDText += imgMDText;
// //       lastImgs = imgMDText;
// //       saveRecord();
// //     } catch (e, stackTrace) {
// //       Logger.logError('ImgRecord 更新记录出错: $e', stackTrace);
// //     }
// //   }

// //   void clearRecord() {
// //     try {
// //       imgMDText = '';
// //       saveRecord();
// //     } catch (e, stackTrace) {
// //       Logger.logError('ImgRecord 清空记录出错: $e', stackTrace);
// //     }
// //   }
// // }

// // class Chat {
// //   late String title;
// //   late List<OpenAIChatCompletionChoiceMessageModel> content;
// //   // late List<OpenAIChatCompletionChoiceMessageModel> prompts;
// //   late OpenAIChatCompletionChoiceMessageModel prompt;
// //   Chat({required this.title, required this.content});
// //   Chat.fromPath(String path) {
// //     try {
// //       final File file = File(path);
// //       final fileName = file.uri.pathSegments.last.split('.').first;
// //       var jsonString = file.readAsStringSync();
// //       var jsonList = json.decode(jsonString) as List<dynamic>;
// //       content = [];
// //       for (var json in jsonList) {
// //         content.add(OpenAIChatCompletionChoiceMessageModel.fromMap(json));
// //       }
// //       title = fileName;
// //     } catch (e, stackTrace) {
// //       Logger.logError('Chat 从路径创建实例出错: $e', stackTrace);
// //     }
// //   }
// //   void setLastMsg(String lastMsg) {
// //     try {
// //       if (content.isNotEmpty) {
// //         content.last = OpenAIChatCompletionChoiceMessageModel(
// //           role: OpenAIChatMessageRole.assistant,
// //           content: [
// //             OpenAIChatCompletionChoiceMessageContentItemModel.text(
// //               lastMsg,
// //             ),
// //           ],
// //         );
// //         saveRecord();
// //       }
// //     } catch (e, stackTrace) {
// //       Logger.logError('Chat 设置最后消息出错: $e', stackTrace);
// //     }
// //   }

// //   void saveRecord() {
// //     try {
// //       final file = File('chats/$title.json');
// //       // 将 content 转换为 JSON 列表
// //       var jsonList = content.map((e) => e.toMap()).toList();
// //       // 将 JSON 列表编码为标准的 JSON 字符串
// //       var jsonString = json.encode(jsonList);
// //       file.writeAsStringSync(jsonString);
// //     } catch (e, stackTrace) {
// //       Logger.logError('Chat 保存记录出错: $e', stackTrace);
// //     }
// //   }

// //   void clearRecord() {
// //     try {
// //       content = [];
// //       saveRecord();
// //     } catch (e, stackTrace) {
// //       Logger.logError('Chat 清空记录出错: $e', stackTrace);
// //     }
// //   }

// //   void setPrompt(String prompt) {
// //     try {
// //       this.prompt = OpenAIChatCompletionChoiceMessageModel(
// //         role: OpenAIChatMessageRole.system,
// //         content: [
// //           OpenAIChatCompletionChoiceMessageContentItemModel.text(
// //             prompt,
// //           ),
// //         ],
// //       );
// //     } catch (e, stackTrace) {
// //       Logger.logError('Chat 设置prompt出错: $e', stackTrace);
// //     }
// //   }

// //   void addMsg({required OpenAIChatMessageRole role, required String text}) {
// //     try {
// //       content.add(OpenAIChatCompletionChoiceMessageModel(
// //         role: role,
// //         content: [
// //           OpenAIChatCompletionChoiceMessageContentItemModel.text(
// //             text,
// //           ),
// //         ],
// //       ));
// //       saveRecord();
// //       if (content.length > 20) {
// //         var sc = content.sublist(0, 2);
// //         var text = sc.map((e) => e.toMap().toString()).toList();
// //         VectorDB().store(title, text, text.toString());
// //       }
// //     } catch (e, stackTrace) {
// //       Logger.logError('Chat 添加消息出错: $e', stackTrace);
// //     }
// //   }

// //   String getLastMsg(int count) {
// //     try {
// //       var startIndex = content.length > count ? content.length - count : 0;
// //       var lastMsgs = content.sublist(startIndex);
// //       return lastMsgs.map((e) => e.toMap().toString()).toList().toString();
// //     } catch (e, stackTrace) {
// //       Logger.logError('Chat 获取最后消息出错: $e', stackTrace);
// //       return '';
// //     }
// //   }

// //   List<OpenAIChatCompletionChoiceMessageModel> getLastMsgModel(int count) {
// //     try {
// //       var startIndex = content.length > count ? content.length - count : 0;
// //       var lastMsgs = content.sublist(startIndex);
// //       var res = [prompt];
// //       res.addAll(lastMsgs);
// //       return res;
// //       // return lastMsgs;
// //     } catch (e, stackTrace) {
// //       Logger.logError('Chat 获取最近消息出错: $e', stackTrace);
// //       return [prompt];
// //     }
// //   }

// //   void showAllRecords() {
// //     try {
// //       Logger.log('===========================所有聊天记录=========================');
// //       var res = content.map((e) => e.toMap().toString()).toList();
// //       for (var r in res) {
// //         Logger.log(r);
// //       }
// //     } catch (e, stackTrace) {
// //       Logger.logError('Chat 显示所有记录出错: $e', stackTrace);
// //     }
// //   }

// //   Widget buildWidget(int index) {
// //     try {
// //       if (index < content.length && index >= 0) {
// //         var msg = content[index].content!.first.text!;
// //         var left = content[index].role == OpenAIChatMessageRole.assistant;
// //         if (content[index].role == OpenAIChatMessageRole.system) {
// //           return const SizedBox();
// //         }
// //         return _build(mdMsg: msg, left: left);
// //       }
// //       return const SizedBox();
// //     } catch (e, stackTrace) {
// //       Logger.logError('Chat 构建 Widget 出错: $e', stackTrace);
// //       return const SizedBox();
// //     }
// //   }

// //   static Widget _build({required String mdMsg, required bool left}) {
// //     try {
// //       if (left) {
// //         return ChatPageMsg(
// //           left: left,
// //           mdMsg: mdMsg,
// //           imgText: '小助手',
// //           headBGColor: const Color.fromARGB(255, 166, 51, 243),
// //           headTextColor: Colors.white,
// //           bgColor: const Color.fromARGB(255, 255, 204, 255),
// //           textColor: const Color.fromARGB(255, 166, 51, 243),
// //         );
// //       } else {
// //         return ChatPageMsg(
// //           left: left,
// //           mdMsg: mdMsg,
// //           imgText: '用户',
// //           headBGColor: const Color.fromARGB(255, 6, 94, 166),
// //           headTextColor: Colors.white,
// //           bgColor: const Color.fromARGB(255, 185, 225, 255),
// //           textColor: const Color.fromARGB(255, 6, 94, 166),
// //         );
// //       }
// //     } catch (e, stackTrace) {
// //       Logger.logError('Chat 静态构建 Widget 出错: $e', stackTrace);
// //       return const SizedBox();
// //     }
// //   }
// // }

// // /// 聊天控制
// // class ChatController with ChangeNotifier {
// //   // 静态私有实例，用于存储单例
// //   static final ChatController _instance = ChatController._internal();

// //   // 工厂构造函数，返回单例实例
// //   factory ChatController() {
// //     return _instance;
// //   }

// //   // 私有构造函数，防止外部实例化
// //   ChatController._internal() {
// //     try {
// //       // readAllChatRecords();
// //       readAllChats();
// //       Prompts().loadPrompts();
// //     } catch (e, stackTrace) {
// //       Logger.logError('ChatController 构造函数出错: $e', stackTrace);
// //     }
// //   }

// //   // 存储所有对话记录，key 是对话标题
// //   final Map<String, ImgRecord> _imgRecords = {};
// //   final Map<String, Chat> _chats = {};
// //   List<int> selectedImgs = [];
// //   // 获取所有对话记录
// //   Map<String, Chat> get chats => _chats;

// //   // 存储所有对话标题
// //   // List<String> get chatTitles => _chatRecords.keys.toList();
// //   List<String> get chatTitles => _chats.keys.toList();

// //   Chat getChat(String title) {
// //     try {
// //       return _chats[title]!;
// //     } catch (e, stackTrace) {
// //       Logger.logError('ChatController getChat 方法出错: $e', stackTrace);
// //       rethrow;
// //     }
// //   }

// //   ImgRecord getImgRecordByTitle(String title) {
// //     try {
// //       return _imgRecords['$title-imgs']!;
// //     } catch (e, stackTrace) {
// //       Logger.logError(
// //           'ChatController getImgRecordByTitle 方法出错: $e', stackTrace);
// //       rethrow;
// //     }
// //   }

// //   String getImgsText(String title) {
// //     try {
// //       return _imgRecords['$title-imgs']?.imgMDText ?? '';
// //     } catch (e, stackTrace) {
// //       Logger.logError('ChatController getImgsText 方法出错: $e', stackTrace);
// //       return '';
// //     }
// //   }

// //   // 读取 chats 目录下的所有聊天记录文件
// //   Future<void> readAllChats() async {
// //     final directory = Directory('chats');
// //     final files = directory.listSync().whereType<File>();
// //     for (final file in files) {
// //       try {
// //         final fileName = file.uri.pathSegments.last;
// //         if (fileName.endsWith('.json')) {
// //           final title = fileName.replaceAll('.json', '');
// //           final chat = Chat.fromPath(file.path);
// //           _chats[title] = chat;
// //         } else if (fileName.endsWith('.txt')) {
// //           final title = fileName.replaceAll('.txt', '');
// //           final imgRecord = ImgRecord.fromPath(file.path);
// //           _imgRecords[title] = imgRecord;
// //           Logger.log('imgRecord: $imgRecord');
// //         }
// //       } catch (e, stackTrace) {
// //         Logger.logError('读取文件 ${file.path} 时出错: $e', stackTrace);
// //       }
// //     }
// //   }

// //   // 发送消息到指定对话
// //   Future<void> sendMessage(String title, String message, bool left) async {
// //     try {
// //       if (_chats.containsKey(title)) {
// //         _chats[title]!.addMsg(
// //           role: left
// //               ? OpenAIChatMessageRole.assistant
// //               : OpenAIChatMessageRole.user,
// //           text: message,
// //         );
// //         notifyListeners();
// //         if (!left) {
// //           var shortRecord = _chats[title]!.getLastMsg(20);
// //           // var longRecord = await VectorDB().query(message, title, 6);
// //           Logger.log('选择图片：$selectedImgs');
// //           var imgPaths = selectedImgs.map((e) {
// //             String path = '';
// //             if (e >= 0) {
// //               path = _imgRecords['$title-imgs']!.imgMDText.split('\n')[e - 1];
// //             }
// //             return path;
// //           }).toList();
// //           Logger.log('用户选择的图片：$imgPaths');
// //           var imgDiscription =
// //               json.decode(await analyseImg(title, imgPaths)).toString();

// //           var prompt =
// //               Prompts().generateStrategyPrompt(imgDiscription, shortRecord, '');
// //           String content = '';
// //           sendMessage(title, '正在思考中...', true);
// //           _chats[title]!.setPrompt(prompt);
// //           await OpenAIUserInteraction().sendMessageWithStream(
// //               '图片解析结果：$imgDiscription, \n用户输入: $message', (event) {
// //             final firstCompletionChoice = event.choices.first;
// //             content += firstCompletionChoice.delta.content?.first?.text ?? '';
// //             _chats[title]!.setLastMsg(extractResponseContent(content));
// //             notifyListeners();
// //           }, () {
// //             Logger.log('llm 回复: $content');
// //             content = content.replaceAll('```json', '').replaceAll('```', '');
// //             updateImgMemory(title, content, imgPaths);
// //             _chats[title]!.showAllRecords();
// //           }, records: _chats[title]!.getLastMsgModel(20));
// //         }

// //         notifyListeners();
// //       }
// //     } catch (e, stackTrace) {
// //       Logger.logError('ChatController sendMessage 方法出错: $e', stackTrace);
// //     }
// //   }

// //   String extractResponseContent(String input) {
// //     // 查找 "Response": 的起始位置
// //     int startIndex = input.indexOf('"Response": "');
// //     if (startIndex == -1) {
// //       // 如果没有找到 "Response": "，返回空字符串
// //       return '正在思考中...';
// //     }
// //     // 计算 "Response": 之后的起始位置
// //     startIndex += '"Response": "'.length;
// //     // 跳过可能存在的空白字符
// //     while (startIndex < input.length && input[startIndex] == ' ') {
// //       startIndex++;
// //     }
// //     // 查找下一个 " 的位置
// //     int endIndex = input.indexOf('",', startIndex);
// //     if (endIndex == -1) {
// //       // 如果没有找到 "，返回 "Response": 后面的所有内容
// //       return input.substring(startIndex).trim();
// //     }
// //     // 返回 " 前面的内容
// //     return input.substring(startIndex, endIndex).trim();
// //   }

// //   void updateImgMemory(String title, String msg, List<String> imgPaths) {
// //     try {
// //       var resMap = json.decode(msg) as Map<String, dynamic>;
// //       if (resMap.containsKey('updated_image')) {
// //         List<dynamic> updatedImgList = resMap['updated_image'];
// //         List<String> updatedImg =
// //             updatedImgList.map((e) => e.toString()).toList();
// //         Logger.log('updateImg: $updatedImg');
// //         Logger.log('imgPaths: $imgPaths');
// //         // 确保 updatedImg 的长度和 imgPaths 的长度一致
// //         if (updatedImg.length == imgPaths.length) {
// //           for (int i = 0; i < imgPaths.length; i++) {
// //             String imgPath = imgPaths[i];
// //             String jsonPath = imgPath.replaceAll(RegExp(r'\.\w+$'), '.json');

// //             // 创建 File 对象
// //             File jsonFile = File(jsonPath);

// //             // 读取原文件内容
// //             Map<String, dynamic> jsonData = {};
// //             if (jsonFile.existsSync()) {
// //               String jsonString = jsonFile.readAsStringSync();
// //               jsonData = json.decode(jsonString) as Map<String, dynamic>;
// //             }

// //             // 添加新的键值对
// //             jsonData['更新描述'] = updatedImg[i];
// //             notifyListeners();
// //             // 将更新后的内容写入 JSON 文件
// //             jsonFile.writeAsStringSync(json.encode(jsonData));
// //           }
// //         } else {
// //           Logger.logError(
// //               'ChatController updateImgMemory 方法出错: updatedImg 和 imgPaths 的长度不一致',
// //               null);
// //         }
// //       }
// //     } catch (e, stackTrace) {
// //       Logger.logError('ChatController updateImgMemory 方法出错: $e', stackTrace);
// //     }
// //   }

// //   void updateImgs(String title, String imgMDText) {
// //     try {
// //       var key = '$title-imgs';
// //       if (_imgRecords.containsKey(key)) {
// //         _imgRecords[key]!.updateRecord(imgMDText);
// //       } else {
// //         _imgRecords[key] = ImgRecord(title: key, imgMDText: imgMDText);
// //       }
// //       notifyListeners();
// //       //todo:解析图片数据并保存
// //     } catch (e, stackTrace) {
// //       Logger.logError('ChatController updateImgs 方法出错: $e', stackTrace);
// //     }
// //   }

// //   void createChat(String title) {
// //     try {
// //       // _chatRecords[title] = ChatRecord(title: title, messages: []);
// //       _chats[title] = Chat(title: title, content: []);
// //       _imgRecords['$title-imgs'] = ImgRecord(title: '$title-imgs');
// //       // sendMessage(title, '你好，我是你的智能助理~', true);
// //       notifyListeners();
// //       sendMessage(title, "正在思考中...", true);
// //       var str = Guidance().generateGuidanceMessage();
// //       str.then((value) {
// //         _chats[title]!.setLastMsg(value);
// //         notifyListeners();
// //       });
// //     } catch (e, stackTrace) {
// //       Logger.logError('ChatController createChat 方法出错: $e', stackTrace);
// //     }
// //   }

// //   // 清空指定对话的聊天记录
// //   void clearChatRecord(String title) {
// //     try {
// //       if (_chats.containsKey(title)) {
// //         _chats[title]!.clearRecord();
// //         notifyListeners();
// //       }
// //     } catch (e, stackTrace) {
// //       Logger.logError('ChatController clearChatRecord 方法出错: $e', stackTrace);
// //     }
// //   }

// //   // 删除指定对话的聊天记录及对应文件
// //   Future<void> deleteChatRecord(String title) async {
// //     try {
// //       if (_chats.containsKey(title)) {
// //         // 从内存中移除聊天记录
// //         _chats.remove(title);
// //         // 删除对应的文件
// //         var file = File('chats/$title.json');
// //         if (await file.exists()) {
// //           await file.delete();
// //         }
// //         notifyListeners();
// //         var directory = Directory('chats/$title');
// //         if (await directory.exists()) {
// //           await directory.delete(recursive: true);
// //         }
// //         file = File('chats/$title-imgs.txt');
// //         if (await file.exists()) {
// //           await file.delete();
// //         }
// //       }
// //     } catch (e, stackTrace) {
// //       Logger.logError('ChatController deleteChatRecord 方法出错: $e', stackTrace);
// //     }
// //   }

// //   Future<void> summarize(String title) async {
// //     try {
// //       if (_chats.containsKey(title)) {
// //         notifyListeners();
// //         Logger.log('选择图片：$selectedImgs');
// //         var imgPaths = selectedImgs.map((e) {
// //           String path = '';
// //           if (e >= 0) {
// //             path = _imgRecords['$title-imgs']!.imgMDText.split('\n')[e - 1];
// //           }
// //           return path;
// //         }).toList();
// //         var imgDiscription =
// //             json.decode(await analyseImg(title, imgPaths)).toString();

// //         var prompt = Prompts().getPrompt("summary_prompt");
// //         String content = '';
// //         sendMessage(title, '正在总结中...', true);
// //         _chats[title]!.setPrompt(prompt);
// //         OpenAIUserInteraction().sendMessageWithStream('图片解析结果：$imgDiscription',
// //             (event) {
// //           final firstCompletionChoice = event.choices.first;
// //           content += firstCompletionChoice.delta.content?.first?.text ?? '';
// //           _chats[title]!.setLastMsg(content);
// //           notifyListeners();
// //         }, () {
// //           Logger.log('llm 总结: $content');
// //         }, records: _chats[title]!.getLastMsgModel(20));

// //         notifyListeners();

// //         _chats[title]!.showAllRecords();
// //       }
// //     } catch (e, stackTrace) {
// //       Logger.logError('ChatController summarize 方法出错: $e', stackTrace);
// //     }
// //   }

// //   void update() {
// //     try {
// //       notifyListeners();
// //     } catch (e, stackTrace) {
// //       Logger.logError('ChatController update 方法出错: $e', stackTrace);
// //     }
// //   }
// // }

// import 'dart:convert';
// import 'dart:io';
// import 'package:chat_pro/chat_page_msg.dart';
// import 'package:chat_pro/embeddings.dart';
// import 'package:dart_openai/dart_openai.dart';
// import 'package:flutter/material.dart';
// import 'backend.dart';

// class Logger {
//   static const String logFilePath = 'chat_app.log';

//   static void log(String message) {
//     final logFile = File(logFilePath);
//     final logMessage = '${DateTime.now()}: $message\n';
//     logFile.writeAsStringSync(logMessage, mode: FileMode.append);
//   }

//   static void logError(String errorMessage, [StackTrace? stackTrace]) {
//     var logMessage = '${DateTime.now()}: [ERROR] $errorMessage\n';
//     if (stackTrace != null) {
//       logMessage += '$stackTrace\n';
//     }
//     final logFile = File(logFilePath);
//     logFile.writeAsStringSync(logMessage, mode: FileMode.append);
//   }
// }

// class ImgRecord {
//   final String title;
//   String imgMDText;
//   late String lastImgs;
//   String get lastImgMDText => imgMDText;
//   ImgRecord({this.imgMDText = '', required this.title}) {
//     try {
//       saveRecord();
//     } catch (e, stackTrace) {
//       Logger.logError('ImgRecord 构造函数中保存记录出错: $e', stackTrace);
//     }
//   }

//   @override
//   bool operator ==(Object other) {
//     return other is ImgRecord && other.imgMDText == imgMDText;
//   }

//   @override
//   int get hashCode => imgMDText.hashCode;

//   factory ImgRecord.fromPath(String path) {
//     try {
//       final File file = File(path);
//       if (file.existsSync()) {
//         final fileName = file.uri.pathSegments.last.split('.').first;
//         var imgMDText = file.readAsStringSync();
//         return ImgRecord(title: fileName, imgMDText: imgMDText);
//       }
//       return ImgRecord(title: '-imgs');
//     } catch (e, stackTrace) {
//       Logger.logError('ImgRecord 从路径创建实例出错: $e', stackTrace);
//       return ImgRecord(title: '-imgs');
//     }
//   }

//   void saveRecord() {
//     try {
//       final file = File('chats/$title.txt');
//       file.writeAsStringSync(imgMDText);
//     } catch (e, stackTrace) {
//       Logger.logError('ImgRecord 保存记录出错: $e', stackTrace);
//     }
//   }

//   void updateRecord(String imgMDText) {
//     try {
//       this.imgMDText += imgMDText;
//       lastImgs = imgMDText;
//       saveRecord();
//     } catch (e, stackTrace) {
//       Logger.logError('ImgRecord 更新记录出错: $e', stackTrace);
//     }
//   }

//   void clearRecord() {
//     try {
//       imgMDText = '';
//       saveRecord();
//     } catch (e, stackTrace) {
//       Logger.logError('ImgRecord 清空记录出错: $e', stackTrace);
//     }
//   }
// }

// class Chat {
//   late String title;
//   late List<Map<String, dynamic>> messages;
//   late OpenAIChatCompletionChoiceMessageModel prompt;

//   Chat(
//       {required this.title,
//       List<OpenAIChatCompletionChoiceMessageModel>? content}) {
//     messages = content != null
//         ? content
//             .map((c) => {
//                   'content': c,
//                   'metadata': {'liked': false, 'disliked': false}
//                 })
//             .toList()
//         : [];
//   }

//   Chat.fromPath(String path) {
//     try {
//       final File file = File(path);
//       final fileName = file.uri.pathSegments.last.split('.').first;
//       var jsonString = file.readAsStringSync();
//       Logger.log('加载文件 $path，内容: $jsonString');
//       var jsonData = json.decode(jsonString);
//       if (jsonData is List) {
//         messages = (jsonData as List<dynamic>).map((item) {
//           return {
//             'content':
//                 OpenAIChatCompletionChoiceMessageModel.fromMap(item['content']),
//             'metadata': Map<String, dynamic>.from(item['metadata']),
//           };
//         }).toList();
//       } else if (jsonData is Map) {
//         var contentList = (jsonData['content'] as List<dynamic>)
//             .map((json) => OpenAIChatCompletionChoiceMessageModel.fromMap(json))
//             .toList();
//         var metadataList = jsonData['metadata'] != null
//             ? List<Map<String, dynamic>>.from(jsonData['metadata'])
//             : List.generate(
//                 contentList.length, (_) => {'liked': false, 'disliked': false});
//         messages = List.generate(
//             contentList.length,
//             (i) => {
//                   'content': contentList[i],
//                   'metadata': metadataList[i],
//                 });
//       } else {
//         throw Exception('无效的 JSON 格式');
//       }
//       title = fileName;
//       Logger.log('成功解析聊天记录: $title，消息数: ${messages.length}');
//     } catch (e, stackTrace) {
//       Logger.logError('Chat 从路径 $path 创建实例出错: $e', stackTrace);
//       messages = [];
//       title = '';
//     }
//   }

//   void saveRecord() {
//     try {
//       final file = File('chats/$title.json');
//       final jsonEncoder = JsonEncoder();
//       final lines = messages
//           .map((msg) => jsonEncoder.convert({
//                 'content': msg['content'].toMap(),
//                 'metadata': msg['metadata'],
//               }))
//           .toList();
//       String jsonString = '[\n' + lines.join(',\n') + '\n]';
//       file.writeAsStringSync(jsonString);
//       Logger.log('保存聊天记录: $title，路径: ${file.path}');
//     } catch (e, stackTrace) {
//       Logger.logError('Chat 保存记录出错: $e', stackTrace);
//     }
//   }

//   void setLastMsg(String lastMsg) {
//     try {
//       if (messages.isNotEmpty) {
//         messages.last['content'] = OpenAIChatCompletionChoiceMessageModel(
//           role: OpenAIChatMessageRole.assistant,
//           content: [
//             OpenAIChatCompletionChoiceMessageContentItemModel.text(lastMsg),
//           ],
//         );
//         saveRecord();
//       }
//     } catch (e, stackTrace) {
//       Logger.logError('Chat 设置最后消息出错: $e', stackTrace);
//     }
//   }

//   void clearRecord() {
//     try {
//       messages = [];
//       saveRecord();
//     } catch (e, stackTrace) {
//       Logger.logError('Chat 清空记录出错: $e', stackTrace);
//     }
//   }

//   void setPrompt(String prompt) {
//     try {
//       this.prompt = OpenAIChatCompletionChoiceMessageModel(
//         role: OpenAIChatMessageRole.system,
//         content: [
//           OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
//         ],
//       );
//     } catch (e, stackTrace) {
//       Logger.logError('Chat 设置prompt出错: $e', stackTrace);
//     }
//   }

//   void addMsg({required OpenAIChatMessageRole role, required String text}) {
//     try {
//       messages.add({
//         'content': OpenAIChatCompletionChoiceMessageModel(
//           role: role,
//           content: [
//             OpenAIChatCompletionChoiceMessageContentItemModel.text(text),
//           ],
//         ),
//         'metadata': {'liked': false, 'disliked': false},
//       });
//       saveRecord();
//       if (messages.length > 20) {
//         var sc = messages
//             .sublist(0, 2)
//             .map((m) => m['content'].toMap().toString())
//             .toList();
//         VectorDB().store(title, sc, sc.toString());
//       }
//     } catch (e, stackTrace) {
//       Logger.logError('Chat 添加消息出错: $e', stackTrace);
//     }
//   }

//   String getLastMsg(int count) {
//     try {
//       var startIndex = messages.length > count ? messages.length - count : 0;
//       var lastMsgs = messages.sublist(startIndex);
//       return lastMsgs
//           .map((m) => m['content'].toMap().toString())
//           .toList()
//           .toString();
//     } catch (e, stackTrace) {
//       Logger.logError('Chat 获取最后消息出错: $e', stackTrace);
//       return '';
//     }
//   }

//   List<OpenAIChatCompletionChoiceMessageModel> getLastMsgModel(int count) {
//     try {
//       var startIndex = messages.length > count ? messages.length - count : 0;
//       var lastMsgs = messages
//           .sublist(startIndex)
//           .map((m) => m['content'] as OpenAIChatCompletionChoiceMessageModel)
//           .toList();
//       var res = [prompt];
//       res.addAll(lastMsgs);
//       return res;
//     } catch (e, stackTrace) {
//       Logger.logError('Chat 获取最近消息出错: $e', stackTrace);
//       return [prompt];
//     }
//   }

//   void showAllRecords() {
//     try {
//       Logger.log('===========================所有聊天记录=========================');
//       var res = messages.map((m) => m['content'].toMap().toString()).toList();
//       for (var r in res) {
//         Logger.log(r);
//       }
//     } catch (e, stackTrace) {
//       Logger.logError('Chat 显示所有记录出错: $e', stackTrace);
//     }
//   }

//   Widget buildWidget(int index, String title) {
//     try {
//       if (index < messages.length && index >= 0) {
//         var msg = messages[index]['content'].content!.first.text!;
//         var left =
//             messages[index]['content'].role == OpenAIChatMessageRole.assistant;
//         if (messages[index]['content'].role == OpenAIChatMessageRole.system) {
//           return const SizedBox();
//         }
//         return _build(mdMsg: msg, left: left, title: title, index: index);
//       }
//       return const SizedBox();
//     } catch (e, stackTrace) {
//       Logger.logError('Chat 构建 Widget 出错: $e', stackTrace);
//       return const SizedBox();
//     }
//   }

//   Widget _build(
//       {required String mdMsg,
//       required bool left,
//       required String title,
//       required int index}) {
//     try {
//       if (left) {
//         return ChatPageMsg(
//           left: left,
//           mdMsg: mdMsg,
//           imgText: '小助手',
//           headBGColor: const Color.fromARGB(255, 166, 51, 243),
//           headTextColor: Colors.white,
//           bgColor: const Color.fromARGB(255, 255, 204, 255),
//           textColor: const Color.fromARGB(255, 166, 51, 243),
//           title: title,
//           index: index,
//         );
//       } else {
//         return ChatPageMsg(
//           left: left,
//           mdMsg: mdMsg,
//           imgText: '用户',
//           headBGColor: const Color.fromARGB(255, 6, 94, 166),
//           headTextColor: Colors.white,
//           bgColor: const Color.fromARGB(255, 185, 225, 255),
//           textColor: const Color.fromARGB(255, 6, 94, 166),
//           title: title,
//           index: index,
//         );
//       }
//     } catch (e, stackTrace) {
//       Logger.logError('Chat 静态构建 Widget 出错: $e', stackTrace);
//       return const SizedBox();
//     }
//   }
// }

// class ChatController with ChangeNotifier {
//   static final ChatController _instance = ChatController._internal();
//   factory ChatController() => _instance;

//   ChatController._internal() {
//     try {
//       readAllChats();
//       Prompts().loadPrompts();
//     } catch (e, stackTrace) {
//       Logger.logError('ChatController 构造函数出错: $e', stackTrace);
//     }
//   }

//   final Map<String, ImgRecord> _imgRecords = {};
//   final Map<String, Chat> _chats = {};
//   List<int> selectedImgs = [];
//   Map<String, Chat> get chats => _chats;
//   List<String> get chatTitles => _chats.keys.toList();

//   Chat getChat(String title) {
//     try {
//       final chat = _chats[title];
//       if (chat == null) {
//         Logger.logError('ChatController getChat: 未找到标题为 "$title" 的聊天记录');
//         throw Exception('Chat with title "$title" not found');
//       }
//       return chat;
//     } catch (e, stackTrace) {
//       Logger.logError('ChatController getChat 方法出错: $e', stackTrace);
//       rethrow;
//     }
//   }

//   ImgRecord getImgRecordByTitle(String title) {
//     try {
//       return _imgRecords['$title-imgs'] ?? ImgRecord(title: '$title-imgs');
//     } catch (e, stackTrace) {
//       Logger.logError(
//           'ChatController getImgRecordByTitle 方法出错: $e', stackTrace);
//       rethrow;
//     }
//   }

//   String getImgsText(String title) {
//     try {
//       return _imgRecords['$title-imgs']?.imgMDText ?? '';
//     } catch (e, stackTrace) {
//       Logger.logError('ChatController getImgsText 方法出错: $e', stackTrace);
//       return '';
//     }
//   }

//   Future<void> readAllChats() async {
//     final directory = Directory('chats');
//     if (!directory.existsSync()) {
//       Logger.log('聊天目录 "chats" 不存在，创建新目录');
//       directory.createSync();
//     }
//     final files = directory.listSync().whereType<File>().toList();
//     Logger.log('发现 ${files.length} 个文件 in chats 目录');
//     for (final file in files) {
//       try {
//         final fileName = file.uri.pathSegments.last;
//         if (fileName.endsWith('.json')) {
//           final title = fileName.replaceAll('.json', '');
//           final chat = Chat.fromPath(file.path);
//           _chats[title] = chat;
//           Logger.log('加载聊天记录: $title，消息数: ${chat.messages.length}');
//         } else if (fileName.endsWith('.txt')) {
//           final titleTxt = fileName.replaceAll('.txt', '');
//           final imgRecord = ImgRecord.fromPath(file.path);
//           _imgRecords[titleTxt] = imgRecord;
//           Logger.log('加载图片记录: $titleTxt');
//         }
//       } catch (e, stackTrace) {
//         Logger.logError('读取文件 ${file.path} 时出错: $e', stackTrace);
//       }
//     }
//     Logger.log('加载完成，共 ${_chats.length} 个聊天记录');
//     notifyListeners();
//   }

//   Future<void> sendMessage(String title, String message, bool left) async {
//     try {
//       if (_chats.containsKey(title)) {
//         // 添加用户或助手消息并立即保存
//         _chats[title]!.addMsg(
//           role: left
//               ? OpenAIChatMessageRole.assistant
//               : OpenAIChatMessageRole.user,
//           text: message,
//         );
//         _chats[title]!.saveRecord(); // 立即保存到文件
//         notifyListeners(); // 通知UI更新

//         // 处理助手回复
//         if (!left) {
//           var shortRecord = _chats[title]!.getLastMsg(20);
//           Logger.log('选择图片：$selectedImgs');
//           var imgPaths = selectedImgs.map((e) {
//             String path = '';
//             if (e >= 0) {
//               path = _imgRecords['$title-imgs']!.imgMDText.split('\n')[e - 1];
//             }
//             return path;
//           }).toList();
//           Logger.log('用户选择的图片：$imgPaths');
//           var imgDiscription =
//               json.decode(await analyseImg(title, imgPaths)).toString();
//           var prompt =
//               Prompts().generateStrategyPrompt(imgDiscription, shortRecord, '');
//           String content = '';

//           // 添加“正在思考中...”消息
//           _chats[title]!.addMsg(
//             role: OpenAIChatMessageRole.assistant,
//             text: '正在思考中...',
//           );
//           _chats[title]!.saveRecord();
//           notifyListeners();

//           // 设置提示词并请求流式回复
//           _chats[title]!.setPrompt(prompt);
//           await OpenAIUserInteraction().sendMessageWithStream(
//             '图片解析结果：$imgDiscription, \n用户输入: $message',
//             (event) {
//               final firstCompletionChoice = event.choices.first;
//               content += firstCompletionChoice.delta.content?.first?.text ?? '';
//               _chats[title]!.setLastMsg(extractResponseContent(content));
//               _chats[title]!.saveRecord(); // 每次流式更新都保存
//               notifyListeners();
//             },
//             () {
//               Logger.log('llm 回复: $content');
//               content = content.replaceAll('```json', '').replaceAll('```', '');
//               updateImgMemory(title, content, imgPaths);
//               _chats[title]!.saveRecord();
//               _chats[title]!.showAllRecords();
//             },
//             records: _chats[title]!.getLastMsgModel(20),
//           );
//         }
//       }
//     } catch (e, stackTrace) {
//       Logger.logError('ChatController sendMessage 方法出错: $e', stackTrace);
//     }
//   }

//   String extractResponseContent(String input) {
//     int startIndex = input.indexOf('"Response": "');
//     if (startIndex == -1) {
//       return '正在思考中...';
//     }
//     startIndex += '"Response": "'.length;
//     while (startIndex < input.length && input[startIndex] == ' ') {
//       startIndex++;
//     }
//     int endIndex = input.indexOf('",', startIndex);
//     if (endIndex == -1) {
//       return input.substring(startIndex).trim();
//     }
//     return input.substring(startIndex, endIndex).trim();
//   }

//   void updateImgMemory(String title, String msg, List<String> imgPaths) {
//     try {
//       var resMap = json.decode(msg) as Map<String, dynamic>;
//       if (resMap.containsKey('updated_image')) {
//         List<dynamic> updatedImgList = resMap['updated_image'];
//         List<String> updatedImg =
//             updatedImgList.map((e) => e.toString()).toList();
//         Logger.log('updateImg: $updatedImg');
//         Logger.log('imgPaths: $imgPaths');
//         if (updatedImg.length == imgPaths.length) {
//           for (int i = 0; i < imgPaths.length; i++) {
//             String imgPath = imgPaths[i];
//             String jsonPath = imgPath.replaceAll(RegExp(r'\.\w+$'), '.json');
//             File jsonFile = File(jsonPath);
//             Map<String, dynamic> jsonData = {};
//             if (jsonFile.existsSync()) {
//               String jsonString = jsonFile.readAsStringSync();
//               jsonData = json.decode(jsonString) as Map<String, dynamic>;
//             }
//             jsonData['更新描述'] = updatedImg[i];
//             notifyListeners();
//             jsonFile.writeAsStringSync(json.encode(jsonData));
//           }
//         } else {
//           Logger.logError(
//               'ChatController updateImgMemory 方法出错: updatedImg 和 imgPaths 的长度不一致',
//               null);
//         }
//       }
//     } catch (e, stackTrace) {
//       Logger.logError('ChatController updateImgMemory 方法出错: $e', stackTrace);
//     }
//   }

//   void updateImgs(String title, String imgMDText) {
//     try {
//       var key = '$title-imgs';
//       if (_imgRecords.containsKey(key)) {
//         _imgRecords[key]!.updateRecord(imgMDText);
//       } else {
//         _imgRecords[key] = ImgRecord(title: key, imgMDText: imgMDText);
//       }
//       notifyListeners();
//     } catch (e, stackTrace) {
//       Logger.logError('ChatController updateImgs 方法出错: $e', stackTrace);
//     }
//   }

//   void createChat(String title) {
//     try {
//       if (title.isEmpty) {
//         Logger.logError('ChatController createChat: 标题为空');
//         return;
//       }
//       _chats[title] = Chat(title: title);
//       _imgRecords['$title-imgs'] = ImgRecord(title: '$title-imgs');
//       notifyListeners();
//       sendMessage(title, "正在思考中...", true);
//       var str = Guidance().generateGuidanceMessage();
//       str.then((value) {
//         _chats[title]!.setLastMsg(value);
//         notifyListeners();
//       });
//     } catch (e, stackTrace) {
//       Logger.logError('ChatController createChat 方法出错: $e', stackTrace);
//     }
//   }

//   void clearChatRecord(String title) {
//     try {
//       if (_chats.containsKey(title)) {
//         _chats[title]!.clearRecord();
//         notifyListeners();
//       }
//     } catch (e, stackTrace) {
//       Logger.logError('ChatController clearChatRecord 方法出错: $e', stackTrace);
//     }
//   }

//   Future<void> deleteChatRecord(String title) async {
//     try {
//       if (_chats.containsKey(title)) {
//         _chats.remove(title);
//         var file = File('chats/$title.json');
//         if (await file.exists()) {
//           await file.delete();
//         }
//         notifyListeners();
//         var directory = Directory('chats/$title');
//         if (await directory.exists()) {
//           await directory.delete(recursive: true);
//         }
//         file = File('chats/$title-imgs.txt');
//         if (await file.exists()) {
//           await file.delete();
//         }
//       }
//     } catch (e, stackTrace) {
//       Logger.logError('ChatController deleteChatRecord 方法出错: $e', stackTrace);
//     }
//   }

//   Future<void> summarize(String title) async {
//     try {
//       if (_chats.containsKey(title)) {
//         notifyListeners();
//         Logger.log('选择图片：$selectedImgs');
//         var imgPaths = selectedImgs.map((e) {
//           String path = '';
//           if (e >= 0) {
//             path = _imgRecords['$title-imgs']!.imgMDText.split('\n')[e - 1];
//           }
//           return path;
//         }).toList();
//         var imgDiscription =
//             json.decode(await analyseImg(title, imgPaths)).toString();
//         var prompt = Prompts().getPrompt("summary_prompt");
//         String content = '';
//         sendMessage(title, '正在总结中...', true);
//         _chats[title]!.setPrompt(prompt);
//         OpenAIUserInteraction().sendMessageWithStream(
//           '图片解析结果：$imgDiscription',
//           (event) {
//             final firstCompletionChoice = event.choices.first;
//             content += firstCompletionChoice.delta.content?.first?.text ?? '';
//             _chats[title]!.setLastMsg(content);
//             notifyListeners();
//           },
//           () {
//             Logger.log('llm 总结: $content');
//           },
//           records: _chats[title]!.getLastMsgModel(20),
//         );
//         _chats[title]!.showAllRecords();
//       }
//     } catch (e, stackTrace) {
//       Logger.logError('ChatController summarize 方法出错: $e', stackTrace);
//     }
//   }

//   void update() {
//     try {
//       notifyListeners();
//     } catch (e, stackTrace) {
//       Logger.logError('ChatController update 方法出错: $e', stackTrace);
//     }
//   }

//   void likeMessage(String title, int index) {
//     try {
//       if (_chats.containsKey(title)) {
//         var chat = _chats[title]!;
//         chat.messages[index]['metadata']['liked'] = true;
//         chat.messages[index]['metadata']['disliked'] = false;
//         chat.saveRecord();
//         Logger.log('用户点赞消息: $title[$index]');
//         notifyListeners();
//       }
//     } catch (e, stackTrace) {
//       Logger.logError('ChatController likeMessage 方法出错: $e', stackTrace);
//     }
//   }

//   void dislikeMessage(String title, int index) {
//     try {
//       if (_chats.containsKey(title)) {
//         var chat = _chats[title]!;
//         chat.messages[index]['metadata']['disliked'] = true;
//         chat.messages[index]['metadata']['liked'] = false;
//         chat.saveRecord();
//         Logger.log('用户踩消息: $title[$index]');
//         notifyListeners();
//       }
//     } catch (e, stackTrace) {
//       Logger.logError('ChatController dislikeMessage 方法出错: $e', stackTrace);
//     }
//   }

//   Future<void> regenerateMessage(String title, int index) async {
//     try {
//       if (_chats.containsKey(title)) {
//         var chat = _chats[title]!;
//         if (index >= chat.messages.length || index < 0) return;

//         if (index == 0 ||
//             chat.messages[index - 1]['content'].role !=
//                 OpenAIChatMessageRole.user) {
//           Logger.log('无法重新生成：没有对应的用户输入');
//           return;
//         }
//         String userMessage =
//             chat.messages[index - 1]['content'].content!.first.text!;

//         chat.messages[index]['content'] =
//             OpenAIChatCompletionChoiceMessageModel(
//           role: OpenAIChatMessageRole.assistant,
//           content: [
//             OpenAIChatCompletionChoiceMessageContentItemModel.text('正在重新生成...')
//           ],
//         );
//         notifyListeners();

//         var shortRecord = chat.getLastMsg(20);
//         Logger.log('重新生成 - 选择图片：$selectedImgs');
//         var imgPaths = selectedImgs.map((e) {
//           String path = '';
//           if (e >= 0) {
//             path = _imgRecords['$title-imgs']!.imgMDText.split('\n')[e - 1];
//           }
//           return path;
//         }).toList();
//         Logger.log('重新生成 - 用户选择的图片：$imgPaths');
//         var imgDiscription =
//             json.decode(await analyseImg(title, imgPaths)).toString();
//         var prompt =
//             Prompts().generateStrategyPrompt(imgDiscription, shortRecord, '');
//         String content = '';

//         chat.setPrompt(prompt);
//         await OpenAIUserInteraction().sendMessageWithStream(
//           '图片解析结果：$imgDiscription, \n用户输入: $userMessage',
//           (event) {
//             final firstCompletionChoice = event.choices.first;
//             content += firstCompletionChoice.delta.content?.first?.text ?? '';
//             chat.messages[index]['content'] =
//                 OpenAIChatCompletionChoiceMessageModel(
//               role: OpenAIChatMessageRole.assistant,
//               content: [
//                 OpenAIChatCompletionChoiceMessageContentItemModel.text(
//                     extractResponseContent(content))
//               ],
//             );
//             notifyListeners();
//           },
//           () {
//             Logger.log('重新生成消息完成: $content');
//             content = content.replaceAll('```json', '').replaceAll('```', '');
//             updateImgMemory(title, content, imgPaths);
//             chat.saveRecord();
//             chat.showAllRecords();
//           },
//           records: chat.getLastMsgModel(20),
//         );
//       }
//     } catch (e, stackTrace) {
//       Logger.logError('ChatController regenerateMessage 方法出错: $e', stackTrace);
//     }
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:chat_pro/chat_page_msg.dart';
import 'package:chat_pro/embeddings.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'backend.dart';

class Logger {
  static const String logFilePath = 'chat_app.log';

  static void log(String message) {
    final logFile = File(logFilePath);
    final logMessage = '${DateTime.now()}: $message\n';
    logFile.writeAsStringSync(logMessage, mode: FileMode.append);
  }

  static void logError(String errorMessage, [StackTrace? stackTrace]) {
    var logMessage = '${DateTime.now()}: [ERROR] $errorMessage\n';
    if (stackTrace != null) logMessage += '$stackTrace\n';
    final logFile = File(logFilePath);
    logFile.writeAsStringSync(logMessage, mode: FileMode.append);
  }
}

class ImgRecord {
  final String title;
  String imgMDText;
  late String lastImgs;
  String get lastImgMDText => imgMDText;
  ImgRecord({this.imgMDText = '', required this.title}) {
    try {
      saveRecord();
    } catch (e, stackTrace) {
      Logger.logError('ImgRecord 构造函数中保存记录出错: $e', stackTrace);
    }
  }

  @override
  bool operator ==(Object other) =>
      other is ImgRecord && other.imgMDText == imgMDText;

  @override
  int get hashCode => imgMDText.hashCode;

  factory ImgRecord.fromPath(String path) {
    try {
      final File file = File(path);
      if (file.existsSync()) {
        final fileName = file.uri.pathSegments.last.split('.').first;
        var imgMDText = file.readAsStringSync();
        return ImgRecord(title: fileName, imgMDText: imgMDText);
      }
      return ImgRecord(title: '-imgs');
    } catch (e, stackTrace) {
      Logger.logError('ImgRecord 从路径创建实例出错: $e', stackTrace);
      return ImgRecord(title: '-imgs');
    }
  }

  void saveRecord() {
    try {
      final file = File('chats/$title.txt');
      file.writeAsStringSync(imgMDText);
    } catch (e, stackTrace) {
      Logger.logError('ImgRecord 保存记录出错: $e', stackTrace);
    }
  }

  void updateRecord(String imgMDText) {
    try {
      this.imgMDText += imgMDText;
      lastImgs = imgMDText;
      saveRecord();
    } catch (e, stackTrace) {
      Logger.logError('ImgRecord 更新记录出错: $e', stackTrace);
    }
  }

  void clearRecord() {
    try {
      imgMDText = '';
      saveRecord();
    } catch (e, stackTrace) {
      Logger.logError('ImgRecord 清空记录出错: $e', stackTrace);
    }
  }
}

class Chat {
  late String title;
  late List<Map<String, dynamic>> messages;
  late OpenAIChatCompletionChoiceMessageModel prompt;

  Chat(
      {required this.title,
      List<OpenAIChatCompletionChoiceMessageModel>? content}) {
    messages = content != null
        ? content
            .map((c) => {
                  'content': c,
                  'metadata': {'liked': false, 'disliked': false}
                })
            .toList()
        : [];
  }

  Chat.fromPath(String path) {
    try {
      final File file = File(path);
      final fileName = file.uri.pathSegments.last.split('.').first;
      var jsonString = file.readAsStringSync();
      Logger.log('加载文件 $path，内容: $jsonString');
      var jsonData = json.decode(jsonString);
      if (jsonData is List) {
        messages = (jsonData as List<dynamic>)
            .map((item) => {
                  'content': OpenAIChatCompletionChoiceMessageModel.fromMap(
                      item['content']),
                  'metadata': Map<String, dynamic>.from(item['metadata']),
                })
            .toList();
      } else if (jsonData is Map) {
        var contentList = (jsonData['content'] as List<dynamic>)
            .map((json) => OpenAIChatCompletionChoiceMessageModel.fromMap(json))
            .toList();
        var metadataList = jsonData['metadata'] != null
            ? List<Map<String, dynamic>>.from(jsonData['metadata'])
            : List.generate(
                contentList.length, (_) => {'liked': false, 'disliked': false});
        messages = List.generate(contentList.length,
            (i) => {'content': contentList[i], 'metadata': metadataList[i]});
      } else {
        throw Exception('无效的 JSON 格式');
      }
      title = fileName;
      Logger.log('成功解析聊天记录: $title，消息数: ${messages.length}');
    } catch (e, stackTrace) {
      Logger.logError('Chat 从路径 $path 创建实例出错: $e', stackTrace);
      messages = [];
      title = '';
    }
  }

  void saveRecord() {
    try {
      final file = File('chats/$title.json');
      final jsonEncoder = JsonEncoder();
      final lines = messages
          .map((msg) => jsonEncoder.convert({
                'content': msg['content'].toMap(),
                'metadata': msg['metadata'],
              }))
          .toList();
      String jsonString = '[\n' + lines.join(',\n') + '\n]';
      file.writeAsStringSync(jsonString);
      Logger.log('保存聊天记录: $title，路径: ${file.path}');
    } catch (e, stackTrace) {
      Logger.logError('Chat 保存记录出错: $e', stackTrace);
    }
  }

  void setLastMsg(String lastMsg) {
    try {
      if (messages.isNotEmpty) {
        messages.last['content'] = OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.assistant,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(lastMsg)
          ],
        );
        saveRecord();
      }
    } catch (e, stackTrace) {
      Logger.logError('Chat 设置最后消息出错: $e', stackTrace);
    }
  }

  void clearRecord() {
    try {
      messages = [];
      saveRecord();
    } catch (e, stackTrace) {
      Logger.logError('Chat 清空记录出错: $e', stackTrace);
    }
  }

  void setPrompt(String prompt) {
    try {
      this.prompt = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt)
        ],
      );
    } catch (e, stackTrace) {
      Logger.logError('Chat 设置prompt出错: $e', stackTrace);
    }
  }

  void addMsg({required OpenAIChatMessageRole role, required String text}) {
    try {
      messages.add({
        'content': OpenAIChatCompletionChoiceMessageModel(
          role: role,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(text)
          ],
        ),
        'metadata': {'liked': false, 'disliked': false},
      });
      saveRecord();
      if (messages.length > 20) {
        var sc = messages
            .sublist(0, 2)
            .map((m) => m['content'].toMap().toString())
            .toList();
        VectorDB().store(title, sc, sc.toString());
      }
    } catch (e, stackTrace) {
      Logger.logError('Chat 添加消息出错: $e', stackTrace);
    }
  }

  String getLastMsg(int count) {
    try {
      var startIndex = messages.length > count ? messages.length - count : 0;
      var lastMsgs = messages.sublist(startIndex);
      return lastMsgs
          .map((m) => m['content'].toMap().toString())
          .toList()
          .toString();
    } catch (e, stackTrace) {
      Logger.logError('Chat 获取最后消息出错: $e', stackTrace);
      return '';
    }
  }

  List<OpenAIChatCompletionChoiceMessageModel> getLastMsgModel(int count) {
    try {
      var startIndex = messages.length > count ? messages.length - count : 0;
      var lastMsgs = messages
          .sublist(startIndex)
          .map((m) => m['content'] as OpenAIChatCompletionChoiceMessageModel)
          .toList();
      var res = [prompt];
      res.addAll(lastMsgs);
      return res;
    } catch (e, stackTrace) {
      Logger.logError('Chat 获取最近消息出错: $e', stackTrace);
      return [prompt];
    }
  }

  void showAllRecords() {
    try {
      Logger.log('===========================所有聊天记录=========================');
      var res = messages.map((m) => m['content'].toMap().toString()).toList();
      for (var r in res) Logger.log(r);
    } catch (e, stackTrace) {
      Logger.logError('Chat 显示所有记录出错: $e', stackTrace);
    }
  }

  Widget buildWidget(int index, String title) {
    try {
      if (index < messages.length && index >= 0) {
        var msg = messages[index]['content'].content!.first.text!;
        var left =
            messages[index]['content'].role == OpenAIChatMessageRole.assistant;
        if (messages[index]['content'].role == OpenAIChatMessageRole.system)
          return const SizedBox();
        return _build(mdMsg: msg, left: left, title: title, index: index);
      }
      return const SizedBox();
    } catch (e, stackTrace) {
      Logger.logError('Chat 构建 Widget 出错: $e', stackTrace);
      return const SizedBox();
    }
  }

  Widget _build(
      {required String mdMsg,
      required bool left,
      required String title,
      required int index}) {
    try {
      if (left) {
        return ChatPageMsg(
          left: left,
          mdMsg: mdMsg,
          imgText: '小助手',
          headBGColor: const Color.fromARGB(255, 166, 51, 243),
          headTextColor: Colors.white,
          bgColor: const Color.fromARGB(255, 255, 204, 255),
          textColor: const Color.fromARGB(255, 166, 51, 243),
          title: title,
          index: index,
        );
      } else {
        return ChatPageMsg(
          left: left,
          mdMsg: mdMsg,
          imgText: '用户',
          headBGColor: const Color.fromARGB(255, 6, 94, 166),
          headTextColor: Colors.white,
          bgColor: const Color.fromARGB(255, 185, 225, 255),
          textColor: const Color.fromARGB(255, 6, 94, 166),
          title: title,
          index: index,
        );
      }
    } catch (e, stackTrace) {
      Logger.logError('Chat 静态构建 Widget 出错: $e', stackTrace);
      return const SizedBox();
    }
  }
}

class ChatController with ChangeNotifier {
  static final ChatController _instance = ChatController._internal();
  factory ChatController() => _instance;

  ChatController._internal() {
    try {
      readAllChats();
      Prompts().loadPrompts();
    } catch (e, stackTrace) {
      Logger.logError('ChatController 构造函数出错: $e', stackTrace);
    }
  }

  final Map<String, ImgRecord> _imgRecords = {};
  final Map<String, Chat> _chats = {};
  List<int> selectedImgs = [];
  Map<String, Chat> get chats => _chats;
  List<String> get chatTitles => _chats.keys.toList();

  Chat getChat(String title) {
    try {
      final chat = _chats[title];
      if (chat == null) {
        Logger.logError('ChatController getChat: 未找到标题为 "$title" 的聊天记录');
        throw Exception('Chat with title "$title" not found');
      }
      return chat;
    } catch (e, stackTrace) {
      Logger.logError('ChatController getChat 方法出错: $e', stackTrace);
      rethrow;
    }
  }

  ImgRecord getImgRecordByTitle(String title) {
    try {
      return _imgRecords['$title-imgs'] ?? ImgRecord(title: '$title-imgs');
    } catch (e, stackTrace) {
      Logger.logError(
          'ChatController getImgRecordByTitle 方法出错: $e', stackTrace);
      rethrow;
    }
  }

  String getImgsText(String title) {
    try {
      return _imgRecords['$title-imgs']?.imgMDText ?? '';
    } catch (e, stackTrace) {
      Logger.logError('ChatController getImgsText 方法出错: $e', stackTrace);
      return '';
    }
  }

  Future<void> readAllChats() async {
    final directory = Directory('chats');
    if (!directory.existsSync()) {
      Logger.log('聊天目录 "chats" 不存在，创建新目录');
      directory.createSync();
    }
    final files = directory.listSync().whereType<File>().toList();
    Logger.log('发现 ${files.length} 个文件 in chats 目录');
    for (final file in files) {
      try {
        final fileName = file.uri.pathSegments.last;
        if (fileName.endsWith('.json')) {
          final title = fileName.replaceAll('.json', '');
          final chat = Chat.fromPath(file.path);
          _chats[title] = chat;
          Logger.log('加载聊天记录: $title，消息数: ${chat.messages.length}');
        } else if (fileName.endsWith('.txt')) {
          final titleTxt = fileName.replaceAll('.txt', '');
          final imgRecord = ImgRecord.fromPath(file.path);
          _imgRecords[titleTxt] = imgRecord;
          Logger.log('加载图片记录: $titleTxt');
        }
      } catch (e, stackTrace) {
        Logger.logError('读取文件 ${file.path} 时出错: $e', stackTrace);
      }
    }
    Logger.log('加载完成，共 ${_chats.length} 个聊天记录');
    notifyListeners();
  }

  Future<void> sendMessage(String title, String message, bool left) async {
    try {
      if (!_chats.containsKey(title)) {
        _chats[title] = Chat(title: title); // 如果聊天不存在，创建新聊天
      }
      var chat = _chats[title]!;
      chat.addMsg(
        role:
            left ? OpenAIChatMessageRole.assistant : OpenAIChatMessageRole.user,
        text: message,
      );
      chat.saveRecord();
      notifyListeners();

      if (!left) {
        var shortRecord = chat.getLastMsg(20);
        Logger.log('选择图片：$selectedImgs');
        var imgPaths = selectedImgs.map((e) {
          String path = '';
          if (e >= 0 && _imgRecords['$title-imgs'] != null) {
            var lines = _imgRecords['$title-imgs']!.imgMDText.split('\n');
            if (e - 1 < lines.length) path = lines[e - 1];
          }
          return path;
        }).toList();
        Logger.log('用户选择的图片：$imgPaths');
        var imgDiscription =
            json.decode(await analyseImg(title, imgPaths)).toString();
        var prompt =
            Prompts().generateStrategyPrompt(imgDiscription, shortRecord, '');
        String content = '';

        chat.addMsg(role: OpenAIChatMessageRole.assistant, text: '正在思考中...');
        chat.saveRecord();
        notifyListeners();

        chat.setPrompt(prompt);
        await OpenAIUserInteraction().sendMessageWithStream(
          '图片解析结果：$imgDiscription, \n用户输入: $message',
          (event) {
            final firstCompletionChoice = event.choices.first;
            content += firstCompletionChoice.delta.content?.first?.text ?? '';
            chat.setLastMsg(extractResponseContent(content));
            chat.saveRecord();
            notifyListeners();
          },
          () {
            Logger.log('llm 回复: $content');
            content = content.replaceAll('```json', '').replaceAll('```', '');
            updateImgMemory(title, content, imgPaths);
            chat.saveRecord();
            chat.showAllRecords();
          },
          records: chat.getLastMsgModel(20),
        );
      }
    } catch (e, stackTrace) {
      Logger.logError('ChatController sendMessage 方法出错: $e', stackTrace);
      notifyListeners(); // 即使出错也通知UI
    }
  }

  String extractResponseContent(String input) {
    int startIndex = input.indexOf('"Response": "');
    if (startIndex == -1) return '正在思考中...';
    startIndex += '"Response": "'.length;
    while (startIndex < input.length && input[startIndex] == ' ') startIndex++;
    int endIndex = input.indexOf('",', startIndex);
    if (endIndex == -1) return input.substring(startIndex).trim();
    return input.substring(startIndex, endIndex).trim();
  }

  void updateImgMemory(String title, String msg, List<String> imgPaths) {
    try {
      var resMap = json.decode(msg) as Map<String, dynamic>;
      if (resMap.containsKey('updated_image')) {
        List<dynamic> updatedImgList = resMap['updated_image'];
        List<String> updatedImg =
            updatedImgList.map((e) => e.toString()).toList();
        Logger.log('updateImg: $updatedImg');
        Logger.log('imgPaths: $imgPaths');
        if (updatedImg.length == imgPaths.length) {
          for (int i = 0; i < imgPaths.length; i++) {
            String imgPath = imgPaths[i];
            String jsonPath = imgPath.replaceAll(RegExp(r'\.\w+$'), '.json');
            File jsonFile = File(jsonPath);
            Map<String, dynamic> jsonData = {};
            if (jsonFile.existsSync()) {
              String jsonString = jsonFile.readAsStringSync();
              jsonData = json.decode(jsonString) as Map<String, dynamic>;
            }
            jsonData['更新描述'] = updatedImg[i];
            jsonFile.writeAsStringSync(json.encode(jsonData));
          }
        } else {
          Logger.logError(
              'ChatController updateImgMemory 方法出错: updatedImg 和 imgPaths 的长度不一致',
              null);
        }
      }
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.logError('ChatController updateImgMemory 方法出错: $e', stackTrace);
    }
  }

  void updateImgs(String title, String imgMDText) {
    try {
      var key = '$title-imgs';
      if (_imgRecords.containsKey(key)) {
        _imgRecords[key]!.updateRecord(imgMDText);
      } else {
        _imgRecords[key] = ImgRecord(title: key, imgMDText: imgMDText);
      }
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.logError('ChatController updateImgs 方法出错: $e', stackTrace);
    }
  }

  void createChat(String title) {
    try {
      if (title.isEmpty) {
        Logger.logError('ChatController createChat: 标题为空');
        return;
      }
      _chats[title] = Chat(title: title);
      _imgRecords['$title-imgs'] = ImgRecord(title: '$title-imgs');
      notifyListeners();
      sendMessage(title, "正在思考中...", true);
      var str = Guidance().generateGuidanceMessage();
      str.then((value) {
        _chats[title]!.setLastMsg(value);
        notifyListeners();
      });
    } catch (e, stackTrace) {
      Logger.logError('ChatController createChat 方法出错: $e', stackTrace);
    }
  }

  void clearChatRecord(String title) {
    try {
      if (_chats.containsKey(title)) {
        _chats[title]!.clearRecord();
        notifyListeners();
      }
    } catch (e, stackTrace) {
      Logger.logError('ChatController clearChatRecord 方法出错: $e', stackTrace);
    }
  }

  Future<void> deleteChatRecord(String title) async {
    try {
      if (_chats.containsKey(title)) {
        _chats.remove(title);
        var file = File('chats/$title.json');
        if (await file.exists()) await file.delete();
        notifyListeners();
        var directory = Directory('chats/$title');
        if (await directory.exists()) await directory.delete(recursive: true);
        file = File('chats/$title-imgs.txt');
        if (await file.exists()) await file.delete();
      }
    } catch (e, stackTrace) {
      Logger.logError('ChatController deleteChatRecord 方法出错: $e', stackTrace);
    }
  }

  Future<void> summarize(String title) async {
    try {
      if (_chats.containsKey(title)) {
        notifyListeners();
        Logger.log('选择图片：$selectedImgs');
        var imgPaths = selectedImgs.map((e) {
          String path = '';
          if (e >= 0) {
            path = _imgRecords['$title-imgs']!.imgMDText.split('\n')[e - 1];
          }
          return path;
        }).toList();
        var imgDiscription =
            json.decode(await analyseImg(title, imgPaths)).toString();
        var prompt = Prompts().getPrompt("summary_prompt");
        String content = '';
        sendMessage(title, '正在总结中...', true);
        _chats[title]!.setPrompt(prompt);
        OpenAIUserInteraction().sendMessageWithStream(
          '图片解析结果：$imgDiscription',
          (event) {
            final firstCompletionChoice = event.choices.first;
            content += firstCompletionChoice.delta.content?.first?.text ?? '';
            _chats[title]!.setLastMsg(content);
            notifyListeners();
          },
          () {
            Logger.log('llm 总结: $content');
          },
          records: _chats[title]!.getLastMsgModel(20),
        );
        _chats[title]!.showAllRecords();
      }
    } catch (e, stackTrace) {
      Logger.logError('ChatController summarize 方法出错: $e', stackTrace);
    }
  }

  void update() {
    try {
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.logError('ChatController update 方法出错: $e', stackTrace);
    }
  }

  void likeMessage(String title, int index) {
    try {
      if (_chats.containsKey(title)) {
        var chat = _chats[title]!;
        chat.messages[index]['metadata']['liked'] = true;
        chat.messages[index]['metadata']['disliked'] = false;
        chat.saveRecord();
        Logger.log('用户点赞消息: $title[$index]');
        notifyListeners();
      }
    } catch (e, stackTrace) {
      Logger.logError('ChatController likeMessage 方法出错: $e', stackTrace);
    }
  }

  void dislikeMessage(String title, int index) {
    try {
      if (_chats.containsKey(title)) {
        var chat = _chats[title]!;
        chat.messages[index]['metadata']['disliked'] = true;
        chat.messages[index]['metadata']['liked'] = false;
        chat.saveRecord();
        Logger.log('用户踩消息: $title[$index]');
        notifyListeners();
      }
    } catch (e, stackTrace) {
      Logger.logError('ChatController dislikeMessage 方法出错: $e', stackTrace);
    }
  }

  Future<void> regenerateMessage(String title, int index) async {
    try {
      if (_chats.containsKey(title)) {
        var chat = _chats[title]!;
        if (index >= chat.messages.length || index < 0) return;

        if (index == 0 ||
            chat.messages[index - 1]['content'].role !=
                OpenAIChatMessageRole.user) {
          Logger.log('无法重新生成：没有对应的用户输入');
          return;
        }
        String userMessage =
            chat.messages[index - 1]['content'].content!.first.text!;

        chat.messages[index]['content'] =
            OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.assistant,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text('正在重新生成...')
          ],
        );
        chat.saveRecord();
        notifyListeners();

        var shortRecord = chat.getLastMsg(20);
        Logger.log('重新生成 - 选择图片：$selectedImgs');
        var imgPaths = selectedImgs.map((e) {
          String path = '';
          if (e >= 0) {
            path = _imgRecords['$title-imgs']!.imgMDText.split('\n')[e - 1];
          }
          return path;
        }).toList();
        Logger.log('重新生成 - 用户选择的图片：$imgPaths');
        var imgDiscription =
            json.decode(await analyseImg(title, imgPaths)).toString();
        var prompt =
            Prompts().generateStrategyPrompt(imgDiscription, shortRecord, '');
        String content = '';

        chat.setPrompt(prompt);
        await OpenAIUserInteraction().sendMessageWithStream(
          '图片解析结果：$imgDiscription, \n用户输入: $userMessage',
          (event) {
            final firstCompletionChoice = event.choices.first;
            content += firstCompletionChoice.delta.content?.first?.text ?? '';
            chat.messages[index]['content'] =
                OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.assistant,
              content: [
                OpenAIChatCompletionChoiceMessageContentItemModel.text(
                    extractResponseContent(content))
              ],
            );
            chat.saveRecord();
            notifyListeners();
          },
          () {
            Logger.log('重新生成消息完成: $content');
            content = content.replaceAll('```json', '').replaceAll('```', '');
            updateImgMemory(title, content, imgPaths);
            chat.saveRecord();
            chat.showAllRecords();
          },
          records: chat.getLastMsgModel(20),
        );
      }
    } catch (e, stackTrace) {
      Logger.logError('ChatController regenerateMessage 方法出错: $e', stackTrace);
    }
  }
}
