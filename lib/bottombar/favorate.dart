import 'package:flutter/material.dart';

class FavoratePage extends StatelessWidget {
  const FavoratePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("image/i.jpg"), fit: BoxFit.cover)),
        // decoration: BoxDecoration(image: AssetImage("image/i.jpg")),
      ),
    );
  }
}
