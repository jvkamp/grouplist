import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grouplist/Pages/contactsPage.dart';
import 'package:grouplist/Pages/groupsPage.dart';
import 'package:grouplist/Pages/listsPage.dart';
import 'package:grouplist/Pages/welcomePage.dart';
import 'package:grouplist/Widget/drawerWidget.dart';
import 'package:grouplist/routes/pageRoute.dart';
import 'package:grouplist/widget/newUserInitiation.dart';

///Declare variables that the databases use for users and groups
final auth = FirebaseAuth.instance;
final uuid = FirebaseAuth.instance.currentUser!.uid;
CollectionReference users = FirebaseFirestore.instance.collection('users');
CollectionReference groups = FirebaseFirestore.instance.collection('groups');

///BuildInfo class standardizes the information and structure used between pages
class BuildInfo {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final String? title;
  final List<DocumentReference>? groups;
  final List<DocumentReference>? lists;
  final List<DocumentReference>? contacts;
  final String? pageRoute;
  final bool all;
  final DocumentReference? list;
  final Map<String, dynamic>? item;

  BuildInfo(
      {this.title,
      this.scaffoldKey,
      this.groups,
      this.contacts,
      this.lists,
      this.pageRoute,
      this.all = true,
      this.list,
      this.item});
}

///RecordUser class for user data that is placed in the database
class RecordUser {
  final String? displayName;
  final DocumentReference? reference;
  final List? groups;
  final String? documentID;
  final String? email;
  final List? groupAdminOf;

  RecordUser.fromMap(Map<String, dynamic> map, {this.reference})
      : displayName = map['displayname'],
        documentID = map['documentID'],
        groupAdminOf = map['groupAdminOf'],
        groups = map['groups'],
        email = map['email'];

  RecordUser.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data() as Map<String, dynamic>,
            reference: snapshot.reference);
}

///RecordGroup class for data on the groups that is placed in the database
class RecordGroup {
  final String displayName;
  final DocumentReference reference;
  final List<DocumentReference> users;
  final DocumentReference? groupAdmin;
  final bool? private;
  final CollectionReference parentReference;

  RecordGroup.fromMap(Map<String, dynamic> map, {required this.reference})
      : users = List.from(map['users']).cast<DocumentReference>(),
        displayName = map['displayname'] ?? "",
        parentReference = reference.parent,
        private = map['private'],
        groupAdmin = map['groupAdmin'];

  RecordGroup.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data() as Map<String, dynamic>,
            reference: snapshot.reference);
}

///HomePage directs to the
class HomePage extends StatefulWidget {
  static const String routeName = '/homePage';
  final BuildInfo? state;

  HomePage({Key? key, this.state}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic>? userGroups;

  User? user = auth.currentUser;

  @override
  void initState() {
    super.initState();
    auth.userChanges().listen((firebaseUser) async {
      // do whatever you want based on the firebaseUser state
      if (firebaseUser == null) {
        await FirebaseAuth?.instance.signOut();
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => WelcomePage()));
      }
    });
  }

  GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  Widget build(BuildContext context) {
    scaffoldKey = new GlobalKey<ScaffoldState>();

    newUserInitiation(user: user);

    return Scaffold(
      key: scaffoldKey,
      drawer: AppDrawer(),
      body: _buildState(context),
    );
  }

  Widget _buildState(BuildContext context) {
    return Builder(builder: (BuildContext context) {
      if (widget.state != null) {
        if (widget.state?.pageRoute == PageRoutes?.lists) {
          return ListsPage(
              state: BuildInfo(
                  scaffoldKey: scaffoldKey,
                  lists: widget.state?.lists,
                  groups: widget.state?.groups,
                  contacts: widget.state?.contacts));
        } else if (widget.state?.pageRoute == PageRoutes.contacts) {
          return ContactsPage(
              state: BuildInfo(
                  scaffoldKey: scaffoldKey,
                  lists: widget.state?.lists,
                  groups: widget.state?.groups,
                  contacts: widget.state?.contacts));
        }
      }
      return GroupsPage(
          state: BuildInfo(
        scaffoldKey: scaffoldKey,
      ));
    });
  }
}

Widget addGroup(BuildContext context, GlobalKey<FormState> _formKey,
    CollectionReference groups, String uid) {
  final controller = TextEditingController();

  return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('Group Name:'),
            TextFormField(
              autofocus: true,
              controller: controller,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a name for your new group';
                }
                return null;
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: ElevatedButton(
                onPressed: () async {
                  // Validate returns true if the form is valid, or false
                  // otherwise.
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, display a Snackbar.
                    DocumentReference docRef = groups.doc();
                    await docRef.set({
                      "displayname": controller.text,
                      "groupAdmin": users.doc(uid),
                      "private": false,
                      "users": [users.doc(uid)]
                    });
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid.toString())
                        .update({
                      "groups": FieldValue.arrayUnion([docRef]),
                      "groupAdminOf": FieldValue.arrayUnion([docRef])
                    });
                    controller.clear();
                    Navigator.pop(context); //close the popup

                  }
                },
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ));
}

Widget addList(BuildContext context, GlobalKey<FormState> _formKey,
    DocumentReference group) {
  final controller = TextEditingController();

  return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('List Name:'),
            TextFormField(
              autofocus: true,
              controller: controller,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a name for your new List';
                }
                return null;
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: ElevatedButton(
                onPressed: () async {
                  // Validate returns true if the form is valid, or false
                  // otherwise.
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, display a Snackbar.

                    DocumentReference docRef = group.collection('lists').doc();

                    await docRef.set(
                        {"displayname": controller.text, "archived": false});

                    controller.clear();
                    Navigator.pop(context); //close the popup

                  }
                },
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ));
}

Widget addListItem(BuildContext context, GlobalKey<FormState> _formKey,
    DocumentReference list) {
  final _itemName = TextEditingController();
  final _comment = TextEditingController();
  final _commentKey = GlobalKey<FormFieldState>();
  final _itemKey = GlobalKey<FormFieldState>();

  CollectionReference colRef = list.collection('listItems');

  return Form(
    key: _formKey,
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: ListView(
        children: <Widget>[
          Text("Name:"),
          TextFormField(
            autofocus: true,
            key: _itemKey,
            controller: _itemName,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter a name for your item';
              }
              return null;
            },
          ),
          SizedBox(height: 8.0),
          Text("Comment:"),
          TextFormField(
            key: _commentKey,
            controller: _comment,
            validator: (value) {
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: ElevatedButton(
              onPressed: () async {
                // Validate returns true if the form is valid, or false
                // otherwise.
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a Snackbar.

                  Map<String, dynamic> enterData = {
                    "iteminfo": {
                      "name": _itemName.text,
                      "comments": _comment.text,
                      "done": false,
                      "additionalDetails": {
                        "cents": null,
                        "quantity": null,
                        "urgent": false
                      }
                    },
                    "archived": false
                  };

                  colRef
                      .add(enterData)
                      .then((value) => print("Item Added"))
                      .catchError((error) => print(error.toString()));

                  _itemName.clear();
                  _comment.clear();
                  Navigator.pop(context); //close the popup

                }
              },
              child: Text('Submit'),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget getUserName(BuildContext context, GlobalKey<FormState> _formKey,
    DocumentReference user) {
  final controller = TextEditingController();
  return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: controller,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a display name that will be visible in your shared lists';
                }
                return null;
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: ElevatedButton(
                onPressed: () {
                  // Validate returns true if the form is valid, or false
                  // otherwise.
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, display a Snackbar.
                    user.update({"displayname": controller.text}).then(
                        (value) => {
                              () {
                                controller.dispose();
                                try {
                                  Navigator.pop(context); //close the popup
                                } catch (e) {
                                  print(e);
                                }
                              }
                            });
                  }
                },
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ));
}
