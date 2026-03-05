import 'package:flutter/material.dart';

import 'package:red_mail/mailTree.dart';

class MailDetailPage extends StatelessWidget {
  final String mailName;
  final Map<String, dynamic> mailFolderData;
  final String myemail;

  // コンストラクタ（窓口）
  const MailDetailPage({
    super.key,
    required this.mailName,
    required this.mailFolderData,
    required this.myemail,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('mailFolder $mailFolderData');
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
              DetailMailAdressDisplay(emailSubject: mailFolderData['subject']),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [],
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
  final String emailSubject;
  @override
  DetailMailAdressState createState() => DetailMailAdressState();
}

class DetailMailAdressState extends State<DetailMailAdressDisplay> {
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
                    widget.emailSubject,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 19,
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
