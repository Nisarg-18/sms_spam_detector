import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MessageDetails extends StatefulWidget {
  final message, contact;
  const MessageDetails({
    Key? key,
    required this.message,
    required this.contact,
  }) : super(key: key);

  @override
  State<MessageDetails> createState() => _MessageDetailsState();
}

class _MessageDetailsState extends State<MessageDetails> {
  bool isLoading = true;
  var pred;
  predict() async {
    try {
      var response = await http.post(
        Uri.parse('https://spam-detection-fastapi.herokuapp.com/predict'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'input_sms': widget.message.body,
        }),
      );
      var jsonData = jsonDecode(response.body);
      setState(() {
        pred = jsonData['prediction'];
      });
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    this.predict();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Message Details'),
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
                  Text('Scanning your message...')
                ],
              ),
            )
          : Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Message',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    Center(
                      child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: Text(
                            widget.message.body,
                            textAlign: TextAlign.justify,
                          )),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'From',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    widget.contact == ''
                        ? SizedBox(
                            height: 0,
                            width: 0,
                          )
                        : Align(
                            alignment: Alignment.topLeft,
                            child: Text(widget.contact)),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.005,
                    ),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text(widget.message.address)),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    pred == 'Ham'
                        ? Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.lightGreen[100],
                            ),
                            child: Text(
                              'Prediction: $pred',
                              style: TextStyle(
                                color: Colors.green[900],
                                fontSize: 18,
                              ),
                            ))
                        : Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.red[100],
                            ),
                            padding: EdgeInsets.all(8),
                            child: Text(
                              'Prediction: $pred',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 18,
                              ),
                            ))
                  ],
                ),
              ),
            ),
    );
  }
}
