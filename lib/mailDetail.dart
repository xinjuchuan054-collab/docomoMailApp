import 'package:flutter/material.dart';

import 'package:red_mail/mailTree.dart';

class MailDetailPage extends StatelessWidget {
  final Map<String, dynamic> mailFolderData;
  final String senderAdress;

  // コンストラクタ（窓口）
  const MailDetailPage({
    super.key,
    required this.senderAdress,
    required this.mailFolderData,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('mailFolder $mailFolderData');
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: MediaQuery.of(context).padding.top,
                color: Colors.black,
              ),
              DetailMailAdressDisplay(emailSubject: mailFolderData),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ExpandableSection(
                          body: mailFolderData, displayName: senderAdress),
                      MailDetailSubjectDisplay(body: mailFolderData),
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

class DetailMailAdressDisplay extends StatefulWidget {
  const DetailMailAdressDisplay({super.key, required this.emailSubject});
  final Map<String, dynamic> emailSubject;
  @override
  DetailMailAdressState createState() => DetailMailAdressState();
}

class DetailMailAdressState extends State<DetailMailAdressDisplay> {
  late Map<String, dynamic> mailData;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    mailData = widget.emailSubject;
    debugPrint('maildata -- $mailData');
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
                    mailData['subject'],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
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

class ExpandableSection extends StatefulWidget {
  const ExpandableSection(
      {super.key, required this.body, required this.displayName});
  final Map<String, dynamic> body;
  final String displayName;
  @override
  ExpandableSectionState createState() => ExpandableSectionState();
}

class ExpandableSectionState extends State<ExpandableSection> {
  bool _isExpanded = false;
  late Map<String, dynamic> mailData;

  @override
  Widget build(BuildContext context) {
    mailData = widget.body;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      color: Color.fromARGB(255, 222, 222, 222),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: screenWidth * 0.04),
              SizedBox(
                width: screenWidth * 0.14,
                child: Column(
                  children: [
                    Text(
                      '差出人',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                      ),
                    ),
                    Text('From'),
                  ],
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              SizedBox(
                width: screenWidth * 0.6,
                child: Row(
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                        backgroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03),
                      ),
                      child: Text(
                        widget.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 19,
                        ),
                      ),
                      onPressed: () {},
                    ),
                    Spacer(),
                  ],
                ),
              ),
              SizedBox(
                width: screenWidth * 0.17,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    alignment: Alignment.center,
                    foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    // 左右に少し余白を持たせる（文字が端に寄りすぎないよう調整）
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Text(_isExpanded ? '閉じる' : '詳細'),
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Container(
              width: double.infinity,
              height: _isExpanded ? screenWidth * 0.25 : 0,
              color: Color.fromARGB(255, 222, 222, 222),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  //初期値で隠れているところ
                  SizedBox(
                    height: screenWidth * 0.12,
                    child: Row(
                      children: [
                        SizedBox(width: screenWidth * 0.04),
                        SizedBox(
                          width: screenWidth * 0.14,
                          child: Column(
                            children: [
                              Text(
                                '受信者',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                ),
                              ),
                              Text('To'),
                            ],
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        SizedBox(
                          width: screenWidth * 0.6,
                          child: Row(
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(
                                  alignment: Alignment.centerLeft,
                                  foregroundColor:
                                      const Color.fromARGB(255, 0, 0, 0),
                                  backgroundColor:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.03),
                                ),
                                child: Text(
                                  widget.displayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 19,
                                  ),
                                ),
                                onPressed: () {},
                              ),
                              Spacer(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: screenWidth * 0.12,
                    child: Row(
                      children: [
                        SizedBox(width: screenWidth * 0.04),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: screenWidth * 0.14,
                              child: Text(
                                '件名',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Text(
                          mailData['subject'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                          ),
                        )
                      ],
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

class MailDetailSubjectDisplay extends StatefulWidget {
  const MailDetailSubjectDisplay({super.key, required this.body});
  final Map<String, dynamic> body;
  @override
  MailDetailSubjectState createState() => MailDetailSubjectState();
}

class MailDetailSubjectState extends State<MailDetailSubjectDisplay> {
  late Map<String, dynamic> mailDetailList;
  late String mailSendDateText;

  @override
  Widget build(BuildContext context) {
    mailDetailList = widget.body;
    debugPrint("データの型: ${mailDetailList['date'].runtimeType}");
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Container(
          color: Color.fromARGB(255, 255, 255, 255),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                mailDetailList['date'],
                style: const TextStyle(
                  color: Color.fromARGB(255, 114, 114, 114),
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                ),
              ),
              SizedBox(
                width: screenWidth * 0.01,
              )
            ],
          ),
        ),
        Container(
          color: Color.fromARGB(255, 255, 255, 255),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: screenWidth * 0.04),
                        Expanded(
                          child: Text(
                            mailDetailList['body'],
                            style: TextStyle(fontSize: 25),
                            maxLines: null,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.04),
                      ],
                    ),
                    SizedBox(
                      height: screenWidth * 0.1,
                      width: screenWidth,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
