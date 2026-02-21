import 'package:flutter/material.dart';
import 'package:enough_mail/enough_mail.dart';
import 'dart:convert';
import 'dart:async';
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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GetMailsDisplay(onLoginUpdated: refresh),
                    OtherMailsDisplay(),
                  ],
                ),
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

  Future<List<Map<String, dynamic>>> getMails(
      {String fetchCounts = "none"}) async {
    final client = ImapClient(isLogEnabled: true);
    List<Map<String, dynamic>> folderResults = [];
    try {
      debugPrint('接続試行中...');
      await client.connectToServer('imap.spmode.ne.jp', 993, isSecure: true);
      debugPrint('接続成功！ログイン中...');
      await client.login(email, password);

      if (fetchCounts == 'getMail') {
        final mailboxes = await client.listMailboxes();

        debugPrint('--- フォルダ一覧 ---');
        debugPrint('フォルダ数: ${mailboxes.length}');

        for (final mailbox in mailboxes) {
          try {
            await client.selectMailbox(mailbox);

            // 2. 検索機能を使って「未読(UNSEEN)」メールのIDリストを取得する
            // サーバーに直接「未読のリストをちょうだい」と聞くので、解析ミスが起きません
            final searchResult =
                await client.searchMessages(searchCriteria: 'UNSEEN');
            final unreadCount = searchResult.matchingSequence?.length ?? 0;

            folderResults.add({
              'name': mailbox.name,
              'unread': unreadCount,
            });

            debugPrint('--- 取得完了 ---');
            debugPrint('フォルダ名: ${mailbox.name}');
            debugPrint('未読件数: $unreadCount');
          } catch (e) {
            continue;
          }
        }
      } else {
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
      }
    } catch (e) {
      debugPrint('受信エラー: $e');
    } finally {
      if (client.isConnected) {
        try {
          await client.logout();
        } catch (_) {
          // ログアウト時のエラーは無視してOK
        }
      }
    }
    return folderResults;
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
  final VoidCallback onLoginUpdated;
  const GetMailsDisplay({super.key, required this.onLoginUpdated});
  @override
  GetMailsState createState() => GetMailsState();
}

class GetMailsState extends State<GetMailsDisplay> {
  final DocomoMailReceiveService _mailService = DocomoMailReceiveService();
  List<Map<String, dynamic>> _folderList = [];
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    getsMails();
  }

  // 非同期処理を扱うためのメソッド
  Future<void> getsMails() async {
    debugPrint('--- 取得開始 ---'); // これがターミナルに出るか確認
    try {
      // タイムアウトを設定して、10秒以上かかったら強制終了させる
      List<Map<String, dynamic>> result = await _mailService
          .getMails(fetchCounts: 'getMail')
          .timeout(const Duration(seconds: 15)); //サーバーとの通信時間

      debugPrint('データ取得成功: ${result.length}件');
      if (mounted) {
        setState(() {
          _folderList = result;
        });
      }
    } on TimeoutException catch (_) {
      debugPrint('タイムアウトしました：サーバーの応答がありません');
    } catch (e) {
      debugPrint('エラー詳細: $e');
    } finally {
      debugPrint('--- 処理終了（ぐるぐるを止めます） ---');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Container(
          width: screenWidth,
          color: const Color.fromARGB(255, 222, 222, 222),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: screenWidth * 0.05,
                padding: EdgeInsets.only(left: screenWidth * 0.03),
                child: Text(
                  '受信メール',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    height: 1.0,
                    leadingDistribution: TextLeadingDistribution.even,
                  ),
                ),
              ),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  children: _folderList.map(
                    (folder) {
                      return Column(
                        children: [
                          SizedBox(
                            height: screenWidth * 0.15, // 高さを統一
                            width: double.infinity,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                alignment: Alignment.centerLeft,
                                foregroundColor:
                                    const Color.fromARGB(255, 0, 0, 0),
                                backgroundColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                // 左右に少し余白を持たせる（文字が端に寄りすぎないよう調整）
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.03),
                              ),
                              onPressed: () {
                                debugPrint('${folder['name']} を選択しました');
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // 1. フォルダ名
                                  Text(
                                    folder['name'] ?? '名前なし',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.normal),
                                  ),
                                  // 2. 未読件数（バッジ）
                                  if (folder['unread'] > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${folder['unread']}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          // ボタン間の区切り線（screenWidth * 0.005 の隙間に相当）
                          SizedBox(
                            width: double.infinity,
                            height: screenWidth * 0.005,
                          ),
                        ],
                      );
                    },
                  ).toList(),
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
                      onPressed: () async {},
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
