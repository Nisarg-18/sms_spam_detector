import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sms/contact.dart';
import 'package:sms/sms.dart';
import 'package:sms_spam_detector/screens/messageDetails.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var predication;
  bool isLoading = true;
  SmsQuery query = new SmsQuery();
  // List<String> predList = [];
  List<SmsMessage> messagesList = [];
  List<String> contactList = [];
  // int messageCount = 10;
  // int currentSmsCount = 0;
  // bool noLoad = false;
  // ItemScrollController _scrollController = ItemScrollController();

  getAllSms() async {
    // List<SmsMessage> messages =
    //     await query.querySms(kinds: [SmsQueryKind.Inbox]);
    List<SmsMessage> messages = await query.getAllSms;
    setState(() {
      messagesList = messages;
      // predList = List<String>.filled(messages.length, '');
      contactList = List<String>.filled(messagesList.length, '');
    });
    for (int j = 0; j < messagesList.length; j++) {
      ContactQuery contacts = new ContactQuery();
      Contact contact = await contacts.queryContact(messagesList[j].address);
      if (contact.fullName != null) {
        contactList[j] = contact.fullName;
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  // predict() async {
  //   for (int j = currentSmsCount; j < messageCount; j++) {
  //     try {
  //       var response = await http.post(
  //         Uri.parse('https://spam-detection-fastapi.herokuapp.com/predict'),
  //         headers: {
  //           'Content-Type': 'application/json',
  //         },
  //         body: json.encode({
  //           'input_sms': messagesList[j].body,
  //         }),
  //       );
  //       var jsonData = jsonDecode(response.body);
  //       setState(() {
  //         predList[j] = jsonData['prediction'];
  //       });
  //     } catch (e) {
  //       print('error: $e');
  //     }
  //   }
  //   setState(() {
  //     isLoading = false;
  //   });
  // }

  // loading() async {
  //   await getAllSms();
  //   predict();
  // }

  @override
  void initState() {
    super.initState();
    this.getAllSms();
    // this.predict();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SMS Spam Detector'),
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Text('Loading your messages...')
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                      child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: messagesList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return MessageDetails(
                                        message: messagesList[index],
                                        contact: contactList[index],
                                      );
                                    }));
                                  },
                                  title: Text(
                                    messagesList[index].body,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: contactList[index] == ''
                                      ? Text(messagesList[index].address)
                                      : Text(contactList[index]),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 5),
                                  // trailing: predList[index] == 'Ham'
                                  //     ? Container(
                                  //         padding: EdgeInsets.all(8),
                                  //         decoration: BoxDecoration(
                                  //           borderRadius:
                                  //               BorderRadius.circular(5),
                                  //           color: Colors.lightGreen[100],
                                  //         ),
                                  //         child: Text(
                                  //           predList[index],
                                  //           style: TextStyle(
                                  //             color: Colors.green[900],
                                  //           ),
                                  //         ))
                                  //     : Container(
                                  //         decoration: BoxDecoration(
                                  //           borderRadius:
                                  //               BorderRadius.circular(5),
                                  //           color: Colors.red[100],
                                  //         ),
                                  //         padding: EdgeInsets.all(8),
                                  //         child: Text(
                                  //           predList[index],
                                  //           style: TextStyle(
                                  //             color: Colors.red,
                                  //           ),
                                  //         ))
                                ),
                              ),
                            );
                          })),
                  // !noLoad
                  //     ? ElevatedButton(
                  //         onPressed: () async {
                  //           setState(() {
                  //             currentSmsCount += 10;
                  //             messageCount += 10;
                  //             if (messageCount > messagesList.length) {
                  //               messageCount = messagesList.length;
                  //               noLoad = true;
                  //             }
                  //             isLoading = true;
                  //           });

                  //           await predict();
                  //         },
                  //         child: Text('Load More'))
                  //     : SizedBox(
                  //         height: 0,
                  //         width: 0,
                  //       )
                ],
              ),
            ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     _scrollController.scrollTo(
      //         index: 0,
      //         duration: Duration(seconds: 2),
      //         curve: Curves.easeInOutCubic);
      //   },
      // ),
    );
  }
}
