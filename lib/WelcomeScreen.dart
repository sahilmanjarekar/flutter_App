import 'package:final_project/allspotpages.dart';
import 'package:final_project/login/login.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  final UserDetail userDetail;

  WelcomeScreen(this.userDetail);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("image/nattu-adnan-Ai2TRdvI6gM-unsplash.jpg"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.7),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 65, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome ${userDetail.displayName ?? userDetail.email}",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 30,
                    fontFamily: 'Zen Dots',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "To Sindhudurg",
                  style: TextStyle(
                    fontFamily: 'Zen Dots',
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w100,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Sindhudurg district is spread over an area of around 5,207 sq. kms. The population of the District is 8,68,825 as per census of 2001. The modern township of Sindhudurg Nagari is the headquarters of Sindhudurg district.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    letterSpacing: 1.3,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllSpotsPage(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Explore All Spots',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color.fromARGB(255, 8, 0, 0),
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
