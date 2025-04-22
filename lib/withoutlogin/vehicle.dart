import 'package:final_project/withoutlogin/bus.dart';
import 'package:final_project/withoutlogin/car.dart';
import 'package:flutter/material.dart';

class vehicle extends StatelessWidget {
  const vehicle({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Home Page",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 21, 9, 0),
      ),
      body: Center(
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          padding: EdgeInsets.all(20),
          children: <Widget>[
            _buildIconContainer(
              context,
              Icons.directions_bus,
              Color.fromARGB(255, 237, 11, 11),
              "Busses Page",
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => bp()),
              ),
            ),
            _buildIconContainer(
              context,
              Icons.directions_car,
              Colors.blue,
              "Car Page",
              () => Navigator.push(
                // Updated onTap callback for car icon
                context,
                MaterialPageRoute(
                    builder: (context) => cp()), // Navigation to CarsPage
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconContainer(BuildContext context, IconData icon, Color color,
      String tooltip, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 50,
            color: color,
          ),
        ),
      ),
    );
  }
}
