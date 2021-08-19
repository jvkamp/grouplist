import 'package:firebase_auth/firebase_auth.dart';

String showExceptions(e) {
  print("Error From showExceptions:   " + e.toString());
  if (e.runtimeType == FirebaseAuthException) {
    print(e.code);
  }
  return e.toString();
}
