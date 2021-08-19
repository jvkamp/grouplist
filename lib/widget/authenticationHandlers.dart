import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:grouplist/Pages/mainPage.dart';
import 'package:grouplist/Widget/returnErrorCodeMessage.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

Future<String> signInWith(
    String method, BuildContext context, GlobalKey<FormState> formKey,
    {Map<String, TextEditingController> controllers = const {}}) async {
  String check = "Error - Not Found";
  if (method == "Google") {
    check = await _google().catchError((e) {
      return showExceptions(e);
    });
  } else if (method == "Apple") {
    check = await _apple().catchError((e) {
      return showExceptions(e);
    });
  } else if (method == "Email") {
    if (formKey.currentState!.validate()) {
      check = await _email(controllers["email"]!, controllers["password"]!,
              controllers["name"] as TextEditingController)
          .catchError((e) {
        return showExceptions(e);
      });
    } else {
      controllers["password"]!.value = TextEditingValue.empty;
      return check;
    }
  }
  if (check == "Success") {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => HomePage()));
    controllers.forEach((key, value) {
      value.value = TextEditingValue.empty;
    });
    return check;
  }

  controllers["password"]!.value = TextEditingValue.empty;

  return check;
}

Future<String> _email(TextEditingController email,
    TextEditingController password, TextEditingController name) async {
  final String nameField = name.text.trim();
  final String emailField = email.text.trim();
  final String passwordField = password.text;
  if (name == "") {
    return await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: emailField, password: passwordField)
        .then((value) => "Success")
        .catchError((e) {
      return showExceptions(e);
    });
  } else {
    return await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: emailField, password: passwordField)
        .then((value) => "Success")
        .catchError((e) {
          return showExceptions(e);
        })
        .whenComplete(() => auth.currentUser!.updateDisplayName(nameField))
        .catchError((e) {
          return showExceptions(e);
        });
  }
}

Future<String> _google() async {
  final GoogleSignInAccount googleUser =
      await (GoogleSignIn().signIn().catchError((e) {
    return Future<GoogleSignInAccount?>(e);
  }) as FutureOr<GoogleSignInAccount>);

  // Obtain the auth details from the request
  final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication.catchError((e) {
    return Future<GoogleSignInAuthentication>(e);
  });

  // Create a new credential
  final GoogleAuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  ) as GoogleAuthCredential;

  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance
      .signInWithCredential(credential)
      .then((UserCredential value) => "Success")
      .catchError((e) {
    return showExceptions(e);
  });
}

Future<String> _apple() async {
  // To prevent replay attacks with the credential returned from Apple, we // include a nonce in the credential request. When signing in in with // Firebase, the nonce in the id token returned by Apple, is expected to // match the sha256 hash of `rawNonce`.
  final rawNonce = generateNonce();
  final nonce = sha256ofString(rawNonce);

  // Request credential for the currently signed in Apple account.
  final appleCredential = await SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
    nonce: nonce,
  ).catchError((e) {
    return Future<AuthorizationCredentialAppleID>(e);
  });

  // Create an `OAuthCredential` from the credential returned by Apple.
  final oauthCredential = OAuthProvider("apple.com").credential(
    idToken: appleCredential.identityToken,
    rawNonce: rawNonce,
  );

  // Sign in the user with Firebase. If the nonce we generated earlier does not match the nonce in `appleCredential.identityToken`, sign in will fail.
  String success = "Error";
  success = await FirebaseAuth.instance
      .signInWithCredential(oauthCredential)
      .then((UserCredential value) => "Success")
      .catchError((e) {
    return showExceptions(e);
  });

  return success;
}

String generateNonce([int length = 32]) {
  final charset =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();
  return List.generate(length, (_) => charset[random.nextInt(charset.length)])
      .join();
}

/// Returns the sha256 hash of [input] in hex notation.
String sha256ofString(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

Future<void> resetPassword(BuildContext context, TextEditingController email,
    GlobalKey<FormState> _formKey, GlobalKey<ScaffoldState> _snackKey) async {
  String emailField;
  if (email.text == "") {
    emailField = await requestEmail(context)
        .then((value) => value!.trim())
        .catchError((e) {
      showExceptions(e);
      return Future<String>.error(e.toString());
    });
  } else {
    emailField = email.text.trim();
  }
  try {
    return await sendPasswordResetEmail(context, emailField);
  } catch (e) {
    showExceptions(e);
    return null;
  }
}

Future<void> sendPasswordResetEmail(BuildContext context, String email) async {
  return FirebaseAuth.instance
      .sendPasswordResetEmail(email: email)
      .catchError((e) async {
    email = await requestEmail(context).then((value) => value!.trim());
    return await FirebaseAuth.instance
        .sendPasswordResetEmail(email: email)
        .catchError((e) {
      showExceptions(e);
      return null;
    });
  });
}

String? requestedEmail;

Future<String?> requestEmail(BuildContext context) async {
  await emailForm(context);
  return requestedEmail ?? null;
}

Future<String?> emailForm(BuildContext context) async {
  final controller = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text("Enter Your Email:"),
            content: Form(
                key: _formKey,
                child: Container(
                  constraints: BoxConstraints(maxHeight: 300),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        controller: controller,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(children: [
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                requestedEmail = controller.text;
                                controller.clear();
                                Navigator.pop(context);
                              }
                            },
                            child: Text('Submit'),
                          ),
                          SizedBox(width: 15),
                          ElevatedButton(
                            onPressed: () {
                              requestedEmail = null;
                              controller.clear();
                              Navigator.pop(context);
                            },
                            child: Text('Cancel'),
                          )
                        ]),
                      ),
                    ],
                  ),
                )));
      });
}
