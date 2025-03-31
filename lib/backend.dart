import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:chat_pro/chat_controller.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:simple_canvas/simple_canvas.dart';

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

class OpenAIUserInteraction {
  // 静态私有实例，用于存储单例
  static final OpenAIUserInteraction _instance =
      OpenAIUserInteraction._internal();

  // 工厂构造函数，返回单例实例
  factory OpenAIUserInteraction() {
    return _instance;
  }

  // String model = "deepseek-chat";
  // String model = "gpt-3.5-turbo-0125";
  String model = "gpt-4o-mini";
  List<String> models = [
    'gpt-4o-mini',
    'gpt-3.5-turbo-0125',
    'deepseek-chat',
    'gpt-4o'
  ];

  // 私有构造函数，防止外部实例化
  OpenAIUserInteraction._internal() {
    init();
  }

  // 初始化 OpenAI API 密钥
  void init() {
    // OpenAI.apiKey = "sk-dPrv6dBqbgs5mfgn5Qw264FgXjEO2cQ8n6GWhwav2pLX8hB4";
    // OpenAI.baseUrl = "https://xiaoai.plus";
    // OpenAI.apiKey = "sk-PwAHRaa4EySMczCbBf99Cc35743c40B5B43cEc71762324F2";
    OpenAI.apiKey = "sk-lDIxGqCIvASAAMQGFd954108C8D74d3eB4334601D15203Aa";
    OpenAI.baseUrl = "https://vip.yi-zhan.top";
    // OpenAI.apiKey = "sk-528.kT3wdhoKY531DD59egtWtRZKT8deOwLVo0i0IxorxyQVePoY";
    // OpenAI.baseUrl = "https://wcode.net/api/gpt";
  }

  void setModel(String model) {
    this.model = model;
  }

  List<String> getModels() {
    return models;
  }

  /// 发送信息并接收 OpenAI 的回复
  /// [message] 是用户发送的消息
  /// 返回 OpenAI 的回复
  Future<String> sendMessage(String message) async {
    try {
      // Logger.log('开始发送消息到 OpenAI: $message');
      // 创建一个聊天完成请求
      final chatCompletion = await OpenAI.instance.chat.create(
        model: model,
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                message,
              ),
            ],
          ),
        ],
        maxTokens: 600,
      );

      // 提取回复内容
      final response = chatCompletion.choices.first.message.content!.first.text;
      // Logger.log('收到 OpenAI 回复: $response');
      return response.toString();
    } catch (e, stackTrace) {
      Logger.logError('发送消息到 OpenAI 时出错: $e', stackTrace);
      return '发送消息到 OpenAI 时出错: $e';
    }
  }

  Future<void> sendMessageWithStream(
      String message,
      void Function(OpenAIStreamChatCompletionModel)? onData,
      void Function()? onDone,
      {List<OpenAIChatCompletionChoiceMessageModel>? records}) async {
    try {
      // Logger.log('开始发送消息到 OpenAI: $message');
      // 创建一个聊天完成请求
      var content = [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          message,
        ),
      ];
      var msg = OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user, content: content);
      records ??= [];
      records.add(msg);
      var chatCompletion = OpenAI.instance.chat.createStream(
        model: model,
        messages: records,
        // maxTokens: 600,
      );
      chatCompletion.listen(onData, onDone: onDone);
      Logger.log('===========================聊天记录=========================');
      for (var i in records) {
        Logger.log(
            'len: ${i.content!.length} ${i.role}: ${i.content!.first.text}');
      }
    } catch (e, stackTrace) {
      Logger.logError('发送消息到 OpenAI with stream时出错: $e', stackTrace);
    }
  }
}

class Guidance {
  // 静态常量，存储用于引导回忆的提示语列表
  static final List<String> recallCues = [
    "a certain specific season or festival, for example, 'Do you remember a special moment last winter?'",
    "a certain specific place, for example, 'Do you have any photos taken during an unforgettable trip?'",
    "a certain important person or item, for example, 'Have you ever received a special gift or card?'",
    "a moment full of joy or emotion, for example, 'Is there any experience that made you especially happy or deeply touched?'",
    "a turning point in life, for example, 'Is there any experience that has changed your view of life?'",
    "a special event, for example, 'Have you ever participated in an unforgettable party or event?'",
    "any unique experience related to the user, for example, 'Is there a photo that reminds you of a certain specific scene?'"
  ];

  /// 异步方法，用于生成引导用户回忆的消息
  /// 返回一个 Future，该 Future 完成时将返回生成的引导消息
  Future<String> generateGuidanceMessage() async {
    try {
      // 记录开始生成引导消息的日志
      // Logger.log('开始生成引导消息');
      // 创建一个随机数生成器实例
      final random = Random();
      // 从 recall_cues 列表中随机选择一个回忆线索
      final selectedCue = recallCues[random.nextInt(recallCues.length)];
      // 从 Prompts 单例中获取引导提示语
      var guidancePrompt = Prompts().getPrompt('guidance_prompt');
      // 构造发送给 GPT - 4o 模型的提示，包含引导提示和选中的回忆线索
      final prompt =
          "$guidancePrompt\n current selected recalling clues：$selectedCue";
      // 记录生成的提示的日志
      // Logger.log('生成的提示: $prompt');
      // 调用 OpenAIUserInteraction 单例的 sendMessage 方法，使用 GPT - 4o 模型生成引导消息
      final result = await OpenAIUserInteraction().sendMessage(prompt);
      // 记录生成的引导消息的日志
      // Logger.log('生成的引导消息: $result');
      // 返回生成的引导消息
      ChatController()
              .getChat(ChatController().currentTitle)
              .content
              .last
              .content![4] =
          OpenAIChatCompletionChoiceMessageContentItemModel.text(result);
      return result;
    } catch (e, stackTrace) {
      // 记录生成引导消息时出错的日志
      Logger.logError('生成引导消息时出错: $e', stackTrace);
      // 返回错误信息
      return '生成引导消息时发生错误。';
    }
  }
}

class Prompts {
  // 静态私有实例，用于存储单例
  static final Prompts _instance = Prompts._internal();

  // 工厂构造函数，返回单例实例
  factory Prompts() {
    return _instance;
  }

  // 私有构造函数，防止外部实例化
  Prompts._internal();

  // 用于存储提示词的 Map
  Map<String, String> promptMap = {};

  // 异步方法，用于读取 assets 目录下的提示词文件
  Future<void> loadPrompts() async {
    try {
      Logger.log('开始加载提示词');
      // 获取 assets 目录下的 AssetManifest.json 文件内容
      final filesContent =
          await rootBundle.loadString('assets/prompt_en/files.json');
      // 将 JSON 字符串解析为 Map
      List<String> fileNames = List<String>.from(jsonDecode(filesContent));
      // 遍历每个文件路径
      for (final fileName in fileNames) {
        String filePath = 'assets/prompt_en/$fileName';
        String content = await rootBundle.loadString(filePath);
        if (fileName.endsWith('.txt')) {
          promptMap[fileName.replaceAll('.txt', '')] = content;
          Logger.log('加载提示词文件: $fileName');
        }
      }
      Logger.log('提示词加载完成');
    } catch (e, stackTrace) {
      Logger.logError('加载提示词时出错: $e', stackTrace);
    }
  }

  String getPrompt(String promptName) {
    return promptMap[promptName]!;
  }

//   Future<Map<String, dynamic>> generateStrategy(String input,
//       String imgDiscription, String shortRecord, String longRecord) async {
//     try {
//       Logger.log('开始生成策略');
//       var prompt = getPrompt('psychological_companion_reply_en');
//       var content = '''当前用户输入（必须直接回应）：$input
// 对话历史（短期记忆）：$shortRecord
// 长期记忆（过去相关回忆）：$longRecord
// 选中图片记忆：${imgDiscription.toString()}''';
//       var strategy =
//           await OpenAIUserInteraction().sendMessage(content + prompt);
//       Logger.log('生成的策略: $strategy');
//       strategy = strategy.replaceAll(RegExp(r'```json|```'), '').trim();
//       var strategyMap = jsonDecode(strategy) as Map<String, dynamic>;
//       Logger.log('解析后的策略: $strategyMap');
//       if (strategyMap.containsKey('updated_image')) {
//         strategyMap['updated_image'] =
//             List<String>.from(strategyMap['updated_image']);
//       }
//       return strategyMap;
//     } catch (e, stackTrace) {
//       Logger.logError('生成策略时出错: $e', stackTrace);
//       return {'Adopted Strategy': '', 'Response': '', 'updated_image': ''};
//     }
//   }

  String generateStrategyPrompt(
      String imgDiscription, String shortRecord, String longRecord) {
    try {
      Logger.log('开始生成策略');
      var prompt = getPrompt('psychological_companion_reply_en');
//       var content = '''
// 长期记忆（过去相关回忆）：$longRecord
// 选中图片记忆：${imgDiscription.toString()}''';
      return prompt;
      // return prompt + content;
    } catch (e, stackTrace) {
      Logger.logError('生成策略时出错: $e', stackTrace);
      return '生成策略时出错: $e';
    }
  }
}

Future<String> analyseImg(String title, List<String> ipath) async {
  var path = ipath.map((e) => e).toList();
  if (path.isEmpty) {
    return '{"description": "未提供有效图片路径: ${path.toString()}", "tags": []}';
  }
  List<String> usedPaths = [];
  List<String> results = [];
  List<Future<String>> futureResults = [];
  // 检查是否有对应的解析后文件
  for (String imagePath in path) {
    String resultFilePath = imagePath.replaceAll(RegExp(r'\.[^.]+$'), '.json');
    File resultFile = File(resultFilePath);
    if (resultFile.existsSync()) {
      var res =
          resultFile.readAsStringSync(encoding: Encoding.getByName('utf-8')!);
      // res = json.decode(res).toString();
      results.add(res);
      usedPaths.add(imagePath);
      Logger.log('找到已解析的文件，直接返回结果');
    }
  }
  path.removeWhere((element) => usedPaths.contains(element));
  if (path.isEmpty) {
    return results.toString();
  }
  try {
    Logger.log('开始分析图片，标题: $title, 图片路径: $path');
    for (String imagePath in path) {
      futureResults.add(analyseImgOnline(imagePath).then((value) {
        ChatController().checkParsedImgs(title);
        return value;
      }));
    }
    var fRes = await Future.wait(futureResults);
    results.addAll(fRes);
    return results.toString();
  } catch (e, stackTrace) {
    Logger.logError('分析图片时出错: $e', stackTrace);
    return '{"description": "分析图片时出错", "tags": []}';
  }
}

Future<String> analyseImgOnline(String imagePath) async {
  Logger.log('path: $imagePath');
  File imageFile = File(imagePath);
  if (!imageFile.existsSync()) {
    Logger.logError('图片文件不存在: $imagePath');
    return '';
  }
  var request = http.MultipartRequest(
      // 'POST', Uri.parse("http://172.16.91.233:5408/analyseImg"));
      'POST',
      // Uri.parse("http://0.0.0.0:5408/analyseImg"));
      Uri.parse("http://172.16.91.233:5408/analyseImg"));
  // 添加图片文件
  var stream = http.ByteStream(imageFile.openRead());
  var length = await imageFile.length();
  var multipartFile = http.MultipartFile('image', stream, length,
      filename: imageFile.path.split('/').last);
  request.files.add(multipartFile);

  // 发送请求
  var streamResponse = await request.send();
  var responseBody = await streamResponse.stream.bytesToString();
  var response = http.Response(responseBody, streamResponse.statusCode);
  if (response.statusCode == 200) {
    var bodyMap = json.decode(response.body) as Map<String, dynamic>;
    // 打印结果
    Logger.log('解析图片结果:${bodyMap['result']}');
    // 保存结果到文件
    String resultFilePath = imagePath.replaceAll(RegExp(r'\.[^.]+$'), '.json');
    File resultFile = File(resultFilePath);
    resultFile.writeAsStringSync(bodyMap['result'],
        mode: FileMode.write,
        encoding: Encoding.getByName('utf-8')!); // 以 UTF-8 编码写入文件
    ImagesBoardManager().addLabels(imagePath);
    return response.body;
  }
  Logger.logError('解析图片失败: ${json.decode(response.body).toString()}');
  return response.body;
}
