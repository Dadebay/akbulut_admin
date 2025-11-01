import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PurchasesView extends StatelessWidget {
  const PurchasesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'PurchasesView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
