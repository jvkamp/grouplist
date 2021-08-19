import 'package:flutter/material.dart';
import 'package:grouplist/Pages/mainPage.dart';

///ContactsPage shows any contacts/friends the user may have saved
class ContactsPage extends StatefulWidget {
  static const String routeName = '/contactsPage';
  final BuildInfo? state;

  ContactsPage({this.state});

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
