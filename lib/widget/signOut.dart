import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grouplist/Pages/welcomePage.dart';

Future<void> signOut(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (BuildContext context) => WelcomePage()));
}
