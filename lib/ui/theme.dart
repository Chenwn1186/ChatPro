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
      Color.fromARGB(205, 239, 222, 255),
      Color.fromARGB(255, 71, 48, 87),
      Color.fromARGB(255, 6, 94, 166),
      Colors.white,
      Color.fromARGB(205, 214, 233, 248),
      Color.fromARGB(255, 16, 112, 186),
    ],
    '蓝色': [
      Color.fromARGB(255, 51, 67, 243),
      Colors.white,
      Color.fromARGB(205, 1, 176, 245),
      Color.fromARGB(255, 244, 245, 255),
      Color.fromARGB(255, 6, 94, 166),
      Colors.white,
      Color.fromARGB(205, 214, 233, 248),
      Color.fromARGB(255, 16, 112, 186),
    ],
    '绿色': [
      Color.fromARGB(255, 62, 153, 36),
      Colors.white,
      Color.fromARGB(205, 54, 160, 58),
      Color.fromARGB(255, 255, 255, 255),
      Color.fromARGB(255, 6, 94, 166),
      Colors.white,
      Color.fromARGB(235, 255, 255, 255),
      Color.fromARGB(255, 2, 29, 51),
    ],
    '白色': [
      Color.fromARGB(255, 230, 230, 230),
      Color.fromARGB(255, 38, 38, 38),
      Color.fromARGB(255, 233, 233, 233),
      Color.fromARGB(255, 0, 0, 0),
      Color.fromARGB(255, 212, 233, 250),
      Color.fromARGB(255, 24, 24, 24),
      Color.fromARGB(235, 230, 230, 230),
      Color.fromARGB(255, 43, 43, 43),
    ],
    '梅红': [
      Color.fromARGB(255, 190, 87, 87),
      Color.fromARGB(255, 237, 237, 237),
      Color.fromARGB(255, 225, 107, 140),
      Color.fromARGB(255, 240, 240, 240),
      Color.fromARGB(255, 238, 82, 155),
      Colors.white,
      Color.fromARGB(255, 245, 190, 200),
      Color.fromARGB(255, 65, 3, 34),
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