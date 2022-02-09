import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'drawer.dart';

class CustomScaffold extends StatelessWidget {

  final Widget body;
  final Widget appBar;
  final bool resizeToAvoidBottomInset;

  CustomScaffold({this.body, this.appBar, this.resizeToAvoidBottomInset});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      drawer: CustomDrawer(),
    );
  }
}