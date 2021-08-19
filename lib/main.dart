import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouplist/Pages/loadingPage.dart';
import 'package:grouplist/Pages/mainPage.dart';
import 'package:grouplist/routes/pageRoute.dart';
import 'package:shared_preferences/shared_preferences.dart';

///Main initializes the app and sets app colors and other defaults
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await waitForFirebase();
  runApp(App());
}

User? fireUser = FirebaseAuth.instance.currentUser;
DocumentReference fireUserRef = FirebaseFirestore.instance
    .collection('users')
    .doc(FirebaseAuth.instance.currentUser!.uid);

Future<void> waitForFirebase() async {
  await Firebase.initializeApp();
  var count = 0;
  await for (var user in FirebaseAuth.instance.authStateChanges()) {
    user = user;
    count += 1;
    if (count >= 1) break;
  }
}

setCurrentPageState(String page) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("currentPage", page);
}

Future<String> getCurrentPageState() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String page = prefs.getString("currentPage") ?? PageRoutes.groups;
  return page;
}

class UserData {
  final String? displayName = fireUserRef
      .get()
      .then((value) => (value.data() as DocumentSnapshot)['displayName'])
      .toString();
  final User? user = fireUser;
  final String email = fireUserRef
      .get()
      .then((value) => (value.data() as DocumentSnapshot)['email'])
      .toString();
  final List<DocumentReference> groupRef = fireUserRef
          .get()
          .then((value) => value.get('groups')) as List<DocumentReference>? ??
      [];
  final List<DocumentReference> groupAdminOfRef =
      fireUserRef.get().then((value) => value.get('groupAdminOf'))
              as List<DocumentReference>? ??
          [];
}

class Palette {
  static const Color primary = Color(0xFF700548);
}

MaterialColor generateMaterialColor(Color color) {
  return MaterialColor(color.value, {
    50: tintColor(color, 0.9),
    100: tintColor(color, 0.8),
    200: tintColor(color, 0.6),
    300: tintColor(color, 0.4),
    400: tintColor(color, 0.2),
    500: color,
    600: shadeColor(color, 0.1),
    700: shadeColor(color, 0.2),
    800: shadeColor(color, 0.3),
    900: shadeColor(color, 0.4),
  });
}

int tintValue(int value, double factor) =>
    max(0, min((value + ((255 - value) * factor)).round(), 255));

Color tintColor(Color color, double factor) => Color.fromRGBO(
    tintValue(color.red, factor),
    tintValue(color.green, factor),
    tintValue(color.blue, factor),
    1);

int shadeValue(int value, double factor) =>
    max(0, min(value - (value * factor).round(), 255));

Color shadeColor(Color color, double factor) => Color.fromRGBO(
    shadeValue(color.red, factor),
    shadeValue(color.green, factor),
    shadeValue(color.blue, factor),
    1);

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        // Initialize FlutterFire:
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          return FutureBuilder(
              future: getCurrentPageState(),
              builder: (context, page) {
                // Check for errors, reinitialize if there are any
                if (snapshot.hasError) {
                  return App();
                }

                // Once complete, show application
                if (snapshot.connectionState == ConnectionState.done &&
                    page.connectionState == ConnectionState.done) {
                  return MaterialApp(
                      home: HomePage(
                        state: BuildInfo(pageRoute: page.toString()),
                      ),
                      title: "GroupList",
                      themeMode: ThemeMode.system,
                      theme: ThemeData(
                          fontFamily: GoogleFonts.roboto().fontFamily,
                          primaryColor: Color(0xFF700548),
                          primaryColorDark: Color(0xFF400021),
                          primaryColorLight: Color(0xFFa23e73),
                          floatingActionButtonTheme:
                              FloatingActionButtonThemeData(
                            backgroundColor: Color(0xFF7798d3),
                          ),
                          secondaryHeaderColor: Color(0xFF7798d3)));
                }

                // Show loading screen while waiting for
                // initialization to complete
                return MaterialApp(
                    home: Loading(),
                    theme: ThemeData(
                      fontFamily: GoogleFonts.roboto().fontFamily,
                      primaryColor: Color(0xFF700548),
                      primaryColorDark: Color(0xFF700548),
                    ));
              });
        });
  }
}
