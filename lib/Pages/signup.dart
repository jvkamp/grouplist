import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouplist/Pages/loginPage.dart';
import 'package:grouplist/Pages/mainPage.dart';
import 'package:grouplist/Pages/welcomePage.dart';
import 'package:grouplist/Widget/authenticationHandlers.dart';
import 'package:grouplist/Widget/bezierContainer.dart';

///SignUpPage creates a form with name, email, and password to create a new user
class SignUpPage extends StatefulWidget {
  SignUpPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

final GlobalKey<FormState> _signInKey = GlobalKey<FormState>();
TextEditingController? _emailController;
TextEditingController? _passwordController;
TextEditingController? _nameController;

class _SignUpPageState extends State<SignUpPage> {
  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nameController = TextEditingController();
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
                  return 'Please enter a display name that will be visible in your shared lists';
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
    Map<String, TextEditingController> controllers = {
      "email": _emailController!,
      "password": _passwordController!,
      "name": _nameController!
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
            String? result;
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: FutureBuilder(
                        future: signInWith("Email", context, _signInKey,
                            controllers: controllers),
                        builder: (context, AsyncSnapshot<String> snapshot) {
                          if (!snapshot.hasData) {
                            return SizedBox(
                                width: 20,
                                height: 20,
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
                          return MaterialButton(
                              child: Text("Ok"),
                              onPressed: () {
                                Navigator.pop(context);
                              });
                        },
                      ),
                    ],
                  );
                });
          },
          child: Text(
            'Register Now',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ));
  }

  Widget _loginAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 15),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Already have an account ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Login',
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

  Widget _title() {
    return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: 'GroupList',
          style: GoogleFonts.sansita(
            textStyle: Theme.of(context).textTheme.headline2,
            color: Colors.black,
            shadows: <Shadow>[
              Shadow(
                offset: Offset(1.0, 1.0),
                blurRadius: 30,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ],
          ),
        ));
  }

  Widget _emailPasswordWidget() {
    return Form(
        key: _signInKey,
        child: Column(
          children: <Widget>[
            _entryField("Name", _nameController),
            _entryField("Email Address", _emailController),
            _entryField("Password", _passwordController, isPassword: true),
          ],
        ));
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
                      signInWith("Google", context, _signInKey);
                    },
                    child: Image(
                        image: AssetImage(
                            'lib/Assets/google_signin_normal_dark.png')))),
            Container(
              width: 10,
              height: 20,
            ),
            Flexible(
                fit: FlexFit.tight,
                child: MaterialButton(
                    onPressed: () {
                      signInWith("Apple", context, _signInKey);
                    },
                    child: Image(
                        image: AssetImage(
                            'lib/Assets/apple_signin_white_wborder.png')))),
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

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
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
                    SizedBox(height: height * .18),
                    Hero(tag: 'titleHero', child: _title()),
                    SizedBox(
                      height: 30,
                    ),
                    _emailPasswordWidget(),
                    SizedBox(
                      height: 20,
                    ),
                    _submitButton(),
                    SizedBox(
                      height: 5,
                    ),
                    _divider(),
                    _altLogin(),
                    _loginAccountLabel(),
                  ],
                ),
              ),
            ),
            Positioned(top: 40, left: 0, child: _backButton()),
          ],
        ),
      ),
    );
  }
}
