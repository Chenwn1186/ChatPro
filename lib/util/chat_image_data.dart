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
      padding: const EdgeInsets.only(left: 4),
      alignment: Alignment.center,
      child: Center(
        child: SizedBox(
          width: size.width * 0.25,
          height: size.width * 0.27,
          child: Column(
            children: [
              const Spacer(),
              const SizedBox(height: 6),
              SingleChildScrollView(
                child: Column(
                  children: [
                    ChatImageDataItem(
                        title: '时间', content: time, width: size.width * 0.20),
                    ChatImageDataItem(
                        title: '地点',
                        content: location,
                        width: size.width * 0.20),
                    ChatImageDataItem(
                        title: '场景', content: scene, width: size.width * 0.20),
                    ChatImageDataItem(
                        title: '人物',
                        content: people.join('，'),
                        width: size.width * 0.20),
                    ChatImageDataItem(
                        title: '物体',
                        content: objects.join('，'),
                        width: size.width * 0.20),
                    ChatImageDataItem(
                        title: '环境',
                        content: environment,
                        width: size.width * 0.20),
                    ChatImageDataItem(
                        title: '活动',
                        content: activitity.join('，'),
                        width: size.width * 0.20),
                    ChatImageDataItem(
                        title: '情绪',
                        content: emotion,
                        width: size.width * 0.20),
                    ChatImageDataItem(
                        title: '描述',
                        content: describe,
                        width: size.width * 0.20),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                    onPressed: () {
                      var path = ChatController()
                          .getImgsText(title)
                          .split('\n')[index];
                      showEditDialog(context, path);
                    },
                    icon: const Icon(Icons.edit)),
              ),
              const Spacer(),
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
      Logger.logError(
        'chat image data updateData 方法出错: $e',
      );
    }
  }

  // 新增弹出对话框的函数
  void showEditDialog(BuildContext context, String imagePath) {
    updateData();
    // 创建 TextEditingController 实例
    final timeController = TextEditingController(text: time);
    final locationController = TextEditingController(text: location);
    final sceneController = TextEditingController(text: scene);
    final peopleController = TextEditingController(text: people.join('，'));
    final objectsController = TextEditingController(text: objects.join('，'));
    final environmentController = TextEditingController(text: environment);
    final activitityController =
        TextEditingController(text: activitity.join('，'));
    final emotionController = TextEditingController(text: emotion);
    final describeController = TextEditingController(text: describe);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('图片信息编辑'),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左边显示图片
              Align(
                alignment: Alignment.centerLeft,
                child: Image.file(
                  File(imagePath),
                  width: 300, // 可以根据需要调整图片宽度
                  // height: 200, // 可以根据需要调整图片高度
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              // 右边显示输入框
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        decoration: const InputDecoration(labelText: '时间'),
                        controller: timeController,
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: '地点'),
                        controller: locationController,
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: '场景'),
                        controller: sceneController,
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: '人物'),
                        controller: peopleController,
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: '物体'),
                        controller: objectsController,
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: '环境'),
                        controller: environmentController,
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: '活动'),
                        controller: activitityController,
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: '情绪'),
                        controller: emotionController,
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: '描述'),
                        controller: describeController,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                // 获取输入框中的数据
                time = timeController.text;
                location = locationController.text;
                scene = sceneController.text;
                people = peopleController.text.split('，');
                objects = objectsController.text.split('，');
                environment = environmentController.text;
                activitity = activitityController.text.split('，');
                emotion = emotionController.text;
                describe = describeController.text;

                // 保存数据到 JSON 文件
                var path =
                    ChatController().getImgsText(title).split('\n')[index];
                var jsonPath = path.replaceAll(RegExp(r'\.[^.]+$'), '.json');
                var file = File(jsonPath);

                var data = {
                  '时间': time,
                  '地点': location,
                  '场景': scene,
                  '人物': people,
                  '物体': objects,
                  '环境': environment,
                  '活动': activitity,
                  '情绪': emotion,
                  '更新描述': describe,
                };

                try {
                  await file.writeAsString(json.encode(data));
                  ChatController().update();
                  Navigator.of(context).pop();
                } catch (e) {
                  // 处理保存文件时的错误
                  print('保存文件时出错: $e');
                }
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }
}

class ChatImageDataItem extends StatelessWidget {
  const ChatImageDataItem(
      {super.key,
      required this.title,
      required this.content,
      required this.width});
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
              Text(title,
                  style: const TextStyle(fontSize: 16, color: Colors.blue)),
              const SizedBox(width: 10),
              SizedBox(
                width: width,
                child: Text(content),
              ),
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
