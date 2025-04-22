import 'package:flutter/material.dart';

class LogoTabBarPage extends StatefulWidget {
  @override
  _LogoTabBarPageState createState() => _LogoTabBarPageState();
}

class _LogoTabBarPageState extends State<LogoTabBarPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logo Tabs'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Image.asset('assets/place_logo.png', fit: BoxFit.cover)),
            Tab(
                icon:
                    Image.asset('assets/vehicle_logo.png', fit: BoxFit.cover)),
            Tab(icon: Image.asset('assets/hotel_logo.png', fit: BoxFit.cover)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(child: Text('Place Content')),
          Center(child: Text('Vehicle Content')),
          Center(child: Text('Hotel Content')),
        ],
      ),
    );
  }
}
