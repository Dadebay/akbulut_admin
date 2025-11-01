import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExpencesView extends StatelessWidget {
  const ExpencesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'ExpencesView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
