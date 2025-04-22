import 'package:final_project/login/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCfrDIApRypUs5zDbmSCVwrgH6f7qvZZwQ",
          appId: "1:21092514136:android:ab60f138ae3ef0d063cd2d",
          messagingSenderId: "21092514136",
          projectId: "last-7892e"));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Finder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
