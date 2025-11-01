import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LogsView extends StatelessWidget {
  const LogsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'LogsView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
