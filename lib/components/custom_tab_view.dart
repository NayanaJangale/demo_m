import 'package:flutter/material.dart';

class CustomTabBarView extends StatefulWidget {
  final List<Widget> wigetList;
  CustomTabBarView(this.wigetList);

  @override
  _CustomTabBarViewState createState() => _CustomTabBarViewState();
}

class _CustomTabBarViewState extends State<CustomTabBarView> {
  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: widget.wigetList,
    );
  }
}
