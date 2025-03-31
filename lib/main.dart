import 'package:chat_pro/backend.dart';
import 'package:chat_pro/chat_controller.dart';
import 'package:chat_pro/chat_list.dart';
import 'package:chat_pro/ui/pura_multiple_radial_gradients.dart';
import 'package:chat_pro/ui/theme.dart';
// import 'package:chat_pro/chat_page.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_canvas/images_board.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    var width = size.width;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatController()),
        ChangeNotifierProvider(create: (_) => ImagesBoardManager()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            textTheme: TextTheme(
              displayLarge: const TextStyle().useSystemChineseFont(),
              displayMedium: const TextStyle().useSystemChineseFont(),
              displaySmall: const TextStyle().useSystemChineseFont(),
              headlineLarge: const TextStyle().useSystemChineseFont(),
              headlineMedium: const TextStyle().useSystemChineseFont(),
              headlineSmall: const TextStyle().useSystemChineseFont(),
              titleLarge: const TextStyle().useSystemChineseFont(),
              titleMedium: const TextStyle().useSystemChineseFont(),
              titleSmall: const TextStyle().useSystemChineseFont(),
              bodyLarge: const TextStyle().useSystemChineseFont(),
              bodyMedium: const TextStyle().useSystemChineseFont(),
              bodySmall: const TextStyle().useSystemChineseFont(),
              labelLarge: const TextStyle().useSystemChineseFont(),
              labelMedium: const TextStyle().useSystemChineseFont(),
              labelSmall: const TextStyle().useSystemChineseFont(),
            ),
            textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
              textStyle: const TextStyle().useSystemChineseFont(),
            ))),
        home: Stack(
          children: [
            Selector<ChatController, String>(
            selector: (_, myType) => ChatThemes().currentTheme,
            shouldRebuild: (previous, next) => true,
            builder: (context, currentTheme, child) {
              return PuraMultipleRadialGradients(
                inputPoints: [
                  InputPoint(
                    const Offset(0.25, 0.25),
                    ChatThemes().getColors()[0].withAlpha(150),
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
            Scaffold(
              appBar: AppBar(
                actions: [
                  PopupMenuButton(
                      icon: const Icon(Icons.change_circle_rounded),
                      tooltip: 'switch model',
                      itemBuilder: (context) {
                        return OpenAIUserInteraction().getModels().map((e) {
                          return PopupMenuItem(
                            value: e,
                            child: Text(e),
                            onTap: () {
                              OpenAIUserInteraction().setModel(e);
                            },
                          );
                        }).toList()..add(
                            PopupMenuItem(
                              value: 'current model',
                              child: Text('current model: ${OpenAIUserInteraction().model}'),
                              onTap: () {
                                // OpenAIUserInteraction().setModel('设置');
                              },
                            ),
                          
                        );
                      })
                ],
              ),
              backgroundColor: const Color.fromARGB(160, 211, 211, 211),
              body: Row(
                children: [
                  SizedBox(
                    width: width * 0.2,
                  ),
                  const Expanded(
                    child: ChatList(),
                  ),
                  SizedBox(
                    width: width * 0.2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
