import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import './Auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'MainPage.dart';
void main() {
  runApp(MyApp());
}
final storage = new FlutterSecureStorage();

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  bool isloggedin = false;
  String token = "";
  @override
  void initState (){
    super.initState();
    var ans = storage.read(key:"token");
    ans.then((value) =>
      {foundToken(value)})
    .catchError((error) => {print(error)});
  }
  loggedIn(){
    setState(() {
      isloggedin=true;
    });
    var ans = storage.read(key:"token");
    ans.then((value) =>
    {foundToken(value)})
        .catchError((error) => {print(error)});

  }
  foundToken(String value){
    if(value!=null)
    setState((){
      token=value;
      isloggedin=true;
    });
    else
      setState(() {
        token="";
        isloggedin=false;
      });
  }
  logOut(){
    storage.deleteAll();
    setState((){
      token="";
      isloggedin=false;
    });
  }
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: isloggedin?MainPage(inpData:isloggedin,logOut:logOut,token: token,):MyLoginPage(onSuccess:loggedIn
    ),
    );
  }
}
