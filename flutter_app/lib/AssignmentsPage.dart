import 'package:flutter_app/submit.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'Logic.dart';
import 'submit.dart';

class AssignmentItem extends StatelessWidget {
  final AssignmentDetails assignment;
  final String token;
  final int userId;
  final int assignmentId;
  AssignmentItem({Key key, @required this.assignment, this.token, this.userId, this.assignmentId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return (Container(
        
        
        child: Column(
          children: [
            Text('Course Id:' + assignment.courseId.toString()),
            Text('Assignemnt Name:' + assignment.name),
            Text('Assignment Id:' + assignment.id.toString()),
            Text('Assignment Due in days:' +  (DateTime.fromMillisecondsSinceEpoch(assignment.duedate*1000,isUtc: true)).difference(DateTime.now()).inDays.toString()),
            Text('Assignment Completed?:' + assignment.completed.toString()),
            RaisedButton(onPressed: (){ 
              checkAssignmentSubmission(token,userId,assignmentId).then((value) => {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SubmitPage(token:token,assignmentId:assignmentId, userId: userId,submitted: value,);}))
              });}
            
            ,
            child:Text('Submitt Assignment'))
          ],
        )
        
        
        ));
  }
}

List<Widget> renderAssignments(List<AssignmentDetails> myAss,String token, int userId) {
  List<Widget> list = new List<Widget>();
  for (var i = 0; i < myAss.length; i++) {
    list.add(new AssignmentItem(assignment:myAss[i],token:token,userId: userId,assignmentId: myAss[i].id));
  }
  return list;
}


class AssignmentViewScreen extends StatefulWidget {
  final String token;
  final int courseId;
  final int userId;

  AssignmentViewScreen({this.token, this.courseId, this.userId});
  @override
  _AssignmentViewScreenState createState() => _AssignmentViewScreenState();
}

class _AssignmentViewScreenState extends State<AssignmentViewScreen> {
  AssignmentsofCourse myAss= new AssignmentsofCourse();
  bool loaded = false;
  @override
  void initState() {
    super.initState();
    getAssignments(widget.token, widget.courseId)
        .then((value) => {
              setState(() {
                myAss = value;
                if(value.assignments.length>0)
                loaded = true;

              })
            })
        .catchError((err) => {print(err)});
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      appBar: AppBar(
        title: Text("Course:" + myAss.courseName),
      ),
      body: Container(
        child: SingleChildScrollView(
          child:
        Column(
          children: loaded?renderAssignments(myAss.assignments,widget.token,widget.userId):[Text("No assignments in this course")],
        
      )
      ),
    ))
    );
  }
}
