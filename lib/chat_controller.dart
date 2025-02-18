import 'dart:convert';
import 'dart:io';
import 'package:chat_pro/chat_page_msg.dart';
import 'package:flutter/material.dart';

class ChatMsg {
  final bool left;
  final String content;

  ChatMsg({
    required this.left,
    required this.content,
  });

  factory ChatMsg.fromJson(Map<String, dynamic> json) {
    return ChatMsg(
      left: json['left'],
      content: json['content'],
    );
  }

  Widget buildWidget() {
    return _build(left: left, mdMsg: content);
  }

  Map<String, dynamic> toJson() {
    return {
      'left': left,
      'content': content,
    };
  }

  static Widget _build({required String mdMsg, required bool left}) {
    if (left) {
      return ChatPageMsg(
        left: left,
        mdMsg: mdMsg,
        imgText: '666',
        headBGColor: const Color.fromARGB(255, 166, 51, 243),
        headTextColor: Colors.white,
        bgColor: const Color.fromARGB(255, 255, 204, 255),
        textColor: const Color.fromARGB(255, 166, 51, 243),
      );
    } else {
      return ChatPageMsg(
        left: left,
        mdMsg: mdMsg,
        imgText: '奶龙',
        headBGColor: const Color.fromARGB(255, 6, 94, 166),
        headTextColor: Colors.white,
        bgColor: const Color.fromARGB(255, 185, 225, 255),
        textColor: const Color.fromARGB(255, 6, 94, 166),
      );
    }
  }
}

class ChatRecord {
  final String title;
  final List<ChatMsg> messages;

  ChatRecord({
    required this.title,
    required this.messages,
  });

  factory ChatRecord.fromJson(String title, List<dynamic> jsonList) {
    return ChatRecord(
      title: title,
      messages: jsonList.map((json) => ChatMsg.fromJson(json)).toList(),
    );
  }

  Future<void> saveRecord() async {
    final file = File('chats/$title.json');
    final jsonList = messages.map((msg) => msg.toJson()).toList();
    final jsonString = json.encode(jsonList);
    file.writeAsString(jsonString);
  }

  void sendMessage(String message, bool left) {
    messages.add(ChatMsg(left: left, content: message));
    saveRecord();
  }
}

class ChatController with ChangeNotifier {
  // 静态私有实例，用于存储单例
  static final ChatController _instance = ChatController._internal();

  // 工厂构造函数，返回单例实例
  factory ChatController() {
    return _instance;
  }

  // 私有构造函数，防止外部实例化
  ChatController._internal() {
    readAllChatRecords();
  }

  // 存储所有对话记录，key 是对话标题
  final Map<String, ChatRecord> _chatRecords = {};

  // 获取所有对话记录
  Map<String, ChatRecord> get chatRecords => _chatRecords;

  // 存储所有对话标题
  List<String> get chatTitles => _chatRecords.keys.toList();

  ChatRecord getChatRecord(String title) {
    return _chatRecords[title]!;
  }

  // 修改此方法，返回消息列表的副本
  List<ChatMsg> getChatRecordMessages(String title) {
    return _chatRecords[title]?.messages.toList() ?? [];
  }

  // 读取 chats 目录下的所有聊天记录文件
  Future<void> readAllChatRecords() async {
    final directory = Directory('chats');
    final files = directory.listSync().whereType<File>();

    for (final file in files) {
      try {
        final fileName = file.uri.pathSegments.last;
        if (!fileName.endsWith('.json')) continue;
        final title = fileName.replaceAll('.json', '');
        final jsonString = await file.readAsString();
        final jsonList = json.decode(jsonString) as List<dynamic>;
        final chatRecord = ChatRecord.fromJson(title, jsonList);
        _chatRecords[title] = chatRecord;
      } catch (e) {
        print('读取文件 ${file.path} 时出错: $e');
      }
    }
    notifyListeners();
  }

  // 发送消息到指定对话
  void sendMessage(String title, String message, bool left) {
    if (_chatRecords.containsKey(title)) {
      _chatRecords[title]!.messages.add(ChatMsg(left: left, content: message));
      notifyListeners();
      _saveChatRecord(title);
      
    }
    
  }

  void receiveMessage() {
    //todo: 从服务器获取消息, 并添加到聊天记录中
    //...
    //sendMessage(title, message, left);
    notifyListeners();
  }

  void createChat(String title) {
    _chatRecords[title] = ChatRecord(title: title, messages: []);
    sendMessage(title, '你好，我是你的智能助理~', true);
  }

  // 保存指定对话的聊天记录到文件
  Future<void> _saveChatRecord(String title) async {
    final file = File('chats/$title.json');
    final jsonList =
        _chatRecords[title]!.messages.map((msg) => msg.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await file.writeAsString(jsonString);
  }
}
