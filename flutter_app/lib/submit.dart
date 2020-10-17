import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'Logic.dart';
import 'package:file_picker/file_picker.dart';
import 'CoursesPage.dart';
import 'dart:io';

class SubmitPage extends StatefulWidget {
  //final AssignmentDetails assignment;
  String token;
  int userId;
  int assignmentId;
  bool submitted;
  SubmitPage(
      {Key key, this.token, this.userId, this.assignmentId, this.submitted})
      : super(key: key);
  @override
  _SubmitPageState createState() => _SubmitPageState();
}

class _SubmitPageState extends State<SubmitPage> {
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      appBar: AppBar(
        title: Text("Submit Assignment"),
      ),
      body: Container(
          child: Column(
        children: [
          widget.submitted
              ? Text('Assignment already submitted!')
              : RaisedButton(
                  onPressed: (() async {
                    print('pressed');
                    FilePickerResult result =
                        await FilePicker.platform.pickFiles();

                    if (result != null) {
                      uploadFile(
                              widget.token,
                              result.files.single.path,
                              result.files.single.name,
                              widget.assignmentId,
                              widget.userId)
                          .then((value) {
                        if (value)
                          Navigator.pop(context);
                        else
                          print('Failed due to some reason');
                      }).catchError((err) {
                        print(err);
                      });
                    }
                  }),
                  child: Text(
                      'Upload a file')) //todo: show accepted filetypes and text sumbission
        ],
      )),
    ));
  }
}
