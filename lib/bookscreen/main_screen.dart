import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
                  '무슨 책을 추천해드릴까요?',
                  style: TextStyle(fontSize: 23),
              ),
          Container(
            height: 80,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: CupertinoSearchTextField(
              placeholder: '책 키워드 검색',
              onSubmitted: (value) {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => KeywordResultPage(keyword: value)
                  ),
                );
              },
            ),
          ),
        ],
      )
    );
  }
}

class KeywordResultPage extends StatelessWidget {
  final String keyword;

  const KeywordResultPage({Key? key, required this.keyword}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('$keyword'),
        trailing: const SizedBox(width: 0, height: 0),
        ),
      child: Center(
        child: Text(
          '입력한 키워드: $keyword',
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}