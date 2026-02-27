import 'package:flutter/material.dart';

class MailCheckPage extends StatelessWidget {
  final String folderName;
  final List<Map<String, String>> mailTexts;
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
                      AllMailDetail(body: mailTexts),
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
  const AllMailDetail({super.key, required this.body});
  final List<Map<String, dynamic>> body;
  @override
  AllMailDetailState createState() => AllMailDetailState();
}

class AllMailDetailState extends State<AllMailDetail> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (widget.body.isEmpty) {
      return Scaffold(
        body: Center(child: Text('読み込み中...')),
      );
    }
    return Column(
      children: widget.body.asMap().entries.map((entry) {
        int mailNum = entry.key;
        Map<String, dynamic> mailFolder = entry.value;
        final String mailFolderName = mailFolder['name'] ?? '名前なし';

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
                    debugPrint('${mailFolder['name']} を選択しました');
                  },
                  child: Row(
                    children: [
                      Checkbox(
                        value: mailFolder['checked'] ?? false,
                        onChanged: (bool? value) {
                          setState(() {
                            // インデックスを使ってリストの中身を更新
                            widget.body[mailNum]['checked'] = value ?? false;
                          });
                          debugPrint(
                              '$mailNum 番目のメール: $mailFolderName を ${value! ? "選択" : "解除"}');
                        },
                      ),
                      Text(
                        mailFolder['name'] ?? '名前不明',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
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
