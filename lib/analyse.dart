import 'package:chat_pro/backend.dart';
import 'package:chat_pro/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 将 AnalysePage 改为 StatefulWidget
class AnalysePage extends StatefulWidget {
  const AnalysePage({super.key});

  @override
  State<AnalysePage> createState() => _AnalysePageState();
}

class _AnalysePageState extends State<AnalysePage> {
  final textFieldController = TextEditingController();
  final promptController = TextEditingController();
  String analysisResult = '分析结果将显示在这里';
  bool isAnalysed = false; // 新增的分析状态变量
  bool isAnalysing = false; // 新增的分析中状态变量
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('分析页面: 分析结果可以复制，粘贴到excel中，设置用|分隔就行'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 输入框
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: textFieldController,
                decoration: InputDecoration(
                  hintText: '输入要分析的内容',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: promptController,
                decoration: InputDecoration(
                  isDense: false, 
                  hintMaxLines: null, 
                  hintText: '如果有自定义的prompt，可以在此输入，留空则使用默认prompt',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 复制按钮
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: isAnalysed
                  ? () {
                      Clipboard.setData(
                          ClipboardData(text: analysisResult));
                    }
                  : null,
            ),
            // 分析按钮
            ElevatedButton(
              onPressed: () async {
                // setState(() {
                //   isAnalysing = true;
                // });
                // 这里可以添加分析逻辑
                ChatController().anaPrompt = promptController.text;
                var resultMap = analyseData(textFieldController.text);
                resultMap.then((value) {
                  String result = generateAnaresult(value);
                  setState(() {
                    ChatController().anaDatas = resultMap;
                    analysisResult = result;
                    isAnalysed = true;
                    isAnalysing = true;
                  });
                });
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 5,
              ),
              child: const Text('分析'),
            ),
            const SizedBox(height: 20),
            // 显示文本
            SelectableText(
              '当前prompt: ${ChatController().anaPrompt}'
            ),
            const SizedBox(height: 20),
            if (isAnalysing)
              Expanded(
                child: Container(
                  // height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    analysisResult,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Future<Map<String, List<List<String>>>> analyseData(String input) async {
  Map<String, List<List<String>>> resultMap = {};
  // 按换行符分割输入字符串，得到字符串列表
  // print(input);
  List<String> lines = input.split(RegExp(r'[\r\n]+'));
  for (String line in lines) {
    // 找到第一个空格的位置
    int firstSpaceIndex = line.indexOf(RegExp(r'\s'));
    List<String> parts;
    if (firstSpaceIndex != -1) {
      // 如果找到了空格，分割字符串
      parts = [
        line.substring(0, firstSpaceIndex),
        line.substring(firstSpaceIndex + 1)
      ];
    } else {
      // 如果没找到空格，整行作为一个元素
      parts = [line];
    }
    if (parts.length == 2) {
      String key = parts[0];
      String valueStr = parts[1];
      // 按分号分割空格后的字符串
      List<String> values = valueStr.split(';');
      // 将每个分割后的字符串用中括号包裹并存储到列表中
      List<List<String>> nestedList = values.map((val) => [val, '']).toList();
      nestedList.removeLast();
      resultMap[key] = nestedList;
    }
  }
  var ai = OpenAIUserInteraction();
  int activeRequests = 0;
  int maxRequests = 30;

  for (String key in resultMap.keys) {
    List<List<String>> nestedList = resultMap[key]!;
    for (int i = 0; i < nestedList.length; i++) {
      while (activeRequests >= maxRequests) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
      activeRequests++;
      String value = nestedList[i][0];
      var prompt = ChatController().anaPrompt;
      if (prompt == '') {
        prompt = '你是一个HCI方向的科研工作者，你接下来要分析用户的谈话，分析结果直接返回子分类，下面是要分类的维度：主题维度:回忆内容与分享、情感表达、反思、寻求支持与指导，情感倾向维度：积极、消极、中立、复杂、矛盾，交互行为维度：叙述、提问、直接对应CA	、发散。 直接返回一个分类结果，不要包含分析过程！示例：0 0 1 0 0 0 1 1 0 0 1 0'; 
      }
      String content =
          '$prompt 分析内容：$value';
      ai.sendMessageWithStream(content, (content) {
        try {
          final firstCompletionChoice = content.choices.first;
          nestedList[i][1] +=
              firstCompletionChoice.delta.content?.first?.text ?? '';
        } catch (e) {}
      }, () {
        activeRequests--;
        nestedList[i][1] = nestedList[i][1].replaceAll(' ', '|');
        print('$key num: $i ${nestedList[i][1]}');
      });
    }
  }

  // 等待所有请求完成
  while (activeRequests > 0) {
    await Future.delayed(const Duration(milliseconds: 10));
  }
  // ChatController().anaDatas = resultMap;
  return resultMap;
}

String generateAnaresult(Map<String, List<List<String>>> resultMap) {
  List<String> keyResults = [];
  // 遍历 resultMap 中的每个键值对
  for (var entry in resultMap.entries) {
    String key = entry.key;
    List<List<String>> value = entry.value;
    // 将 value 中的每个字符串列表用 | 合并成一个字符串
    List<String> mergedValues = value.map((list) => list.join('|')).toList();
    // 在每个合并后的字符串前添加 key 和 |
    List<String> prefixedValues =
        mergedValues.map((val) => '$key|$val').toList();
    // 将添加前缀后的字符串列表用换行符合并成一个字符串
    String keyResult = prefixedValues.join('\n');
    keyResults.add(keyResult);
  }
  // 将每个 key 对应的字符串用换行符合并成一个完整的字符串
  return keyResults.join('\n');
}

class AnalyseResultPage extends StatelessWidget {
  final Map<String, List<List<String>>> resultMap;

  const AnalyseResultPage({super.key, required this.resultMap});
  @override
  Widget build(BuildContext context) {
    if (resultMap.isEmpty) {
      return const Center(
        child: Text('分析结果为空, 或者正在分析'),
      );
    }
    var anaDatas = resultMap;
    var keys = anaDatas.keys.toList();
    return ListView.builder(
      itemCount: keys.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
            title: Text(keys[index]),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      title: Text(keys[index]),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: anaDatas[keys[index]]!
                              .map((e) => SelectableText('${e[0]} : ${e[1]}'))
                              .toList(),
                        ),
                      ),
                    );
                  });
            });
      },
    );
  }
}
