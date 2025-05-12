import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bookapp/bookscreen/bookdetailpage.dart';
import 'package:bookapp/gemini/gemini_screen.dart';
import 'package:bookapp/main.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ##### 메인 화면 #####
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String keyword = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.of(context, rootNavigator: true).push(
              CupertinoPageRoute(
                builder: (context) => GeminiScreen(),
              ),
            );
          },
          child: Image.asset(
            'asset/img/google-gemini-icon.png',
            width: 25,
            height: 25,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('어떤 책을 읽어볼까요?', style: TextStyle(fontSize: 23)),
          Container(
            height: 80,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: CupertinoSearchTextField(
              placeholder: '책 키워드 검색',
              onSubmitted: (value) {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => KeywordResultPage(keyword: value),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ##### 키워드 입력 후 #####
class KeywordResultPage extends StatefulWidget {
  final String keyword;

  const KeywordResultPage({Key? key, required this.keyword}) : super(key: key);

  @override
  State<KeywordResultPage> createState() => _KeywordResultPageState();
}

class _KeywordResultPageState extends State<KeywordResultPage> {
  List books = [];
  bool isLoading = false;
  int page = 1;
  bool hasMore = true;
  ScrollController scrollController = ScrollController();

  String? kakaoAPIKey = dotenv.env['KAKAO_API_KEY'];    // ##### 카카오 API 키

  @override
  void initState() {
    super.initState();
    fetchBooks(widget.keyword);

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        fetchBooks(widget.keyword);
      }
    });
  }

  // ##### 카카오 api 불러오기
  Future<void> fetchBooks(String keyword) async {
    if (isLoading || !hasMore) return;

    setState(() => isLoading = true);

    final response = await http.get(
      Uri.parse(
        'https://dapi.kakao.com/v3/search/book?query=$keyword&page=$page&size=${50}',
      ),
      headers: {'Authorization': 'KakaoAK ${kakaoAPIKey}'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List newBooks = data['documents'];

      setState(() {
        books.addAll(newBooks);
        page++;
        isLoading = false;
        if (newBooks.length < 10) hasMore = false;
      });
    } else {
      setState(() => isLoading = false);
      throw Exception('책을 불러올 수 없습니다.');
    }
  }


  //검색된 책 2열로 나열
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.keyword),
        trailing: const SizedBox(width: 0),
      ),
      child: SafeArea(
        child: books.isEmpty
                ? const Center(child: Text('검색 결과가 없습니다.'))
                : Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1,
                            ),
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          final book = books[index];
                          return CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder:
                                      (context) => BookDetailPage(book: book),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: CupertinoColors.systemGrey2,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  book['thumbnail'] != '' // 책 썸네일
                                      ? Image.network(
                                        book['thumbnail'],
                                        height: 100,
                                        fit: BoxFit.cover,
                                      )
                                      : Container(
                                        child: Center(
                                          child: Text('(썸네일 없음)', style: TextStyle(color: Colors.grey)),
                                        ),
                                        height: 100,
                                      ),
                                  const SizedBox(height: 12),
                                  Text(
                                    // 책 제목
                                    book['title'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    // 책 저자
                                    book['authors'].join(', '),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}