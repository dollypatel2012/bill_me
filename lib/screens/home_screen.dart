import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Welcome to Billing App\nTap + to create a new bill',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18)),
    );
  }
}