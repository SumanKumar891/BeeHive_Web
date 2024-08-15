import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:syngenta/homepage.dart';
import 'package:syngenta/startpage.dart';
import 'package:syngenta/weather.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: StartPage(
            //email: 'milanpreetkaur502@gmail.com',
            ));
  }
}
