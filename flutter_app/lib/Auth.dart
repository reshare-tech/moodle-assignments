import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = new FlutterSecureStorage();

class LoginResponse {
  final String error;
  final String success;
  final String token;

  LoginResponse({this.error, this.success, this.token});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      error: json['error'] as String,
      token: json['token'] as String,
    );
  }
}


class MyLoginPage extends StatefulWidget {
  final VoidCallback onSuccess;
  MyLoginPage({this.onSuccess});
  @override
  _MyLoginPageS createState() => _MyLoginPageS();

}
class _MyLoginPageS extends State<MyLoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final serverController = TextEditingController();

  String errText = "";
  void doLogin(String server,String email,String password) async{
    //var url = 'http://' + server +'/login/token.php';
    //String send1 = '{\"email\":\"'+ email+ '\", \"password\":\"'+ password +'\"}';
    //print(send1);
    /*
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json'
    };*/
    //var sede = jsonEncode({"email":email,"password":password});
  Map<String,String> myQuery ={
  'username': email,
  'password': password,
  'service': 'moodle_mobile_app'
};

  var uri = Uri(
  scheme: 'http',
  host: '192.168.100.184',
  port:80,
  path: '/moodle/login/token.php',
  queryParameters:myQuery,
  );

var response = await http.post(uri);
    
    Map<String, dynamic> resp = jsonDecode(response.body);
    LoginResponse lr = new LoginResponse.fromJson(resp);
    print(lr.token);
    
    if(lr.error == null){
      print("Cool");
      await storage.deleteAll();
      await storage.write(key: "token", value: lr.token);
      widget.onSuccess();
    }
    else{
      setState(() {
        errText=lr.error;
      });
    }
    return;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

        appBar: AppBar(
          title: const  Text("Login"),
        ),
        body: Container(
          child: Column(
            children: [
              TextField(
                controller: serverController,
                decoration: InputDecoration(
                    hintText: "Moodle server address"
                ),),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                    hintText: "Username"
                ),),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                    hintText: "Password"
                ),),
              RaisedButton(
                  onPressed: (){
                    print("server:"+serverController.text+"email:"+emailController.text+ "\npassword:"+ passwordController.text);
                    doLogin(serverController.text,emailController.text, passwordController.text);
                  },
                  color: Colors.yellow,
                  child:Text(
                      "Login"
                  )
              ),
              Text(errText)
            ],
          ),
        )
    );

  }
}


