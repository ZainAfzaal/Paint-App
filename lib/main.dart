import 'package:flutter/material.dart';
import 'paint_home_page.dart';

void main() {
  runApp(PaintApp());
}

class PaintApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ' Paint App',
      debugShowCheckedModeBanner: false,
      home: PaintHomePage(),
    );
  }
}
