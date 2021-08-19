import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grouplist/Pages/listsPage.dart';
import 'package:grouplist/Pages/mainPage.dart';
import 'package:grouplist/Widget/popUpContainer.dart';
import 'package:grouplist/main.dart';
import 'package:grouplist/widget/newUserInitiation.dart';

///GroupsPage structures a page that shows the groups that the user is part of
class GroupsPage extends StatefulWidget {
  static const String routeName = '/groupsPage';
  final String thisRoute = routeName.toString();
  final String pageTitle = 'Groups';
  final BuildInfo? state;

  GroupsPage({Key? key, this.state}) : super(key: key);

  @override
  _GroupsPageState createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  RecordGroup? record;
  Map? userData;
  List<DocumentReference>? userGroups = [];
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference groups = FirebaseFirestore.instance.collection('groups');
  Stream<DocumentSnapshot>? userSnapshots;
  Stream<QuerySnapshot>? groupsSnapshots;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    userSnapshots = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();

    groupsSnapshots = groups.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    setCurrentPageState(this.widget.thisRoute);
    GlobalKey<ScaffoldState>? _scaffoldKey = widget.state!.scaffoldKey;
    return Scaffold(
      appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              _scaffoldKey!.currentState!.openDrawer();
            },
            child: Icon(Icons.menu),
          ),
          title: Text(widget.pageTitle)),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        //Change so clicking plus will ask new group, contact, or list in bottom drawer, will add new widget page for "addItemDrawer"
        onPressed: () {
          showPopup(
              context,
              addGroup(context, GlobalKey<FormState>(), groups, user!.uid),
              "New Group");
        },
        tooltip: 'Create New Group',
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: userSnapshots,
        builder: (context, userAsyncSnapshot) {
          if (!userAsyncSnapshot.hasData) return LinearProgressIndicator();

          DocumentSnapshot userSnapshot = userAsyncSnapshot.requireData;

          if (userSnapshot.data() == null) {
            newUserInitiation();
          }

          userData = userSnapshot.data() as Map<dynamic, dynamic>;

          if (widget.state!.groups != null &&
              widget.state!.groups!.isNotEmpty) {
            userGroups = widget.state!.groups;
          } else {
            userGroups =
                List.from((userSnapshot.data() as DocumentSnapshot)['groups']);
          }

          while (userGroups!.isEmpty) return LinearProgressIndicator();

          return StreamBuilder<QuerySnapshot>(
              stream: groupsSnapshots,
              builder: (context, groupsSnapshot) {
                if (!groupsSnapshot.hasData) {
                  return LinearProgressIndicator();
                }
                List<DocumentSnapshot> listToBuild = [];

                groupsSnapshot.requireData.docs.forEach((group) {
                  if (userGroups!.any((groups) => groups == group.reference)) {
                    listToBuild.add(group);
                  }
                });
                if (listToBuild.isEmpty) {
                  return Padding(
                      key: ValueKey('empty'),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 20.0),
                      child: Container(
                          // height: 80,
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ListTile(
                            title: Text("Add a new group!"),
                            trailing: Icon(Icons.add),
                            onTap: () {
                              showPopup(
                                  context,
                                  addGroup(context, GlobalKey<FormState>(),
                                      groups, user!.uid),
                                  "New Group");
                            },
                          )));
                }
                return _buildList(context, listToBuild);
              });
        });
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> usersGroups) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: usersGroups
          .map((data) => _buildListItem(context, data))
          .toList(growable: true),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = RecordGroup.fromSnapshot(data);
    return Padding(
        key: ValueKey(data.id),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Container(
            //height: 80,
            decoration: BoxDecoration(
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Theme.of(context).shadowColor,
                    offset: Offset(2, 2),
                    blurRadius: 2)
              ],
              color: Theme.of(context).cardColor,
              border: Border.all(),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              title: Text(record.displayName.toString()),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () async {
                await _openLists(data);
              },
            )));
  }

  Future<Object?> _openLists(DocumentSnapshot data) async {
    final record = RecordGroup.fromSnapshot(data);
    return Navigator.of(context).push(MaterialPageRoute<String>(
        builder: (context) => ListsPage(
              state: BuildInfo(
                  pageRoute: "/listsPage",
                  groups: [record.reference],
                  scaffoldKey: widget.state!.scaffoldKey,
                  all: false),
            )));
  }
}
