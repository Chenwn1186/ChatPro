import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

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

  // 私有构造函数，防止外部实例化
  OpenAIUserInteraction._internal() {
    init();
  }

  // 初始化 OpenAI API 密钥
  void init() {
    OpenAI.apiKey = "sk-dPrv6dBqbgs5mfgn5Qw264FgXjEO2cQ8n6GWhwav2pLX8hB4";
    OpenAI.baseUrl = "https://xiaoai.plus";
  }

  /// 发送信息并接收 OpenAI 的回复
  /// [message] 是用户发送的消息
  /// 返回 OpenAI 的回复
  Future<String> sendMessage(String message) async {
    try {
      Logger.log('开始发送消息到 OpenAI: $message');
      // 创建一个聊天完成请求
      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4o",
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
      Logger.log('收到 OpenAI 回复: $response');
      return response.toString();
    } catch (e, stackTrace) {
      Logger.logError('发送消息到 OpenAI 时出错: $e', stackTrace);
      return 'An error occurred while getting a response.';
    }
  }
}

class Guidance {
  static final List<String> recall_cues = [
    "a specific season or holiday, such as 'Do you remember a special moment from last winter?'",
    "a specific location, such as 'Do you have any photos taken during a memorable trip?'",
    "an important person or object, such as 'Have you ever received a special gift or card?'",
    "a moment of joy or emotion, such as 'Is there an experience that brought you particular happiness or moved you deeply?'",
    "a turning point in life, such as 'Was there an experience that changed how you view life?'",
    "a special event, such as 'Have you attended a memorable gathering or event?'",
    "any unique experience tied to the user, such as 'Is there a photo that reminds you of a specific scene?'"
  ];
  Future<String> generate_guidance_message() async {
    try {
      Logger.log('开始生成引导消息');
      // 随机选择一个回忆线索
      final random = Random();
      final selectedCue = recall_cues[random.nextInt(recall_cues.length)];

      // 构造发送给GPT-4o模型的提示，包含引导提示和选中的回忆线索
      var guidancePrompt = Prompts().getPrompt('guidance_prompt');
      final prompt = "$guidancePrompt\n\n当前选择的回忆线索是：$selectedCue";
      Logger.log('生成的提示: $prompt');
      // 调用OpenAI的聊天完成接口，使用GPT-4o模型生成引导消息
      final result = await OpenAIUserInteraction().sendMessage(prompt);
      Logger.log('生成的引导消息: $result');
      return result;
    } catch (e, stackTrace) {
      Logger.logError('生成引导消息时出错: $e', stackTrace);
      return 'An error occurred while generating guidance message.';
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

  Future<Map<String, dynamic>> generateStrategy(
      String input,
      String imgDiscription,
      String shortRecord,
      String longRecord) async {
    try {
      Logger.log('开始生成策略');
      var prompt = getPrompt('psychological_companion_reply');
      var content = '''当前用户输入（必须直接回应）：$input\n
对话历史（短期记忆）：$shortRecord\n
长期记忆（过去相关回忆）：$longRecord\n
选中图片记忆：${imgDiscription.toString()}\n''';
      var strategy =
          await OpenAIUserInteraction().sendMessage(content + prompt);
      Logger.log('生成的策略: $strategy');
      var strategyMap = jsonDecode(strategy) as Map<String, dynamic>;
      Logger.log('解析后的策略: $strategyMap');
      return strategyMap;
    } catch (e, stackTrace) {
      Logger.logError('生成策略时出错: $e', stackTrace);
      return {};
    }
  }

  Future<String> generateContent(
      String title,
      String input,
      String imgDiscription,
      String shortRecord,
      String longRecord) async {
    try {
      Logger.log('开始生成内容，标题: $title, 输入: $input');
      var strategyMap = await generateStrategy(
          input, imgDiscription, shortRecord, longRecord);
      String selectedStrategy = strategyMap["Adopted Strategy"] ?? "";
      String initialResponse = strategyMap["Response"] ?? "";

      String prompt = '''
Generate a natural, warm response to help the user recall past moments and provide emotional support.
1. Directly respond to the current user message: '$input'.
2. Prioritize and explicitly use relevant information from short - term dialog context, long - term history, and image context below. 
Do NOT say 'I don’t remember' or 'I don’t have details' if any context is available—use it creatively!
3. If no specific details match, encourage the user to share more while connecting to available context.

Image context: ${imgDiscription.isNotEmpty ? json.encode(imgDiscription) : 'None'}
Short - term dialog context: ${shortRecord.isNotEmpty ? shortRecord : 'None'}
Long - term history (past relevant memories): $longRecord
Selected strategy: $selectedStrategy
Initial response suggestion: $initialResponse
Return in JSON format: {"response": "...", "updated_image": null}
''';

      // 记录日志，显示发送给LLM的提示词
      Logger.log("Prompt for LLM: $prompt");

      // 调用OpenAI的聊天完成接口，获取回复
      var chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4o",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                prompt,
              ),
            ],
          ),
        ],
        maxTokens: 800,
      );

      // String responseRaw =
      //     chatCompletion.choices.first.message.content!.first.text!;
      // // 处理回复，去除可能的JSON格式标记
      // if (responseRaw.startsWith("```json")) {
      //   responseRaw = responseRaw.substring(7, responseRaw.length - 3);
      // }
      // print("\nLLM response: $responseRaw \n");
      // Map<String, dynamic> responseData = json.decode(responseRaw);
      // // 获取回复内容
      // String response = responseData["response"];
      // // 获取更新后的图片信息
      // String? updatedImage = responseData["updated_image"];

      // // 这里假设你有一个 MemoryModule 类来处理图片记忆
      // // 并且有对应的方法来更新和保存图片记忆
      // // 由于没有 MemoryModule 类的完整实现，这里只是示例代码
      // // if (updatedImage != null && imageHash != null && memoryModule.imageMemory.containsKey(title) && memoryModule.imageMemory[title].containsKey(imageHash)) {
      // //   String prevDescription = memoryModule.imageMemory[title][imageHash]["description"];
      // //   memoryModule.imageMemory[title][imageHash]["description"] = updatedImage;
      // //   // 将更新后的图片记忆保存到文件中
      // //   File('images/image_memory_$title.json').writeAsStringSync(json.encode(memoryModule.imageMemory[title], ensureAscii: false, indent: 4));
      // //   // 记录图片记忆更新日志
      // //   String logEntry = "[${DateTime.now().toIso8601String()}] User $title updated image $imageHash: ${json.encode(prevDescription)} -> ${json.encode(updatedImage)}";
      // //   File("logs/image_memory_updates.log").writeAsStringSync("$logEntry\n", mode: FileMode.append);
      // //   // 记录日志，显示图片记忆已更新
      // //   print("Image memory updated: $logEntry");
      // // }

      // // 记录日志，显示最终的LLM回复
      // Logger.log("Final LLM response: $response");

      String response = "我可能有些细节没记清，但你和姐姐的时光一定很美好，能再告诉我一些吗？";
      return response;
    } catch (e, stackTrace) {
      // 记录日志，显示解析LLM回复为JSON时出错
      Logger.logError("Failed to parse LLM response as JSON: $e", stackTrace);
      // 使用备用回复
      String response = "我可能有些细节没记清，但你和姐姐的时光一定很美好，能再告诉我一些吗？";
      return response;
    }
  }
}

//todo 图片解析, 分对话建立索引：图片哈希值-解析结果
Future<String> analyseImg(String title, List<String> path) async {
  if (path.isEmpty) {
    return '{"description": "未提供有效图片路径", "tags": []}';
  }
  try {
    Logger.log('开始分析图片，标题: $title, 图片路径: $path');
    // path: 图片路径的列表
    // 遍历每张图片

    for (String imagePath in path) {
      // 读取图片并转换为 base64
      Logger.log('path: $imagePath');
      File imageFile = File(imagePath);
      if (!imageFile.existsSync()) {
        Logger.logError('图片文件不存在: $imagePath');
        continue;
      }
      List<int> imageBytes = imageFile.readAsBytesSync();
      String imageBase64 = base64Encode(imageBytes);

      // 将 base64 编码写入 txt 文件
      String fileName =
          '${imagePath.split('/').last.replaceAll('.', '_')}_base64.txt';
      File txtFile = File("chats/$title/${fileName}_base64.txt");
      txtFile.writeAsStringSync(imageBase64);

      // 构造请求数据
      Map<String, String> data = {"image_base64": imageBase64};
      http.Response response = http.Response("", 200);
      // 发送请求
      response = await http.post(
        Uri.parse("http://172.16.90.86:5000/analyze"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );
      // 检查响应状态码
      if (response.statusCode == 200) {
        // 打印结果
        Logger.log(response.body);
        // 保存结果到文件
        String resultFilePath = "${imagePath.split('.').first}.json";
        File resultFile = File(resultFilePath);
        resultFile.writeAsStringSync(response.body, mode: FileMode.write, encoding: Encoding.getByName('utf-8')!); // 以 UTF-8 编码写入文件
        return response.body;
      }
    }
    Logger.log('未提供有效图片路径，返回默认结果');
    return '{"description": "未提供有效图片路径", "tags": []}';
  } catch (e, stackTrace) {
    Logger.logError('分析图片时出错: $e', stackTrace);
    return '{"description": "未提供有效图片路径", "tags": []}';
  }
}

void updateImgAnalysis(String title) {}
