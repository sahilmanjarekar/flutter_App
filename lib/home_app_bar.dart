import 'package:flutter/material.dart';

class HomeAppBar extends StatefulWidget {
  const HomeAppBar({Key? key}) : super(key: key);

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  double getResponsiveFontSize(double baseFontSize, double screenWidth) {
    return baseFontSize * screenWidth / 375.0;
  }

  double getResponsivePadding(double basePadding, double screenWidth) {
    return basePadding * screenWidth / 375.0;
  }

  double getResponsiveIconSize(double baseIconSize, double screenWidth) {
    return baseIconSize * screenWidth / 375.0;
  }

  double getAppBarHeight(double screenHeight) {
    return screenHeight < 600 ? 56 : 80; // Example sizes
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return AppBar(
      automaticallyImplyLeading: false, // No back button
      title: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: getResponsivePadding(16, screenWidth)),
          child: Row(
            children: [
              // Logo or any widget you want on the left side
              Image.asset(
                "image/download__1_-removebg-preview (1).png",
                height: getResponsiveIconSize(55, screenWidth),
              ),
              SizedBox(
                  width: getResponsivePadding(
                      8, screenWidth)), // Space between logo and text
              // App Name or title
              Center(
                child: Text(
                  "Sindhudurg Tour",
                  // textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: getResponsiveFontSize(20, screenWidth),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Zen Dots',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      centerTitle: true,
    );
  }
}

// import 'package:flutter/material.dart';

// class HomeAppBar extends StatefulWidget {
//   const HomeAppBar({Key? key}) : super(key: key);

//   @override
//   State<HomeAppBar> createState() => _HomeAppBarState();
// }

// class _HomeAppBarState extends State<HomeAppBar>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController =
//         TabController(length: 3, vsync: this); // Initialize TabController
//   }

//   @override
//   void dispose() {
//     _tabController.dispose(); // Dispose TabController
//     super.dispose();
//   }

//   double getResponsiveFontSize(double baseFontSize, double screenWidth) {
//     return baseFontSize * screenWidth / 375.0;
//   }

//   double getResponsivePadding(double basePadding, double screenWidth) {
//     return basePadding * screenWidth / 375.0;
//   }

//   double getResponsiveIconSize(double baseIconSize, double screenWidth) {
//     return baseIconSize * screenWidth / 375.0;
//   }

//   double getAppBarHeight(double screenHeight) {
//     return screenHeight < 600 ? 56 : 80; // Example sizes
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;

//     return AppBar(
//       automaticallyImplyLeading: false, // No back button
//       title: SafeArea(
//         child: Container(
//           padding: EdgeInsets.symmetric(
//             horizontal: getResponsivePadding(16, screenWidth),
//           ),
//           height: getAppBarHeight(screenHeight),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.asset(
//                 "assets/logo.png", // Ensure you have this asset
//                 height: getResponsiveIconSize(55, screenWidth),
//               ),
//               SizedBox(width: getResponsivePadding(8, screenWidth)),
//               Text(
//                 "Sindhudurg Tour",
//                 style: TextStyle(
//                   fontSize: getResponsiveFontSize(20, screenWidth),
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'Zen Dots',
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       centerTitle: true,
//       bottom: TabBar(
//         controller: _tabController,
//         tabs: [
//           Tab(icon: Icon(Icons.place), text: 'Places'),
//           Tab(icon: Icon(Icons.directions_car), text: 'Vehicles'),
//           Tab(icon: Icon(Icons.hotel), text: 'Hotels'),
//         ],
//       ),
//     );
//   }
// }

// // Usage Example, wrapping HomeAppBar with DefaultTabController
// class HomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//         appBar: PreferredSize(
//           preferredSize: Size.fromHeight(
//               kToolbarHeight + 50), // Adjust the height as needed
//           child: HomeAppBar(),
//         ),
//         body: TabBarView(
//           children: [
//             Center(child: Text('Place Content')),
//             Center(child: Text('Vehicle Content')),
//             Center(child: Text('Hotel Content')),
//           ],
//         ),
//       ),
//     );
//   }
// }
