import 'package:flutter/material.dart';
import 'package:jana_soz/theme/pallete.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: Pallete.darkModeAppTheme,
      home: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Image.asset('assets/images/sammy-line-team-marketing.png'),
        ),
      ),
    );
  }
}
