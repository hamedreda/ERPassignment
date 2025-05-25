import 'package:flutter/material.dart';
import 'AdminPage.dart';
import 'UserPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _UsernameController = TextEditingController();
  final _PasswordController = TextEditingController();
  final String AdminUsername = "admin";
  final String AdminPassword = "0000";
  final String UserUsername = "user";
  final String UserPassword = "1111";
  void _login(String username,String password){
    if(username ==AdminUsername && password ==AdminPassword)
      Navigator.push(context, MaterialPageRoute(builder: (context)=>AdminPage()));
    else if(username ==UserUsername && password ==UserPassword)
      Navigator.push(context, MaterialPageRoute(builder: (context)=>UserPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // leading: IconButton(onPressed: (){}, icon: Icon(Icons.dark_mode),),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "StockWise",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  )
              ),
              SizedBox(height: 60,),
              Text("LOGIN",style: TextStyle(fontSize: 40),),
              Padding(
                padding: EdgeInsets.all(20),
                child:
                Card(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(40,20,40,20),
                      child: Column(
                        children: [
                          TextField(
                            decoration: InputDecoration(labelText: "username"),
                            controller: _UsernameController,
                          ),
                          TextField(
                            decoration: InputDecoration(labelText: "password"),
                            controller: _PasswordController,
                            obscureText: true,
                          ),
                          SizedBox(height: 30,)
                        ],
                      ),
                    )
                ),
              ),
              ElevatedButton(onPressed: ()=>_login(_UsernameController.text,_PasswordController.text), child: Text("Login"))
            ],
          ),
        )
    );
  }
}
