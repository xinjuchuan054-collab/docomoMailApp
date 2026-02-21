import 'package:flutter/material.dart';
import 'package:enough_mail/enough_mail.dart';

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
        body: Column(
          children: [
            Container(
              //上部の隙間色
              height: MediaQuery.of(context).padding.top,
              color: Colors.black,
            ),
            MailAdressDisplay(),
            GetMailsDisplay(),
            OtherMailsDisplay(),
          ],
        ),
      ),
    );
  }
}

class DocomoMailService {
  final String email = 'your_address@docomo.ne.jp';
  final String password = 'your_app_password';

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
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Container(
          width: screenWidth,
          color: const Color.fromARGB(255, 222, 222, 222),
          //padding: EdgeInsets.only(left: screenWidth * 0.03),
          child: Column(
            children: [
              Padding(
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
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
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
                        '送信BOX',
                        style: TextStyle(),
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                height: screenWidth * 0.004,
                color: Color.fromARGB(255, 222, 222, 222),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        foregroundColor: Color.fromARGB(255, 0, 0, 0),
                        backgroundColor: Color.fromARGB(255, 255, 255, 255),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0)),
                      ),
                      child: const Text('未送信BOX'),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                height: 0.01,
                color: Color.fromARGB(255, 222, 222, 222),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
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
