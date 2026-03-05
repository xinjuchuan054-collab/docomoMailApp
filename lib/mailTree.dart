import 'package:flutter/material.dart';
import 'package:red_mail/main.dart';

import 'package:red_mail/mailDetail.dart';

class MailCheckPage extends StatelessWidget {
  final String folderName;
  final List<Map<String, dynamic>> mailTexts;
  final String mailadress;

  // コンストラクタ（窓口）
  const MailCheckPage({
    super.key,
    required this.folderName,
    required this.mailTexts,
    required this.mailadress,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 222, 222, 222),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: MediaQuery.of(context).padding.top,
                color: Colors.black,
              ),
              TreeMailAdressDisplay(folder: folderName, myAdress: mailadress),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      AllMailDetail(body: mailTexts, myAdress: mailadress),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TreeMailAdressDisplay extends StatefulWidget {
  const TreeMailAdressDisplay(
      {super.key, required this.folder, required this.myAdress});
  final String folder;
  final String myAdress;
  @override
  MailAdressState createState() => MailAdressState();
}

class MailAdressState extends State<TreeMailAdressDisplay> {
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
                    widget.folder.isEmpty ? '' : widget.folder,
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
                    widget.myAdress.isEmpty ? '' : widget.myAdress,
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

class AllMailDetail extends StatefulWidget {
  const AllMailDetail({super.key, required this.body, required this.myAdress});
  final List<Map<String, dynamic>> body;
  final String myAdress;
  @override
  AllMailDetailState createState() => AllMailDetailState();
}

class AllMailDetailState extends State<AllMailDetail> {
  late List<Map<String, dynamic>> mailFolderList;
  bool isInitialized = false; // 初期化フラグ

  @override
  void initState() {
    super.initState();
    mailFolderList =
        widget.body.map((item) => Map<String, dynamic>.from(item)).toList();
    isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    if (!isInitialized || mailFolderList.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('読み込み中...')),
      );
    }

    debugPrint('mailFolder $mailFolderList');

    if (mailFolderList.isEmpty) {
      return Scaffold(
        body: Center(child: Text('読み込み中...')),
      );
    }
    return Column(
      children: mailFolderList.asMap().entries.map((entry) {
        int mailNum = entry.key;
        Map<String, dynamic> mailFolder =
            Map<String, dynamic>.from(entry.value);
        debugPrint('mailFolder $mailFolder');
        final String mailFolderName = mailFolder['senderName'] ?? '名前不明';
        bool readCheck = mailFolder['read'];

        String mailAddressName = mailFolder['senderEmail'];

        for (int i = 0; i < contactAddress.length; i++) {
          var contact = contactAddress[i];
          debugPrint(('${contact['mail']})  $mailAddressName'));
          if (('${contact['mail']}') == mailAddressName) {
            mailAddressName = ('${contact['name']}');
            debugPrint('一致するアドレスが見つかりました！');
            break;
          }
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: screenWidth * 0.25,
              width: double.infinity,
              color: const Color.fromARGB(255, 255, 255, 255),
              child: SizedBox(
                child: TextButton(
                  style: TextButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    // 左右に少し余白を持たせる（文字が端に寄りすぎないよう調整）
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                  ),
                  onPressed: () {
                    debugPrint('${mailFolder['senderName']} を選択しました');

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MailDetailPage(
                          mailName: mailAddressName,
                          mailFolderData: mailFolder,
                          myemail: widget.myAdress,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.08,
                        child: Checkbox(
                          value: mailFolderList[mailNum]['checked'] ?? false,
                          onChanged: (bool? value) {
                            setState(() {
                              mailFolderList[mailNum]['checked'] =
                                  value ?? false;
                            });
                            debugPrint(
                                '$mailNum 番目のメール: $mailFolderName を ${value! ? "選択" : "解除"}');
                          },
                        ),
                      ),
                      SizedBox(
                        child: Column(
                          children: [
                            SizedBox(
                              height: screenWidth * 0.03,
                              width: screenWidth * 0.04,
                            ),
                            if (readCheck == false)
                              Container(
                                height: screenWidth * 0.04,
                                width: screenWidth * 0.04,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 33, 174, 255),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: screenWidth * 0.02,
                          ),
                          SizedBox(
                            width: screenWidth * 0.8,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  mailAddressName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  mailFolder['date'],
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 114, 114, 114),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Text(
                            mailFolder['subject'] ?? '件名なし',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(
                            height: screenWidth * 0.01,
                          ),
                          SizedBox(
                            width: screenWidth * 0.8,
                            child: Text(
                              mailFolder['body'] ?? 'テキスト無し',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: screenWidth * 0.005,
              width: screenWidth,
            ),
          ],
        );

        /*return Text(
          '$mailNum: ${mailFolder.toString()}',
        );*/
      }).toList(),
    );
  }
}
