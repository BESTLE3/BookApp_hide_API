import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
//import 'package:bookapp/gemini/message_history.dart';

String geminiAPIKey = dotenv.env['GEMINI_API_KEY'] ?? 'default_key_here';
String? kakaoAPIKey = dotenv.env['KAKAO_API_KEY'];

Future<void> saveMessage(ChatMessage message) async {
  final box = Hive.box<ChatMessage>('message_history');
  await box.add(message);
}

Future<List<ChatMessage>> loadMessage() async {
  final box = Hive.box<ChatMessage>('message_history');
  return box.values.toList();
}

class GeminiChatScreen extends StatelessWidget {

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(56.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.purple, Colors.orange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: AppBar(
              leading: IconButton(
                padding: EdgeInsets.symmetric(horizontal: 20),
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(
                '책 봇',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.question_answer),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                ),
              ],
            ),
          ),
        ),
        body : LlmChatView(
          welcomeMessage: '안녕하세요! 📚 어떤 책을 추천받고 싶으신가요?',
          errorMessage: '오류가 발생했습니다. 다시 시도해주세요.',
          style: LlmChatViewStyle(chatInputStyle: ChatInputStyle(hintText: '어떤 책을 찾으시나요?')),
          suggestions: [
            '힐링에 도움되는 책 추천해줘',
            '자기계발에 좋은책 추천해줘',
            '최근에 인기 있는 소설 추천해줘'
          ],
          provider: GeminiProvider(
            model: GenerativeModel(
              model: 'gemini-2.0-flash',
              apiKey: geminiAPIKey,
              systemInstruction: Content.text('''
              당신은 책만 추천하는 챗봇입니다.
              사용자의 감정, 상황, 질문에 따라 가장 적절한 책을 추천하세요.
              다른 주제에 대한 답변은 하지 마세요.
              책 제목, 저자, 간단한 소개, 추천 이유를 포함해 주세요.
              가능하다면 한국어로 출판된 책 위주로 추천해 주세요.
              사용자의 질문에 가장 근접한 책 3권만 추천해 주세요.
              책 제목, 저자, 간단한 소개, 추천 이유를 출력할 때 꼭 줄바꿈 해 주세요.
              인기있는 최식작을 우선으로 추천해주세요.
              '''),
            ),
          ),
        ),
      ),
    );
  }
}