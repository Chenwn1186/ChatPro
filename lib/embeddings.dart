import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dart_openai/dart_openai.dart';

class OpenAIEmbeddings {

  Future<List<double>> embedDocuments(List<String> texts) async {
    try {
      final embedding = await OpenAI.instance.embedding.create(
        model: "text-embedding-ada-002",
        input: texts, // 确保输入为字符串列表
      );
      return embedding.data.first.embeddings;
    } catch (e) {
      print('Error generating embeddings: $e');
      return [];
    }
  }
}

class VectorDB {
  final OpenAIEmbeddings embedding = OpenAIEmbeddings();

  VectorDB();

  Future<void> store(String title, List<String> text, String history) async {
    if (text.isEmpty) return;
    final vector = await embedding.embedDocuments(text);
    await _saveToCSV({'text': history, 'embedding': vector}, title);
  }

  Future<void> _saveToCSV(Map<String, dynamic> data, String title) async {
    final savePath = 'chats/$title/$title.csv';
    final dir = Directory('chats/$title');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final file = File(savePath);
    final header = await file.exists() ? '' : 'text,embedding\n';
    final line = '${data['text']},${json.encode(data['embedding'])}\n';
    await file.writeAsString(header + line, mode: FileMode.append);
  }

  Future<List<dynamic>> query(String text, String title, int topN, [double threshold = 0.8]) async {
    print("begin query");
    if (text.isEmpty) return [[''], ['']];

    double relatednessFn(List<double> x, List<double> y) {
      return 1 - _cosineDistance(x, y);
    }

    final savePath = 'chats/$title/$title.csv';
    if (!await File(savePath).exists()) return [[''], ['']];

    final lines = await File(savePath).readAsLines();
    final headers = lines[0].split(',');
    final data = <Map<String, dynamic>>[];
    for (var i = 1; i < lines.length; i++) {
      final values = lines[i].split(',');
      final embeddingList = json.decode(values[1]) as List<dynamic>;
      if (embeddingList is! List<double>) {
        throw const FormatException('Invalid embedding format');
      }
      final row = {
        headers[0]: values[0],
        headers[1]: embeddingList.cast<double>(),
      };
      data.add(row);
    }

    topN = topN < data.length ? topN : data.length;
    final queryEmbedding = await embedding.embedDocuments([text]);
    final stringsAndRelatednesses = data.map((row) {
      return (row['text'] as String, relatednessFn(queryEmbedding, row['embedding'] as List<double>));
    }).toList();

    stringsAndRelatednesses.sort((a, b) => b.$2.compareTo(a.$2));

    final finalStrings = <String>[];
    final finalRelatednesses = <double>[];
    for (var i = 0; i < stringsAndRelatednesses.length; i++) {
      if (stringsAndRelatednesses[i].$2 < threshold) break;
      finalStrings.add(stringsAndRelatednesses[i].$1);
      finalRelatednesses.add(stringsAndRelatednesses[i].$2);
    }

    // return [
    //   finalStrings.sublist(0, topN.clamp(0, finalStrings.length)),
    //   finalRelatednesses.sublist(0, topN.clamp(0, finalRelatednesses.length)),
    // ];
    return finalStrings.sublist(0, topN.clamp(0, finalStrings.length));
  }

  double _cosineDistance(List<double> x, List<double> y) {
    double dotProduct = 0;
    double normX = 0;
    double normY = 0;
    for (var i = 0; i < x.length; i++) {
      dotProduct += x[i] * y[i];
      normX += x[i] * x[i];
      normY += y[i] * y[i];
    }
    normX = sqrt(normX);
    normY = sqrt(normY);
    if (normX == 0 || normY == 0) return 1;
    return 1 - (dotProduct / (normX * normY));
  }
}