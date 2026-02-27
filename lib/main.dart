import 'package:flutter/material.dart';
import 'package:enough_mail/enough_mail.dart';
import 'dart:convert';
import 'dart:async';
import 'package:charset_converter/charset_converter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:red_mail/mailTree.dart';

String _email = '';
List<Map<String, dynamic>> folderResults = [];

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
  bool _isLoggedIn = false; // ログイン状態を管理する変数

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // 起動時にチェック
  }

  // 保存されているログイン情報を確認
  Future<void> _checkLoginStatus() async {
    final prefss = await SharedPreferences.getInstance();
    await prefss.setStringList('loginStateNow', [
      'nandemoii1145@gmail.com',
      '.tgjENVc+Y',
      'nbbr9xb5kw2znbtfqxag@docomo.ne.jp',
    ]);

    _email = 'nbbr9xb5kw2znbtfqxag@docomo.ne.jp';

    final prefs = await SharedPreferences.getInstance();
    final List<String>? loginStateNow = prefs.getStringList('loginStateNow');
    setState(() {
      if (loginStateNow != null && loginStateNow.isNotEmpty) {
        _isLoggedIn = true;
        // ここで代入することで、親から子へ新しいメルアドが渡される
        _email = loginStateNow[2];
      } else {
        _isLoggedIn = false;
        _email = '';
      }
    });
  }

  void refresh() async {
    // 保存されたデータを再確認してフラグを更新
    final prefs = await SharedPreferences.getInstance();
    final List<String>? loginStateNow = prefs.getStringList('loginStateNow');

    setState(() {
      _isLoggedIn = loginStateNow != null && loginStateNow.isNotEmpty;
    });

    debugPrint('再描画実行: ログイン状態 = $_isLoggedIn');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'メールアプリ',
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color.fromARGB(255, 222, 222, 222),
        body: Stack(
          children: [
            if (_isLoggedIn == false) LoginDisplay(onLoginUpdated: refresh),
            Column(
              children: [
                Container(
                  //上部の隙間色
                  height: MediaQuery.of(context).padding.top,
                  color: Colors.black,
                ),
                MailAdressDisplay(email: _email),
                if (_isLoggedIn)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          GetMailsDisplay(
                              onLoginUpdated: refresh, body: folderResults),
                        ],
                      ),
                    ),
                  ),
              ],
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
  Future<List<Map<String, dynamic>>> getMails(
      {String fetchCounts = "none"}) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? loginStateNow = prefs.getStringList('loginStateNow');

    if (loginStateNow == null || loginStateNow.length < 2) {
      debugPrint('エラー: ログイン情報が SharedPreferences に見つかりません');
      return []; // または throw Exception
    }

    // クラス変数に代入（またはローカル変数として利用
    final iMAPid = loginStateNow[0];
    final password = loginStateNow[1];
    _email = loginStateNow[2];

    final client = ImapClient(isLogEnabled: true);
    try {
      debugPrint('接続試行中...');
      await client.connectToServer('imap.spmode.ne.jp', 993, isSecure: true);
      debugPrint('接続成功！ログイン中...');
      await client.login(iMAPid, password);

      final mailboxes = await client.listMailboxes();

      debugPrint('--- フォルダ一覧 ---');
      debugPrint('フォルダ数: ${mailboxes.length}');

      for (final mailbox in mailboxes) {
        String mailBoxName = mailbox.name;
        if (mailBoxName == 'INBOX') {
          mailBoxName = '受信メール';
        } else if (mailBoxName == 'Sent') {
          mailBoxName = '送信済みメール';
        } else if (mailBoxName == 'Drafts') {
          mailBoxName = '未送信メール';
        } else if (mailBoxName == 'Trash') {
          mailBoxName = 'ゴミ箱';
        }

        try {
          await client.selectMailbox(mailbox);

          // 1. 未読件数の取得
          final searchResult =
              await client.searchMessages(searchCriteria: 'UNSEEN');
          final unreadCount = searchResult.matchingSequence?.length ?? 0;

          List<Map<String, String>> emailsInFolder = [];

          final fetchResult =
              await client.fetchRecentMessages(messageCount: 50);

          for (final message in fetchResult.messages) {
            String subject = message.decodeSubject() ?? '件名なし';
            final fromAddress = message.from?.first;
            final senderName = fromAddress?.personalName ?? '名前なし';
            final senderEmail = fromAddress?.email ?? 'アドレス不明';

            String? body = message.decodeTextPlainPart() ??
                message.decodeTextHtmlPart() ??
                '本文なし';

            if (subject.contains('=?shift_jis?B?')) {
              try {
                final regExp =
                    RegExp(r'=\?shift_jis\?B\?(.+)\?=', caseSensitive: false);
                final match = regExp.firstMatch(subject);
                if (match != null) {
                  final bytes = base64.decode(match.group(1)!);
                  subject = await CharsetConverter.decode("cp932", bytes);
                }
              } catch (e) {
                debugPrint('デコードエラー: $e');
              }
            }

            emailsInFolder.add({
              'subject': subject,
              'senderName': senderName,
              'senderEmail': senderEmail,
              'body': body,
            });
          }

          folderResults.add({
            'name': mailBoxName,
            'unread': unreadCount,
            'messages': emailsInFolder,
          });

          debugPrint('$mailBoxName の取得完了 (${emailsInFolder.length}件)');
        } catch (e) {
          debugPrint('$mailBoxName は空きフォルダ: $e');
          folderResults.add({
            'name': mailBoxName,
            'unread': 0,
          });
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

bool loginCheck = false;
bool loginVisible = true;
final TextEditingController _idController = TextEditingController();
final TextEditingController _passController = TextEditingController();
final TextEditingController _mailController = TextEditingController();

class LoginDisplay extends StatefulWidget {
  final VoidCallback onLoginUpdated;
  const LoginDisplay({super.key, required this.onLoginUpdated});
  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<LoginDisplay> {
  @override
  void initState() {
    super.initState();
    loginConditionCheck();
  }

  void loginConditionCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? loginStateNow = prefs.getStringList('loginStateNow');

    debugPrint('現在のloginStateNow: $loginStateNow');
    setState(() {
      if (loginStateNow != null && loginStateNow.isNotEmpty) {
        loginCheck = false;
        loginVisible = false;
      } else {
        //ローカルデータない場合
        loginCheck = true;
        loginVisible = true;
      }
    });
    widget.onLoginUpdated();

    debugPrint('現在のloginCheck: $loginCheck');
  }

  Future<void> loginConditionSave() async {
    final prefs = await SharedPreferences.getInstance();
    String? loginState = prefs.getString('loginStateNow');

    if (loginState != null && loginState.isNotEmpty) {
      debugPrint('【確認】ログイン中: ユーザーID = $loginState');
    } else {
      debugPrint('【確認】未ログイン状態です');
    }
  }

  Future<void> loginRequest() async {
    if (_idController.text.isEmpty || _passController.text.isEmpty) {
      debugPrint('IDとパスワードを入力してください');
      return;
    }

    final DocomoMailReceiveService _mailService = DocomoMailReceiveService();
    try {
      List<Map<String, dynamic>> result = await _mailService
          .getMails(fetchCounts: 'loginCheck')
          .timeout(const Duration(seconds: 15));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('loginStateNow',
          [_idController.text, _passController.text, _mailController.text]);

      debugPrint('ログイン成功・保存完了');

      setState(() {
        loginCheck = false;
        loginVisible = false;
      });

      widget.onLoginUpdated();
    } on TimeoutException catch (_) {
      debugPrint('タイムアウトしました');
    } catch (e) {
      debugPrint('ログイン失敗: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ログインフォームの追加
        if (loginVisible) ...[
          Positioned.fill(
            child: ModalBarrier(
              color: Colors.black54,
              dismissible: false,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  left: 32,
                  right: 32,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white, // 背景が透けないように白に設定
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _mailController,
                        decoration: const InputDecoration(
                            labelText: 'メールアドレス(~@docomo.ne.jpなど)',
                            border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _idController,
                        decoration: const InputDecoration(
                            labelText: 'IMAPユーザーID',
                            border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passController,
                        obscureText: true,
                        decoration: const InputDecoration(
                            labelText: 'IMAP専用パスワード',
                            border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: loginRequest,
                        child: const Text('ログイン実行'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class MailAdressDisplay extends StatefulWidget {
  const MailAdressDisplay({super.key, required this.email});
  final String email;
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
          Positioned.fill(
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
                    widget.email.isEmpty ? '読み込み中...' : widget.email,
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
  final List<Map<String, dynamic>> body;
  const GetMailsDisplay(
      {super.key, required this.onLoginUpdated, required this.body});
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _folderList.isNotEmpty ? _folderList : widget.body;
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
                height: screenWidth * 0.1,
                padding: EdgeInsets.only(left: screenWidth * 0.03),
                child: Row(
                  children: [
                    Text(
                      '受信メール',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        height: 1.0,
                        leadingDistribution: TextLeadingDistribution.even,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  children: _folderList.asMap().entries.map(
                    (entry) {
                      int index = entry.key; // 何番目かの番号
                      Map<String, dynamic> folder = entry.value;
                      final String folderName = folder['name'] ?? '名前なし';
                      // 「送信済みメール」かどうかを判定
                      final List<Map<String, String>> folderMessages =
                          List<Map<String, String>>.from(
                              folder['messages'] ?? []);
                      final bool isSentFolder = folderName == '送信済みメール';
                      return Column(
                        children: [
                          if (isSentFolder)
                            Container(
                              height: screenWidth * 0.1,
                              padding:
                                  EdgeInsets.only(left: screenWidth * 0.03),
                              child: Row(
                                children: [
                                  Text(
                                    '送信済・未送信メール・ゴミ箱',
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 17,
                                      height: 1.0,
                                      leadingDistribution:
                                          TextLeadingDistribution.even,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (isSentFolder)
                            SizedBox(
                              width: double.infinity,
                              height: screenWidth * 0.005,
                            ),
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MailCheckPage(
                                      folderName: folderName,
                                      mailTexts: folderMessages,
                                      mailadress: _email,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: folder['checked'] ?? false,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            // インデックスを使ってリストの中身を更新
                                            _folderList[index]['checked'] =
                                                value ?? false;
                                          });
                                          debugPrint(
                                              '$index 番目のフォルダ: $folderName を ${value! ? "選択" : "解除"}');
                                        },
                                      ),
                                      Text(
                                        folder['name'] ?? '名前なし',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
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
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
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
