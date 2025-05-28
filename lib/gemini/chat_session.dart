import 'dart:convert';
import 'dart:io';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:path_provider/path_provider.dart';

class ChatSession {
  final String id;
  final String title;
  final List<ChatMessage> messages;

  ChatSession({
    required this.id,
    required this.title,
    required this.messages,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      title: json['title'],
      messages: (json['messages'] as List)
          .map((m) => ChatMessage.fromJson(m))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'messages': messages.map((m) => m.toJson()).toList(),
  };
}

Future<File> _getChatFile() async {
  final dir = await getApplicationDocumentsDirectory();
  return File('${dir.path}/chat_sessions.json');
}

Future<void> saveAllSessions(List<ChatSession> sessions) async {
  final file = await _getChatFile();
  final jsonList = sessions.map((s) => s.toJson()).toList();
  await file.writeAsString(jsonEncode({'sessions': jsonList}));
}

Future<List<ChatSession>> loadAllSessions() async {
  final file = await _getChatFile();
  if (!await file.exists()) return [];
  final jsonStr = await file.readAsString();
  final data = jsonDecode(jsonStr);
  final List<dynamic> sessionList = data['sessions'];
  return sessionList.map((e) => ChatSession.fromJson(e)).toList();
}
