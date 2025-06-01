import 'package:flutter/Cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bookapp/gemini/history_screen.dart';
import 'chat_storage.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

String geminiAPIKey = dotenv.env['GEMINI_API_KEY'] ?? 'default_key_here';

// 채팅 내역 저장 관련
Future<File> _getChatFile() async {
  final dir = await getApplicationDocumentsDirectory();
  return File('${dir.path}/chat_history.json');
}

class GeminiChatScreen extends StatefulWidget {
  final List<ChatMessage>? restoredHistory;

  const GeminiChatScreen({this.restoredHistory});

  @override
  State<GeminiChatScreen> createState() => _GeminiChatScreenState();
}

class _GeminiChatScreenState extends State<GeminiChatScreen> {
  late GeminiProvider provider;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    provider = GeminiProvider(
      model: GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: geminiAPIKey,
        systemInstruction: Content.text('''
              당신은 책만 추천하는 챗봇입니다.
              사용자의 감정, 상황, 질문에 따라 가장 적절한 책을 추천하세요.
              다른 주제에 대한 답변은 하지 마세요.
              책 제목, 저자, 간단한 소개, 추천 이유를 포함해 출력해 주세요.
              가능하다면 한국어로 출판된 책 위주로 추천해 주세요.
              사용자의 질문에 가장 근접한 책 3권만 추천해 주세요.
              인기있는 최신작을 우선으로 추천해주세요.
              책 제목, 저자, 간단한 소개, 추천 이유를 출력할 때 줄바꿈 해 주세요.
              '''),
      ),
    );
    _initHistory();
    provider.addListener(_onHistoryChanged);
  }

  Future<void> _initHistory() async {
    final loaded = widget.restoredHistory ?? await loadChatHistory();
    provider.history = loaded;
    setState(() => _loading = false);
  }

  void _onHistoryChanged() {
    saveChatHistory(provider.history.toList());
  }

  @override
  void dispose() {
    provider.removeListener(_onHistoryChanged);
    super.dispose();
  }

  void _startNewChat() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('새 대화를 시작할까요?'),
            content: Text('기존 대화 내용은 저장됩니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('확인'),
              ),
            ],
          ),
    );
    if (confirm == true) {
      setState(() {
        provider.history = [];
      });
      await saveChatHistory([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
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
                onPressed: () {
                  //Navigator.of(context).push(_createRoute());
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: Text('미완성'),
                        content: Text('업데이트 예정'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            child: Text('확인'),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(Icons.question_answer),
                padding: EdgeInsets.symmetric(horizontal: 20),
              ),
              IconButton(
                onPressed: () {
                  _startNewChat();
                },
                icon: Icon(Icons.add_comment),
                tooltip: '새 대화 시작',
                padding: EdgeInsets.symmetric(horizontal: 20),
              ),
            ],
          ),
        ),
      ),
      body: LlmChatView(
        welcomeMessage: '안녕하세요! 📚 어떤 책을 추천받고 싶으신가요?',
        errorMessage: '오류가 발생했습니다. 다시 시도해주세요.',
        style: LlmChatViewStyle(
          chatInputStyle: ChatInputStyle(hintText: '어떤 책을 찾으시나요?'),
        ),
        suggestions: ['힐링에 도움되는 책 추천해줘', '자기계발에 좋은책 추천해줘', '최근에 인기 있는 소설 추천해줘'],
        provider: provider,
      ),
    );
  }
}

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => HistoryScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: Duration(milliseconds: 150),
    reverseTransitionDuration: Duration(milliseconds: 150),
  );
}
