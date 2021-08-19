import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:grouplist/Widget/signOut.dart';

class AppDrawer extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _createHeader(),
          _createDrawerItem(
            context,
            icon: Icons.collections_bookmark_sharp,
            text: 'Groups',
          ),
          _createDrawerItem(
            context,
            icon: Icons.list_alt_sharp,
            text: 'Lists',
          ),
          _createDrawerItem(
            context,
            icon: Icons.contacts_sharp,
            text: 'Contacts',
          ),
          Divider(),
          _createDrawerItem(context, icon: Icons.settings, text: 'Settings'),
          Divider(),
          _createDrawerItem(context, icon: Icons.logout, text: 'Sign Out',
              onTap: () async {
            await signOut(context);
          }),
        ],
      ),
    );
  }

  Widget _createHeader() {
    return DrawerHeader(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(color: Color(0xFF7798d3)),
        child: Stack(children: <Widget>[
          Positioned(
            top: 12.0,
            left: 30.0,
            child: ClipOval(
                child: Image.network(FirebaseAuth.instance.currentUser!.photoURL!,
                    cacheHeight: 50, cacheWidth: 50)),
          ),
          Positioned(
              bottom: 42.0,
              left: 30.0,
              child: Text(user!.displayName!,
                  style:
                      TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600))),
          Positioned(
              bottom: 12.0,
              left: 30.0,
              child: Text(user!.email!,
                  style:
                      TextStyle(fontSize: 15.0, fontWeight: FontWeight.w100))),
        ]));
  }

  Widget _createDrawerItem(BuildContext context,
      {IconData? icon, required String text, GestureTapCallback? onTap}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon),
          Padding(
            padding: EdgeInsets.only(left: 32.0),
            child: Text(
              text,
              style: TextStyle(fontSize: 20.0),
            ),
          )
        ],
      ),
      onTap: onTap ??
          () {
            Navigator.pop(context);
          },
    );
  }
}
