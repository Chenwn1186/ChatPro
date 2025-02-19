// import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
// import 'package:pura_music/media_controller.dart';
import 'package:win32/win32.dart';

/// 包含文件的添加、删除、选择等操作
class FileUtils {
  // 修改方法名，从 pickFolder 改为 pickFile
  static Future<List<String>?> pickFile(BuildContext context) {
    var str = showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return const FilePickerDialog();
      },
    );
    return str;
  }

  static Future<void> createDirectoryIfNotExists(String path) async {
    Directory directory = Directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  static Future<String> copyFileToDirectory(String filePath, String directoryPath) async {
    File file = File(filePath);
    String fileName = path.basename(file.path);
    String newPath = path.join(directoryPath, fileName);
    File newFile = await file.copy(newPath);
    return newFile.path;
  }
}

class FilePickerDialog extends StatefulWidget {
  const FilePickerDialog({super.key});

  @override
  _FilePickerDialogState createState() => _FilePickerDialogState();
}

class _FilePickerDialogState extends State<FilePickerDialog> {
  String _currentPath = '\\';
  late Future<List<FileSystemEntity>> _filesFuture;
  List<String> _drives = [];
  bool _isRoot = true;
  List<File> _selectedFiles = []; // 用于存储选中的文件

  @override
  void initState() {
    super.initState();
    _filesFuture = _getFilesAndFolders(_currentPath);
    _drives = _getWindowsDrives();
  }

  static List<String> _getWindowsDrives() {
    final logicalDrives = GetLogicalDrives();
    final drives = <String>[];

    for (var i = 0; i < 26; i++) {
      if ((logicalDrives & (1 << i)) != 0) {
        final driveLetter = String.fromCharCode(65 + i);
        drives.add('$driveLetter:\\');
      }
    }

    return drives;
  }

  Future<List<FileSystemEntity>> _getFilesAndFolders(
      String directoryPath) async {
    final directory = Directory(directoryPath);
    List<FileSystemEntity> entities = [];

    try {
      if (directoryPath == '\\') {
        entities = await directory
           .list()
           .where((entity) => entity is Directory)
           .toList();
      } else {
        entities = await directory.list().toList();
      }

      entities.sort((a, b) {
        if (a is Directory && b is File) return -1;
        if (a is File && b is Directory) return 1;
        return a.path.toLowerCase().compareTo(b.path.toLowerCase());
      });
    } catch (e) {
      print('Error reading directory: $e');
    }

    return entities;
  }

  void _updatePath(String newPath) {
    setState(() {
      _currentPath = newPath;
      _filesFuture = _getFilesAndFolders(_currentPath);
      _selectedFiles.clear(); // 点击文件夹或返回时清空选中的文件
    });
  }

  bool _isImageFile(File file) {
    final ext = path.extension(file.path).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif'].contains(ext);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          IconButton(
            onPressed: () {
              if (!_drives.contains(_currentPath)) {
                _updatePath(path.dirname(_currentPath));
              } else {
                setState(() {
                  _isRoot = true;
                  _currentPath = "";
                  _selectedFiles.clear(); // 回到根目录时清空选中的文件
                });
              }
            },
            icon: const Icon(Icons.arrow_upward),
            tooltip: "上级目录",
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '选择文件',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(
                  width: 500,
                  child: Text(
                    '当前路径：$_currentPath',
                    style: const TextStyle(fontSize: 10),
                  ))
            ],
          ),
        ],
      ),
      titlePadding: const EdgeInsets.only(top: 10, left: 10, right: 10),
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      content: SizedBox(
        width: 600,
        height: 400,
        child: Column(
          children: [
            Expanded(
              child: _isRoot
                 ? ListView.builder(
                      itemCount: _drives.length,
                      itemBuilder: (context, index) {
                        return SizedBox(
                            height: 25,
                            width: 280,
                            child: InkWell(
                              onTap: () {
                                _updatePath(_drives[index]);
                                _isRoot = false;
                              },
                              child: Row(
                                children: [
                                  const Icon(Icons.folder),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    width: 500,
                                    child: Text(
                                      _drives[index],
                                      style: const TextStyle(
                                          overflow: TextOverflow.fade),
                                    ),
                                  ),
                                ],
                              ),
                            ));
                      })
                 : FutureBuilder<List<FileSystemEntity>>(
                      future: _filesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(child: Text('当前目录下没有文件或文件夹'));
                        } else {
                          return ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                final file = snapshot.data![index];
                                final fileName = path.basename(file.path);
                                final isSelected = file is File && _selectedFiles.contains(file);
                                // 根据文件类型动态调整高度
                                final itemHeight = file is File && _isImageFile(file) ? 80.0 : 25.0;
                                return SizedBox(
                                    height: itemHeight,
                                    width: 280,
                                    child: InkWell(
                                      onTap: () {
                                        if (file is Directory) {
                                          _updatePath(file.path);
                                        } else if (file is File && _isImageFile(file)) {
                                          setState(() {
                                            if (_selectedFiles.contains(file)) {
                                              _selectedFiles.remove(file);
                                            } else {
                                              _selectedFiles.add(file);
                                            }
                                          });
                                        }
                                      },
                                      child: Container(
                                        color: isSelected ? const Color.fromARGB(255, 109, 216, 255) : null,
                                        child: Row(
                                          children: [
                                            if (file is Directory)
                                              const Icon(Icons.folder) // 文件夹图标使用默认大小
                                            else if (file is File && _isImageFile(file))
                                              Image.file(
                                                file,
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                              )
                                            else
                                              const Icon(Icons.insert_drive_file), // 非图片文件图标使用默认大小
                                            const SizedBox(width: 10),
                                            SizedBox(
                                              width: 500,
                                              child: Text(
                                                fileName,
                                                style: const TextStyle(
                                                    overflow: TextOverflow.fade),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ));
                              });
                        }
                      },
                    ),
            )
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            if (_selectedFiles.isNotEmpty) {
              final filePaths = _selectedFiles.map((file) => file.path).toList();
              Navigator.of(context).pop(filePaths);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('请选择至少一个图片文件')),
              );
            }
          },
          child: const Text('确定'),
        ),
        TextButton(
          child: const Text('取消'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
