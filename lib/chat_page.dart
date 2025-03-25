// import 'dart:io';
import 'dart:ui';

import 'package:chat_pro/chat_controller.dart';
import 'package:chat_pro/ui/pura_multiple_radial_gradients.dart';
import 'package:chat_pro/ui/theme.dart';
import 'package:chat_pro/util/chat_image_data.dart';
import 'package:chat_pro/util/file_utils.dart';
import 'package:dart_openai/dart_openai.dart';
// import 'package:chat_pro/chat_page_msg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

import 'package:simple_canvas/draggable_image.dart';
import 'package:simple_canvas/images_board.dart';

// 将 ChatPage 改为 StatefulWidget
class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.chatRecord});
  // final ChatRecord chatRecord;
  final Chat chatRecord;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController =
      ChatController().chatListScrollController;

  @override
  void dispose() {
    // _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    var width = size.width * 0.65;
    var height = size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 4,
        scrolledUnderElevation: 4,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Text(widget.chatRecord.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          PopupMenuButton(
              icon: const Icon(Icons.color_lens),
              tooltip: '切换主题',
              itemBuilder: (context) {
                return ChatThemes().getThemeNames().map((e) {
                  return PopupMenuItem(
                    value: e,
                    child: Text(e),
                    onTap: () {
                      ChatThemes().setTheme(e);
                    },
                  );
                }).toList();
              })
        ],
      ),
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Selector<ChatController, String>(
            selector: (_, myType) => ChatThemes().currentTheme,
            shouldRebuild: (previous, next) => true,
            builder: (context, currentTheme, child) {
              return PuraMultipleRadialGradients(
                inputPoints: [
                  InputPoint(
                    const Offset(0.25, 0.25),
                    ChatThemes().getColors()[0],
                    0.25,
                    0.35,
                    const Duration(seconds: 2),
                  ),
                  InputPoint(
                    const Offset(0.75, 0.25),
                    ChatThemes().getColors()[2],
                    0.28,
                    0.35,
                    const Duration(seconds: 3),
                  ),
                  InputPoint(
                    const Offset(0.6, 0.75),
                    ChatThemes().getColors()[0],
                    0.26,
                    0.38,
                    const Duration(seconds: 3),
                  ),
                  InputPoint(
                    const Offset(0.4, 0.5),
                    ChatThemes().getColors()[6],
                    0.12,
                    0.28,
                    const Duration(seconds: 2, microseconds: 450),
                  ),
                  InputPoint(
                    const Offset(0.1, 0.8),
                    ChatThemes().getColors()[6],
                    0.12,
                    0.18,
                    const Duration(seconds: 2, microseconds: 450),
                  ),
                ],
                backgroundColor: Colors.white,
                blurRadius: 40,
              );
            },
          ),
          Row(
            children: [
              Selector<ChatController, (List<String>, List<int>)>(
                selector: (_, chatController) => (
                  chatController.getImgs(widget.chatRecord.title),
                  chatController.selectedImgs
                ),
                shouldRebuild: (previous, next) => true,
                builder: (context, data, child) {
                  var imgs = data.$1;

                  return SizedBox(
                    width: width,
                    child: Stack(
                      children: [
                        SizedBox(
                          width: width,
                          height: height,
                          child: ImagesBoard(
                            width: width,
                            height: height,
                          ),
                        ),
                        Positioned(
                            bottom: 10,
                            child: SizedBox(
                              height: 120,
                              width: width * 0.65,
                              child: Card(
                                elevation: 0,
                                color:
                                    const Color.fromRGBO(205, 205, 205, 0.486),
                                clipBehavior: Clip.antiAlias,
                                shape: const ContinuousRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                ),
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                  child: SizedBox(
                                    height: 120,
                                    width: width * 0.65,
                                  ),
                                ),
                              ),
                            )),
                        Positioned(
                          bottom: 10,
                          child: SizedBox(
                            height: 120,
                            width: width * 0.6,
                            child: ListView.builder(
                              // controller: ScrollController(),
                              clipBehavior: Clip.none,
                              scrollDirection: Axis.horizontal,
                              itemCount: imgs.length,
                              padding: const EdgeInsets.all(10),
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                return DraggableImage(
                                  width: 100,
                                  height: 100,
                                  imgPath: imgs[index],
                                  isSelected: ChatController()
                                      .selectedImgs
                                      .contains(index),
                                  onTap: () {
                                    if (!ChatController()
                                        .selectedImgs
                                        .contains(index)) {
                                      ChatController().selectedImgs.add(index);
                                    }
                                    if (!ChatController()
                                        .finalSelectedImgs
                                        .contains(index)) {
                                      ChatController()
                                          .finalSelectedImgs
                                          .add(index);
                                    }
                                    ChatController().currentImgIndex = index;
                                    // ChatController().update();
                                    ChatController().checkParsedImgs(
                                        widget.chatRecord.title);
                                  },
                                  onRightTap: () {
                                    ChatController()
                                        .selectedImgs
                                        .removeWhere((e) => e == index);
                                    ChatController().checkParsedImgs(
                                        widget.chatRecord.title);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Selector<ChatController, int>(
                            selector: (_, chatController) =>
                                chatController.currentImgIndex,
                            // shouldRebuild: (previous, next) => true,
                            builder: (context, currentIndex, child) {
                              return Card(
                                elevation: 4,
                                shape: const ContinuousRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                ),
                                child: ChatImageData(
                                  currentIndex,
                                  title: widget.chatRecord.title,
                                  width: width * 0.3,
                                  height: 300,
                                ).buildWidget(context),
                              );
                            },
                          ),
                        ),
                        // Positioned(
                        //   left: 10,
                        //   top: 50,
                        //   child: Card(
                        //     elevation: 4,
                        //     shape: const RoundedRectangleBorder(
                        //       borderRadius:
                        //           BorderRadius.all(Radius.circular(12)),
                        //     ),
                        //     child: Padding(
                        //       padding: const EdgeInsets.all(8),
                        //       child: Column(
                        //         children: [
                        //           IconButton(
                        //             icon: Icon(Icons.pan_tool),
                        //             onPressed: () {},
                        //             tooltip: '平移工具',
                        //           ),
                        //           SizedBox(height: 10),
                        //           IconButton(
                        //             icon: Icon(Icons.crop_square),
                        //             onPressed: () {},
                        //             tooltip: '矩形工具',
                        //           ),
                        //           SizedBox(height: 10),
                        //           IconButton(
                        //             icon: Icon(Icons.line_axis),
                        //             onPressed: () {},
                        //             tooltip: '直线工具',
                        //           ),
                        //           SizedBox(height: 10),
                        //           IconButton(
                        //             icon: Icon(Icons.text_fields),
                        //             onPressed: () {},
                        //             tooltip: '文本工具',
                        //           ),
                        //           SizedBox(height: 10),
                        //           IconButton(
                        //             icon: Icon(Icons.clear),
                        //             onPressed: () {},
                        //             tooltip: '清除',
                        //           ),
                        //           SizedBox(height: 10),
                        //           IconButton(
                        //             icon: Icon(Icons.color_lens),
                        //             onPressed: () {},
                        //             tooltip: '颜色选择',
                        //           ),
                        //           SizedBox(height: 10),
                        //           IconButton(
                        //             icon: Icon(Icons.label),
                        //             onPressed: () {},
                        //             tooltip: '标签',
                        //           ),
                        //           SizedBox(height: 10),
                        //           IconButton(
                        //             icon: Icon(Icons.select_all),
                        //             onPressed: () {},
                        //             tooltip: '框选',
                        //           ),
                        //           SizedBox(height: 10),
                        //           IconButton(
                        //             icon: Icon(Icons.undo),
                        //             onPressed: () {},
                        //             tooltip: '撤销',
                        //           ),
                        //           SizedBox(height: 10),
                        //           IconButton(
                        //             icon: Icon(Icons.redo),
                        //             onPressed: () {},
                        //             tooltip: '重做',
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  );
                },
              ),
              Expanded(
                child: Column(
                  children: [
                    Selector<ChatController, int>(
                      // 修改为调用新的方法
                      selector: (_, myType) => myType
                          .getChat(widget.chatRecord.title)
                          .content
                          .length,
                      // shouldRebuild: (previous, next) => true,
                      shouldRebuild: (previous, next) {
                        // print('previous: $previous, next: $next');
                        return previous != next;
                      },
                      builder: (context, messagesLength, child) {
                        // 当消息列表更新时，滚动到最底部
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_scrollController.hasClients) {
                            _scrollController.jumpTo(
                                _scrollController.position.maxScrollExtent);
                          }
                        });
                        return Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: messagesLength + 1,
                            itemBuilder: (BuildContext context, int index) {
                              if (index == messagesLength) {
                                return const SizedBox(
                                  height: 60,
                                );
                              }
                              return Selector<ChatController,
                                  List<OpenAIChatCompletionChoiceMessageModel>>(
                                selector: (_, chatController) => chatController
                                    .getChat(widget.chatRecord.title)
                                    .content,
                                shouldRebuild: (previous, next) => true,
                                builder: (context, content, child) {
                                  return widget.chatRecord.buildWidget(index);
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                    Stack(children: [
                      ChatInputField(title: widget.chatRecord.title),
                    ])
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChatInputField extends StatefulWidget {
  const ChatInputField({super.key, required this.title});
  final String title;

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _textEditingController =
      ChatController().textEditingController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus(); // 初始化时请求焦点
  }

  @override
  void dispose() {
    // _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: const ContinuousRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 120, // 设置输入框的最大高度
                ),
                child: SingleChildScrollView(
                  child: CallbackShortcuts(
                      bindings: {
                        const SingleActivator(LogicalKeyboardKey.enter,
                            control: false): () {
                          if (!ChatController().sendPermission) return;
                          if (_textEditingController.text.isNotEmpty) {
                            ChatController().sendMessage(widget.title,
                                _textEditingController.text, false);
                          }

                          // 发送消息后重新请求焦点
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _focusNode.requestFocus();
                            _textEditingController.clear();
                          });
                        },
                        const SingleActivator(LogicalKeyboardKey.enter,
                            control: true): () {
                          _textEditingController.text += '\n';
                        },
                      },
                      child: Selector<ChatController, TextEditingController>(
                        selector: (_, chatController) =>
                            chatController.textEditingController,
                        builder: (context, textEditingController, child) {
                          return TextField(
                            controller: _textEditingController,
                            focusNode: _focusNode,
                            decoration: const InputDecoration(
                              hintText: '输入消息...',
                              border: InputBorder.none,
                            ),
                            maxLines: null,
                            enableInteractiveSelection: true,
                            enableIMEPersonalizedLearning: true,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                          );
                        },
                      )),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                ChatController().generateGuidence(widget.title);
              },
              icon: const Icon(Icons.wysiwyg_outlined),
              tooltip: '生成引导',
            ),
            IconButton(
              onPressed: () {
                ChatController().summarize(widget.title);
              },
              icon: const Icon(Icons.done_all_outlined),
              tooltip: "总结",
            ),
            IconButton(
              icon: const Icon(Icons.photo),
              tooltip: "上传图片",
              onPressed: () async {
                // 处理上传图片的逻辑
                List<String>? filePaths = await FileUtils.pickFile(context);
                if (filePaths != null && filePaths.isNotEmpty) {
                  String chatDir = '.\\chats\\${widget.title}';
                  await FileUtils.createDirectoryIfNotExists(chatDir);
                  List<String> imgs = [];
                  for (String filePath in filePaths) {
                    String newPath =
                        await FileUtils.copyFileToDirectory(filePath, chatDir);
                    // newPath = newPath.replaceAll('\\', '/');
                    if (newPath.isNotEmpty) {
                      imgs.add(newPath);
                    }
                  }
                  ChatController().addImgs(widget.title, imgs);
                }
              },
            ),
            Selector<ChatController, bool>(
              selector: (_, chatController) => chatController.sendPermission,
              builder: (context, sendPermission, child) {
                return IconButton(
                  icon: const Icon(Icons.send),
                  tooltip: "发送",
                  onPressed: !sendPermission
                      ? null
                      : () {
                          if (_textEditingController.text.isNotEmpty) {
                            // 处理发送消息的逻辑
                            ChatController().sendMessage(widget.title,
                                _textEditingController.text, false);
                            _textEditingController.clear();
                            // 发送消息后重新请求焦点
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _focusNode.requestFocus();
                            });
                          }
                        },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
