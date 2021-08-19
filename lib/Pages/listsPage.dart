import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grouplist/Pages/displayList.dart';
import 'package:grouplist/Pages/mainPage.dart';
import 'package:grouplist/main.dart';
import 'package:grouplist/widget/popUpContainer.dart';

///ListsPage structures a page that shows the lists the user has
class ListsPage extends StatefulWidget {
  static const String routeName = '/listsPage';
  final String thisRoute = routeName.toString();
  final String pageTitle = 'Lists';
  final BuildInfo? state;

  ListsPage({Key? key, this.state}) : super(key: key);

  @override
  _ListsPageState createState() => _ListsPageState();
}

List<DocumentSnapshot> listToBuild = [];

class _ListsPageState extends State<ListsPage> with TickerProviderStateMixin {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference groups = FirebaseFirestore.instance.collection('groups');
  Stream<QuerySnapshot>? groupSnapshots;
  Stream? listSnapshots;
  late AnimationController _animationController;
  static const List<IconData> fabIcons = const [
    Icons.playlist_add,
    Icons.person_add
  ];

  User? user = FirebaseAuth.instance.currentUser;
  DocumentReference userRef = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid);

//TODO: Add person button needs to add name to group and then send request to that person to see if they accept.
  @override
  void initState() {
    super.initState();
    listSnapshots = groups
        .doc(widget.state!.groups!.single.id)
        .collection('lists')
        .snapshots();

    _animationController = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    groupSnapshots = groups.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    setCurrentPageState(this.widget.thisRoute);
    GlobalKey<ScaffoldState>? _scaffoldKey = widget.state!.scaffoldKey;
    return Scaffold(
        appBar: AppBar(
          leading: Builder(builder: (BuildContext context) {
            if (!widget.state!.all) {
              return IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context);
                },
              );
            } else {
              return IconButton(
                onPressed: () {
                  _scaffoldKey!.currentState!.openDrawer();
                },
                icon: Icon(Icons.menu),
              );
            }
          }),
          title: Text(widget.pageTitle),
        ),
        body: _buildBody(context),
        floatingActionButton: fabMenu(fabIcons, _animationController));
  }

  List<DocumentSnapshot> groupSnap = [];

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: groupSnapshots,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            LinearProgressIndicator();
          }
          if (!snapshot.hasData) {
            LinearProgressIndicator();
          }
          return StreamBuilder<QuerySnapshot>(
            stream: listSnapshots as Stream<QuerySnapshot>?,
            builder: (BuildContext context, asyncsnapshot) {
              if (asyncsnapshot.hasError) {
                return LinearProgressIndicator();
              }
              switch (asyncsnapshot.connectionState) {
                case ConnectionState.none:
                  return LinearProgressIndicator();
                case ConnectionState.waiting:
                  return LinearProgressIndicator();
                case ConnectionState.active:
                  {
                    if (!asyncsnapshot.hasData)
                      return LinearProgressIndicator();
                    listToBuild = asyncsnapshot.requireData.docs;

                    return _buildList(context, listToBuild);
                  }

                case ConnectionState.done:
                  return LinearProgressIndicator();
              }
            },
          );
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
    final record = RecordList.fromSnapshot(data);
    return Padding(
        key: ValueKey(data.id),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Container(
            // height: 80,
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
              title: Text(record.displayName!),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute<String>(
                    builder: (context) => DisplayList(
                          state: BuildInfo(
                              title: record.displayName, list: data.reference),
                        )));
              },
            )));
  }

  Widget fabMenu(List<IconData> icons, AnimationController _controller) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 70.0,
          width: 60.0,
          alignment: FractionalOffset.topCenter,
          child: new ScaleTransition(
            scale: new CurvedAnimation(
              parent: _controller,
              curve: new Interval(0.0, 1.0 / icons.length / 2.0,
                  curve: Curves.easeOut),
            ),
            child: new FloatingActionButton(
              heroTag: null,
              mini: true,
              child: new Icon(Icons.person_add),
              onPressed: () {
                showPopup(
                    context,
                    addList(context, GlobalKey<FormState>(),
                        widget.state!.groups!.first),
                    "New People");
              },
            ),
          ),
        ),
        Container(
          height: 70.0,
          width: 60.0,
          alignment: FractionalOffset.topCenter,
          child: new ScaleTransition(
            scale: new CurvedAnimation(
              parent: _controller,
              curve: new Interval(0.0, 1.0 / icons.length / 2.0,
                  curve: Curves.easeOut),
            ),
            child: new FloatingActionButton(
              heroTag: null,
              mini: true,
              child: new Icon(Icons.playlist_add),
              onPressed: () {
                showPopup(
                    context,
                    addList(context, GlobalKey<FormState>(),
                        widget.state!.groups!.first),
                    "New List");
              },
            ),
          ),
        )
      ]..add(
          new FloatingActionButton(
            heroTag: null,
            child: new AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget? child) {
                return new Transform(
                  transform: new Matrix4.rotationZ(_controller.value * .5 * pi),
                  alignment: FractionalOffset.center,
                  child: new Icon(
                      _controller.isDismissed ? Icons.add : Icons.close),
                );
              },
            ),
            onPressed: () {
              if (_controller.isDismissed) {
                _controller.forward();
              } else {
                _controller.reverse();
              }
            },
          ),
        ),
    );
  }
}

class RecordList {
  final String? displayName;
  final DocumentReference reference;
  final Stream<QuerySnapshot> items;

  RecordList.fromMap(Map<String, dynamic> map, {required this.reference})
      : displayName = map['displayname'],
        items = reference.collection('listItems').snapshots();

  RecordList.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data() as Map<String, dynamic>,
            reference: snapshot.reference);
}
