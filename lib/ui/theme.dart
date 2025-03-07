import 'package:chat_pro/chat_controller.dart';
import 'package:flutter/material.dart';

class ChatThemes {
  // 静态私有实例，用于存储单例
  static final ChatThemes _instance = ChatThemes._internal();

  // 工厂构造函数，返回单例实例
  factory ChatThemes() {
    return _instance;
  }

  // 私有构造函数，防止外部实例化
  ChatThemes._internal();

  String currentTheme = '默认';
  static const Map<String, List<Color>> themes = {
    '默认': [
      Color.fromARGB(255, 166, 51, 243),
      Colors.white,
      Color.fromARGB(205, 224, 222, 255),
      Color.fromARGB(255, 71, 48, 87),
      Color.fromARGB(255, 6, 94, 166),
      Colors.white,
      Color.fromARGB(205, 214, 233, 248),
      Color.fromARGB(255, 16, 112, 186),
    ],
    '蓝色': [
      Color.fromARGB(255, 166, 51, 243),
      Colors.white,
      Color.fromARGB(155, 111, 233, 254),
      Color.fromARGB(255, 30, 36, 111),
      Color.fromARGB(255, 6, 94, 166),
      Colors.white,
      Color.fromARGB(205, 214, 233, 248),
      Color.fromARGB(255, 16, 112, 186),
    ],
    '绿色': [
      Color.fromARGB(255, 166, 51, 243),
      Colors.white,
      Color.fromARGB(205, 224, 222, 255),
      Color.fromARGB(255, 71, 48, 87),
      Color.fromARGB(255, 6, 94, 166),
      Colors.white,
      Color.fromARGB(205, 214, 233, 248),
      Color.fromARGB(255, 16, 112, 186),
    ],
  };

  List<Color> getColors() {
    return themes[currentTheme]!;
  }

  List<String> getThemeNames() {
    return themes.keys.toList();
  }

  void setTheme(String theme) {
    currentTheme = theme;
    ChatController().update();
  }
}