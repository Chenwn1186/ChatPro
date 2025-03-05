import 'dart:convert';
import 'dart:io';

import 'package:chat_pro/chat_controller.dart';
import 'package:flutter/material.dart';

class ChatImageData {
  String time = '';
  String location = '';
  String scene = '';
  List<String> people = [];
  List<String> objects = [];
  String environment = '';
  List<String> activitity = [];
  String emotion = '';
  String describe = '';
  final String title;
  final int index;

  ChatImageData(this.index, {required this.title});
  Widget buildWidget(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    updateData();
    return Container(
      // color: Colors.blue,
      alignment: Alignment.center,
      child: Center(
        child: SizedBox(
          width: size.width * 0.25,
          height: size.width * 0.25,
          child: Column(
            children: [
              Spacer(),
              SingleChildScrollView(
                child: Column(
                  children: [
                    // const Spacer(),
                    ChatImageDataItem(title: '时间', content: time, width: size.width * 0.20),
                    ChatImageDataItem(title: '地点', content: location, width: size.width * 0.20),
                    ChatImageDataItem(title: '场景', content: scene, width: size.width * 0.20),
                    ChatImageDataItem(title: '人物', content: people.join('，'), width: size.width * 0.20),
                    ChatImageDataItem(title: '物体', content: objects.join('，'), width: size.width * 0.20),
                    ChatImageDataItem(title: '环境', content: environment, width: size.width * 0.20),
                    ChatImageDataItem(title: '活动', content: activitity.join('，'), width: size.width * 0.20),
                    ChatImageDataItem(title: '情绪', content: emotion, width: size.width * 0.20),
                    ChatImageDataItem(title: '描述', content: describe, width: size.width * 0.20),
                    // const Spacer(),
                  ],
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void updateData() {
    try {
      var path = ChatController().getImgsText(title).split('\n')[index];
      var jsonPath = path.replaceAll(RegExp(r'\.[^.]+$'), '.json');
      var file = File(jsonPath);
      if (!file.existsSync()) return;
      var jsonData = file.readAsStringSync();
      var data = json.decode(jsonData) as Map<String, dynamic>;
      time = data['时间'];
      location = data['地点'];
      scene = data['场景'];
      List<dynamic> temp = data['人物'];
      people = List<String>.from(temp);
      temp = data['物体'];
      objects = List<String>.from(temp);
      environment = data['环境'];
      temp = data['活动'];
      activitity = List<String>.from(temp);
      emotion = data['情绪'];
      describe = data['更新描述'] ?? '';
    } catch (e, stackTrace) {
      Logger.logError('chat image data updateData 方法出错: $e', );
    }
  }
}

class ChatImageDataItem extends StatelessWidget {
  const ChatImageDataItem(
      {super.key, required this.title, required this.content, required this.width});
  final String title;
  final String content;
  final double width;
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.blue,
      child: Column(
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle( fontSize: 16, color: Colors.blue)),
              const SizedBox(width: 10),
              SizedBox(width: width,child: Text(content),),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Divider(
              height: 1,
              color: Colors.grey[300],
            ),
          )
        ],
      ),
    );
  }
}
