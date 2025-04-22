import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(), // Add an AppBar if needed
      body: Center(
        child: Image.network(
          imageUrl,
          // Set fit to cover the entire screen
          fit: BoxFit.cover,
          // Add other image properties as needed
        ),
      ),
    );
  }
}
