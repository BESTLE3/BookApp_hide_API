import 'dart:io';
import 'dart:convert';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:path_provider/path_provider.dart';
import 'chat_session.dart';

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

Future<void> saveChatHistory(List<ChatMessage> history) async {
  final file = await _getChatFile();
  final jsonList = history.map((m) => m.toJson()).toList();
  await file.writeAsString(jsonEncode(jsonList));
}

Future<List<ChatMessage>> loadChatHistory() async {
  final file = await _getChatFile();
  if (!await file.exists()) return <ChatMessage>[];
  final jsonStr = await file.readAsString();
  final List<dynamic> jsonList = jsonDecode(jsonStr);
  return jsonList.map((e) => ChatMessage.fromJson(e)).toList();
}