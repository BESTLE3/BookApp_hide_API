import 'package:flutter/Cupertino.dart';
import 'package:flutter/material.dart';

class GeminiScreen extends StatelessWidget {
  const GeminiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          middle: Text('책 봇')
      ),
      child: SafeArea(
          child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.all(10),
              color: CupertinoColors.systemGrey6,
              child: Text('Gemini Screen')
          )
      ),
    );
  }
}
