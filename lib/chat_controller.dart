import 'dart:convert';
import 'dart:io';
import 'package:chat_pro/chat_page_msg.dart';
import 'package:chat_pro/embeddings.dart';
import 'package:chat_pro/ui/theme.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'backend.dart';

// 日志工具类
class Logger {
  static const String logFilePath = 'chat_app.log';

  static void log(String message) {
    final logFile = File(logFilePath);
    final logMessage = '${DateTime.now()}: $message\n';
    logFile.writeAsStringSync(logMessage, mode: FileMode.append);
  }

  static void logError(String errorMessage, [StackTrace? stackTrace]) {
    var logMessage = '${DateTime.now()}: [ERROR] $errorMessage\n';
    if (stackTrace != null) {
      logMessage += '$stackTrace\n';
    }
    final logFile = File(logFilePath);
    logFile.writeAsStringSync(logMessage, mode: FileMode.append);
  }
}

class ImgRecord {
  final String title;
  // String imgMDText;
  // String get lastImgMDText => imgMDText;
  late List<String> imgs;
  ImgRecord({required this.title, List<String>? imgs}) {
    try {
      this.imgs = imgs ?? [];
      saveRecord();
    } catch (e, stackTrace) {
      Logger.logError('ImgRecord 构造函数中保存记录出错: $e', stackTrace);
    }
  }

  @override
  bool operator ==(Object other) {
    return other is ImgRecord && other.imgs == imgs;
  }

  @override
  int get hashCode => imgs.hashCode;

  factory ImgRecord.fromPath(String path) {
    final File file = File(path);
    final fileName = file.uri.pathSegments.last.split('.').first;
    try {
      if (file.existsSync()) {
        var imgsJson = json.decode(file.readAsStringSync()) as List<dynamic>;
        var imgs = imgsJson.map((e) => e.toString()).toList();
        return ImgRecord(title: fileName, imgs: imgs);
      }
      return ImgRecord(title: '$fileName-imgs');
    } catch (e, stackTrace) {
      Logger.logError('ImgRecord 从路径创建实例出错: $e', stackTrace);
      return ImgRecord(title: '$fileName-imgs');
    }
  }

  void saveRecord() {
    try {
      final file = File('chats/$title.json');
      file.writeAsStringSync(json.encode(imgs));
    } catch (e, stackTrace) {
      Logger.logError('ImgRecord 保存记录出错: $e', stackTrace);
    }
  }

  void addImgs(List<String> paths) {
    try {
      imgs.addAll(paths);
      saveRecord();
    } catch (e, stackTrace) {
      Logger.logError('ImgRecord 更新记录出错: $e', stackTrace);
    }
  }

  void checkParsedImgs() {
    try {
      ChatController().isParsed = List.filled(imgs.length, false);
      for (int i = 0; i < imgs.length; i++) {
        String resultFilePath = imgs[i].replaceAll(RegExp(r'\.[^.]+$'), '.json');
        if(File(resultFilePath).existsSync()){
          ChatController().isParsed[i] = true;
        }
      }
      for (var index in ChatController().selectedImgs) {
        if (ChatController().isParsed[index] == false) {
          ChatController().sendPermission = false;
          ChatController().update();
          Logger.log('selectedImgs: ${ChatController().selectedImgs}\nisParsed: ${ChatController().isParsed}');
          return;
        }
      }
      Logger.log('selectedImgs: ${ChatController().selectedImgs}\nisParsed: ${ChatController().isParsed}');
      ChatController().sendPermission = true;
      ChatController().update();
    } catch (e, stackTrace) {
      Logger.logError('ImgRecord 检查解析图片出错: $e', stackTrace);
    }
  }
}

class Chat {
  late String title;
  late List<OpenAIChatCompletionChoiceMessageModel> content;
  // late List<OpenAIChatCompletionChoiceMessageModel> prompts;
  late OpenAIChatCompletionChoiceMessageModel prompt;
  Chat({required this.title, required this.content});
  Chat.fromPath(String path) {
    try {
      final File file = File(path);
      final fileName = file.uri.pathSegments.last.split('.').first;
      var jsonString = file.readAsStringSync();
      var jsonList = json.decode(jsonString) as List<dynamic>;
      content = [];
      for (var json in jsonList) {
        content.add(OpenAIChatCompletionChoiceMessageModel.fromMap(json));
      }
      title = fileName;
    } catch (e, stackTrace) {
      Logger.logError('Chat 从路径创建实例出错: $e', stackTrace);
    }
  }
  void setLastMsg(String msg) {
    try {
      if (content.isNotEmpty) {
        content.last.content![0] =
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
          msg,
        );
        saveRecord();
      }
    } catch (e, stackTrace) {
      Logger.logError('Chat 设置最后消息出错: $e', stackTrace);
    }
  }

  void saveRecord() {
    try {
      final file = File('chats/$title.json');
      // 将 content 转换为 JSON 列表
      var jsonList = content.map((e) => e.toMap()).toList();
      // 将 JSON 列表编码为标准的 JSON 字符串
      var jsonString = json.encode(jsonList);
      file.writeAsStringSync(jsonString);
    } catch (e, stackTrace) {
      Logger.logError('Chat 保存记录出错: $e', stackTrace);
    }
  }

  // void clearRecord() {
  //   try {
  //     content = [];
  //     saveRecord();
  //   } catch (e, stackTrace) {
  //     Logger.logError('Chat 清空记录出错: $e', stackTrace);
  //   }
  // }

  void setPrompt(String prompt) {
    try {
      this.prompt = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            prompt,
          ),
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            '',
          ),
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            '',
          ),
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            'true',
          ),
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            '',
          ),
        ],
      );
    } catch (e, stackTrace) {
      Logger.logError('Chat 设置prompt出错: $e', stackTrace);
    }
  }

  void setRecommendations(String recommendations) {
    try {
      if (content.isNotEmpty) {
        var lastMsg = content.last;
        lastMsg.content![1] =
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
          recommendations,
        );
        // content[content.length - 1] = lastMsg;
        saveRecord();
      }
    } catch (e, stackTrace) {
      Logger.logError('Chat 设置推荐出错: $e', stackTrace);
    }
  }

  void setShowRecommendations(bool showRecommendations, int index) {
    try {
      if (content.isNotEmpty) {
        var msg = content[index];
        msg.content![3] =
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
          showRecommendations.toString(),
        );
        saveRecord();
      }
    } catch (e, stackTrace) {
      Logger.logError('Chat 设置显示推荐出错: $e', stackTrace);
    }
  }

  void addMsg({required OpenAIChatMessageRole role, required String text}) {
    try {
      content.add(OpenAIChatCompletionChoiceMessageModel(
        role: role,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            text,
          ),
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            '',
          ),
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            '',
          ),
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            'true',
          ),
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            '',
          ),
        ],
      ));
      saveRecord();
      setShowRecommendations(false, content.length - 2);
      if (content.length > 20) {
        var sc = content.sublist(0, 2);
        var text = sc.map((e) => e.toMap().toString()).toList();
        VectorDB().store(title, text, text.toString());
      }
    } catch (e, stackTrace) {
      Logger.logError('Chat 添加消息出错: $e', stackTrace);
    }
  }

  String getLastMsg({int index = 0}) {
    try {
      if(content.length - 1 - index < 0) return '';
      var lastMsgs = content[content.length - 1 - index];
      // if(lastMsgs.role == OpenAIChatMessageRole.user) {
      //   return lastMsgs.content![0].text!;
      // }
      return lastMsgs.content![0].text!;
    } catch (e, stackTrace) {
      Logger.logError('Chat 获取最后消息出错: $e', stackTrace);
      return '';
    }
  }

  List<OpenAIChatCompletionChoiceMessageModel> getLastMsgModel(int count) {
    try {
      var startIndex = content.length > count ? content.length - count : 0;
      var lastMsgs = content.sublist(startIndex);
      var prompt = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            this.prompt.content![0].text!,
          ),
        ],
      );
      var res = [prompt];
      res.addAll(lastMsgs);
      res = res.map((e) {
        if (e.role == OpenAIChatMessageRole.assistant) {
          var cont = e.content![4];
          OpenAIChatCompletionChoiceMessageModel newMsg =
              OpenAIChatCompletionChoiceMessageModel(
                  role: e.role, content: [cont]);
          return newMsg;
        } else if (e.role == OpenAIChatMessageRole.user) {
          var cont = e.content![0];
          OpenAIChatCompletionChoiceMessageModel newMsg =
              OpenAIChatCompletionChoiceMessageModel(
                  role: e.role, content: [cont]);
          return newMsg;
        }
        return e;
      }).toList();
      // Logger.log('res: ${res.toString()}');
      return res;
      // return lastMsgs;
    } catch (e, stackTrace) {
      Logger.logError('Chat 获取最近消息出错: $e', stackTrace);
      return [prompt];
    }
  }

  void showAllRecords() {
    try {
      Logger.log('===========================所有聊天记录=========================');
      var res = content.map((e) => e.toMap().toString()).toList();
      for (var r in res) {
        Logger.log(r);
      }
    } catch (e, stackTrace) {
      Logger.logError('Chat 显示所有记录出错: $e', stackTrace);
    }
  }

  Widget buildWidget(int index) {
    try {
      if (index < content.length && index >= 0) {
        var msg = content[index].content!.first.text!;
        var left = content[index].role == OpenAIChatMessageRole.assistant;
        var thumbUp = content[index].content![2].text!;
        bool showRecommendations = content[index].content![3].text! == 'true';
        if (content[index].role == OpenAIChatMessageRole.system) {
          return const SizedBox();
        }
        if (content[index].content![1].text!.isNotEmpty) {
          var rcm = content[index].content![1].text!;
          var rcmList = json.decode(rcm) as List<dynamic>;
          if (rcmList.isNotEmpty) {
            var rcmList2 = rcmList.map((e) => e as String).toList();

            return _build(
                mdMsg: msg,
                left: left,
                recommendations: rcmList2,
                index: index,
                thumbUp: thumbUp,
                showRecommendations: showRecommendations);
          }
        }
        return _build(
            mdMsg: msg,
            left: left,
            index: index,
            thumbUp: thumbUp,
            showRecommendations: showRecommendations);
      }
      return const SizedBox();
    } catch (e, stackTrace) {
      Logger.logError('Chat 构建 Widget 出错: $e', stackTrace);
      return const SizedBox();
    }
  }

  void setThumbUp(int index, String thumbUp) {
    try {
      var msg = content[index];
      msg.content![2] =
          OpenAIChatCompletionChoiceMessageContentItemModel.text(thumbUp);
      saveRecord();
    } catch (e, stackTrace) {
      Logger.logError('Chat 点赞出错: $e', stackTrace);
    }
  }

  static Widget _build(
      {required String mdMsg,
      required bool left,
      List<String> recommendations = const [],
      required int index,
      required String thumbUp,
      bool showRecommendations = false}) {
    try {
      if (left) {
        return ChatPageMsg(
          left: left,
          mdMsg: mdMsg,
          imgText: '小助手',
          headBGColor: ChatThemes().getColors()[0],
          headTextColor: ChatThemes().getColors()[1],
          bgColor: ChatThemes().getColors()[2],
          textColor: ChatThemes().getColors()[3],
          recommendations: recommendations,
          index: index,
          thumbUp: thumbUp,
          showRecommendations: showRecommendations,
        );
      } else {
        return ChatPageMsg(
          left: left,
          mdMsg: mdMsg,
          imgText: '用户',
          headBGColor: ChatThemes().getColors()[4],
          headTextColor: ChatThemes().getColors()[5],
          bgColor: ChatThemes().getColors()[6],
          textColor: ChatThemes().getColors()[7],
          recommendations: recommendations,
          index: index,
          thumbUp: thumbUp,
          showRecommendations: showRecommendations,
        );
      }
    } catch (e, stackTrace) {
      Logger.logError('Chat 静态构建 Widget 出错: $e', stackTrace);
      return const SizedBox();
    }
  }
}

/// 聊天控制
class ChatController with ChangeNotifier {
  // 静态私有实例，用于存储单例
  static final ChatController _instance = ChatController._internal();

  // 工厂构造函数，返回单例实例
  factory ChatController() {
    return _instance;
  }

  // 私有构造函数，防止外部实例化
  ChatController._internal() {
    try {
      // readAllChatRecords();
      readAllChats();
      Prompts().loadPrompts();
    } catch (e, stackTrace) {
      Logger.logError('ChatController 构造函数出错: $e', stackTrace);
    }
  }

  // 存储所有对话记录，key 是对话标题
  final Map<String, ImgRecord> _imgRecords = {};
  final Map<String, Chat> _chats = {};
  List<int> selectedImgs = [];
  int currentImgIndex = -1;
  // 获取所有对话记录
  Map<String, Chat> get chats => _chats;

  // 存储所有对话标题
  // List<String> get chatTitles => _chatRecords.keys.toList();
  List<String> get chatTitles => _chats.keys.toList();
  String currentTitle = '';
  String lastInput = '';

  ScrollController chatListScrollController = ScrollController();
  final TextEditingController textEditingController = TextEditingController();

  List<bool> isParsed = [];

  bool sendPermission = true;

  Chat getChat(String title) {
    try {
      return _chats[title]!;
    } catch (e, stackTrace) {
      Logger.logError('ChatController getChat 方法出错: $e', stackTrace);
      rethrow;
    }
  }

  // ImgRecord getImgRecordByTitle(String title) {
  //   try {
  //     return _imgRecords['$title-imgs']!;
  //   } catch (e, stackTrace) {
  //     Logger.logError(
  //         'ChatController getImgRecordByTitle 方法出错: $e', stackTrace);
  //     rethrow;
  //   }
  // }

  List<String> getImgs(String title) {
    try {
      return _imgRecords['$title-imgs']?.imgs ?? [];
    } catch (e, stackTrace) {
      Logger.logError('ChatController getImgs 方法出错: $e', stackTrace);
      return [];
    }
  }

  // 读取 chats 目录下的所有聊天记录文件
  Future<void> readAllChats() async {
    final directory = Directory('chats');
    if (!directory.existsSync()) {
      directory.createSync();
    }
    final files = directory.listSync().whereType<File>();
    for (final file in files) {
      try {
        final fileName = file.uri.pathSegments.last;
        if (fileName.endsWith('-imgs.json')) {
          final title = fileName.replaceAll('.json', '');
          final imgRecord = ImgRecord.fromPath(file.path);
          _imgRecords[title] = imgRecord;
          Logger.log('imgRecord: $imgRecord');
        } else if (fileName.endsWith('.json')) {
          final title = fileName.replaceAll('.json', '');
          final chat = Chat.fromPath(file.path);
          _chats[title] = chat;
        }
      } catch (e, stackTrace) {
        Logger.logError('读取文件 ${file.path} 时出错: $e', stackTrace);
      }
    }
  }

  // 发送消息到指定对话
  Future<void> sendMessage(String title, String message, bool left,
      {bool resend = false}) async {
    try {
      if (_chats.containsKey(title)) {
        if (!resend) {
          _chats[title]!.addMsg(
            role: left
                ? OpenAIChatMessageRole.assistant
                : OpenAIChatMessageRole.user,
            text: message,
          );
        }
        notifyListeners();
        if (!left) {
          //此时禁止发送信息
          sendPermission = false;
          lastInput = message;
          notifyListeners();
          Logger.log('选择图片：$selectedImgs');
          var imgPaths = selectedImgs.map((e) {
            String path = '';
            if (e >= 0) {
              // path = _imgRecords['$title-imgs']!.imgs[e - 1];
              path = _imgRecords['$title-imgs']!.imgs[e];
            }
            return path;
          }).toList();
          Logger.log('用户输入：$message');
          Logger.log('用户选择的图片：$imgPaths');
          if (!resend) {
            sendMessage(title, '正在解析图片中...', true);
          }
          var imgDiscription =
              json.decode(await analyseImg(title, imgPaths)).toString();
          var imgDiscriptionRes = '图片解析结果：$imgDiscription';
          if (imgDiscription.isEmpty) {
            imgDiscriptionRes = '';
          }
          var prompt = Prompts().getPrompt('psychological_companion_reply');
          String content = '';

          _chats[title]!.setPrompt(prompt);
          _chats[title]!.setLastMsg('正在思考中...');

          var records = _chats[title]!.getLastMsgModel(20);
          records.removeLast();
          records.removeLast();

          var input = resend
              ? "$imgDiscriptionRes, \n用户输入: $message\n你之前回复的格式不是json格式,请重新组织答案!"
              : "$imgDiscriptionRes, \n用户输入: $message\n你之前回复的格式不是json格式,请重新组织答案!";
          await OpenAIUserInteraction().sendMessageWithStream(input, (event) {
            final firstCompletionChoice = event.choices.first;
            try {
              content += firstCompletionChoice.delta.content?.first?.text ?? '';
              _chats[title]!.setLastMsg(extractResponseContent(content));
            } catch (e) {
              Logger.logError('ChatController 获取llm流式回复 出错: $e');
            }
            notifyListeners();
          }, () {
            Logger.log('llm 回复: $content');
            content = content.replaceAll('```json', '').replaceAll('```', '');

            // _chats[title]!.showAllRecords();
            Map<String, dynamic> contentMap = {};
            try {
              contentMap = json.decode(content) as Map<String, dynamic>;
            } catch (e) {
              Logger.logError('ChatController 解析llm回复 出错: $e');
              contentMap = {
                "Adopted Strategy": "无策略",
                "Response": content,
                "updated_image": [],
                "Recommendations": []
              };
              _chats[title]!.setLastMsg(content);
            }
            var rcmStr = List<String>.from(contentMap['Recommendations']!);
            _chats[title]!.setRecommendations(json.encode(rcmStr));
            // 发送消息完成后，允许发送信息
            sendPermission = true;
            notifyListeners();
            List<dynamic> updatedMemorys0 =
                contentMap['updated_image']! as List<dynamic>;
            List<String> updatedMemorys =
                updatedMemorys0.map((e) => e.toString()).toList();
            updateImgMemory(title, updatedMemorys, imgPaths);
            // print('contentMap: $contentMap');

            notifyListeners();
            var cont = """{
                "Adopted Strategy": ${contentMap["Adopted Strategy"]},
                "Response": ${contentMap["Response"]},
                "updated_image": ${contentMap["updated_image"]},
                "Recommendations": ${contentMap["Recommendations"]}
              }""";
            _chats[title]!.content.last.content![4] =
                OpenAIChatCompletionChoiceMessageContentItemModel.text(cont);

            Logger.log('contentMap: $cont');
            if (chatListScrollController.hasClients) {
              Future.delayed(const Duration(milliseconds: 100), () {
                chatListScrollController
                    .jumpTo(chatListScrollController.position.maxScrollExtent);
              });
            }
          }, records: records);
        }

        notifyListeners();
      }
    } catch (e, stackTrace) {
      Logger.logError('ChatController sendMessage 方法出错: $e', stackTrace);
    }
  }

  Future<void> resendMsg() async {
    try {
      sendMessage(currentTitle, lastInput, false, resend: true);
    } catch (e, stackTrace) {
      Logger.logError('ChatController resendMsg 方法出错: $e', stackTrace);
    }
  }

  String extractResponseContent(String input) {
    // 查找 "Response": 的起始位置
    int startIndex = input.indexOf('"Response":');
    if (startIndex == -1) {
      // 如果没有找到 "Response": "，返回空字符串
      return '正在思考中...';
    }
    // 计算 "Response": 之后的起始位置
    startIndex += '"Response":'.length;
    // 跳过可能存在的空白字符
    while (startIndex < input.length &&
        (input[startIndex] == ' ' || input[startIndex] == '"')) {
      startIndex++;
    }
    // 查找下一个 " 的位置
    int endIndex = input.indexOf('",', startIndex);
    if (endIndex == -1) {
      // 如果没有找到 "，返回 "Response": 后面的所有内容
      return input.substring(startIndex).trim();
    }
    // 返回 " 前面的内容
    return input.substring(startIndex, endIndex).trim();
  }

  void updateImgMemory(
      String title, List<String> memorys, List<String> imgPaths) {
    try {
      Logger.log('更新记忆: $memorys');
      Logger.log('需要更新记忆的图片：: $imgPaths');
      // 确保 updatedImg 的长度和 imgPaths 的长度一致
      if (memorys.length == imgPaths.length) {
        for (int i = 0; i < imgPaths.length; i++) {
          String imgPath = imgPaths[i];
          if (memorys[i].isEmpty) continue;
          String jsonPath = imgPath.replaceAll(RegExp(r'\.[^.]+$'), '.json');

          // 创建 File 对象
          File jsonFile = File(jsonPath);

          // 读取原文件内容
          Map<String, dynamic> jsonData = {};
          if (jsonFile.existsSync()) {
            String jsonString = jsonFile.readAsStringSync();
            jsonData = json.decode(jsonString) as Map<String, dynamic>;
          }

          // 添加新的键值对
          jsonData['更新描述'] = memorys[i];
          notifyListeners();

          // 将更新后的内容写入 JSON 文件
          jsonFile.writeAsStringSync(json.encode(jsonData));
        }
      } else {
        Logger.logError(
            'ChatController updateImgMemory 方法出错: memorys 和 imgPaths 的长度不一致',
            null);
      }
    } catch (e, stackTrace) {
      Logger.logError('ChatController updateImgMemory 方法出错: $e', stackTrace);
    }
  }

  void addImgs(String title, List<String> paths) {
    try {
      var key = '$title-imgs';
      if (_imgRecords.containsKey(key)) {
        _imgRecords[key]!.addImgs(paths);
      } else {
        _imgRecords[key] = ImgRecord(title: key, imgs: paths);
      }
      analyseImg(title, paths).then(
        (value) {
          
          notifyListeners(); 
        }
      );
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.logError('ChatController addImgs 方法出错: $e', stackTrace);
    }
  }

  void checkParsedImgs(String title){
    try {
      var key = '$title-imgs';
      if (_imgRecords.containsKey(key)) {
        _imgRecords[key]!.checkParsedImgs();
        notifyListeners();
      }
    }
    catch(e, stackTrace){
      Logger.logError('ChatController checkParsedImgs 方法出错: $e', stackTrace); 
    }
  }

  void createChat(String title) {
    try {
      // _chatRecords[title] = ChatRecord(title: title, messages: []);
      _chats[title] = Chat(title: title, content: []);
      _imgRecords['$title-imgs'] = ImgRecord(title: '$title-imgs');
      // sendMessage(title, '你好，我是你的智能助理~', true);
      // notifyListeners();
      generateGuidence(title);
    } catch (e, stackTrace) {
      Logger.logError('ChatController createChat 方法出错: $e', stackTrace);
    }
  }

  void generateGuidence(String title) {
    try {
      sendPermission = false;
      sendMessage(title, "正在思考中...", true);

      var str = Guidance().generateGuidanceMessage();
      str.then((value) {
        _chats[title]!.setLastMsg(value);
        sendPermission = true;
        notifyListeners();
      });
    } catch (e, stackTrace) {
      Logger.logError('ChatController generateGuidence 方法出错: $e', stackTrace);
    }
  }

  // 清空指定对话的聊天记录
  // void clearChatRecord(String title) {
  //   try {
  //     if (_chats.containsKey(title)) {
  //       _chats[title]!.clearRecord();
  //       _imgRecords['$title-imgs']!.clearRecord();
  //       notifyListeners();
  //     }
  //   } catch (e, stackTrace) {
  //     Logger.logError('ChatController clearChatRecord 方法出错: $e', stackTrace);
  //   }
  // }

  // 删除指定对话的聊天记录及对应文件
  Future<void> deleteChatRecord(String title) async {
    try {
      if (_chats.containsKey(title)) {
        // 从内存中移除聊天记录
        _chats.remove(title);
        // 删除对应的文件
        var file = File('chats/$title.json');
        if (await file.exists()) {
          await file.delete();
        }
        notifyListeners();
        var directory = Directory('chats/$title');
        if (await directory.exists()) {
          await directory.delete(recursive: true);
        }
        file = File('chats/$title-imgs.json');
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e, stackTrace) {
      Logger.logError('ChatController deleteChatRecord 方法出错: $e', stackTrace);
    }
  }

  Future<void> summarize(String title) async {
    try {
      if (_chats.containsKey(title)) {
        var imgDiscription = getImgAnalasis(title);

        var prompt = Prompts().getPrompt("summary_prompt");
        String content = '';
        sendMessage(title, '正在总结中...', true);
        _chats[title]!.setPrompt(prompt);
        OpenAIUserInteraction().sendMessageWithStream('图片解析结果：$imgDiscription',
            (event) {
          final firstCompletionChoice = event.choices.first;
          content += firstCompletionChoice.delta.content?.first?.text ?? '';
          _chats[title]!.setLastMsg(content);
          notifyListeners();
        }, () {
          Logger.log('llm 总结: $content');
        }, records: _chats[title]!.getLastMsgModel(20));

        notifyListeners();

        _chats[title]!.showAllRecords();
      }
    } catch (e, stackTrace) {
      Logger.logError('ChatController summarize 方法出错: $e', stackTrace);
    }
  }

  void setThumbUp(int index, String thumbUp) {
    try {
      if (_chats.containsKey(currentTitle)) {
        _chats[currentTitle]!.setThumbUp(index, thumbUp);
        notifyListeners();
      }
    } catch (e, stackTrace) {
      Logger.logError('ChatController setThumbUp 方法出错: $e', stackTrace);
    }
  }

  void setShowRecommendations(bool showRecommendations, int index) {
    try {
      if (_chats.containsKey(currentTitle)) {
        _chats[currentTitle]!
            .setShowRecommendations(showRecommendations, index);
        notifyListeners();
      }
    } catch (e, stackTrace) {
      Logger.logError(
          'ChatController setShowRecommendations 方法出错: $e', stackTrace);
    }
  }

  String getImgAnalasis(String title) {
    try {
      var path = 'chats/$title';
      var result = '';
      var directory = Directory(path);
      if (directory.existsSync()) {
        var files = directory.listSync();
        for (var file in files) {
          if (file is File && file.path.endsWith('.json')) {
            result += file.readAsStringSync();
          }
        }
      }
      return result;
    } catch (e, stackTrace) {
      Logger.logError('ChatController getImgAnalasis 方法出错: $e', stackTrace);
      return '';
    }
  }

  void update() {
    try {
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.logError('ChatController update 方法出错: $e', stackTrace);
    }
  }
}
