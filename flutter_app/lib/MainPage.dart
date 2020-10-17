import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'Logic.dart';
import 'CoursesPage.dart';

class MainPage extends StatefulWidget {
  final bool inpData;
  final VoidCallback logOut;
  final String token;
  MainPage({this.inpData,this.logOut,this.token});
  @override
  _MainPageState createState() => _MainPageState();
}


class _MainPageState extends State<MainPage> {
 String siteName = "SiteName";
 String fullName = "fullName";
 int userId = -1;
void initState (){
    super.initState();
    getDetails(widget.token).then(
      (value) => {setState((){
        siteName = value.sitename;
        fullName = value.fullname;
        userId = value.userId;
      }) }
    ).catchError((err)=>{print(err)});
    
  }
  @override
  Widget build(BuildContext context){
    return(
    Scaffold(
      appBar: AppBar(
        title: Text( "Welcome to the app"),
      ),
      body: Container(
        child:Column(
          children: [
            Text("site: "+ siteName),
            Text("User full Name: "+ fullName),
            Text("User Id: "+ userId.toString()),
            RaisedButton(
              child: Text("Get Courses"),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) {
            return AssignmentScreen(token:widget.token,userId:userId);
          }));
                
              },
            ),
            RaisedButton(
              child: Text("Logout"),
              onPressed: ()async{
                print("Try to log out !!!!!");
                widget.logOut();
              },
            )
          ],
        )
      ),
    )
    );
  }
}