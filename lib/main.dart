import 'package:chat_pro/chat_controller.dart';
import 'package:chat_pro/chat_list.dart';
// import 'package:chat_pro/chat_page.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        home: Scaffold(
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
      ),
    );
  }
}
