import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
    // ignore: unused_field
    late double  _deviceWidth  ;
    late double  _deviceHeight ;
    
      


  @override
  Widget build(BuildContext context) {
     _deviceWidth = MediaQuery.of(context).size.width;
     _deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: _loginPageUI(),
    );
  }
  Widget _loginPageUI() {
    return Container(
      alignment: Alignment.center,
      color: Colors.deepPurpleAccent,
      child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:<Widget>[
                  _headingWidget()
                ],
      )

    );
  }
  Widget _headingWidget() {
    return Container(
      height: _deviceHeight * 0.12,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Text(
            "Welcome Back",
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Please login to your account",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
