import 'package:flutter/material.dart';
import 'package:grouplist/Pages/mainPage.dart';

///DisplayItem shows the specific item in a list, with full details
class DisplayItem extends StatefulWidget {
  final BuildInfo? state;

  DisplayItem({this.state});

  @override
  _DisplayItemState createState() => _DisplayItemState();
}

class _DisplayItemState extends State<DisplayItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: ListView());
  }
}
