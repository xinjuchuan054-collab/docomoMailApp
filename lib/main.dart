import 'package:flutter/material.dart';
import 'package:enough_mail/enough_mail.dart';
import 'dart:convert';
import 'package:charset_converter/charset_converter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void refresh() {
    setState(() {}); // 画面全体を再描画する
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'メールアプリ',
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color.fromARGB(255, 222, 222, 222),
        body: Column(
          children: [
            Container(
              //上部の隙間色
              height: MediaQuery.of(context).padding.top,
              color: Colors.black,
            ),
            MailAdressDisplay(),
            Expanded(
              child: Column(
                children: [
                  GetMailsDisplay(),
                  OtherMailsDisplay(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DocomoMailService {
  final String email = 'nbbr9xb5kw2znbtfqxag@docomo.ne.jp';
  final String password = '.tgjENVc+Y';

  Future<void> sendTestMail() async {
    final client = SmtpClient('docomo.ne.jp', isLogEnabled: true);
    try {
      await client.connectToServer('smtp.spmode.ne.jp', 465, isSecure: true);
      await client.authenticate(email, password, AuthMechanism.plain);

      final builder = MessageBuilder.prepareMultipartAlternativeMessage(
        plainText: 'Flutterからのテストメールです。',
      )
        ..from = [MailAddress('送信元名', email)]
        ..to = [MailAddress('宛先名', 'recipient@example.com')]
        ..subject = 'テスト送信';

      await client.sendMessage(builder.buildMimeMessage());
      await client.quit();
      print('送信成功！');
    } catch (e) {
      print('送信エラー: $e');
    }
  }
}

class DocomoMailReceiveService {
  final String email = 'nandemoii1145@gmail.com';
  final String password = '.tgjENVc+Y';

  Future<void> fetchMails() async {
    final client = ImapClient(isLogEnabled: true);
    try {
      await client.connectToServer('imap.spmode.ne.jp', 993, isSecure: true);

      await client.login(email, password);

      final mailboxes = await client.listMailboxes();

      debugPrint('--- フォルダ一覧 ---');
      debugPrint('フォルダ数: ${mailboxes.length}');

      for (final mailbox in mailboxes) {
        try {
          // mailboxStatus ではなく statusMailbox を使い、
          // 欲しい情報（未読数）を文字列のリストで直接指定します。
          // 第2引数の ['UNSEEN'] は IMAP の標準仕様のキーワードです。
          final dynamic status =
              await client.statusMailbox(mailbox, [StatusFlags.unseen]);
          final folderName = mailbox.name;

          // status オブジェクトの中にある unseen プロパティを確認します
          // もし unseen でエラーが出る場合は messagesCount を試してください
          final unreadCount = status.unseen ?? 0;

          debugPrint('フォルダ名: $folderName | 未読: $unreadCount 件');
        } catch (e) {
          // 選択できないフォルダや、ステータスが取れないフォルダはスキップ
          continue;
        }
      }

      for (final mailbox in mailboxes) {
        debugPrint('フォルダ名: ${mailbox.name}');
      }

      await client.selectInbox();

      final fetchResult = await client.fetchRecentMessages(messageCount: 50);

      for (final message in fetchResult.messages) {
        String? subject = message.decodeSubject();
        final fromAddress = message.from?.first;
        final senderName = fromAddress?.personalName ?? '名前なし';
        final senderEmail = fromAddress?.email ?? 'アドレス不明';

        String? body = message.decodeTextPlainPart();
        if (body == null || body.isEmpty) {
          body = message.decodeTextHtmlPart();
        }

        //shift-JIS規格からデコードする
        if (subject != null && subject.contains('=?shift_jis?B?')) {
          try {
            final regExp =
                RegExp(r'=\?shift_jis\?B\?(.+)\?=', caseSensitive: false);
            final match = regExp.firstMatch(subject);

            if (match != null) {
              final base64String = match.group(1)!;

              final bytes = base64.decode(base64String);
              subject = await CharsetConverter.decode("Shift_JIS", bytes);
            }
          } catch (e) {
            debugPrint('CharsetConverterエラー: $e');
          }
        }

        debugPrint('送信者 : $senderName 送信アドレス : $senderEmail 件名: $subject');
        debugPrint('本文 : $body');
      }
      await client.logout();
    } catch (e) {
      debugPrint('受信エラー: $e');
    }
  }
}

class MailAdressDisplay extends StatefulWidget {
  const MailAdressDisplay({super.key});
  @override
  MailAdressState createState() => MailAdressState();
}

class MailAdressState extends State<MailAdressDisplay> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      height: screenWidth * 0.12,
      width: screenWidth,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              color: const Color.fromARGB(255, 18, 150, 251),
              padding: EdgeInsets.only(left: screenWidth * 0.03),
              width: screenWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'メールフォルダ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 19,
                      height: 1.0,
                      leadingDistribution: TextLeadingDistribution.even,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.019),
                  Text(
                    'hdcyedsvhcnwduvibwenkvuh@docomo.ne.jp',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      height: 1.0,
                      leadingDistribution: TextLeadingDistribution.even,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GetMailsDisplay extends StatefulWidget {
  const GetMailsDisplay({super.key});
  @override
  GetMailsState createState() => GetMailsState();
}

class GetMailsState extends State<GetMailsDisplay> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Container(
          height: screenWidth * 0.05,
          width: screenWidth,
          color: const Color.fromARGB(255, 222, 222, 222),
          padding: EdgeInsets.only(left: screenWidth * 0.03),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '受信メール',
                style: TextStyle(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  height: 1.0,
                  leadingDistribution: TextLeadingDistribution.even,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class OtherMailsDisplay extends StatefulWidget {
  const OtherMailsDisplay({super.key});
  @override
  OtherMailsState createState() => OtherMailsState();
}

class OtherMailsState extends State<OtherMailsDisplay> {
  final DocomoMailReceiveService _receiveService = DocomoMailReceiveService();
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Container(
          height: screenWidth * 0.51,
          width: screenWidth,
          color: const Color.fromARGB(255, 222, 222, 222),
          //padding: EdgeInsets.only(left: screenWidth * 0.03),
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                height: screenWidth * 0.05,
                child: Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.03),
                  child: Text(
                    '送信メール・未送信メール・ごみ箱',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      height: 1.0,
                      leadingDistribution: TextLeadingDistribution.even,
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: screenWidth * 0.15,
                    width: double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        foregroundColor: Color.fromARGB(255, 0, 0, 0),
                        backgroundColor: Color.fromARGB(255, 255, 255, 255),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0)),
                      ),
                      child: const Text(
                        '送信済みメール',
                        style: TextStyle(),
                      ),
                      onPressed: () async {
                        // メソッドを実行
                        await _receiveService.fetchMails();
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                height: screenWidth * 0.005,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: screenWidth * 0.15,
                    width: double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        foregroundColor: Color.fromARGB(255, 0, 0, 0),
                        backgroundColor: Color.fromARGB(255, 255, 255, 255),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0)),
                      ),
                      child: const Text('未送信メール'),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                height: screenWidth * 0.005,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: screenWidth * 0.15,
                    width: double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        foregroundColor: Color.fromARGB(255, 0, 0, 0),
                        backgroundColor: Color.fromARGB(255, 255, 255, 255),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0)),
                      ),
                      child: const Text('ゴミ箱'),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
