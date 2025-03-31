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
  final double width;
  final double height;

  ChatImageData(this.index, {required this.width, required this.height, required this.title});
  Widget buildWidget(BuildContext context) {
    // var size = MediaQuery.sizeOf(context);
    var textWidth = width*0.8;
    updateData();
    if(index < 0)return Container();
    return Container(
      // color: Colors.blue,
      width: width + 30,
      height: height,
      padding: const EdgeInsets.only(left: 4),
      alignment: Alignment.center,
      child: Stack(
        children: [
          // const Spacer(),
          const SizedBox(height: 6),
          SingleChildScrollView(
            child: Column(
              children: [
                ChatImageDataItem(
                    title: 'Time', content: time, width: textWidth),
                ChatImageDataItem(
                    title: 'Location', content: location, width: textWidth),
                ChatImageDataItem(
                    title: 'Scene', content: scene, width: textWidth),
                ChatImageDataItem(
                    title: 'People',
                    content: people.join('，'),
                    width: textWidth),
                ChatImageDataItem(
                    title: 'Objects',
                    content: objects.join('，'),
                    width: textWidth),
                ChatImageDataItem(
                    title: 'Environment',
                    content: environment,
                    width: textWidth),
                ChatImageDataItem(
                    title: 'Activitys',
                    content: activitity.join('，'),
                    width: textWidth),
                ChatImageDataItem(
                    title: 'Emotion', content: emotion, width: textWidth),
                ChatImageDataItem(
                    title: 'Description', content: describe, width: textWidth),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
                onPressed: () {
                  var path = ChatController().getImgs(title)[index];
                  showEditDialog(context, path);
                },
                icon: const Icon(Icons.edit)),
          ),
          // const Spacer(),
        ],
      ),
    );
  }

  void updateData() {
    try {
      var path = ChatController().getImgs(title)[index];
      var jsonPath = path.replaceAll(RegExp(r'\.[^.]+$'), '.json');
      var file = File(jsonPath);
      if (!file.existsSync()) return;
      var jsonData = file.readAsStringSync();
      var data = json.decode(jsonData) as Map<String, dynamic>;
      time = data['Time'];
      location = data['Location'];
      scene = data['Scene'];
      List<dynamic> temp = data['People'];
      people = List<String>.from(temp);
      temp = data['Objects'];
      objects = List<String>.from(temp);
      environment = data['Environment'];
      temp = data['Activities'];
      activitity = List<String>.from(temp);
      emotion = data['Emotion'];
      describe = data['Description'] ?? '';
    } catch (e, stackTrace) {
      // Logger.logError('chat image data updateData 方法出错: $e', stackTrace);
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
          title: const Text('Edit Image Data'),
          content: SizedBox(
            height: 500,
            child: Row(
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
                SizedBox(
                  width: 300,
                  height: 800,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Spacer(),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Time'),
                        controller: timeController,
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Location'),
                        controller: locationController,
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Scene'),
                        controller: sceneController,
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: 'People'),
                        controller: peopleController,
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Objects'),
                        controller: objectsController,
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Environment'),
                        controller: environmentController,
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Activitys'),
                        controller: activitityController,
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Emotion'),
                        controller: emotionController,
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Description'),
                        controller: describeController,
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: (){
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
                    ChatController().getImgs(title)[index];
                var jsonPath = path.replaceAll(RegExp(r'\.[^.]+$'), '.json');
                var file = File(jsonPath);

                var data = {
                  'Time': time,
                  'Location': location,
                  'Scene': scene,
                  'People': people,
                  'Objects': objects,
                  'Environment': environment,
                  'Activitys': activitity,
                  'Emotion': emotion,
                  'Description': describe,
                };

                try {
                  var fileW = file.writeAsString(json.encode(data));
                  fileW.then((value) {
                    // Logger.log('chat image data save json success');
                    ChatController().update();
                  });
                  
                  
                  Navigator.of(context).pop();
                } catch (e) {
                  // 处理保存文件时的错误
                  Logger.logError('chat image data save json 方法出错: $e');
                }
              },
              child: const Text('Save'),
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
        mainAxisSize: MainAxisSize.min,
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
          const Padding(
            padding: EdgeInsets.only(right: 10),
            child: Divider(
              height: 4,
              color: Color.fromARGB(255, 138, 138, 138),
            ),
          )
        ],
      ),
    );
  }
}
