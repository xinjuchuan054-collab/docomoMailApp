import 'package:flutter/material.dart';

class MailCheckPage extends StatelessWidget {
  final String folderName;
  final dynamic mailTexts;

  // コンストラクタ（窓口）
  const MailCheckPage({
    super.key,
    required this.folderName, // ★これを追加
    required this.mailTexts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(folderName), // ★アプリバーにフォルダ名が表示されるようになる！
      ),
      body: Center(child: Text(mailTexts.toString())),
    );
  }
}
