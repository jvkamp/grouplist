import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grouplist/Pages/mainPage.dart';
import 'package:grouplist/widget/popUpContainer.dart';

///DisplayList shows the items in a list when it is opened
class DisplayList extends StatefulWidget {
  final BuildInfo? state;

  DisplayList({this.state});

  @override
  _DisplayListState createState() => _DisplayListState();
}

class _DisplayListState extends State<DisplayList> {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference groups = FirebaseFirestore.instance.collection('groups');
  Stream<QuerySnapshot>? listItems;

  @override
  void initState() {
    super.initState();

    listItems = widget.state!.list!.collection('listItems').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.state!.title!)),
        body: _buildBody(context),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showPopup(
                context,
                addListItem(
                    context, GlobalKey<FormState>(), widget.state!.list!),
                "New Entry");
          },
          tooltip: 'Create New List',
          child: Icon(Icons.add),
        ));
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: listItems,
        builder: (BuildContext context, items) {
          if (!items.hasData) return LinearProgressIndicator();
          List<DocumentSnapshot> listToBuild = items.data!.docs;

          if (listToBuild.isEmpty) return LinearProgressIndicator();
          return _buildList(context, listToBuild);
        });
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> listItems) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: listItems
          .map((data) => _buildListItem(context, data))
          .toList(growable: true),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final itemRef = RecordListItems.fromSnapshot(data).reference;
    final Map<String, dynamic> info =
        RecordListItems.fromSnapshot(data).iteminfo!;
    final String comments = RecordListItems.fromSnapshot(data).comments ?? "";
    final String name = RecordListItems.fromSnapshot(data).name ?? "";

    bool? check = info['done'];

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
              leading: Checkbox(
                  value: check,
                  onChanged: (bool? newValue) {
                    setState(() {
                      itemRef!.set(
                          {
                            "iteminfo": {"done": newValue}
                          },
                          SetOptions(
                            merge: true,
                          )).whenComplete(() => check = newValue);
                    });
                  }),
              title: Text(name),
              subtitle: Text(comments.toString().trim()),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute<String>(
                    builder: (context) => DisplayList(
                          state: BuildInfo(title: name, item: info),
                        )));
              },
            )));
  }
}

class RecordListItems {
  final DocumentReference? reference;
  final Map<String, dynamic>? additionalDetails;
  @required
  final String? name;
  final String? comments;
  final Map<String, dynamic>? iteminfo;

  RecordListItems.fromMap(Map<String, dynamic> map, {this.reference})
      : name = map['iteminfo']['name'],
        additionalDetails = map['iteminfo']['additionalDetails'],
        iteminfo = map['iteminfo'],
        comments = map['iteminfo']['comments'];

  RecordListItems.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data() as Map<String, dynamic>,
            reference: snapshot.reference);
}

/*

cost = map['iteminfo']['additionalDetail']['cost'] ?? null,
urgent = map['iteminfo']['additionalDetail']['urgent'] ?? null,
comments = map['iteminfo']['comments'] ?? '',
done = map['iteminfo']['done'] ?? null,
quantity = map['iteminfo']['quantity'] ?? null,
additionalDetails = map['iteminfo']['additionalDetails'],*/
