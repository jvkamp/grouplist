import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouplist/Pages/mainPage.dart';
import 'package:grouplist/Pages/signup.dart';
import 'package:grouplist/Pages/welcomePage.dart';
import 'package:grouplist/Widget/authenticationHandlers.dart';
import 'package:grouplist/Widget/bezierContainer.dart';

///LoginPage features a form with email and password, or Google and Apple as
///alt logins
class LoginPage extends StatefulWidget {
  LoginPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AssetImage apple = AssetImage('lib/Assets/apple_signin_white_wborder.png');
  AssetImage google = AssetImage('lib/Assets/google_signin_normal_light.png');
  TextEditingController? _emailController;
  TextEditingController? _passwordController;
  GlobalKey<FormState> _logInKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => WelcomePage()));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            Text('Back',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  Widget _entryField(String title, TextEditingController? controller,
      {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your email and password';
                }
                return null;
              },
              controller: controller,
              obscureText: isPassword,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget _submitButton() {
    Map<String, TextEditingController?> controllers = {
      "email": _emailController,
      "password": _passwordController
    };
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.shade200,
                  offset: Offset(2, 4),
                  blurRadius: 5,
                  spreadRadius: 2)
            ],
            gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF7272AB), Color(0xFF700548)])),
        child: MaterialButton(
          onPressed: () {
            if (_logInKey.currentState!.validate()) {
              String? result;
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: FutureBuilder(
                          future: signInWith("Email", context, _logInKey,
                              controllers: controllers
                                  as Map<String, TextEditingController>),
                          builder: (context, AsyncSnapshot<String> snapshot) {
                            if (!snapshot.hasData) {
                              return SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CircularProgressIndicator());
                            }
                            return Text(snapshot.requireData);
                          }),
                      actions: [
                        Builder(
                          builder: (context) {
                            if (result == "Success") {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomePage()));
                            }
                            return TextButton(
                                child: Text("Ok"),
                                onPressed: () {
                                  Navigator.pop(context);
                                });
                          },
                        ),
                      ],
                    );
                  });
            }
          },
          child: Text(
            'Login',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ));
  }

  Widget _createAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => SignUpPage()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Don\'t have an account ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Register',
              style: TextStyle(
                  color: Color(0xFF700548),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _altLogin() {
    return Container(
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.bottomCenter,
        height: 50,
        child: Row(
          children: [
            Flexible(
                fit: FlexFit.tight,
                child: MaterialButton(
                    onPressed: () {
                      signInWith("Google", context, _logInKey);
                    },
                    child: Image(image: google))),
            Container(
              width: 10,
              height: 20,
            ),
            Flexible(
                fit: FlexFit.tight,
                child: MaterialButton(
                    onPressed: () {
                      signInWith("Apple", context, _logInKey);
                    },
                    child: Image(image: apple))),
          ],
        ));
  }

  Widget _divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          SizedBox(width: 20, height: 2),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text('or'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          SizedBox(width: 20, height: 2),
        ],
      ),
    );
  }

  Widget _title() {
    return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: 'GroupList',
          style: GoogleFonts.sansita(
              textStyle: Theme.of(context).textTheme.headline2,
              color: Colors.black),
        ));
  }

  Widget _emailPasswordWidget() {
    return Form(
        key: _logInKey,
        child: Column(
          children: <Widget>[
            _entryField("Email Address", _emailController),
            _entryField("Password", _passwordController, isPassword: true),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
    return Scaffold(
        key: _scaffoldKey,
        body: Container(
          height: height,
          child: Stack(
            children: <Widget>[
              Positioned(
                  top: -height * .15,
                  right: MediaQuery.of(context).size.width * .45,
                  child: BezierContainer()),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: height * .2),
                      Hero(tag: 'titleHero', child: _title()),
                      SizedBox(height: 50),
                      _emailPasswordWidget(),
                      SizedBox(height: 20),
                      _submitButton(),
                      Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.centerRight,
                          child: TextButton(
                              onPressed: () async {
                                await resetPassword(context, _emailController!,
                                    _logInKey, _scaffoldKey);

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                        duration: Duration(seconds: 4),
                                        content: Row(children: <Widget>[
                                          CircularProgressIndicator(),
                                          Text(
                                              "  Sending password reset email..."),
                                        ])));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  duration: Duration(seconds: 1),
                                  content: Text("Sent!"),
                                ));
                              },
                              child: Text('Forgot Password ?',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)))),
                      _divider(),
                      _altLogin(),
                      SizedBox(height: 10),
                      _createAccountLabel(),
                    ],
                  ),
                ),
              ),
              Positioned(top: 40, left: 0, child: _backButton()),
            ],
          ),
        ));
  }
}
