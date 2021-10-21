import 'package:flutter/material.dart';
import 'package:teachers/components/custom_app_bar.dart';

class DemoDataTablePage extends StatefulWidget {
  @override
  _DemoDataTablePageState createState() => _DemoDataTablePageState();
}

class _DemoDataTablePageState extends State<DemoDataTablePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomAppBar(
          title: 'Data Table',
          subtitle: 'Let\'s check Data Table functionality',
        ),
        elevation: 0,
      ),
      body: Container(

      ),
    );
  }
}
