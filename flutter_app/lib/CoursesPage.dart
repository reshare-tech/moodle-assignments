import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'Logic.dart';
import 'AssignmentsPage.dart';
class CourseItem extends StatelessWidget {
  final CourseDetails course;
  final int courseId;
  final String token;
  final int userId;
  CourseItem({Key key, @required this.course,@required this.token,@required this.courseId, @required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            Text('Course Id:' + course.id.toString()),
            Text('Course Name:' + course.name),
            Text('Course Summary:' + course.summary),
            RaisedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) {
            return AssignmentViewScreen(token:token,courseId:courseId, userId: userId);
          }));
                
              },child: Text('View Assignments'),)
          ],
        )
        
        ));
  }
}

List<Widget> renderCourses(List<CourseDetails> myCourses, String token,int userId) {
  List<Widget> list = new List<Widget>();
  for (var i = 0; i < myCourses.length; i++) {
    list.add(new CourseItem(course: myCourses[i],token:token,courseId: myCourses[i].id,userId: userId,));
  }
  return list;
}

class AssignmentScreen extends StatefulWidget {
  final String token;
  final int userId;

  AssignmentScreen({this.token, this.userId});
  @override
  _AssignmentScreenState createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  String coursesDetails = "Details loading...";
  String nCourses = '0';
  List<CourseDetails> myCourses = new List<CourseDetails>();
  void initState() {
    super.initState();
    getCoursesDetails(widget.token, widget.userId)
        .then((value) => {
              setState(() {
                nCourses = value.length.toString();
                myCourses = value;
              })
            })
        .catchError((err) => {print(err)});
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      appBar: AppBar(
        title: Text("No. of enrolled couses:" + nCourses),
      ),
      body: Container(
          child: Column(children: [
        Column(
          children: renderCourses(myCourses,widget.token,widget.userId),
        ),
      ])),
    ));
  }
}
