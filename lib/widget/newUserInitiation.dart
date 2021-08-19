import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

newUserInitiation({User? user}) {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference groups = FirebaseFirestore.instance.collection('groups');
  user ??= FirebaseAuth.instance.currentUser;
  DocumentReference setGroupRef = groups.doc(user!.uid);
  DocumentReference setUserRef = users.doc(user.uid);

  users
      .doc(user.uid)
      .set({
        "displayname": user.displayName,
        "email": user.email,
        "groupAdminOf": [setGroupRef],
        "groups": [setGroupRef]
      })
      .then((value) => print("User Added"))
      .catchError((error) => print("Failed to add user: $error"));
  groups
      .doc(user.uid)
      .set({
        "displayname": "Personal",
        "groupAdmin": setUserRef,
        "private": true,
        "users": [setUserRef]
      })
      .then((value) => print("Default Group Added"))
      .catchError((error) => print("Failed to add group: $error"));
}
