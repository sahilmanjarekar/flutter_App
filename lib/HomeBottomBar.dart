import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:final_project/allspotpages.dart';
import 'package:final_project/bottombar/location.dart';
import 'package:final_project/page.dart';

class HomeBottomBar extends StatelessWidget {
  final String userEmail;
  final String displayName;

  const HomeBottomBar({
    Key? key,
    required this.userEmail,
    required this.displayName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 0, 0, 0),
      child: SalomonBottomBar(
        currentIndex: 1,
        onTap: (int index) {
          if (index == 2) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => Location()));
          } else if (index == 1) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => AllSpotsPage()));
          } else if (index == 0) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => bus()));
          }
        },
        items: [
          SalomonBottomBarItem(
            icon: Icon(
              Icons.car_rental,
              color: Colors.cyan,
              size: 30,
            ),
            title: Text(
              'Bus',
              style: TextStyle(color: Colors.cyan),
            ),
            selectedColor: Colors.cyan,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.home_filled),
            title: Text(
              'Home',
              style: TextStyle(color: Colors.cyan),
            ),
            selectedColor: Color.fromARGB(255, 5, 184, 255),
          ),
          SalomonBottomBarItem(
            icon: Icon(
              Icons.location_on_outlined,
              color: Colors.cyan,
              size: 30,
            ),
            title: Text(
              'Location',
              style: TextStyle(color: Colors.cyan),
            ),
            selectedColor: Colors.cyan,
          ),
        ],
      ),
    );
  }
}
